import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../models/coordenador_model.dart';
import '../viewmodels/coordenador_viewmodel.dart';

class CoordenadorResetSenhaBottomSheet extends StatefulWidget {
  final Coordenador coordenador;
  final CoordenadorViewModel vm;

  const CoordenadorResetSenhaBottomSheet({
    super.key,
    required this.coordenador,
    required this.vm,
  });

  static void show(BuildContext context, CoordenadorViewModel vm, Coordenador coordenador) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoordenadorResetSenhaBottomSheet(coordenador: coordenador, vm: vm),
    );
  }

  @override
  State<CoordenadorResetSenhaBottomSheet> createState() => _CoordenadorResetSenhaBottomSheetState();
}

class _CoordenadorResetSenhaBottomSheetState extends State<CoordenadorResetSenhaBottomSheet> {
  bool _salvando = false;

  Future<void> _confirmar() async {
    setState(() => _salvando = true);
    try {
      await widget.vm.resetPassword(widget.coordenador.email);
      if (mounted) Navigator.pop(context);
      Get.snackbar(
        'E-mail enviado',
        'Um e-mail de redefinição de senha foi enviado para ${widget.coordenador.email}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erro ao redefinir senha'),
        content: Text(e.message ?? 'Erro desconhecido.'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
      ));
    } catch (e) {
      if (!mounted) return;
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erro ao redefinir senha'),
        content: Text('$e'),
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
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: isWide ? 480 : double.infinity,
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
                    color: colors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.key_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redefinir Senha',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Coordenador: ${widget.coordenador.nome}',
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.tertiaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.tertiary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: colors.tertiary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'A senha do coordenador será redefinida para a senha padrão abaixo.',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 18, color: colors.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Senha padrão:',
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AuthService.defaultPassword,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Após redefinir, o coordenador deverá usar esta senha para acessar o sistema.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant.withOpacity(0.7)),
                  ),
                ],
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
                  onPressed: _salvando ? null : _confirmar,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  ),
                  icon: _salvando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_salvando ? 'Redefinindo...' : 'Concluir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
