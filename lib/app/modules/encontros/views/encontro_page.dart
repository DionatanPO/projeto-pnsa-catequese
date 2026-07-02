import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../viewmodels/encontro_viewmodel.dart';
import '../viewmodels/encontros_viewmodel.dart';

void showEncontroDialog(BuildContext context, EncontrosViewModel encontrosVm, CatequizandoViewModel catequizandoVm, {TurmaModel? turma, RxList<TurmaModel>? turmas}) {
  final vm = EncontroViewModel(encontrosVm: encontrosVm);
  final todosTurmas = turmas ?? <TurmaModel>[].obs;
  Get.put(vm);

  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return GetBuilder<EncontroViewModel>(
        builder: (ctrl) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme, colorScheme, ctrl, turma, todosTurmas, catequizandoVm),
                if (ctrl.turma == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Selecione uma turma acima', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildTabs(theme, colorScheme, ctrl),
                  Expanded(
                    child: ctrl.abaAtual.value == 0
                        ? _buildChamadaTab(theme, colorScheme, ctrl, ctx)
                        : _buildEncontrosTab(theme, colorScheme, ctrl, ctx),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  ).then((_) => Get.delete<EncontroViewModel>());
}

void showNovoEncontroDialog(BuildContext context, EncontrosViewModel encontrosVm, {RxList<TurmaModel>? turmas}) {
  final todosTurmas = turmas ?? <TurmaModel>[].obs;
  final dataCtrl = DateTime.now().obs;
  final descCtrl = TextEditingController();
  final turmaSelecionada = Rx<TurmaModel?>(null);

  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Obx(
        () => Dialog(
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
                        child: Icon(Icons.event_rounded, color: colorScheme.onPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Novo Encontro',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: DropdownButtonFormField<TurmaModel>(
                    value: turmaSelecionada.value,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Turma',
                      prefixIcon: Icon(Icons.group_rounded),
                    ),
                    items: todosTurmas.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
                    onChanged: (v) => turmaSelecionada.value = v,
                    validator: (v) => v == null ? 'Selecione uma turma' : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: InkWell(
                    onTap: () async {
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
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () {
                          final turma = turmaSelecionada.value;
                          if (turma == null) return;
                          encontrosVm.criarEncontro(turma.id, dataCtrl.value, descCtrl.text.trim());
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Salvar'),
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

Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, EncontroViewModel ctrl, TurmaModel? turma, RxList<TurmaModel> turmas, CatequizandoViewModel catequizandoVm) {
  final turmaVm = Get.find<TurmaViewModel>();
  return Container(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      gradient: LinearGradient(
        colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
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
          child: Icon(Icons.group_rounded, color: colorScheme.onPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gerenciar Encontros',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (turma != null)
                Text(
                  turma.nome,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                )
              else
                DropdownButtonFormField<TurmaModel>(
                  value: null,
                  isExpanded: true,
                  dropdownColor: colorScheme.primary,
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 13),
                  hint: Text('Selecione a turma...', style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 13)),
                  items: turmas.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
                  onChanged: (t) {
                    if (t != null) {
                      ctrl.definirTurma(t, turmaVm, catequizandoVm);
                    }
                  },
                ),
            ],
          ),
        ),
        if (turma != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${ctrl.todosAlunos.length} alunos',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildTabs(ThemeData theme, ColorScheme colorScheme, EncontroViewModel ctrl) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
    ),
    child: Row(
      children: [
        _tabButton('Chamada', Icons.checklist_rounded, ctrl.abaAtual.value == 0, colorScheme, () => ctrl.setAba(0)),
        const SizedBox(width: 4),
        _tabButton('Encontros', Icons.calendar_month_rounded, ctrl.abaAtual.value == 1, colorScheme, () => ctrl.setAba(1)),
      ],
    ),
  );
}

Widget _tabButton(String label, IconData icon, bool ativo, ColorScheme colorScheme, VoidCallback onPressed) {
  return Expanded(
    child: InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ativo ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: ativo ? colorScheme.primary : colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: ativo ? FontWeight.w600 : FontWeight.w400,
                color: ativo ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildChamadaTab(ThemeData theme, ColorScheme colorScheme, EncontroViewModel ctrl, BuildContext ctx) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Descrição do encontro (tema, atividade...)',
            prefixIcon: Icon(Icons.notes_rounded, color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
          onChanged: ctrl.setDescricao,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar aluno...',
                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: ctrl.setSearch,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  final data = await showDatePicker(
                    context: ctx,
                    initialDate: ctrl.dataSelecionada.value,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (data != null) ctrl.carregarData(data);
                },
                icon: Icon(Icons.calendar_month_rounded, size: 18),
                label: Obx(() => Text(
                  '${ctrl.dataSelecionada.value.day.toString().padLeft(2, '0')}/'
                  '${ctrl.dataSelecionada.value.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13),
                )),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: GetBuilder<EncontroViewModel>(
          builder: (ctrl) {
            final list = ctrl.alunosFiltrados;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum aluno encontrado',
                      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final aluno = list[i];
                final inicial = aluno.nome.trim().isNotEmpty ? aluno.nome.trim()[0].toUpperCase() : '?';
                final presente = ctrl.presencasLocais[aluno.id] ?? true;
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: presente
                          ? colorScheme.outlineVariant.withOpacity(0.3)
                          : colorScheme.error.withOpacity(0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: presente
                              ? colorScheme.primaryContainer
                              : colorScheme.errorContainer,
                          child: Text(
                            inicial,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: presente
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aluno.nome,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_outline_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${aluno.parentesco}: ${aluno.responsavel}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.phone_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    aluno.telefone,
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: presente,
                          activeColor: colorScheme.primary,
                          onChanged: (v) => ctrl.alternarPresenca(aluno.id, v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      if (ctrl.todosAlunos.isNotEmpty)
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
          ),
          child: GetBuilder<EncontroViewModel>(
            builder: (ctrl) {
              return Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${ctrl.totalPresentes} / ${ctrl.todosAlunos.length} presentes',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      ctrl.salvar();
                      Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Salvar Chamada'),
                  ),
                ],
              );
            },
          ),
        ),
    ],
  );
}

Widget _buildEncontrosTab(ThemeData theme, ColorScheme colorScheme, EncontroViewModel ctrl, BuildContext ctx) {
  final encontros = ctrl.encontrosVm.encontrosDaTurma(ctrl.turma!.id);

  return Column(
    children: [
      if (encontros.isEmpty)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Nenhum encontro registrado',
                  style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  'As chamadas salvas aparecerão aqui.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        )
      else
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: encontros.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = encontros[i];
              final presentes = ctrl.encontrosVm.presentesNoDia(ctrl.turma!.id, e.data.toIso8601String().split('T')[0], ctrl.todosAlunos.length);
              final total = ctrl.todosAlunos.length;
              final percent = total > 0 ? (presentes / total * 100).round() : 0;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.data.day.toString().padLeft(2, '0')}/'
                              '${e.data.month.toString().padLeft(2, '0')}/'
                              '${e.data.year}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (e.descricao.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                e.descricao,
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 14, color: colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '$presentes / $total presentes',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.percent_rounded, size: 14, color: colorScheme.tertiary),
                                const SizedBox(width: 4),
                                Text(
                                  '$percent%',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.tertiary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.visibility_rounded, size: 18, color: colorScheme.primary),
                          onPressed: () => _verAlunosDoEncontro(theme, colorScheme, ctrl, e),
                          tooltip: 'Ver alunos',
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                          onPressed: () {
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
                                    onPressed: () {
                                      ctrl.removerEncontro(e);
                                      Get.back();
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Excluir encontro',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    ],
  );
}

void _verAlunosDoEncontro(ThemeData theme, ColorScheme colorScheme, EncontroViewModel ctrl, Encontro encontro) {
  final lista = ctrl.todosAlunos.map((a) {
    final f = encontro.frequencias.where((f) => f.catequizandoId == a.id).firstOrNull;
    return (aluno: a, presente: f?.presente ?? true);
  }).toList()
    ..sort((a, b) => a.presente == b.presente ? 0 : (a.presente ? -1 : 1));

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calendar_month_rounded, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lista de Presença', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                        Text(
                          '${encontro.data.day.toString().padLeft(2, '0')}/'
                          '${encontro.data.month.toString().padLeft(2, '0')}/'
                          '${encontro.data.year}',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${lista.where((x) => x.presente).length}/${lista.length}',
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (encontro.descricao.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.notes_rounded, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(encontro.descricao, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = lista[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: item.presente ? colorScheme.primaryContainer : colorScheme.errorContainer,
                      child: Text(
                        item.aluno.nome[0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: item.presente ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    title: Text(item.aluno.nome, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(item.aluno.responsavel, style: theme.textTheme.bodySmall),
                    trailing: Icon(
                      item.presente ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: item.presente ? colorScheme.primary : colorScheme.error,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Fechar')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
