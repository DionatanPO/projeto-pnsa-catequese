import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../models/turma_model.dart';
import '../viewmodels/turma_viewmodel.dart';

class GerenciarTurmaPage extends StatefulWidget {
  final TurmaModel turma;

  const GerenciarTurmaPage({super.key, required this.turma});

  @override
  State<GerenciarTurmaPage> createState() => _GerenciarTurmaPageState();
}

class _GerenciarTurmaPageState extends State<GerenciarTurmaPage> {
  late final MatriculaViewModel matriculaVm;
  late final CatequizandoViewModel catequizandoVm;
  final _selectedIds = <String>{};
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    matriculaVm = Get.find<MatriculaViewModel>();
    catequizandoVm = Get.find<CatequizandoViewModel>();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Catequizando> get _catequizandosNaTurma {
    var list = matriculaVm.getAlunosDaTurma(widget.turma.id, catequizandoVm.catequizandos);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((a) =>
        a.nome.toLowerCase().contains(q) ||
        a.responsavel.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  List<Catequizando> get _catequizandosFora {
    final idsNaTurma = _catequizandosNaTurma.map((a) => a.id).toSet();
    return catequizandoVm.catequizandos.where((a) => !idsNaTurma.contains(a.id)).toList();
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _catequizandosNaTurma.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_catequizandosNaTurma.map((a) => a.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isWide = MediaQuery.sizeOf(context).width > 900;
    final catequizandos = _catequizandosNaTurma;
    final selectMode = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: _buildAppBar(theme, colors, isWide, catequizandos, selectMode),
      body: isWide
          ? _buildWideLayout(theme, colors, catequizandos, selectMode)
          : _buildNarrowLayout(theme, colors, catequizandos, selectMode),
      bottomNavigationBar: selectMode
          ? Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [_buildSelectionBar(theme, colors)])
          : (!isWide ? Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [_buildBottomBar(theme, colors)]) : null),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    ColorScheme colors,
    bool isWide,
    List<Catequizando> catequizandos,
    bool selectMode,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: isWide ? colors.surfaceContainerLow : colors.surface,
      title: isWide
          ? const Text('Gerenciamento de Turma', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.turma.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${catequizandos.length} catequizando(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton.icon(
            onPressed: _toggleSelectAll,
            icon: Icon(
              _selectedIds.length == catequizandos.length ? Icons.deselect_rounded : Icons.select_all_rounded,
              size: 18,
            ),
            label: Text(
              _selectedIds.length == catequizandos.length ? 'Limpar Seleção' : 'Selecionar Todos',
            ),
          ),
        ),
      ],
    );
  }

  // Layout para telas amplas (Desktop / Web / Tablets horizontais)
  Widget _buildWideLayout(ThemeData theme, ColorScheme colors, List<Catequizando> catequizandos, bool selectMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Painel Lateral (Detalhes e Informações)
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border(right: BorderSide(color: colors.outlineVariant.withOpacity(0.3))),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTurmaSidebarInfo(theme, colors, catequizandos),
              const Spacer(),
              if (_catequizandosFora.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _showAdicionarDialog,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Adicionar Catequizando'),
                  ),
                ),
            ],
          ),
        ),
        // Painel Principal (Busca e Grade de Catequizandos)
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: _buildSearchBar(theme, colors, padding: EdgeInsets.zero),
              ),
              Expanded(
                child: _buildGradeCatequizandos(theme, colors, catequizandos),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout para telas menores (Dispositivos móveis)
  Widget _buildNarrowLayout(ThemeData theme, ColorScheme colors, List<Catequizando> catequizandos, bool selectMode) {
    return Column(
      children: [
        _buildTurmaHeader(theme, colors),
        _buildSearchBar(theme, colors),
        Expanded(child: _buildListaCatequizandos(theme, colors, catequizandos)),
      ],
    );
  }

  Widget _buildTurmaSidebarInfo(ThemeData theme, ColorScheme colors, List<Catequizando> catequizandos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.turma.nome,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.turma.status == 'Ativa'
                ? colors.primaryContainer.withOpacity(0.5)
                : colors.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.turma.status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.turma.status == 'Ativa' ? colors.primary : colors.error,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _sidebarDetailItem(Icons.person_outline_rounded, 'Catequistas', widget.turma.catequistas.join(', '), colors),
        const SizedBox(height: 16),
        _sidebarDetailItem(Icons.schedule_outlined, 'Dia e Horário', widget.turma.diaHorario, colors),
        const SizedBox(height: 16),
        _sidebarDetailItem(Icons.school_outlined, 'Etapa atual', widget.turma.etapa, colors),
        const SizedBox(height: 16),
        _sidebarDetailItem(Icons.group_outlined, 'Total de Catequizandos', '${catequizandos.length} cadastrado(s)', colors),
      ],
    );
  }

  Widget _sidebarDetailItem(IconData icon, String label, String value, ColorScheme colors) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant.withOpacity(0.6)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTurmaHeader(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.3))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _infoChip(Icons.person_outline_rounded, widget.turma.catequistas.join(', '), colors),
            const SizedBox(width: 12),
            _infoChip(Icons.schedule_outlined, widget.turma.diaHorario, colors),
            const SizedBox(width: 12),
            _infoChip(Icons.school_outlined, widget.turma.etapa, colors),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.turma.status == 'Ativa'
                    ? colors.primaryContainer.withOpacity(0.5)
                    : colors.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.turma.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.turma.status == 'Ativa' ? colors.primary : colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colors, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: AppTheme.searchInputDecoration(
          colors,
          hintText: 'Buscar catequizando...',
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  // Visualização adaptativa para listas em Mobile
  Widget _buildListaCatequizandos(ThemeData theme, ColorScheme colors, List<Catequizando> catequizandos) {
    if (catequizandos.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: catequizandos.length,
        itemBuilder: (_, i) => _buildCardCatequizando(theme, colors, catequizandos[i]),
      ),
    );
  }

  // Visualização em Grade Adaptativa para Desktops e Tablets
  Widget _buildGradeCatequizandos(ThemeData theme, ColorScheme colors, List<Catequizando> catequizandos) {
    if (catequizandos.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 380,
          mainAxisExtent: 140,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: catequizandos.length,
        itemBuilder: (_, i) => _buildCardCatequizando(theme, colors, catequizandos[i]),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
            child: Column(
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: colors.onSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'Nenhum catequizando encontrado' : 'Nenhum catequizando nesta turma',
            style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Cartão do catequizando com visual refinado e interações
  Widget _buildCardCatequizando(ThemeData theme, ColorScheme colors, Catequizando a) {
    final selected = _selectedIds.contains(a.id);
    final tempoMeses = matriculaVm.mesesNaTurmaAtual(a.id);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: selected ? colors.primaryContainer.withOpacity(0.15) : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant.withOpacity(0.4),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() {
          if (selected) {
            _selectedIds.remove(a.id);
          } else {
            _selectedIds.add(a.id);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selectedIds.add(a.id);
                  } else {
                    _selectedIds.remove(a.id);
                  }
                }),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 20,
                backgroundColor: selected
                    ? colors.primaryContainer
                    : colors.secondaryContainer.withOpacity(0.5),
                child: Text(
                  a.nome.isNotEmpty ? a.nome[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selected ? colors.onPrimaryContainer : colors.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      a.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: _studentDetail(Icons.phone_rounded, a.telefone, colors)),
                        const SizedBox(width: 8),
                        _studentDetail(Icons.cake_rounded, '${a.idade} anos', colors),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _studentDetail(Icons.person_rounded, a.responsavel, colors, faded: true)),
                        if (tempoMeses != null) ...[
                          const SizedBox(width: 8),
                          _studentDetail(Icons.timer_outlined, '$tempoMeses meses', colors),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(a.status, colors),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (v) => _handleStudentAction(v, a),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'concluir',
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
                      title: Text('Concluir', style: TextStyle(fontSize: 13)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'transferir',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz_rounded, size: 18),
                      title: Text('Transferir', style: TextStyle(fontSize: 13)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'remover',
                    child: ListTile(
                      leading: Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 18),
                      title: Text('Remover da turma', style: TextStyle(fontSize: 13, color: Colors.red)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentDetail(IconData icon, String label, ColorScheme colors, {bool faded = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: faded ? colors.onSurfaceVariant.withOpacity(0.4) : colors.onSurfaceVariant.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: faded ? colors.onSurfaceVariant.withOpacity(0.5) : colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colors) {
    final isActive = status == 'Em Andamento';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? colors.primaryContainer.withOpacity(0.4) : colors.errorContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? colors.primary : colors.error),
      ),
    );
  }

  void _handleStudentAction(String action, Catequizando a) {
    switch (action) {
      case 'concluir':
        _showConcluirDialog([a]);
      case 'transferir':
        _showTransferirDialog(a);
      case 'remover':
        matriculaVm.desmatricular(a.id);
        setState(() => _selectedIds.remove(a.id));
    }
  }

  // Painel Flutuante Inferior de Ações de seleção (Mobile e Desktop)
  Widget _buildSelectionBar(ThemeData theme, ColorScheme colors) {
    final selectedObjs = _catequizandosNaTurma.where((a) => _selectedIds.contains(a.id)).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text('${_selectedIds.length}'),
                backgroundColor: colors.primaryContainer,
                labelStyle: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(' selecionado(s)', style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              )),
              const SizedBox(width: 12),
              _selectionAction(Icons.swap_horiz_rounded, 'Transferir', () {
                final vm = Get.find<TurmaViewModel>();
                _showTransferirMultiDialog(selectedObjs, vm.turmas);
              }, colors),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Cancelar',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedIds.clear()),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Barra de ações comuns para Mobile
  Widget _buildBottomBar(ThemeData theme, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: FilledButton.icon(
            onPressed: _catequizandosFora.isNotEmpty ? () => _showAdicionarDialog() : null,
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: const Text('Adicionar Catequizando', style: TextStyle(fontSize: 14)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectionAction(
    IconData icon,
    String label,
    VoidCallback onPressed,
    ColorScheme colors, {
    Color? color,
    bool isDestructive = false,
  }) {
    final bg = isDestructive ? colors.error : (color ?? colors.secondaryContainer);
    final fg = isDestructive ? colors.onError : (color ?? colors.onSecondaryContainer);
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  void _showConcluirDialog(List<Catequizando> catequizandos) {
    final isSingle = catequizandos.length == 1;
    String? selectedTurmaId;
    final turmaVm = Get.find<TurmaViewModel>();
    final outrasTurmas = turmaVm.turmas.where((t) => t.id != widget.turma.id && t.status == 'Ativa').toList();

    Get.dialog(StatefulBuilder(
      builder: (context, setState) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(isSingle ? 'Concluir Catequizando' : 'Concluir Catequizandos'),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSingle
                      ? '${catequizandos.first.nome} concluiu esta etapa/turma.'
                      : '${catequizandos.length} catequizandos concluíram esta etapa/turma.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTurmaId,
                  decoration: const InputDecoration(
                    labelText: 'Transferir para a próxima turma (opcional)',
                    prefixIcon: Icon(Icons.auto_stories_rounded),
                  ),
                  items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                  onChanged: (v) => setState(() => selectedTurmaId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: () async {
                for (final c in catequizandos) {
                  if (selectedTurmaId != null) {
                    await matriculaVm.matricular(c.id, selectedTurmaId!);
                  } else {
                    await matriculaVm.concluir(c.id);
                  }
                }
                if (context.mounted) Get.back();
                this.setState(() => _selectedIds.clear());
              },
              icon: Icon(selectedTurmaId != null ? Icons.swap_horiz_rounded : Icons.check_circle_outline_rounded, size: 16),
              label: Text(selectedTurmaId != null ? 'Concluir e Transferir' : 'Concluir'),
            ),
          ],
        );
      },
    ));
  }

  void _showTransferirDialog(Catequizando catequizando) {
    String? selectedTurmaId;
    final turmaVm = Get.find<TurmaViewModel>();
    final outrasTurmas = turmaVm.turmas.where((t) => t.id != widget.turma.id && t.status == 'Ativa').toList();

    Get.dialog(StatefulBuilder(
      builder: (context, setState) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 28),
              SizedBox(width: 12),
              Text('Transferir Catequizando'),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${catequizando.nome} será transferido para:',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTurmaId,
                  decoration: const InputDecoration(
                    labelText: 'Turma de destino',
                    prefixIcon: Icon(Icons.auto_stories_rounded),
                  ),
                  items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                  onChanged: (v) => setState(() => selectedTurmaId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: selectedTurmaId == null
                  ? null
                  : () async {
                      await matriculaVm.matricular(catequizando.id, selectedTurmaId!);
                      if (context.mounted) Get.back();
                      this.setState(() => _selectedIds.remove(catequizando.id));
                    },
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text('Transferir'),
            ),
          ],
        );
      },
    ));
  }

  void _showTransferirMultiDialog(List<Catequizando> catequizandos, List<TurmaModel> todasTurmas) {
    String? selectedTurmaId;
    final outrasTurmas = todasTurmas.where((t) => t.id != widget.turma.id && t.status == 'Ativa').toList();

    Get.dialog(StatefulBuilder(
      builder: (context, setState) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 28, color: colors.primary),
              const SizedBox(width: 12),
              Text('Transferir ${catequizandos.length} catequizandos'),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Os catequizandos selecionados serão transferidos para:',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTurmaId,
                  decoration: const InputDecoration(
                    labelText: 'Turma de destino',
                    prefixIcon: Icon(Icons.auto_stories_rounded),
                  ),
                  items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                  onChanged: (v) => setState(() => selectedTurmaId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: selectedTurmaId == null
                  ? null
                  : () async {
                      for (final c in catequizandos) {
                        await matriculaVm.matricular(c.id, selectedTurmaId!);
                      }
                      if (context.mounted) Get.back();
                      this.setState(() => _selectedIds.clear());
                    },
              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
              label: const Text('Transferir'),
            ),
          ],
        );
      },
    ));
  }

  void _showAdicionarDialog() {
    final tempSelected = <String>{};
    final todasTurmas = Get.find<TurmaViewModel>().turmas;

    Get.dialog(StatefulBuilder(
      builder: (context, setState) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_add_rounded, color: colors.primary, size: 28),
              const SizedBox(width: 12),
              const Text('Adicionar Catequizandos'),
            ],
          ),
          content: Container(
            width: 480,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: colors.tertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Os catequizandos selecionados serão matriculados nesta turma. Caso já estejam em outra turma ativa, a matrícula anterior será concluída automaticamente.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onTertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _catequizandosFora.isEmpty
                ? const Center(child: Text('Nenhum catequizando disponível para matrícula'))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _catequizandosFora.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = _catequizandosFora[i];
                      final sel = tempSelected.contains(a.id);
                      final turmaAtual = matriculaVm.getNomeTurmaAtual(a.id, todasTurmas);
                      return CheckboxListTile(
                        value: sel,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            tempSelected.add(a.id);
                          } else {
                            tempSelected.remove(a.id);
                          }
                        }),
                        title: Text(a.nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${a.idade} anos', style: Theme.of(context).textTheme.bodySmall),
                            if (turmaAtual != null)
                              Row(
                                children: [
                                  Icon(Icons.menu_book_rounded, size: 12, color: colors.onSurfaceVariant.withOpacity(0.5)),
                                  const SizedBox(width: 4),
                                  Flexible(child: Text(turmaAtual, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant.withOpacity(0.7)))),
                                ],
                              ),
                          ],
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: colors.secondaryContainer.withOpacity(0.5),
                          child: Text(
                            a.nome.isNotEmpty ? a.nome[0].toUpperCase() : '?',
                            style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSecondaryContainer),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
            FilledButton.icon(
              onPressed: tempSelected.isEmpty
                  ? null
                  : () async {
                      for (final id in tempSelected) {
                        await matriculaVm.matricular(id, widget.turma.id);
                      }
                      if (context.mounted) Get.back();
                      this.setState(() {});
                    },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Adicionar (${tempSelected.length})'),
            ),
          ],
        );
      },
    ));
  }
}
