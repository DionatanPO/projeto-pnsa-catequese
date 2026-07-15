import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/catequista_model.dart';
import '../viewmodels/catequista_viewmodel.dart';

class CatequistaTable extends StatelessWidget {
  final List<Catequista> catequistas;
  final ThemeData theme;
  final CatequistaViewModel vm;
  final void Function(Catequista) onEdit;

  const CatequistaTable({
    super.key,
    required this.catequistas,
    required this.theme,
    required this.vm,
    required this.onEdit,
  });

  // Widget para criar badges de status profissionais (Ativo / Inativo)
  Widget _buildStatusBadge(String status, ColorScheme colors) {
    final isActive = status.toLowerCase() == 'ativo' || status.toLowerCase() == 'ativa';
    final bgColor = isActive 
        ? colors.primaryContainer.withOpacity(0.3) 
        : colors.errorContainer.withOpacity(0.25);
    final textColor = isActive 
        ? colors.primary 
        : colors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            0: FlexColumnWidth(0.6),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1.6),
            3: FlexColumnWidth(2.5),
            4: FlexColumnWidth(2),
            5: FixedColumnWidth(96),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
            bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
          ),
          children: [
            // Linha de Cabeçalho com paleta suave
            TableRow(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
              ),
              children: [
                const SizedBox.shrink(),
                _sortableHeader('Nome', Icons.person_outline_rounded, 1),
                _sortableHeader('Status', Icons.info_outline_rounded, 2),
                _sortableHeader('Email', Icons.mail_outline_rounded, 3),
                _sortableHeader('Telefone', Icons.phone_outlined, 4),
                _headerCell('Ações', Icons.touch_app_outlined),
              ],
            ),
            // Linhas de dados
            ...catequistas.asMap().entries.map(
              (entry) {
                final i = entry.key;
                final c = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: i.isOdd
                        ? colors.surfaceContainerLowest.withOpacity(0.5)
                        : Colors.transparent,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: colors.primaryContainer.withOpacity(0.4),
                        child: Text(
                          c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                    _bodyCell(c.nome, isBold: true),
                    _buildStatusBadge(c.status, colors),
                    _bodyCell(c.email),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: colors.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              c.telefone,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Coluna de ações com botões discretos e dialog atualizado
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.edit_outlined, size: 18, color: colors.primary),
                              onPressed: () => onEdit(c),
                              tooltip: 'Editar',
                            ),
                          ),
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.delete_outline_rounded, size: 18, color: colors.error),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: colors.error, size: 28),
                                        const SizedBox(width: 12),
                                        const Text('Confirmar Exclusão'),
                                      ],
                                    ),
                                    content: Text(
                                      'Deseja realmente excluir "${c.nome}"? Esta ação não poderá ser desfeita.',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          vm.removeCatequista(c.id);
                                          Get.back();
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: colors.error,
                                          foregroundColor: colors.onError,
                                        ),
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

  Widget _sortableHeader(String label, IconData icon, int col) {
    final isActive = vm.sortColumn.value == col;
    final colorScheme = theme.colorScheme;
    final contentColor = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => vm.sortBy(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: contentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
                color: contentColor,
                letterSpacing: 0.3,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
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

class PaginationControls extends StatelessWidget {
  final CatequistaViewModel vm;
  const PaginationControls({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final total = vm.totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: vm.currentPage.value > 0 ? vm.prevPage : null,
        ),
        const SizedBox(width: 8),
        ...List.generate(total, (i) {
          final isCurrent = i == vm.currentPage.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: isCurrent
                ? FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: const Size(38, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
          );
        }),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: vm.currentPage.value < total - 1 ? vm.nextPage : null,
        ),
      ],
    );
  }
}