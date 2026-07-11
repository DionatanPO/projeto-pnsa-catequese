import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../models/chamada_model.dart';
import '../viewmodels/encontros_viewmodel.dart';
import 'encontro_page.dart';

void showEditarEncontroDialog(BuildContext context, Encontro encontro, String turmaNome, EncontrosViewModel encontrosVm) {
  final descCtrl = TextEditingController(text: encontro.descricao);
  final dataCtrl = encontro.data.obs;

  showDialog(
    context: context,
    builder: (ctx) {
      var saving = false;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return StatefulBuilder(
        builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.edit_rounded, color: colorScheme.onPrimary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar Encontro',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              turmaNome,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: InkWell(
                      onTap: saving ? null : () async {
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
                          prefixIcon: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        child: Obx(() => Text(
                          '${dataCtrl.value.day.toString().padLeft(2, '0')}/'
                          '${dataCtrl.value.month.toString().padLeft(2, '0')}/'
                          '${dataCtrl.value.year}',
                        )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Tema, atividade...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  setState(() { saving = true; });
                                  final updated = Encontro(
                                    id: encontro.id,
                                    turmaId: encontro.turmaId,
                                    data: dataCtrl.value,
                                    descricao: descCtrl.text.trim(),
                                  );
                                  await encontrosVm.atualizarEncontro(updated);
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                },
                          icon: saving
                              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(saving ? 'Salvando...' : 'Salvar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
      );
    },
  );
}

void showChamadaDialog(
  BuildContext context,
  Encontro encontro,
  String turmaNome,
  EncontrosViewModel encontrosVm,
  CatequizandoViewModel catequizandoVm,
) {
  final turmaVm = Get.find<TurmaViewModel>();
  final alunos = turmaVm.alunosDaTurma(encontro.turmaId, catequizandoVm.catequizandos);
  final presencas = <String, bool>{};
  final descricaoCtrl = TextEditingController(text: encontro.descricao);
  final searchCtrl = TextEditingController();

  final chamadas = encontrosVm.chamadaRepo.getByEncontro(encontro.id);
  for (final a in alunos) {
    final c = chamadas.firstWhereOrNull((c) => c.catequizandoId == a.id);
    presencas[a.id] = c?.presente ?? true;
  }

  showDialog(
    context: context,
    builder: (ctx) {
      var saving = false;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.checklist_rounded, color: colorScheme.onPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chamada', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                            Text(turmaNome, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${alunos.length} alunos', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${encontro.data.day.toString().padLeft(2, '0')}/'
                        '${encontro.data.month.toString().padLeft(2, '0')}/'
                        '${encontro.data.year}',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (encontro.descricao.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            encontro.descricao,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: descricaoCtrl,
                    decoration: InputDecoration(
                      hintText: 'Tema, atividade...',
                      prefixIcon: Icon(Icons.notes_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      isDense: true,
                    ),
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: AppTheme.searchInputDecoration(
                          colorScheme,
                          hintText: 'Buscar aluno...',
                          suffixIcon: searchCtrl.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { searchCtrl.clear(); setState(() {}); })
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: saving ? null : () { for (final a in alunos) presencas[a.id] = true; setState(() {}); },
                                icon: Icon(Icons.check_circle_outline, size: 14, color: colorScheme.primary),
                                label: Text('Todos Presentes', style: TextStyle(fontSize: 11, color: colorScheme.primary)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: saving ? null : () { for (final a in alunos) presencas[a.id] = false; setState(() {}); },
                                icon: Icon(Icons.cancel_outlined, size: 14, color: colorScheme.error),
                                label: Text('Todos Ausentes', style: TextStyle(fontSize: 11, color: colorScheme.error)),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (alunos.isEmpty)
                  const Expanded(child: Center(child: Text('Nenhum aluno nesta turma')))
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      itemCount: alunos.where((a) {
                        final q = searchCtrl.text.toLowerCase().trim();
                        return q.isEmpty || a.nome.toLowerCase().contains(q) || a.responsavel.toLowerCase().contains(q);
                      }).length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final filtered = alunos.where((a) {
                          final q = searchCtrl.text.toLowerCase().trim();
                          return q.isEmpty || a.nome.toLowerCase().contains(q) || a.responsavel.toLowerCase().contains(q);
                        }).toList();
                        final aluno = filtered[i];
                        final presente = presencas[aluno.id] ?? true;
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: presente ? colorScheme.outlineVariant.withOpacity(0.3) : colorScheme.error.withOpacity(0.4)),
                          ),
                          child: InkWell(
                            onTap: saving ? null : () => setState(() => presencas[aluno.id] = !presente),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: presente ? colorScheme.primaryContainer : colorScheme.errorContainer,
                                    child: Text(
                                      aluno.nome.trim().isNotEmpty ? aluno.nome.trim()[0].toUpperCase() : '?',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: presente ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(aluno.nome, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text('${aluno.parentesco}: ${aluno.responsavel}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(presente ? Icons.check_circle_rounded : Icons.cancel_rounded, color: presente ? colorScheme.primary : colorScheme.error, size: 26),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${presencas.values.where((v) => v).length} / ${alunos.length} presentes',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      setState(() { saving = true; });
                                      final chamadas = presencas.entries
                                          .map((e) => Chamada(id: '', encontroId: '', catequizandoId: e.key, presente: e.value))
                                          .toList();
                                      await encontrosVm.salvarFrequencias(encontro.turmaId, encontro.data, chamadas, descricao: descricaoCtrl.text.trim());
                                      if (ctx.mounted) Navigator.of(ctx).pop();
                                    },
                              icon: saving
                                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                                  : const Icon(Icons.save_rounded, size: 18),
                              label: Text(saving ? 'Salvando...' : 'Salvar Chamada'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

const _monthsShort = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

class EncontrosPage extends StatelessWidget {
  final EncontrosViewModel encontrosVm;
  final RxList<TurmaModel> turmas;
  final CatequizandoViewModel catequizandoVm;

  const EncontrosPage({
    super.key,
    required this.encontrosVm,
    required this.turmas,
    required this.catequizandoVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    encontrosVm.rebuildList(turmas);

    return GetBuilder<EncontrosViewModel>(
      init: encontrosVm,
      id: 'encontros',
      builder: (_) {
        final paginated = encontrosVm.paginatedItems;
        final total = encontrosVm.totalPages;

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Obx(() => TextField(
                onChanged: encontrosVm.setSearch,
                decoration: AppTheme.searchInputDecoration(
                  colorScheme,
                  hintText: 'Buscar encontros...',
                  suffixIcon: encontrosVm.searchQuery.value.isNotEmpty
                      ? IconButton(icon: Icon(Icons.clear_rounded), onPressed: () => encontrosVm.setSearch(''))
                      : null,
                ),
              )),
              const SizedBox(height: 16),
              Expanded(
                child: paginated.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 56, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
                            const SizedBox(height: 16),
                            Text(
                              encontrosVm.searchQuery.value.isNotEmpty ? 'Nenhum encontro encontrado' : 'Nenhum encontro registrado',
                              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Clique em "Novo" para criar o primeiro encontro.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: paginated.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _EncontroCard(
                          item: paginated[i],
                          encontrosVm: encontrosVm,
                          catequizandoVm: catequizandoVm,
                        ),
                      ),
              ),
              if (total > 1) _PaginationControls(vm: encontrosVm, theme: theme),
            ],
          ),
        );
      },
    );
  }
}

class _EncontroCard extends StatelessWidget {
  final ({Encontro encontro, String turmaNome}) item;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const _EncontroCard({
    required this.item,
    required this.encontrosVm,
    required this.catequizandoVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final e = item.encontro;
    final chamadas = encontrosVm.chamadaRepo.getByEncontro(e.id);
    final presentes = chamadas.where((c) => c.presente).length;
    final total = chamadas.length;
    final percent = total > 0 ? presentes / total : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => showChamadaDialog(context, e, item.turmaNome, encontrosVm, catequizandoVm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('${e.data.day}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary)),
                        Text(_monthsShort[e.data.month - 1], style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(item.turmaNome, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.tertiary, fontSize: 11)),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_horiz_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                              onSelected: (v) {
                                if (v == 'edit') showEditarEncontroDialog(context, e, item.turmaNome, encontrosVm);
                                if (v == 'delete') {
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Excluir Encontro'),
                                      content: Text('Deseja excluir o encontro de '
                                          '${e.data.day.toString().padLeft(2, '0')}/'
                                          '${e.data.month.toString().padLeft(2, '0')}/'
                                          '${e.data.year}?'),
                                      actions: [
                                        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                        FilledButton(
                                          onPressed: () async {
                                            await encontrosVm.removerEncontro(e);
                                            Get.back();
                                          },
                                          style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Excluir')])),
                              ],
                            ),
                          ],
                        ),
                        if (e.descricao.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(e.descricao, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: percent >= 0.7 ? colorScheme.primary : (percent >= 0.4 ? colorScheme.tertiary : colorScheme.error),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$presentes/$total', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 4),
                    Text('(${(percent * 100).round()}%)', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final EncontrosViewModel vm;
  final ThemeData theme;

  const _PaginationControls({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final total = vm.totalPages;
    final current = vm.currentPage.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: current > 0 ? vm.prevPage : null,
            tooltip: 'Anterior',
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(total, current),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: current < total - 1 ? vm.nextPage : null,
            tooltip: 'Próximo',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int total, int current) {
    final pages = <Widget>[];
    final int start;
    final int end;

    if (total <= 7) {
      start = 0;
      end = total;
    } else {
      start = (current - 2).clamp(0, total - 5);
      end = (start + 5).clamp(0, total);
    }

    if (start > 0) {
      pages.add(_pageChip(0, current));
      pages.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...'),
      ));
    }

    for (var i = start; i < end; i++) {
      pages.add(_pageChip(i, current));
    }

    if (end < total) {
      pages.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text('...'),
      ));
      pages.add(_pageChip(total - 1, current));
    }

    return pages;
  }

  Widget _pageChip(int page, int current) {
    final isActive = page == current;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 36,
        height: 36,
        child: isActive
            ? FilledButton.tonal(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(36, 36),
                ),
                child: Text(
                  '${page + 1}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              )
            : TextButton(
                onPressed: () => vm.goToPage(page),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  '${page + 1}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                ),
              ),
      ),
    );
  }
}
