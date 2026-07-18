import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileEditBottomSheet extends StatefulWidget {
  final ProfileViewModel vm;

  const ProfileEditBottomSheet({super.key, required this.vm});

  static void show(BuildContext context, ProfileViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileEditBottomSheet(vm: vm),
    );
  }

  @override
  State<ProfileEditBottomSheet> createState() => _ProfileEditBottomSheetState();
}

class _ProfileEditBottomSheetState extends State<ProfileEditBottomSheet> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _novaSenhaCtrl;
  late final GlobalKey<FormState> _formKey;

  bool _salvando = false;
  String _emailOriginal = '';

  @override
  void initState() {
    super.initState();
    final p = widget.vm.profile.value;
    _emailOriginal = p.email;
    _nomeCtrl = TextEditingController(text: p.name != '---' ? p.name : '');
    _emailCtrl = TextEditingController(text: p.email != '---' ? p.email : '');
    _novaSenhaCtrl = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  bool get _emailAlterado => _emailCtrl.text.trim() != _emailOriginal;
  bool get _senhaAlterada => _novaSenhaCtrl.text.trim().isNotEmpty;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_emailAlterado && !_senhaAlterada && _nomeCtrl.text.trim() == widget.vm.profile.value.name) return;

    final nome = _nomeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final novaSenha = _novaSenhaCtrl.text.trim();

    setState(() => _salvando = true);

    try {
      if (_emailAlterado) {
        final existe = await widget.vm.checkEmailExists(email);
        if (existe) {
          setState(() => _salvando = false);
          Get.dialog(AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('E-mail já cadastrado'),
            content: Text('O e-mail "$email" já está em uso por outra conta.'),
            actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
          ));
          return;
        }
      }

      await widget.vm.updateProfile(
        nome: nome,
        email: _emailAlterado ? email : null,
        newPassword: _senhaAlterada ? novaSenha : null,
      );

      if (mounted) Navigator.pop(context);
      Get.snackbar(
        'Perfil atualizado',
        'Suas informações foram salvas com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Login necessário'),
          content: const Text('Por segurança, faça logout e login novamente antes de alterar e-mail ou senha.'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
        ));
      } else if (e.code == 'email-already-in-use') {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('E-mail já cadastrado'),
          content: Text('O e-mail "${_emailCtrl.text.trim()}" já está em uso.'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
        ));
      } else {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Erro'),
          content: Text(e.message ?? 'Erro ao atualizar perfil.'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
        ));
      }
    } catch (e) {
      if (!mounted) return;
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erro'),
        content: Text(e.toString()),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
      ));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: isWide ? 520 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.edit_rounded, color: colors.onPrimary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Perfil',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Altere suas informações pessoais',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        filled: true,
                        fillColor: colors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error, width: 2),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                        filled: true,
                        fillColor: colors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                        if (!emailRegex.hasMatch(v.trim())) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: colors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'Nova senha (opcional)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _novaSenhaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Mínimo 6 caracteres',
                        prefixIcon: Icon(Icons.lock_open_rounded, size: 20),
                        filled: true,
                        fillColor: colors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.outlineVariant.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.error, width: 2),
                        ),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty && v.trim().length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _salvando ? null : () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                      : Icon(Icons.check_rounded, size: 18),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
