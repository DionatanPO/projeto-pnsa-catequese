import 'package:flutter/material.dart';

class CalendarioInline extends StatefulWidget {
  final DateTime dataSelecionada;
  final ValueChanged<DateTime> onDataChanged;
  final String? turmaId;
  final List<DateTime>? encontrosExistentes;
  final List<DateTime>? feriados;

  const CalendarioInline({
    super.key,
    required this.dataSelecionada,
    required this.onDataChanged,
    this.turmaId,
    this.encontrosExistentes,
    this.feriados,
  });

  @override
  State<CalendarioInline> createState() => _CalendarioInlineState();
}

class _CalendarioInlineState extends State<CalendarioInline> {
  late DateTime _mesAtual;

  @override
  void initState() {
    super.initState();
    _mesAtual = DateTime(widget.dataSelecionada.year, widget.dataSelecionada.month);
  }

  void _mesAnterior() {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1);
    });
  }

  void _proximoMes() {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1);
    });
  }

  bool _isMesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isHoje(DateTime d) {
    final now = DateTime.now();
    return _isMesmoDia(d, now);
  }

  bool _temEncontro(DateTime d) {
    return widget.encontrosExistentes?.any((e) => _isMesmoDia(e, d)) ?? false;
  }

  bool _isFeriado(DateTime d) {
    return widget.feriados?.any((f) => _isMesmoDia(f, d)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final diasSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final primeiroDia = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final ultimoDia = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
    final diasNoMes = ultimoDia.day;
    final offsetInicial = primeiroDia.weekday % 7;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(cs, theme),
          _buildDiasSemana(diasSemana, cs, theme),
          _buildGrid(offsetInicial, diasNoMes, cs, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, ThemeData theme) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 24),
            onPressed: _mesAnterior,
            tooltip: 'Mês anterior',
            style: IconButton.styleFrom(
              foregroundColor: cs.primary,
              backgroundColor: cs.primaryContainer,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${meses[_mesAtual.month - 1]} ${_mesAtual.year}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 24),
            onPressed: _proximoMes,
            tooltip: 'Próximo mês',
            style: IconButton.styleFrom(
              foregroundColor: cs.primary,
              backgroundColor: cs.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiasSemana(List<String> dias, ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: dias.map((d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildGrid(int offset, int diasNoMes, ColorScheme cs, ThemeData theme) {
    final linhas = <Widget>[];
    int dia = 1;

    for (int semana = 0; semana < 6; semana++) {
      final cells = <Widget>[];
      for (int d = 0; d < 7; d++) {
        if (semana == 0 && d < offset) {
          cells.add(const SizedBox());
        } else if (dia <= diasNoMes) {
          final data = DateTime(_mesAtual.year, _mesAtual.month, dia);
          final selecionado = _isMesmoDia(data, widget.dataSelecionada);
          final hoje = _isHoje(data);
          final temEncontro = _temEncontro(data);
          final feriado = _isFeriado(data);
          final passou = data.isBefore(DateTime.now().subtract(const Duration(days: 1)));

          cells.add(_buildDia(
            data,
            dia,
            selecionado,
            hoje,
            temEncontro,
            feriado,
            passou,
            cs,
            theme,
          ));
          dia++;
        } else {
          cells.add(const SizedBox());
        }
      }
      linhas.add(Row(children: cells.map((c) => Expanded(child: c)).toList()));
      if (dia > diasNoMes) break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(children: linhas),
    );
  }

  Widget _buildDia(
    DateTime data,
    int dia,
    bool selecionado,
    bool hoje,
    bool temEncontro,
    bool feriado,
    bool passou,
    ColorScheme cs,
    ThemeData theme,
  ) {
    final bgColor = selecionado
        ? cs.primary
        : hoje
            ? cs.primaryContainer.withOpacity(0.5)
            : Colors.transparent;

    final fgColor = selecionado
        ? cs.onPrimary
        : passou
            ? cs.onSurfaceVariant.withOpacity(0.4)
            : cs.onSurface;

    final borderColor = temEncontro && !selecionado
        ? cs.error
        : feriado && !selecionado
            ? cs.tertiary
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: passou ? null : () => widget.onDataChanged(data),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor, width: 2)
                : null,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$dia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fgColor,
                    fontWeight: selecionado || hoje ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (temEncontro && !selecionado)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (feriado && !selecionado && !temEncontro)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (hoje && !selecionado)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}