import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/relatorio_viewmodel.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../../core/utils/relatorio_generator.dart';

Color _corStatus(String status) {
  switch (status) {
    case 'Em Andamento': return Colors.blue;
    case 'Formado': return Colors.green;
    case 'Desistente': return Colors.red;
    case 'Transferido': return Colors.orange;
    case 'Inativo': return Colors.grey;
    default: return Colors.grey;
  }
}

class RelatorioPage extends StatefulWidget {
  final RelatorioViewModel relatorioVm;
  final CatequizandoViewModel catequizandoVm;
  final TurmaViewModel turmaVm;
  final EncontrosViewModel encontrosVm;
  final MatriculaViewModel matriculaVm;

  const RelatorioPage({
    super.key,
    required this.relatorioVm,
    required this.catequizandoVm,
    required this.turmaVm,
    required this.encontrosVm,
    required this.matriculaVm,
  });

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.relatorioVm.tabIndex.value,
    );
    _tabController.addListener(() {
      widget.relatorioVm.tabIndex.value = _tabController.index;
    });
    _refresh();
    ever(widget.catequizandoVm.catequizandos, (_) => _refresh());
  }

  void _refresh() {
    widget.relatorioVm.loadStatusReport(widget.catequizandoVm.catequizandos);
    widget.relatorioVm.loadTurmasPorEtapaReport(
      widget.turmaVm.turmas,
      widget.matriculaVm,
    );
    widget.relatorioVm.loadEncontrosReport(
      widget.turmaVm.turmas,
      widget.encontrosVm,
    );
    widget.relatorioVm.loadFaixaEtariaReport(widget.catequizandoVm.catequizandos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Relatórios', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Relatórios gerenciais', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => RelatorioGenerator.generate(widget.relatorioVm),
                icon: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.primary),
                tooltip: 'Exportar relatório em PDF',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Turmas por Etapa'),
            Tab(text: 'Encontros'),
            Tab(text: 'Faixa Etária'),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _StatusTab(vm: widget.relatorioVm, theme: theme),
              _TurmasEtapaTab(vm: widget.relatorioVm, theme: theme),
              _EncontrosTab(vm: widget.relatorioVm, theme: theme),
              _FaixaEtariaTab(vm: widget.relatorioVm, theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _StatusTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.statusCounts;
          final total = items.fold(0, (sum, s) => sum + s.count);

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Distribuição por Status',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$total catequizandos no total',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _StatusBar(item: item, theme: theme),
                  )),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Relatório gerado com base nos dados atuais',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  final StatusCount item;
  final ThemeData theme;

  const _StatusBar({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final color = _corStatus(item.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item.status,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text('${item.count}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            SizedBox(
              width: 44,
              child: Text('(${(item.percent * 100).toStringAsFixed(0)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.percent,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _TurmasEtapaTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _TurmasEtapaTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.turmasPorEtapa;
          final totalTurmas = items.fold(0, (sum, i) => sum + i.totalTurmas);
          final totalAlunos = items.fold(0, (sum, i) => sum + i.totalAlunos);

          if (items.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Nenhuma turma cadastrada', style: theme.textTheme.bodyMedium)),
              ),
            );
          }

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Turmas por Etapa',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$totalTurmas turmas, $totalAlunos alunos',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _EtapaBar(item: item, theme: theme),
                  )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EtapaBar extends StatelessWidget {
  final TurmaEtapaCount item;
  final ThemeData theme;

  const _EtapaBar({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(item.etapa,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text('${item.totalTurmas} turmas',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('${item.totalAlunos} alunos',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (item.totalAlunos / 50).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _EncontrosTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _EncontrosTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.encontrosRealizados;
          final totalEncontros = items.fold(0, (sum, i) => sum + i.totalEncontros);

          if (items.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Nenhum encontro registrado', style: theme.textTheme.bodyMedium)),
              ),
            );
          }

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Encontros Realizados',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$totalEncontros encontros no total',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _EncontroCard(item: item, theme: theme),
                  )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EncontroCard extends StatelessWidget {
  final EncontrosTurmaCount item;
  final ThemeData theme;

  const _EncontroCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(item.turmaNome,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 2,
          child: Text('${item.totalEncontros} encontros',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(
          flex: 2,
          child: Text('${item.mediaPresenca.toStringAsFixed(0)} presenças/méd',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _FaixaEtariaTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _FaixaEtariaTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.faixaEtaria;
          final total = items.fold(0, (sum, i) => sum + i.total);

          if (items.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Nenhum catequizando cadastrado', style: theme.textTheme.bodyMedium)),
              ),
            );
          }

          return Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_rounded, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Distribuição por Faixa Etária',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('$total catequizandos',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                ),
                                children: [
                                  _tableCell('Faixa', theme, header: true),
                                  _tableCell('Masc', theme, header: true, align: TextAlign.center),
                                  _tableCell('Fem', theme, header: true, align: TextAlign.center),
                                  _tableCell('Total', theme, header: true, align: TextAlign.center),
                                ],
                              ),
                              ...items.map((item) => TableRow(
                                children: [
                                  _tableCell(item.faixa, theme),
                                  _tableCell('${item.masculino}', theme, align: TextAlign.center),
                                  _tableCell('${item.feminino}', theme, align: TextAlign.center),
                                  _tableCell('${item.total}', theme, align: TextAlign.center, bold: true),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FaixaBar(item: item, total: total, theme: theme),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _tableCell(String text, ThemeData theme, {bool header = false, TextAlign align = TextAlign.left, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        textAlign: align,
        style: (header ? theme.textTheme.labelMedium : theme.textTheme.bodySmall)?.copyWith(
          fontWeight: header || bold ? FontWeight.w600 : null,
          color: header ? theme.colorScheme.onSurfaceVariant : null,
        ),
      ),
    );
  }
}

class _FaixaBar extends StatelessWidget {
  final FaixaEtariaCount item;
  final int total;
  final ThemeData theme;

  const _FaixaBar({
    required this.item,
    required this.total,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? item.total / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(item.faixa,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text('${item.total}',
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            SizedBox(
              width: 44,
              child: Text('(${(percent * 100).toStringAsFixed(0)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (item.masculino > 0)
              Expanded(
                flex: item.masculino,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),
            if (item.feminino > 0)
              Expanded(
                flex: item.feminino,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    borderRadius: BorderRadius.horizontal(
                      right: item.masculino == 0 ? const Radius.circular(4) : Radius.zero,
                    ),
                  ),
                ),
              ),
            if (item.masculino == 0 && item.feminino == 0)
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (item.masculino > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    Text('Masc: ${item.masculino}',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            if (item.feminino > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.tertiary),
                  ),
                  const SizedBox(width: 4),
                  Text('Fem: ${item.feminino}',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
