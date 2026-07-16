import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../viewmodels/encontros_viewmodel.dart';

void showEditarEncontroBottomSheet(BuildContext context, Encontro encontro, String turmaNome, EncontrosViewModel encontrosVm) {
  final descCtrl = TextEditingController(text: encontro.descricao);
  final dataCtrl = encontro.data.obs;
  final salvando = false.obs;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      final isWide = MediaQuery.of(context).size.width >= 600;

      return Obx(() => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: isWide ? 480 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 32, offset: const Offset(0, -8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.edit_rounded, color: cs.onPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Editar Encontro', style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onSurface, fontWeight: FontWeight.bold)),
                        Text(turmaNome, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: salvando.value ? null : () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: dataCtrl.value,
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (d != null) dataCtrl.value = d;
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data',
                          prefixIcon: Icon(Icons.calendar_month_rounded, color: cs.primary),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        child: Text(
                          '${dataCtrl.value.day.toString().padLeft(2, '0')}/'
                          '${dataCtrl.value.month.toString().padLeft(2, '0')}/'
                          '${dataCtrl.value.year}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Tema, atividade...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
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
                    onPressed: salvando.value ? null : () => Navigator.pop(ctx),
                    child: Text('Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: salvando.value ? null : () async {
                      salvando.value = true;
                      final updated = Encontro(
                        id: encontro.id,
                        turmaId: encontro.turmaId,
                        data: dataCtrl.value,
                        descricao: descCtrl.text.trim(),
                      );
                      await encontrosVm.atualizarEncontro(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    icon: salvando.value
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(salvando.value ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    },
  );
}