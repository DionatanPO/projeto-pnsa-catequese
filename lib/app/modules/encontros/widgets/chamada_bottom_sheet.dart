import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../models/chamada_model.dart';
import '../viewmodels/encontros_viewmodel.dart';

class ChamadaBottomSheet extends StatefulWidget {
  final Encontro encontro;
  final String turmaNome;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const ChamadaBottomSheet({
    super.key,
    required this.encontro,
    required this.turmaNome,
    required this.encontrosVm,
    required this.catequizandoVm,
  });

  static void show(BuildContext context, Encontro encontro, String turmaNome,
      EncontrosViewModel encontrosVm, CatequizandoViewModel catequizandoVm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChamadaBottomSheet(
        encontro: encontro,
        turmaNome: turmaNome,
        encontrosVm: encontrosVm,
        catequizandoVm: catequizandoVm,
      ),
    );
  }

  @override
  State<ChamadaBottomSheet> createState() => _ChamadaBottomSheetState();
}

class _ChamadaBottomSheetState extends State<ChamadaBottomSheet> {
  final _searchCtrl = TextEditingController();
  final _presencas = <String, bool>{};
  final _salvando = false.obs;
  Timer? _debounce;

  List<Catequizando> get _catequizandos {
    final turmaVm = Get.find<TurmaViewModel>();
    return turmaVm.alunosDaTurma(widget.encontro.turmaId, widget.catequizandoVm.catequizandos);
  }

  List<Catequizando> get _filtrados {
    var list = _catequizandos;

    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((c) =>
        c.nome.toLowerCase().contains(q) ||
        c.responsavel.toLowerCase().contains(q)
      ).toList();
    }

    return list;
  }

  int get _totalPresentes => _presencas.values.where((v) => v).length;
  int get _totalCatequizandos => _catequizandos.length;

  @override
  void initState() {
    super.initState();

    final chamadas = widget.encontrosVm.chamadaRepo.getByEncontro(widget.encontro.id);
    for (final c in _catequizandos) {
      final ch = chamadas.firstWhereOrNull((ch) => ch.catequizandoId == c.id);
      _presencas[c.id] = ch?.presente ?? true;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _salvar() async {
    _salvando.value = true;
    try {
      final chamadas = _presencas.entries
          .map((e) => Chamada(id: '', encontroId: '', catequizandoId: e.key, presente: e.value))
          .toList();
      await widget.encontrosVm.salvarFrequencias(
        widget.encontro.turmaId,
        widget.encontro.data,
        chamadas,
        descricao: widget.encontro.descricao,
      );
      if (context.mounted) Navigator.pop(context);
    } finally {
      _salvando.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isWide ? 560 : double.infinity,
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
          _buildHandle(cs),
          _buildHeader(cs, theme),
          _buildInfoRow(cs, theme),
          _buildDescricaoReadonly(cs, theme),
          _buildSearch(cs, theme),
          _buildList(cs, theme),
          _buildFooter(cs, theme),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: cs.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.checklist_rounded, color: cs.onPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chamada', style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.bold)),
                Text(widget.turmaNome, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$_totalCatequizandos catequizandos',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(_fmt(widget.encontro.data), style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface, fontWeight: FontWeight.w600)),
          if (widget.encontro.descricao.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(width: 4, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.encontro.descricao, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescricaoReadonly(ColorScheme cs, ThemeData theme) {
    if (widget.encontro.descricao.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.encontro.descricao,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 200), () => setState(() {}));
        },
        decoration: InputDecoration(
          hintText: 'Buscar catequizando...',
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.primary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () { _searchCtrl.clear(); setState(() {}); })
              : null,
          filled: true,
          fillColor: cs.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          isDense: true,
        ),
      ),
    );
  }



  Widget _buildList(ColorScheme cs, ThemeData theme) {
    final list = _filtrados;
    return Expanded(
      child: list.isEmpty
          ? Center(
              child: Text(
                _searchCtrl.text.isNotEmpty ? 'Nenhum catequizando encontrado' : 'Nenhum catequizando nesta turma',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final c = list[i];
                final presente = _presencas[c.id] ?? true;
                return _CatequizandoCard(
                  catequizando: c,
                  presente: presente,
                  saving: _salvando.value,
                  onToggle: () {
                    setState(() => _presencas[c.id] = !presente);
                  },
                );
              },
            ),
    );
  }

  Widget _buildFooter(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          
          final statusWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$_totalPresentes / $_totalCatequizandos presentes',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

          final actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _salvando.value ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _salvando.value ? null : _salvar,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _salvando.value
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(_salvando.value ? 'Salvando...' : 'Salvar Chamada'),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statusWidget,
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _salvando.value ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _salvando.value ? null : _salvar,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _salvando.value
                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                            : const Icon(Icons.save_rounded, size: 18),
                        label: Text(_salvando.value ? 'Salvando...' : 'Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: statusWidget),
              const SizedBox(width: 16),
              actionsWidget,
            ],
          );
        },
      ),
    );
  }
}

class _CatequizandoCard extends StatelessWidget {
  final Catequizando catequizando;
  final bool presente;
  final bool saving;
  final VoidCallback onToggle;

  const _CatequizandoCard({
    required this.catequizando,
    required this.presente,
    required this.saving,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: presente ? cs.outlineVariant.withOpacity(0.3) : cs.error.withOpacity(0.4),
          width: presente ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: saving ? null : onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: presente ? cs.primaryContainer : cs.errorContainer,
                child: Text(
                  catequizando.nome.trim().isNotEmpty ? catequizando.nome.trim()[0].toUpperCase() : '?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: presente ? cs.onPrimaryContainer : cs.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(catequizando.nome, style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: presente ? cs.onSurface : cs.onSurface,
                    ), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('${catequizando.parentesco}: ${catequizando.responsavel}',
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: presente
                    ? Icon(Icons.check_circle_rounded, key: const ValueKey(true), color: cs.primary, size: 26)
                    : Icon(Icons.cancel_rounded, key: const ValueKey(false), color: cs.error, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}