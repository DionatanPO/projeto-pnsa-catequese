import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'desktop_auth_helper.dart'
    if (dart.library.html) 'desktop_auth_helper_stub.dart';
import 'drive_config.dart';

class GoogleDriveService {
  static const String _clientIdStr = DriveConfig.clientId;
  static const String _driveCredsKey = DriveConfig.credsStorageKey;
  static const List<String> _scopes = DriveConfig.scopes;

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _webAccount;

  auth.AutoRefreshingAuthClient? _desktopClient;
  http.Client? _desktopBaseClient;

  drive.DriveApi? _driveApi;
  String? _email;

  bool get isReady => _driveApi != null;
  String? get emailLogado => _email;

  Future<bool> tryAutoSignIn() async {
    if (kIsWeb) {
      return _tryAutoSignInWeb();
    }
    return _tryAutoSignInDesktop();
  }

  Future<void> signIn() async {
    if (kIsWeb) {
      await _signInWeb();
    } else {
      await _signInDesktop();
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) {
      await _signOutWeb();
    } else {
      await _signOutDesktop();
    }
  }

  Future<bool> _tryAutoSignInWeb() async {
    try {
      _webAccount = await _getGoogleSignIn().signInSilently();
      if (_webAccount != null) {
        final ok = await _getGoogleSignIn().requestScopes(_scopes);
        if (!ok) return false;
        _driveApi = drive.DriveApi(_GoogleAuthClient(_webAccount!));
        _email = _webAccount!.email;
        return true;
      }
    } catch (e) {
      debugPrint('[Drive] Web auto sign-in falhou: $e');
    }
    return false;
  }

  Future<void> _signInWeb() async {
    _webAccount = await _getGoogleSignIn().signIn();
    if (_webAccount == null) throw Exception('Login do Google cancelado');
    _driveApi = drive.DriveApi(_GoogleAuthClient(_webAccount!));
    _email = _webAccount!.email;
  }

  Future<void> _signOutWeb() async {
    await _getGoogleSignIn().signOut();
    _webAccount = null;
    _driveApi = null;
    _email = null;
  }

  GoogleSignIn _getGoogleSignIn() {
    _googleSignIn ??= GoogleSignIn(
      clientId: _clientIdStr,
      scopes: _scopes,
    );
    return _googleSignIn!;
  }

  Future<bool> _tryAutoSignInDesktop() async {
    try {
      const storage = FlutterSecureStorage();
      final saved = await storage.read(key: _driveCredsKey);
      if (saved == null) return false;

      final creds = auth.AccessCredentials.fromJson(
        jsonDecode(saved) as Map<String, dynamic>,
      );
      final clientId = auth.ClientId(_clientIdStr);
      _desktopBaseClient = http.Client();

      auth.AccessCredentials freshCreds;
      if (creds.accessToken.hasExpired) {
        try {
          freshCreds = await auth.refreshCredentials(
            clientId,
            creds,
            _desktopBaseClient!,
          );
          await storage.write(
            key: _driveCredsKey,
            value: jsonEncode(freshCreds.toJson()),
          );
        } catch (_) {
          _desktopBaseClient?.close();
          _desktopBaseClient = null;
          await storage.delete(key: _driveCredsKey);
          return false;
        }
      } else {
        freshCreds = creds;
      }

      _desktopClient = auth.autoRefreshingClient(
        clientId,
        freshCreds,
        _desktopBaseClient!,
      );
      _driveApi = drive.DriveApi(_desktopClient!);
      _email = _extractEmail(freshCreds);
      return true;
    } catch (e) {
      debugPrint('[Drive] Desktop auto sign-in falhou: $e');
      _desktopBaseClient?.close();
      _desktopBaseClient = null;
      _desktopClient = null;
      const storage = FlutterSecureStorage();
      await storage.delete(key: _driveCredsKey);
      return false;
    }
  }

  Future<void> _signInDesktop() async {
    final clientId = auth.ClientId(_clientIdStr);

    _desktopClient = await doClientViaUserConsent(clientId, _scopes);

    const storage = FlutterSecureStorage();
    await storage.write(
      key: _driveCredsKey,
      value: jsonEncode(_desktopClient!.credentials.toJson()),
    );

    _driveApi = drive.DriveApi(_desktopClient!);
    _email = _extractEmail(_desktopClient!.credentials);
  }

  Future<void> _signOutDesktop() async {
    _desktopClient?.close();
    _desktopBaseClient?.close();
    _desktopClient = null;
    _desktopBaseClient = null;
    _driveApi = null;
    _email = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: _driveCredsKey);
  }

  String _extractEmail(auth.AccessCredentials creds) {
    if (creds.idToken != null) {
      try {
        final parts = creds.idToken!.split('.');
        if (parts.length >= 2) {
          final normalized = base64Url.normalize(parts[1]);
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(normalized)),
          ) as Map<String, dynamic>;
          return payload['email'] as String? ??
              payload['sub'] as String? ??
              'Conta Google';
        }
      } catch (_) {}
    }
    return 'Conta Google';
  }

  Future<String> createFolder(String nomePasta, {String? parentFolderId}) async {
    if (_driveApi == null) throw Exception('Google Drive não conectado');

    final folder = drive.File()
      ..name = nomePasta
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = parentFolderId != null ? [parentFolderId] : null;

    final created = await _driveApi!.files.create(
      folder,
      $fields: 'id, name',
    );

    return created.id!;
  }

  Future<DocumentoDrive> uploadFile({
    required Uint8List bytes,
    required String nome,
    String? mimeType,
    String? parentFolderId,
  }) async {
    if (_driveApi == null) throw Exception('Google Drive não conectado');

    mimeType ??= _inferMimeType(nome);
    final tamanho = bytes.length;
    debugPrint(
      '[Drive] uploadFile: nome=$nome, mimeType=$mimeType, tamanho=$tamanho, parentFolderId=$parentFolderId',
    );

    final media = drive.Media(Stream.value(bytes), tamanho);
    final driveFile = drive.File()
      ..name = nome
      ..mimeType = mimeType
      ..parents = parentFolderId != null ? [parentFolderId] : null;

    final uploaded = await _driveApi!.files.create(
      driveFile,
      uploadMedia: media,
      $fields: 'id, name, mimeType, size, webViewLink, webContentLink',
    );

    return DocumentoDrive(
      driveFileId: uploaded.id!,
      nome: uploaded.name ?? nome,
      mimeType: uploaded.mimeType ?? mimeType,
      tamanho: int.tryParse(uploaded.size ?? '') ?? tamanho,
      webViewLink: uploaded.webViewLink,
      downloadLink: uploaded.webContentLink,
    );
  }

  Future<Uint8List> downloadFile(String driveFileId) async {
    if (_driveApi == null) throw Exception('Google Drive não conectado');
    final response = await _driveApi!.files.get(
      driveFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (response is drive.Media) {
      final chunks = await response.stream.toList();
      final len = chunks.fold<int>(0, (p, c) => p + c.length);
      final bytes = Uint8List(len);
      int offset = 0;
      for (final chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      return bytes;
    }
    throw Exception('Falha ao baixar arquivo do Drive');
  }

  Future<void> deleteFile(String driveFileId) async {
    if (_driveApi == null) throw Exception('Google Drive não conectado');
    await _driveApi!.files.delete(driveFileId);
  }

  String _inferMimeType(String nome) {
    final ext = nome.split('.').last.toLowerCase();
    switch ('.$ext') {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.zip':
      case '.rar':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  void dispose() {
    _desktopClient?.close();
    _desktopBaseClient?.close();
    _driveApi = null;
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final GoogleSignInAccount _account;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._account);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final auth = await _account.authentication;
    request.headers['Authorization'] = 'Bearer ${auth.accessToken}';
    return _inner.send(request);
  }
}

class DocumentoDrive {
  final String driveFileId;
  final String nome;
  final String mimeType;
  final int tamanho;
  final String? webViewLink;
  final String? downloadLink;

  DocumentoDrive({
    required this.driveFileId,
    required this.nome,
    this.mimeType = '',
    this.tamanho = 0,
    this.webViewLink,
    this.downloadLink,
  });
}
