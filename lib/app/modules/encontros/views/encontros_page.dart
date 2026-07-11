import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../models/chamada_model.dart';
import '../viewmodels/encontros_viewmodel.dart';

void showEditarEncontroDialog(BuildContext context, Encontro encontro, String turmaNome, EncontrosViewModel encontrosVm) {
  final descCtrl = TextEditingController(text: encontro.descricao);
  final dataCtrl = encontro.data.obs;

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
                      onPressed: () async {
                        final updated = Encontro(
                          id: encontro.id,
                          turmaId: encontro.turmaId,
                          data: dataCtrl.value,
                          descricao: descCtrl.text.trim(),
                        );
                        await encontrosVm.atualizarEncontro(updated);
                        if (ctx.mounted) Navigator.of(ctx).pop();
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

void showChamadaDialog(
  BuildContext context,
  String turmaId,
  String turmaNome,
  EncontrosViewModel encontrosVm,
  CatequizandoViewModel catequizandoVm, {
  DateTime? dataInicial,
}) {
  final turmaVm = Get.find<TurmaViewModel>();
  final alunos = turmaVm.alunosDaTurma(turmaId, catequizandoVm.catequizandos);
  DateTime dataAtual = dataInicial ?? DateTime.now();
  final presencas = <String, bool>{};
  final descricaoCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  bool showHistory = false;

  void carregarChamadas(DateTime data) {
    presencas.clear();
    final chamadas = encontrosVm.chamadasDoDia(turmaId, data);
    final e = encontrosVm.encontroDoDia(turmaId, data);
    descricaoCtrl.text = e?.descricao ?? '';
    for (final a in alunos) {
      final c = chamadas.firstWhereOrNull((c) => c.catequizandoId == a.id);
      presencas[a.id] = c?.presente ?? true;
    }
  }

  carregarChamadas(dataAtual);

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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          dataAtual = dataAtual.subtract(const Duration(days: 1));
                          carregarChamadas(dataAtual);
                          setState(() {});
                        },
                        tooltip: 'Dia anterior',
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: ctx,
                              initialDate: dataAtual,
                              firstDate: DateTime(2025),
                              lastDate: DateTime.now(),
                              locale: const Locale('pt', 'BR'),
                            );
                            if (d != null) {
                              dataAtual = d;
                              carregarChamadas(d);
                              setState(() {});
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month_rounded, size: 16, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  '${dataAtual.day.toString().padLeft(2, '0')}/'
                                  '${dataAtual.month.toString().padLeft(2, '0')}/'
                                  '${dataAtual.year}',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: dataAtual.isBefore(DateTime.now()) ? () {
                          dataAtual = dataAtual.add(const Duration(days: 1));
                          carregarChamadas(dataAtual);
                          setState(() {});
                        } : null,
                        tooltip: 'Próximo dia',
                      ),
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
                        decoration: InputDecoration(
                          hintText: 'Buscar aluno...',
                          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          isDense: true,
                          suffixIcon: searchCtrl.text.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { searchCtrl.clear(); setState(() {}); })
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: () { for (final a in alunos) presencas[a.id] = true; setState(() {}); },
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
                                onPressed: () { for (final a in alunos) presencas[a.id] = false; setState(() {}); },
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
                            onTap: () => setState(() => presencas[aluno.id] = !presente),
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
                      if (alunos.isNotEmpty)
                        InkWell(
                          onTap: () { showHistory = !showHistory; setState(() {}); },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: 8),
                                Text('Histórico de Encontros', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                const Spacer(),
                                Icon(showHistory ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      if (showHistory)
                        SizedBox(
                          height: 120,
                          child: _buildHistoryList(context, theme, colorScheme, turmaId, encontrosVm, (date) {
                            dataAtual = date;
                            carregarChamadas(date);
                            searchCtrl.clear();
                            showHistory = false;
                          }, setState),
                        ),
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
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () async {
                                final chamadas = presencas.entries
                                    .map((e) => Chamada(id: '', encontroId: '', catequizandoId: e.key, presente: e.value))
                                    .toList();
                                await encontrosVm.salvarFrequencias(turmaId, dataAtual, chamadas, descricao: descricaoCtrl.text.trim());
                                if (ctx.mounted) Navigator.of(ctx).pop();
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
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildHistoryList(BuildContext context, ThemeData theme, ColorScheme colorScheme, String turmaId, EncontrosViewModel encontrosVm, void Function(DateTime) onSelectDate, StateSetter setState) {
  final encontrosDaTurma = encontrosVm.encontros.where((e) => e.turmaId == turmaId).toList()
    ..sort((a, b) => b.data.compareTo(a.data));
  if (encontrosDaTurma.isEmpty) {
    return Center(child: Text('Nenhum encontro registrado', style: theme.textTheme.bodySmall));
  }
  return ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: encontrosDaTurma.length,
    separatorBuilder: (_, __) => const Divider(height: 1),
    itemBuilder: (_, i) {
      final e = encontrosDaTurma[i];
      final chamadas = encontrosVm.chamadaRepo.getByEncontro(e.id);
      final presentes = chamadas.where((c) => c.presente).length;
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          '${e.data.day.toString().padLeft(2, '0')}/${e.data.month.toString().padLeft(2, '0')}/${e.data.year}',
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: e.descricao.isNotEmpty
            ? Text(e.descricao, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$presentes/${chamadas.length}', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary)),
            const SizedBox(width: 8),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.visibility_rounded, size: 16, color: colorScheme.primary),
              onPressed: () {
                onSelectDate(e.data);
                setState(() {});
              },
              tooltip: 'Carregar esta data',
            ),
          ],
        ),
      );
    },
  );
}

const _meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];

const _diasSemana = ['D','S','T','Q','Q','S','S'];

int _daysInMonth(int year, int month) {
  if (month == 2) {
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
  }
  return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
}

int _firstWeekdayOffset(int year, int month) {
  return DateTime(year, month, 1).weekday % 7;
}

Widget _dot(Color color) {
  return Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class _CalendarHeader extends StatelessWidget {
  final EncontrosViewModel vm;
  final List<TurmaModel> turmas;
  final CatequizandoViewModel catequizandoVm;

  const _CalendarHeader({required this.vm, required this.turmas, required this.catequizandoVm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final statusPorDia = vm.statusChamadaPorDia(turmaId: vm.selectedTurmaId.value.isNotEmpty ? vm.selectedTurmaId.value : null);
      final daysInMonth = _daysInMonth(vm.calendarYear.value, vm.calendarMonth.value);
      final offset = _firstWeekdayOffset(vm.calendarYear.value, vm.calendarMonth.value);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: vm.prevMonth,
                      tooltip: 'Mês anterior',
                    ),
                    Text(
                      '${_meses[vm.calendarMonth.value - 1]} ${vm.calendarYear.value}',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: vm.nextMonth,
                      tooltip: 'Próximo mês',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: _diasSemana.map((d) => Expanded(
                    child: Center(child: Text(d, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600))),
                  )).toList(),
                ),
                const SizedBox(height: 4),
                Table(
                  children: [
                    for (var row = 0; row < ((offset + daysInMonth + 6) ~/ 7); row++)
                      TableRow(
                        children: [
                          for (var col = 0; col < 7; col++)
                            _buildDayCell(row * 7 + col, offset, daysInMonth, statusPorDia, context, colorScheme, theme),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Com chamada', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 20),
                    _dot(colorScheme.tertiary),
                    const SizedBox(width: 6),
                    Text('Sem chamada', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 20),
                    _dot(colorScheme.outlineVariant),
                    const SizedBox(width: 6),
                    Text('Sem encontro', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCell(int index, int offset, int daysInMonth, Map<DateTime, bool> statusPorDia, BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    final day = index - offset + 1;
    final isToday = day == DateTime.now().day && vm.calendarMonth.value == DateTime.now().month && vm.calendarYear.value == DateTime.now().year;

    if (index < offset || day > daysInMonth) {
      return const SizedBox(height: 32);
    }

    final date = DateTime(vm.calendarYear.value, vm.calendarMonth.value, day);
    final hasEncontro = statusPorDia.containsKey(date);
    final temChamada = statusPorDia[date];

    return InkWell(
      onTap: hasEncontro ? () {
        final turmaId = vm.selectedTurmaId.value;
        if (turmaId.isEmpty) return;
        final turmaNome = turmas.firstWhereOrNull((t) => t.id == turmaId)?.nome ?? '';
        showChamadaDialog(context, turmaId, turmaNome, vm, catequizandoVm, dataInicial: date);
      } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isToday ? colorScheme.primaryContainer.withOpacity(0.4) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? colorScheme.primary : (hasEncontro ? colorScheme.onSurface : colorScheme.onSurfaceVariant),
              ),
            ),
            if (hasEncontro)
              _dot(temChamada == true ? colorScheme.primary : colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}

class _QuickChamadaBar extends StatelessWidget {
  final EncontrosViewModel vm;
  final List<TurmaModel> turmas;
  final CatequizandoViewModel catequizandoVm;

  const _QuickChamadaBar({required this.vm, required this.turmas, required this.catequizandoVm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.checklist_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: vm.selectedTurmaId.value.isEmpty ? null : vm.selectedTurmaId.value,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                items: turmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (v) => vm.selectedTurmaId.value = v ?? '',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: vm.selectedTurmaId.value.isEmpty
                  ? null
                  : () {
                      final turma = turmas.firstWhereOrNull((t) => t.id == vm.selectedTurmaId.value);
                      if (turma == null) return;
                      showChamadaDialog(context, turma.id, turma.nome, vm, catequizandoVm, dataInicial: DateTime.now());
                    },
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Fazer Chamada'),
            ),
          ],
        ),
      ),
    );
  }
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
            const SizedBox(height: 8),
            _CalendarHeader(vm: encontrosVm, turmas: turmas, catequizandoVm: catequizandoVm),
            const SizedBox(height: 16),
            _QuickChamadaBar(vm: encontrosVm, turmas: turmas, catequizandoVm: catequizandoVm),
            const SizedBox(height: 20),
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
                              item.encontro.turmaId,
                              item.turmaNome,
                              widget.encontrosVm,
                              widget.catequizandoVm,
                              dataInicial: item.encontro.data,
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
                                      onPressed: () async {
                                        await widget.encontrosVm.removerEncontro(item.encontro);
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
        final chamadas = encontrosVm.chamadaRepo.getByEncontro(item.encontro.id);
        final presentes = chamadas.where((c) => c.presente).length;
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
                          '$presentes / ${chamadas.length} presentes',
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
                            item.encontro.turmaId,
                            item.turmaNome,
                            encontrosVm,
                            catequizandoVm,
                            dataInicial: item.encontro.data,
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
                                    onPressed: () async {
                                      await encontrosVm.removerEncontro(item.encontro);
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
