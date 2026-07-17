import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/relatorio_viewmodel.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../../core/utils/relatorio_generator.dart';

// ── Paleta de cores por status ─────────────────────────────────────────────
Color _corStatus(String status) {
  switch (status) {
    case 'Em Andamento': return const Color(0xFF2563EB);
    case 'Formado':      return const Color(0xFF16A34A);
    case 'Desistente':   return const Color(0xFFDC2626);
    case 'Transferido':  return const Color(0xFFD97706);
    case 'Inativo':      return const Color(0xFF6B7280);
    default:             return const Color(0xFF6B7280);
  }
}

Color _corStatusBg(String status, ColorScheme cs) {
  switch (status) {
    case 'Em Andamento': return cs.primaryContainer.withOpacity(0.3);
    case 'Formado':      return const Color(0xFFDCFCE7);
    case 'Desistente':   return cs.errorContainer.withOpacity(0.3);
    case 'Transferido':  return const Color(0xFFFEF3C7);
    case 'Inativo':      return cs.surfaceContainerHighest;
    default:             return cs.surfaceContainerHighest;
  }
}

IconData _iconStatus(String status) {
  switch (status) {
    case 'Em Andamento': return Icons.trending_up_rounded;
    case 'Formado':      return Icons.workspace_premium_rounded;
    case 'Desistente':   return Icons.person_off_rounded;
    case 'Transferido':  return Icons.swap_horiz_rounded;
    case 'Inativo':      return Icons.pause_circle_outline_rounded;
    default:             return Icons.help_outline_rounded;
  }
}

// ── Page principal ─────────────────────────────────────────────────────────
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

  final _tabs = const [
    (icon: Icons.donut_large_rounded,   label: 'Status'),
    (icon: Icons.school_rounded,        label: 'Turmas'),
    (icon: Icons.event_note_rounded,    label: 'Encontros'),
    (icon: Icons.people_alt_rounded,    label: 'Faixa Etária'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
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
    widget.relatorioVm.loadTurmasPorEtapaReport(widget.turmaVm.turmas, widget.matriculaVm);
    widget.relatorioVm.loadEncontrosReport(widget.turmaVm.turmas, widget.encontrosVm);
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
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final hPad = isWide ? 32.0 : 16.0;

    return Column(
      children: [
        // ── Cabeçalho ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.analytics_rounded, color: cs.onPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Relatórios',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Visão geral e indicadores da catequese',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Tooltip(
                message: 'Exportar relatório em PDF',
                child: FilledButton.tonalIcon(
                  onPressed: () => RelatorioGenerator.generate(widget.relatorioVm),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: isWide ? const Text('Exportar PDF') : const SizedBox.shrink(),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Tabs ───────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            labelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: theme.textTheme.labelMedium,
            tabs: _tabs.map((t) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 16),
                  const SizedBox(width: 6),
                  Text(t.label),
                ],
              ),
            )).toList(),
          ),
        ),

        const SizedBox(height: 4),
        Divider(height: 1, color: cs.outlineVariant.withOpacity(0.4)),

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

// ── Widget helpers ─────────────────────────────────────────────────────────

Widget _sectionCard({required ThemeData theme, required Widget child}) {
  final cs = theme.colorScheme;
  return Container(
    decoration: BoxDecoration(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      boxShadow: [
        BoxShadow(
          color: cs.shadow.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(24),
    child: child,
  );
}

Widget _cardHeader(ThemeData theme, IconData icon, String title, String subtitle) {
  final cs = theme.colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 20),
      Divider(color: cs.outlineVariant.withOpacity(0.3)),
      const SizedBox(height: 16),
    ],
  );
}

Widget _emptyState(ThemeData theme, String msg) {
  final cs = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 48),
    alignment: Alignment.center,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.inbox_rounded, size: 32, color: cs.onSurfaceVariant.withOpacity(0.5)),
        ),
        const SizedBox(height: 16),
        Text(msg, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      ],
    ),
  );
}

// ── KPI Card ───────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _KpiCard({
    required this.theme,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── STATUS TAB ─────────────────────────────────────────────────────────────
class _StatusTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _StatusTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final hPad = isWide ? 32.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.statusCounts;
          final total = items.fold(0, (sum, s) => sum + s.count);
          final ativos = items.where((s) => s.status == 'Em Andamento').fold(0, (s, i) => s + i.count);
          final formados = items.where((s) => s.status == 'Formado').fold(0, (s, i) => s + i.count);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPIs
              GridView.count(
                crossAxisCount: isWide ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 1.8 : 1.7,
                children: [
                  _KpiCard(theme: theme, icon: Icons.people_rounded, value: '$total',
                      label: 'Total cadastrado', color: cs.primary),
                  _KpiCard(theme: theme, icon: Icons.trending_up_rounded, value: '$ativos',
                      label: 'Em andamento', color: const Color(0xFF2563EB)),
                  _KpiCard(theme: theme, icon: Icons.workspace_premium_rounded, value: '$formados',
                      label: 'Formados', color: const Color(0xFF16A34A)),
                ],
              ),
              const SizedBox(height: 20),

              // Card distribuição
              _sectionCard(
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(theme, Icons.donut_large_rounded,
                        'Distribuição por Status', '$total catequizandos no total'),
                    if (items.isEmpty)
                      _emptyState(theme, 'Nenhum catequizando cadastrado')
                    else
                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _StatusBar(item: item, theme: theme),
                      )),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Dados atualizados em tempo real',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final bgColor = _corStatusBg(item.status, theme.colorScheme);
    final icon = _iconStatus(item.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(item.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: color, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Spacer(),
            Text('${item.count}',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${(item.percent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: color, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.percent,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── TURMAS POR ETAPA TAB ───────────────────────────────────────────────────
class _TurmasEtapaTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _TurmasEtapaTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final hPad = isWide ? 32.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.turmasPorEtapa;
          final totalTurmas = items.fold(0, (sum, i) => sum + i.totalTurmas);
          final totalAlunos = items.fold(0, (sum, i) => sum + i.totalAlunos);
          final maxAlunos = items.isEmpty ? 1 : items.map((i) => i.totalAlunos).reduce((a, b) => a > b ? a : b);

          return Column(
            children: [
              // KPIs
              if (items.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(child: _KpiCard(theme: theme, icon: Icons.class_rounded,
                        value: '$totalTurmas', label: 'Turmas ativas', color: cs.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(theme: theme, icon: Icons.people_rounded,
                        value: '$totalAlunos', label: 'Alunos matriculados', color: const Color(0xFF7C3AED))),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              _sectionCard(
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(theme, Icons.school_rounded, 'Turmas por Etapa',
                        '$totalTurmas turmas · $totalAlunos alunos'),
                    if (items.isEmpty)
                      _emptyState(theme, 'Nenhuma turma cadastrada')
                    else
                      ...items.asMap().entries.map((entry) {
                        final item = entry.value;
                        final pct = maxAlunos > 0 ? item.totalAlunos / maxAlunos : 0.0;
                        final colors = [
                          cs.primary,
                          const Color(0xFF7C3AED),
                          const Color(0xFF0891B2),
                          const Color(0xFF16A34A),
                          const Color(0xFFD97706),
                        ];
                        final color = colors[entry.key % colors.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _EtapaBar(item: item, theme: theme, color: color, percent: pct.toDouble()),
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _EtapaBar extends StatelessWidget {
  final TurmaEtapaCount item;
  final ThemeData theme;
  final Color color;
  final double percent;

  const _EtapaBar({required this.item, required this.theme, required this.color, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.etapa,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${item.totalTurmas} turma${item.totalTurmas != 1 ? 's' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text('${item.totalAlunos} alunos',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── ENCONTROS TAB ──────────────────────────────────────────────────────────
class _EncontrosTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _EncontrosTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;
    final hPad = isWide ? 32.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.encontrosRealizados;
          final totalEncontros = items.fold(0, (sum, i) => sum + i.totalEncontros);

          return Column(
            children: [
              if (items.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(child: _KpiCard(theme: theme, icon: Icons.event_rounded,
                        value: '$totalEncontros', label: 'Total de encontros', color: cs.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(theme: theme, icon: Icons.groups_rounded,
                        value: '${items.length}', label: 'Turmas com encontros', color: const Color(0xFF0891B2))),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              _sectionCard(
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(theme, Icons.event_note_rounded, 'Encontros por Turma',
                        '$totalEncontros encontros realizados no total'),
                    if (items.isEmpty)
                      _emptyState(theme, 'Nenhum encontro registrado')
                    else ...[
                      // Cabeçalho da tabela
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3,
                              child: Text('Turma', style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
                            Expanded(flex: 2,
                              child: Text('Encontros', textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
                            Expanded(flex: 2,
                              child: Text('Méd. Presenças', textAlign: TextAlign.right,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...items.asMap().entries.map((entry) {
                        final item = entry.value;
                        final isEven = entry.key.isEven;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: isEven ? Colors.transparent : cs.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 3,
                                child: Text(item.turmaNome,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                              Expanded(flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('${item.totalEncontros}',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                            color: cs.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              Expanded(flex: 2,
                                child: Text(item.mediaPresenca.toStringAsFixed(1),
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── FAIXA ETÁRIA TAB ───────────────────────────────────────────────────────
class _FaixaEtariaTab extends StatelessWidget {
  final RelatorioViewModel vm;
  final ThemeData theme;

  const _FaixaEtariaTab({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final hPad = isWide ? 32.0 : 16.0;
    final cs = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, hPad),
      children: [
        Obx(() {
          final items = vm.faixaEtaria;
          final total = items.fold(0, (sum, i) => sum + i.total);
          final totalMasc = items.fold(0, (sum, i) => sum + i.masculino);
          final totalFem = items.fold(0, (sum, i) => sum + i.feminino);

          if (items.isEmpty) {
            return _sectionCard(theme: theme, child: _emptyState(theme, 'Nenhum catequizando cadastrado'));
          }

          return Column(
            children: [
              // KPIs
              GridView.count(
                crossAxisCount: isWide ? 3 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 1.6 : 1.6,
                children: [
                  _KpiCard(theme: theme, icon: Icons.people_rounded,
                      value: '$total', label: 'Total', color: cs.primary),
                  _KpiCard(theme: theme, icon: Icons.male_rounded,
                      value: '$totalMasc', label: 'Masculino', color: const Color(0xFF2563EB)),
                  _KpiCard(theme: theme, icon: Icons.female_rounded,
                      value: '$totalFem', label: 'Feminino', color: const Color(0xFFDB2777)),
                ],
              ),
              const SizedBox(height: 20),

              // Card com tabela
              _sectionCard(
                theme: theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardHeader(theme, Icons.people_alt_rounded,
                        'Distribuição por Faixa Etária', '$total catequizandos cadastrados'),

                    // Tabela
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest.withOpacity(0.6)),
                              children: [
                                _tCell('Faixa', theme, header: true),
                                _tCell('Masc', theme, header: true, align: TextAlign.center),
                                _tCell('Fem', theme, header: true, align: TextAlign.center),
                                _tCell('Total', theme, header: true, align: TextAlign.center),
                              ],
                            ),
                            ...items.asMap().entries.map((entry) {
                              final item = entry.value;
                              final isEven = entry.key.isEven;
                              return TableRow(
                                decoration: BoxDecoration(
                                    color: isEven ? Colors.transparent : cs.surfaceContainerLowest),
                                children: [
                                  _tCell(item.faixa, theme),
                                  _tCell('${item.masculino}', theme, align: TextAlign.center,
                                      color: const Color(0xFF2563EB)),
                                  _tCell('${item.feminino}', theme, align: TextAlign.center,
                                      color: const Color(0xFFDB2777)),
                                  _tCell('${item.total}', theme, align: TextAlign.center, bold: true),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Barras de faixa
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _FaixaBar(item: item, total: total, theme: theme),
                    )),

                    // Legenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legenda(theme, const Color(0xFF2563EB), 'Masculino'),
                        const SizedBox(width: 20),
                        _legenda(theme, const Color(0xFFDB2777), 'Feminino'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _tCell(String text, ThemeData theme,
      {bool header = false, TextAlign align = TextAlign.left, bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: (header ? theme.textTheme.labelMedium : theme.textTheme.bodySmall)?.copyWith(
          fontWeight: header || bold ? FontWeight.w700 : FontWeight.w500,
          color: color ?? (header ? theme.colorScheme.onSurfaceVariant : null),
        ),
      ),
    );
  }

  Widget _legenda(ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _FaixaBar extends StatelessWidget {
  final FaixaEtariaCount item;
  final int total;
  final ThemeData theme;

  const _FaixaBar({required this.item, required this.total, required this.theme});

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? item.total / total : 0.0;
    final cs = theme.colorScheme;
    const colorMasc = Color(0xFF2563EB);
    const colorFem = Color(0xFFDB2777);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(item.faixa,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text('${item.total}',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${(percent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Barra segmentada masc/fem
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (item.masculino > 0)
                  Expanded(
                    flex: item.masculino,
                    child: Container(color: colorMasc),
                  ),
                if (item.masculino > 0 && item.feminino > 0)
                  const SizedBox(width: 2),
                if (item.feminino > 0)
                  Expanded(
                    flex: item.feminino,
                    child: Container(color: colorFem),
                  ),
                if (item.masculino == 0 && item.feminino == 0)
                  Expanded(child: Container(color: cs.surfaceContainerHighest)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (item.masculino > 0) ...[
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: colorMasc, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('${item.masculino} masc',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(width: 12),
            ],
            if (item.feminino > 0) ...[
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: colorFem, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('${item.feminino} fem',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ],
        ),
      ],
    );
  }
}
