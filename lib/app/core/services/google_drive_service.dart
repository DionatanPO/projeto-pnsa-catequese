import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'desktop_auth_helper.dart'
    if (dart.library.html) 'desktop_auth_helper_stub.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'drive_config.dart';

class GoogleDriveService {
  auth.ClientId get _clientId => kIsWeb
      ? auth.ClientId(DriveConfig.webClientId)
      : auth.ClientId(DriveConfig.desktopClientId, DriveConfig.desktopClientSecret);
  static const String _driveCredsKey = DriveConfig.credsStorageKey;
  static const String _driveSkipAutoSignInKey = DriveConfig.skipAutoSignInKey;
  static const List<String> _scopes = DriveConfig.scopes;

  auth.AutoRefreshingAuthClient? _desktopClient;
  http.Client? _desktopBaseClient;

  GoogleSignIn? _googleSignIn;
  http.Client? _webHttpClient;

  drive.DriveApi? _driveApi;
  String? _email;

  bool get isReady => _driveApi != null;
  String? get emailLogado => _email;

  Future<bool> tryAutoSignIn() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;

    const storage = FlutterSecureStorage();
    final skip = await storage.read(key: _driveSkipAutoSignInKey);
    if (skip == 'true') return false;

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
      const storage = FlutterSecureStorage();
      final saved = await storage.read(key: _driveCredsKey);
      debugPrint('[Drive] Auto restauração - Tem dados salvos? ${saved != null}');
      
      if (saved == null) {
        debugPrint('[Drive] Sem token salvo - auto-login ignorado');
        return false;
      }

      final creds = auth.AccessCredentials.fromJson(
        jsonDecode(saved) as Map<String, dynamic>,
      );
      
      debugPrint('[Drive] Auto restauração - Expirou? ${creds.accessToken.hasExpired}');
      if (creds.accessToken.hasExpired) {
        debugPrint('[Drive] Auto restauração - Token expirado!');
        await storage.delete(key: _driveCredsKey);
        await storage.delete(key: 'google_drive_email');
        return false;
      }

      _webHttpClient = auth.authenticatedClient(http.Client(), creds);
      _driveApi = drive.DriveApi(_webHttpClient!);
      
      final savedEmail = await storage.read(key: 'google_drive_email');
      _email = savedEmail ?? DriveConfig.allowedEmail;
      
      debugPrint('[Drive] Auto restauração - Sucesso!');
      return true;
    } catch (e) {
      debugPrint('[Drive] Web auto sign-in falhou: $e');
      _webHttpClient?.close();
      _webHttpClient = null;
      return false;
    }
  }

  Future<void> _signInWeb() async {
    _googleSignIn ??= GoogleSignIn(
      clientId: DriveConfig.webClientId,
      scopes: _scopes,
    );
    
    GoogleSignInAccount? account;
    try {
      account = await _googleSignIn!.signIn();
    } catch (e) {
      // Reseta a instância caso o usuário feche o pop-up ou seja bloqueado
      // Isso ajuda a evitar que o navegador bloqueie a próxima tentativa
      _googleSignIn = null;
      rethrow;
    }
    
    if (account == null) {
      _googleSignIn = null;
      throw Exception('Login cancelado pelo usuário');
    }

    if (account.email != DriveConfig.allowedEmail) {
      await _googleSignIn!.signOut();
      throw Exception('Conta inválida! O sistema só aceita ${DriveConfig.allowedEmail}');
    }

    final httpClient = await _googleSignIn!.authenticatedClient();
    if (httpClient == null) throw Exception('Falha ao obter cliente autenticado');

    _webHttpClient = httpClient;
    _driveApi = drive.DriveApi(httpClient);
    _email = account.email;

    const storage = FlutterSecureStorage();
    await storage.delete(key: _driveSkipAutoSignInKey);

    final authData = await account.authentication;
    if (authData.accessToken != null) {
      final token = auth.AccessToken(
        'Bearer',
        authData.accessToken!,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      );
      final credentials = auth.AccessCredentials(token, null, _scopes);
      await storage.write(
        key: _driveCredsKey,
        value: jsonEncode(credentials.toJson()),
      );
      await storage.write(key: 'google_drive_email', value: _email);
    }
  }

  Future<void> _signOutWeb() async {
    await _googleSignIn?.signOut();
    _googleSignIn?.disconnect().catchError((_) => null);
    _webHttpClient?.close();
    _webHttpClient = null;
    _driveApi = null;
    _email = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: _driveCredsKey);
    await storage.delete(key: 'google_drive_email');
    await storage.write(key: _driveSkipAutoSignInKey, value: 'true');
  }

  Future<bool> _tryAutoSignInDesktop() async {
    try {
      const storage = FlutterSecureStorage();
      final saved = await storage.read(key: _driveCredsKey);
      if (saved == null) return false;

      final creds = auth.AccessCredentials.fromJson(
        jsonDecode(saved) as Map<String, dynamic>,
      );
      _desktopBaseClient = http.Client();

      auth.AccessCredentials freshCreds;
      if (creds.accessToken.hasExpired) {
        try {
          freshCreds = await auth.refreshCredentials(
            _clientId,
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
        _clientId,
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
    _desktopClient = await doClientViaUserConsent(_clientId, _scopes);

    final emailDetectado = _extractEmail(_desktopClient!.credentials);
    if (emailDetectado != 'Conta Google' && emailDetectado != DriveConfig.allowedEmail) {
      _desktopClient?.close();
      _desktopClient = null;
      throw Exception('Conta inválida! O sistema só aceita ${DriveConfig.allowedEmail}');
    }

    const storage = FlutterSecureStorage();
    await storage.write(
      key: _driveCredsKey,
      value: jsonEncode(_desktopClient!.credentials.toJson()),
    );
    await storage.delete(key: _driveSkipAutoSignInKey);

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
    await storage.write(key: _driveSkipAutoSignInKey, value: 'true');
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

    final query = StringBuffer()
      ..write("name = '${nomePasta.replaceAll("'", "\\'")}'")
      ..write(" and mimeType = 'application/vnd.google-apps.folder'")
      ..write(' and trashed = false');
    if (parentFolderId != null) {
      query.write(" and '$parentFolderId' in parents");
    }

    final existing = await _driveApi!.files.list(
      q: query.toString(),
      $fields: 'files(id, name)',
      pageSize: 1,
    );

    if (existing.files != null && existing.files!.isNotEmpty) {
      debugPrint('[Drive] Pasta já existe: ${existing.files!.first.id}');
      return existing.files!.first.id!;
    }

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
    _webHttpClient?.close();
    _driveApi = null;
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
