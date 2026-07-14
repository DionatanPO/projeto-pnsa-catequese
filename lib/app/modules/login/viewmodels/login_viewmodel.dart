import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

class LoginViewModel extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  AuthController get _authController => Get.find();

  void toggleObscure() => obscurePassword.toggle();

  void login() async {
    emailError.value = '';
    passwordError.value = '';

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      emailError.value = 'Informe o e-mail';
      emailFocus.requestFocus();
      return;
    }

    if (!GetUtils.isEmail(email)) {
      emailError.value = 'E-mail inválido';
      emailFocus.requestFocus();
      return;
    }

    if (password.isEmpty) {
      passwordError.value = 'Informe a senha';
      passwordFocus.requestFocus();
      return;
    }

    if (password.length < 6) {
      passwordError.value = 'Senha deve ter no mínimo 6 caracteres';
      passwordFocus.requestFocus();
      return;
    }

    isLoading.value = true;

    try {
      await _authController.login(email, password);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _authController.ensureUserDocExists(uid, email);
      isLoading.value = false;
      passwordController.clear();
      emailController.clear();
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      switch (e.code) {
        case 'invalid-email':
          emailError.value = 'E-mail inválido';
          break;
        case 'user-disabled':
          emailError.value = 'Esta conta foi desativada';
          break;
        case 'user-not-found':
          emailError.value = 'Nenhum usuário encontrado com este e-mail';
          break;
        case 'wrong-password':
          passwordError.value = 'Senha incorreta';
          break;
        case 'invalid-credential':
          passwordError.value = 'E-mail ou senha inválidos';
          break;
        case 'too-many-requests':
          Get.snackbar(
            'Muitas tentativas',
            'Acesso temporariamente bloqueado. Tente novamente mais tarde.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        default:
          Get.snackbar(
            'Erro ao entrar',
            'Ocorreu um erro inesperado. Tente novamente.',
            snackPosition: SnackPosition.BOTTOM,
          );
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
