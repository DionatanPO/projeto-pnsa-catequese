import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';
import '../viewmodels/encontros_viewmodel.dart';

void showEditarEncontroDialog(BuildContext context, Encontro encontro, String turmaNome, EncontrosViewModel encontrosVm) {
  final descCtrl = TextEditingController(text: encontro.descricao);

  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Dialog(
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
                          '$turmaNome — '
                          '${encontro.data.day.toString().padLeft(2, '0')}/'
                          '${encontro.data.month.toString().padLeft(2, '0')}/'
                          '${encontro.data.year}',
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
                        encontrosVm.atualizarEncontro(encontro, descCtrl.text.trim());
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
      );
    },
  );
}

void showChamadaDialog(BuildContext context, Encontro encontro, String turmaId, String turmaNome, EncontrosViewModel encontrosVm, CatequizandoViewModel catequizandoVm) {
  final turmaVm = Get.find<TurmaViewModel>();
  final alunos = turmaVm.alunosDaTurma(turmaId, catequizandoVm.catequizandos);
  final presencas = <String, bool>{};
  for (final a in alunos) {
    final f = encontro.frequencias.firstWhereOrNull((f) => f.catequizandoId == a.id);
    presencas[a.id] = f?.presente ?? true;
  }

  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
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
                            Text(
                              'Chamada',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$turmaNome — '
                              '${encontro.data.day.toString().padLeft(2, '0')}/'
                              '${encontro.data.month.toString().padLeft(2, '0')}/'
                              '${encontro.data.year}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
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
                          '${alunos.length} alunos',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (encontro.descricao.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            encontro.descricao,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (alunos.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Nenhum aluno nesta turma')),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: alunos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final aluno = alunos[i];
                        final presente = presencas[aluno.id] ?? true;
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
                                  radius: 22,
                                  backgroundColor: presente
                                      ? colorScheme.primaryContainer
                                      : colorScheme.errorContainer,
                                  child: Text(
                                    aluno.nome.trim().isNotEmpty
                                        ? aluno.nome.trim()[0].toUpperCase()
                                        : '?',
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
                                          Expanded(
                                            child: Text(
                                              '${aluno.parentesco}: ${aluno.responsavel}',
                                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: presente,
                                  activeColor: colorScheme.primary,
                                  onChanged: (v) {
                                    setState(() => presencas[aluno.id] = v);
                                  },
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
                    children: [
                      Text(
                        '${presencas.values.where((v) => v).length} / ${alunos.length} presentes',
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
                          final frequencias = presencas.entries
                              .map((e) => Frequencia(catequizandoId: e.key, presente: e.value))
                              .toList();
                          encontrosVm.salvarFrequencias(turmaId, encontro.data, frequencias);
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Salvar Chamada'),
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
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    encontrosVm.rebuildList(turmas);

    return GetBuilder<EncontrosViewModel>(
      init: encontrosVm,
      id: 'encontros',
      builder: (_) {
        final paginated = encontrosVm.paginatedItems;
        final total = encontrosVm.totalPages;

        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
          children: [
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                onChanged: encontrosVm.setSearch,
                decoration: InputDecoration(
                  hintText: 'Buscar por turma, descrição ou data...',
                  prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                  suffixIcon: encontrosVm.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () => encontrosVm.setSearch(''),
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (paginated.isEmpty && encontrosVm.allItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        encontrosVm.searchQuery.value.isNotEmpty
                            ? 'Nenhum encontro encontrado'
                            : 'Nenhum encontro registrado',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else if (paginated.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'Nenhum resultado para essa busca',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _EncontrosListMobile(
                          list: paginated,
                          theme: theme,
                          encontrosVm: encontrosVm,
                          catequizandoVm: catequizandoVm,
                        ),
                        if (total > 1) _PaginationControls(vm: encontrosVm, theme: theme),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _EncontrosTable(
                        list: paginated,
                        theme: theme,
                        encontrosVm: encontrosVm,
                        catequizandoVm: catequizandoVm,
                      ),
                      if (total > 1) _PaginationControls(vm: encontrosVm, theme: theme),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _EncontrosTable extends StatefulWidget {
  final List<({Encontro encontro, String turmaNome})> list;
  final ThemeData theme;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const _EncontrosTable({required this.list, required this.theme, required this.encontrosVm, required this.catequizandoVm});

  @override
  State<_EncontrosTable> createState() => _EncontrosTableState();
}

class _EncontrosTableState extends State<_EncontrosTable> {
  void _sort(int col) {
    widget.encontrosVm.sortBy(col);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final items = widget.list;
    final sortCol = widget.encontrosVm.sortColumn.value;
    final sortAsc = widget.encontrosVm.sortAscending.value;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(4),
          3: FixedColumnWidth(170),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.85)],
              ),
            ),
            children: [
              _sortableHeader('Data', Icons.calendar_month_rounded, 0, sortCol, sortAsc),
              _sortableHeader('Turma', Icons.group_rounded, 1, sortCol, sortAsc),
              _sortableHeader('Descrição', Icons.notes_rounded, 2, sortCol, sortAsc),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...items.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final item = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? theme.colorScheme.surfaceContainerLow.withOpacity(0.4)
                      : Colors.transparent,
                ),
                children: [
                  _bodyCell(
                    '${item.encontro.data.day.toString().padLeft(2, '0')}/'
                    '${item.encontro.data.month.toString().padLeft(2, '0')}/'
                    '${item.encontro.data.year}',
                    isBold: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.turmaNome,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  _bodyCell(item.encontro.descricao.isNotEmpty ? item.encontro.descricao : '-'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                            onPressed: () => showEditarEncontroDialog(context, item.encontro, item.turmaNome, widget.encontrosVm),
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.checklist_rounded, size: 18, color: theme.colorScheme.tertiary),
                            onPressed: () => showChamadaDialog(
                              context,
                              item.encontro,
                              item.encontro.id.split('_').first,
                              item.turmaNome,
                              widget.encontrosVm,
                              widget.catequizandoVm,
                            ),
                            tooltip: 'Chamada',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Excluir Encontro'),
                                  content: Text('Deseja excluir o encontro de '
                                      '${item.encontro.data.day.toString().padLeft(2, '0')}/'
                                      '${item.encontro.data.month.toString().padLeft(2, '0')}/'
                                      '${item.encontro.data.year}?'),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        widget.encontrosVm.removerEncontro(item.encontro);
                                        Get.back();
                                      },
                                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
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
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sortableHeader(String label, IconData icon, int col, int sortCol, bool sortAsc) {
    final theme = widget.theme;
    final isActive = sortCol == col;
    return InkWell(
      onTap: () => _sort(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, IconData icon) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: isBold
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            : theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _EncontrosListMobile extends StatelessWidget {
  final List<({Encontro encontro, String turmaNome})> list;
  final ThemeData theme;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const _EncontrosListMobile({required this.list, required this.theme, required this.encontrosVm, required this.catequizandoVm});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.turmaNome,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.encontro.data.day.toString().padLeft(2, '0')}/'
                              '${item.encontro.data.month.toString().padLeft(2, '0')}/'
                              '${item.encontro.data.year}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (item.encontro.descricao.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.encontro.descricao,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${item.encontro.frequencias.where((f) => f.presente).length} / ${item.encontro.frequencias.length} presentes',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 17,
                          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                          onPressed: () => showEditarEncontroDialog(context, item.encontro, item.turmaNome, encontrosVm),
                          tooltip: 'Editar',
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 17,
                          icon: Icon(Icons.checklist_rounded, color: theme.colorScheme.tertiary),
                          onPressed: () => showChamadaDialog(
                            context,
                            item.encontro,
                            item.encontro.id.split('_').first,
                            item.turmaNome,
                            encontrosVm,
                            catequizandoVm,
                          ),
                          tooltip: 'Chamada',
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 17,
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Excluir Encontro'),
                                content: Text('Deseja excluir o encontro de '
                                    '${item.encontro.data.day.toString().padLeft(2, '0')}/'
                                    '${item.encontro.data.month.toString().padLeft(2, '0')}/'
                                    '${item.encontro.data.year}?'),
                                actions: [
                                  TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                  FilledButton(
                                    onPressed: () {
                                      encontrosVm.removerEncontro(item.encontro);
                                      Get.back();
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Excluir',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
