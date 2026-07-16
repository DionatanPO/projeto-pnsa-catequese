import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';
import '../widgets/turma_form_bottom_sheet.dart';
import 'turma_table.dart';
import 'gerenciar_turma_page.dart';

void showTransferirDialog(BuildContext context, Catequizando catequizando, TurmaModel turmaAtual, List<TurmaModel> todasTurmas) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final matriculaVm = Get.find<MatriculaViewModel>();
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                      child: Icon(Icons.swap_horiz_rounded, color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transferir Catequizando', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                          Text(catequizando.nome, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turma atual:', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma',
                        hintText: 'Selecione a turma de destino',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                      validator: (v) => v == null ? 'Selecione uma turma' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A matrícula atual será marcada como "Transferida" e uma nova matrícula será criada na turma de destino.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: selectedTurmaId == null
                          ? null
                          : () {
                              matriculaVm.transferir(catequizando.id, selectedTurmaId!);
                              Navigator.of(ctx).pop();
                            },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Transferir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool> showTransferirDialogMulti(BuildContext context, List<Catequizando> catequizandos, TurmaModel turmaAtual, List<TurmaModel> todasTurmas, MatriculaViewModel matriculaVm) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();
  final count = catequizandos.length;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                      child: Icon(Icons.swap_horiz_rounded, color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transferir Catequizandos', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                          Text('$count catequizando(s) selecionado(s)', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turma atual:', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma',
                        hintText: 'Selecione a turma de destino',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                      validator: (v) => v == null ? 'Selecione uma turma' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'As matrículas atuais serão marcadas como "Transferida" e novas matrículas serão criadas na turma de destino.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: selectedTurmaId == null
                          ? null
                          : () async {
                              for (final c in catequizandos) {
                                await matriculaVm.transferir(c.id, selectedTurmaId!);
                              }
                              if (ctx.mounted) Navigator.of(ctx).pop(true);
                            },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Transferir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

void showConcluirComTransferenciaDialog(
  BuildContext context,
  List<Catequizando> catequizandos,
  TurmaModel turmaAtual,
  List<TurmaModel> todasTurmas,
  MatriculaViewModel matriculaVm, {
  VoidCallback? onDone,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isSingle = catequizandos.length == 1;
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSingle ? 'Concluir Catequizando' : 'Concluir Catequizandos',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            isSingle ? catequizandos.first.nome : '${catequizandos.length} catequizando(s)',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSingle
                          ? 'O catequizando concluiu esta turma. Deseja transferi-lo para outra turma?'
                          : 'Os catequizandos concluíram esta turma. Deseja transferi-los para outra turma?',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSingle
                          ? 'Deseja transferi-lo para outra turma?'
                          : 'Deseja transferi-los para outra turma?',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma (opcional)',
                        hintText: 'Selecione para transferir',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedTurmaId != null
                                  ? 'A matrícula atual será concluída e uma nova será criada na turma de destino.'
                                  : 'Selecione uma turma acima para transferir, ou clique em "Concluir" para apenas encerrar a matrícula.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
                        for (final c in catequizandos) {
                          if (selectedTurmaId != null) {
                            await matriculaVm.matricular(c.id, selectedTurmaId!);
                          } else {
                            await matriculaVm.concluir(c.id);
                          }
                        }
                        onDone?.call();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      icon: Icon(
                        selectedTurmaId != null ? Icons.swap_horiz_rounded : Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(selectedTurmaId != null ? 'Concluir e Transferir' : 'Concluir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showTurmaDialog(BuildContext context, TurmaViewModel vm, {TurmaModel? turma}) {
  TurmaFormBottomSheet.show(context, vm, turma: turma);
}

void showNovaTurmaDialog(BuildContext context, TurmaViewModel vm) {
  TurmaFormBottomSheet.show(context, vm);
}

class TurmaPage extends StatelessWidget {
  final TurmaViewModel vm;
  final CatequizandoViewModel catequizandoVm;
  const TurmaPage({super.key, required this.vm, required this.catequizandoVm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        const SizedBox(height: 16),
        Obx(
          () => TextField(
            onChanged: vm.setSearch,
            decoration: AppTheme.searchInputDecoration(
              theme.colorScheme,
              hintText: 'Buscar por nome, catequista ou horário...',
              suffixIcon: vm.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => vm.setSearch(''),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filtros Rápidos (Chips)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final cs = theme.colorScheme;
            final currentStatus = vm.filterStatus.value;
            return Row(
              children: [
                _buildFilterChip(
                  label: 'Todas',
                  isSelected: currentStatus == 'Todos',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Todos';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: cs.primary,
                ),
                _buildFilterChip(
                  label: 'Ativas',
                  isSelected: currentStatus == 'Ativa',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Ativa';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.green.shade700,
                ),
                _buildFilterChip(
                  label: 'Inativas',
                  isSelected: currentStatus == 'Inativa',
                  onSelected: (_) {
                    vm.filterStatus.value = 'Inativa';
                    vm.currentPage.value = 0;
                  },
                  theme: theme,
                  activeColor: Colors.grey.shade600,
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 16),

        Obx(() {
          final list = vm.paginatedTurmas;
          if (list.isEmpty) {
            final hasFilter = vm.searchQuery.value.isNotEmpty || vm.filterStatus.value != 'Todos';
            return _buildEmptyState(
              theme: theme,
              icon: hasFilter ? Icons.search_off_rounded : Icons.school_outlined,
              title: hasFilter ? 'Nenhum resultado encontrado' : 'Nenhuma turma cadastrada',
              subtitle: hasFilter
                  ? 'Tente ajustar os filtros ou o termo de busca.'
                  : 'Clique no botão "+" para adicionar a primeira turma.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final t = list[i];
                    return TurmaCard(
                      turma: t,
                      theme: theme,
                      onEdit: () => showTurmaDialog(context, vm, turma: t),
                      onDelete: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: Text('Deseja excluir a turma "${t.nome}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar')),
                              FilledButton(
                                onPressed: () {
                                  vm.removeTurma(t.id);
                                  Get.back();
                                },
                                style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return TurmaTable(
                list: list,
                theme: theme,
                vm: vm,
                onManage: (t) => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GerenciarTurmaPage(turma: t)),
                ),
                onEdit: (t) => showTurmaDialog(context, vm, turma: t),
                onDelete: (t) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Confirmar Exclusão'),
                      content: Text('Deseja excluir a turma "${t.nome}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancelar')),
                        FilledButton(
                          onPressed: () {
                            vm.removeTurma(t.id);
                            Get.back();
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (vm.totalPages <= 1) return const SizedBox.shrink();
          return TurmaPagination(vm: vm);
        }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    required ThemeData theme,
    required Color activeColor,
  }) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : cs.onSurfaceVariant,
        ),
        selectedColor: activeColor,
        backgroundColor: cs.surfaceContainerHighest.withOpacity(0.4),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? activeColor : cs.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
