import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';

// Mapeamento de status para cores Material mais suaves e modernas
Color turmaStatusColor(String status) {
  switch (status) {
    case 'Ativa':
      return Colors.green.shade700;
    case 'Concluída':
      return Colors.blue.shade700;
    case 'Suspensa':
      return Colors.amber.shade800;
    default:
      return Colors.grey.shade600;
  }
}

class TurmaCard extends StatelessWidget {
  final TurmaModel turma;
  final ThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TurmaCard({
    super.key,
    required this.turma,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final corStatus = turmaStatusColor(turma.status);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone Identificador da Turma
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book_rounded, color: colors.primary),
            ),
            const SizedBox(width: 14),
            // Informações da Turma
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          turma.nome,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge de Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: corStatus.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: corStatus,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              turma.status,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: corStatus,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: colors.onSurfaceVariant.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          turma.catequista, 
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined, size: 13, color: colors.onSurfaceVariant.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          turma.diaHorario, 
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Quantidade de alunos e Ações
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge de quantidade de catequizandos matriculados
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${Get.find<MatriculaViewModel>().totalAlunosNaTurma(turma.id)} alunos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cardActionButton(Icons.edit_outlined, colors.primary, onEdit, 'Editar'),
                    _cardActionButton(Icons.delete_outline_rounded, colors.error, onDelete, 'Excluir'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardActionButton(IconData icon, Color color, VoidCallback onPressed, String tooltip) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

class TurmaTable extends StatelessWidget {
  final List<TurmaModel> list;
  final ThemeData theme;
  final TurmaViewModel vm;
  final void Function(TurmaModel) onManage;
  final void Function(TurmaModel) onEdit;
  final void Function(TurmaModel) onDelete;

  const TurmaTable({
    super.key,
    required this.list,
    required this.theme,
    required this.vm,
    required this.onManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    return Obx(
      () => Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant.withOpacity(0.3)),
        ),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.6),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.6),
            3: FlexColumnWidth(1.2),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(2.2),
            6: FixedColumnWidth(120),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
            bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
          ),
          children: [
            // Cabeçalho Neutro Material 3
            TableRow(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
              ),
              children: [
                _sortableHeader('Turma', Icons.groups_outlined, 0),
                _sortableHeader('Catequista', Icons.person_outline_rounded, 1),
                _sortableHeader('Horário', Icons.schedule_outlined, 2),
                _sortableHeader('Status', Icons.info_outline_rounded, 3),
                _sortableHeader('Alunos', Icons.people_outline_rounded, 4),
                _sortableHeader('Observações', Icons.description_outlined, 5),
                _headerCell('Ações', Icons.touch_app_outlined),
              ],
            ),
            // Linhas de dados
            ...list.asMap().entries.map(
              (entry) {
                final i = entry.key;
                final t = entry.value;
                final corStatus = turmaStatusColor(t.status);

                return TableRow(
                  decoration: BoxDecoration(
                    color: i.isOdd
                        ? colors.surfaceContainerLowest.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                  children: [
                    // Coluna Turma
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.menu_book_rounded, size: 16, color: colors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.nome,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _bodyCell(t.catequista),
                    _bodyCell(t.diaHorario),
                    // Badge de Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: corStatus.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: corStatus,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.status,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: corStatus,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Coluna de contagem de alunos matriculados
                    _bodyCell('${Get.find<MatriculaViewModel>().totalAlunosNaTurma(t.id)}', isBold: true),
                    // Coluna de observações
                    _bodyCell(
                      t.observacoes != null && t.observacoes!.isNotEmpty ? t.observacoes! : '-',
                      maxLines: 2,
                    ),
                    // Botões de ação da linha
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tableActionButton(
                            Icons.people_outline_rounded,
                            colors.tertiary,
                            () => onManage(t),
                            'Ver Catequizandos',
                          ),
                          _tableActionButton(
                            Icons.edit_outlined,
                            colors.primary,
                            () => onEdit(t),
                            'Editar',
                          ),
                          _tableActionButton(
                            Icons.delete_outline_rounded,
                            colors.error,
                            () => onDelete(t),
                            'Excluir',
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
      ),
    );
  }

  Widget _tableActionButton(IconData icon, Color color, VoidCallback onPressed, String tooltip) {
    return SizedBox(
      width: 36,
      height: 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _sortableHeader(String label, IconData icon, int col) {
    final colorScheme = theme.colorScheme;
    final isActive = vm.sortColumn.value == col;
    final contentColor = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => vm.sortBy(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: contentColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                  color: contentColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                vm.sortAscending.value ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14,
                color: contentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false, int? maxLines}) {
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        style: isBold
            ? theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              )
            : theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
      ),
    );
  }
}

class TurmaPagination extends StatelessWidget {
  final TurmaViewModel vm;
  const TurmaPagination({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final total = vm.totalPages;
      final current = vm.currentPage.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: current > 0 ? vm.prevPage : null,
          ),
          const SizedBox(width: 8),
          ...List.generate(total, (i) {
            final isCurrent = i == current;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: isCurrent
                  ? FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(38, 38),
                        backgroundColor: colors.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => vm.goToPage(i),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(38, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                          color: colors.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: current < total - 1 ? vm.nextPage : null,
          ),
        ],
      );
    });
  }
}