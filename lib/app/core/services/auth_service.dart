import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String defaultPassword = 'Pnsa@2024';

  Stream<User?> get user => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String> createAccount(String email, String password) async {
    final apiKey = _auth.app.options.apiKey;
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = data['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String? ?? '';

      if (message == 'EMAIL_EXISTS') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Já existe uma conta com este e-mail.',
        );
      }

      throw Exception(message.isNotEmpty ? message : 'Erro ao criar conta de autenticação');
    }

    return data['localId'] as String;
  }

  Future<bool> checkEmailExists(String email) async {
    final apiKey = _auth.app.options.apiKey;
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=$apiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': email,
        'continueUri': 'http://localhost',
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['registered'] == true;
  }

  Future<void> updateAuthEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> updateAuthPassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
