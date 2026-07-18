import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/coordenador_model.dart';
import '../viewmodels/coordenador_viewmodel.dart';
import '../widgets/coordenador_reset_senha_bottom_sheet.dart';

class CoordenadorTable extends StatefulWidget {
  final List<Coordenador> coordenadores;
  final ThemeData theme;
  final CoordenadorViewModel vm;
  final void Function(Coordenador) onEdit;

  const CoordenadorTable({
    super.key,
    required this.coordenadores,
    required this.theme,
    required this.vm,
    required this.onEdit,
  });

  @override
  State<CoordenadorTable> createState() => _CoordenadorTableState();
}

class _CoordenadorTableState extends State<CoordenadorTable> {
  int _sortColumn = -1;
  bool _sortAscending = true;

  String _getSortKey(Coordenador c, int col) {
    switch (col) {
      case 1: return c.nome;
      case 2: return c.area;
      case 3: return c.status;
      case 4: return c.email;
      case 5: return c.telefone;
      default: return '';
    }
  }

  void _sort(int col) {
    setState(() {
      if (_sortColumn == col) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = col;
        _sortAscending = true;
      }
    });
  }

  List<Coordenador> get _sortedList {
    if (_sortColumn < 0) return widget.coordenadores;
    final sorted = List<Coordenador>.from(widget.coordenadores);
    sorted.sort((a, b) {
      final r = _getSortKey(a, _sortColumn).compareTo(_getSortKey(b, _sortColumn));
      return _sortAscending ? r : -r;
    });
    return sorted;
  }

  // Badge para o Status (Ativo / Inativo)
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

  // Badge personalizado para a Área de Coordenação
  Widget _buildAreaBadge(String area, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: colors.secondaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            area,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final sorted = _sortedList;

    return Card(
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
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1.6),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(2),
          6: FixedColumnWidth(80),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
          bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.2), width: 0.8),
        ),
        children: [
          // Cabeçalho unificado com cores suaves (Material 3)
          TableRow(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
            ),
            children: [
              const SizedBox.shrink(),
              _sortableHeader('Nome', Icons.person_outline_rounded, 1),
              _sortableHeader('Área', Icons.category_outlined, 2),
              _sortableHeader('Status', Icons.info_outline_rounded, 3),
              _sortableHeader('Email', Icons.mail_outline_rounded, 4),
              _sortableHeader('Telefone', Icons.phone_outlined, 5),
              _headerCell('Ações', Icons.touch_app_outlined),
            ],
          ),
          // Linhas de dados
          ...sorted.asMap().entries.map(
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
                  _buildAreaBadge(c.area, colors),
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
                  // Dropdown de ações
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz_rounded, color: colors.onSurfaceVariant),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (v) {
                      switch (v) {
                        case 'edit':
                          widget.onEdit(c);
                        case 'reset':
                          CoordenadorResetSenhaBottomSheet.show(context, widget.vm, c);
                        case 'delete':
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
                                'Deseja realmente excluir o coordenador "${c.nome}"? Esta ação não poderá ser desfeita.',
                                style: TextStyle(color: colors.onSurfaceVariant),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    widget.vm.removeCoordenador(c.id);
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
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: _menuItem(Icons.edit_outlined, 'Editar', colors.primary)),
                      PopupMenuItem(value: 'reset', child: _menuItem(Icons.key_rounded, 'Redefinir Senha', colors.tertiary)),
                      PopupMenuItem(value: 'delete', child: _menuItem(Icons.delete_outline_rounded, 'Excluir', colors.error)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sortableHeader(String label, IconData icon, int col) {
    final theme = widget.theme;
    final colorScheme = theme.colorScheme;
    final isActive = _sortColumn == col;
    final contentColor = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => _sort(col),
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
                _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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
    final theme = widget.theme;
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

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    final theme = widget.theme;
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