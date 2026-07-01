import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LoginViewModel extends GetxController {
  final emailController = TextEditingController(text: 'admin@pnsa.com');
  final passwordController = TextEditingController(text: '123456');
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

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

    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
    Get.offAllNamed(AppRoutes.home);
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
