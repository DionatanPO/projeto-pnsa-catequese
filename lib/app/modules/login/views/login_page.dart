import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginViewModel>(
      init: LoginViewModel(),
      builder: (vm) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _LargeScreen(vm: vm);
          }
          return _CompactScreen(vm: vm);
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final LoginViewModel vm;

  const _LoginForm({required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.church_rounded, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 20),
        Text(
          'Entrar',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Acesse sua conta',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 36),
        Obx(
          () => TextField(
            controller: vm.emailController,
            focusNode: vm.emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'E-mail',
              errorText:
                  vm.emailError.value.isNotEmpty ? vm.emailError.value : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => TextField(
            controller: vm.passwordController,
            focusNode: vm.passwordFocus,
            obscureText: vm.obscurePassword.value,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => vm.login(),
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: IconButton(
                icon: Icon(
                  vm.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: vm.toggleObscure,
              ),
              errorText: vm.passwordError.value.isNotEmpty
                  ? vm.passwordError.value
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text('Esqueci a Senha'),
                      ],
                    ),
                    content: const Text(
                      'Para redefinir suas credenciais de acesso, procure um coordenador responsável pelo sistema.',
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () => Get.back(),
                        child: const Text('Entendi'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Esqueci a senha'),
            ),
          ),
        const SizedBox(height: 8),
        Obx(
          () => FilledButton(
            onPressed: vm.isLoading.value ? null : vm.login,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: vm.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Entrar', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _LargeScreen extends StatelessWidget {
  final LoginViewModel vm;

  const _LargeScreen({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.church_rounded,
                      size: 72,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Paróquia\nNossa Senhora Auxiliadora',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de Gestão de Catequese',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: _LoginForm(vm: vm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactScreen extends StatelessWidget {
  final LoginViewModel vm;

  const _CompactScreen({required this.vm});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 24.0;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(hPad),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _LoginForm(vm: vm),
          ),
        ),
      ),
    );
  }
}
