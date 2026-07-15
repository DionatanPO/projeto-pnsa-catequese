import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';

// Paleta de status suavizada e profissional
Color catequizandoStatusColor(String status) {
  switch (status) {
    case 'Em Andamento':
      return Colors.blue.shade700;
    case 'Formado':
      return Colors.green.shade700;
    case 'Desistente':
      return Colors.red.shade700;
    case 'Transferido':
      return Colors.amber.shade800;
    case 'Inativo':
      return Colors.grey.shade600;
    default:
      return Colors.grey.shade600;
  }
}

class CatequizandoCard extends StatelessWidget {
  final Catequizando aluno;
  final ThemeData theme;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;
  final VoidCallback onHistorico;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDocumentos;
  final VoidCallback onExportar;

  const CatequizandoCard({
    super.key,
    required this.aluno,
    required this.theme,
    this.turmas = const [],
    required this.matriculaVm,
    required this.onHistorico,
    required this.onEdit,
    required this.onDelete,
    required this.onDocumentos,
    required this.onExportar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final turmaNome = matriculaVm.getNomeTurmaAtual(aluno.id, turmas) ?? '';
    final tempoLongo = matriculaVm.getTemTempoLongo(aluno.id);
    final corStatus = catequizandoStatusColor(aluno.status);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.secondaryContainer.withOpacity(0.4),
              child: Text(
                aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aluno.nome,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Badge de Turma / Alerta de Tempo Longo
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded, 
                            size: 13,
                            color: tempoLongo ? Colors.orange.shade800 : colors.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              turmaNome,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tempoLongo ? Colors.orange.shade800 : colors.onSurfaceVariant,
                                fontWeight: tempoLongo ? FontWeight.bold : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tempoLongo) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.schedule_rounded, size: 13, color: Colors.orange.shade800),
                          ],
                        ],
                      ),
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
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: corStatus),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              aluno.status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: corStatus,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _infoChip(Icons.person_outline_rounded, aluno.responsavel, theme),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Idade Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${aluno.idade} anos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Ações (dropdown)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz_rounded,
                      color: theme.colorScheme.onSurfaceVariant, size: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  onSelected: (value) {
                    switch (value) {
                      case 'historico': onHistorico(); break;
                      case 'editar': onEdit(); break;
                      case 'exportar': onExportar(); break;
                      case 'documentos': onDocumentos(); break;
                      case 'excluir': onDelete(); break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'historico', child: _menuItem(Icons.history_rounded, 'Histórico', colors.tertiary)),
                    PopupMenuItem(value: 'editar', child: _menuItem(Icons.edit_outlined, 'Editar', colors.primary)),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'exportar', child: _menuItem(Icons.download_rounded, 'Exportar Dados', colors.primary)),
                    PopupMenuItem(value: 'documentos', child: _menuItem(Icons.folder_outlined, 'Documentos', colors.tertiary)),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'excluir', child: _menuItem(Icons.delete_outline_rounded, 'Excluir', colors.error)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label, 
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CatequizandoTable extends StatefulWidget {
  final List<Catequizando> alunos;
  final ThemeData theme;
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;
  final void Function(Catequizando) onHistorico;
  final void Function(Catequizando) onEdit;
  final void Function(Catequizando) onDelete;
  final void Function(Catequizando) onDocumentos;
  final void Function(Catequizando) onExportar;

  const CatequizandoTable({
    super.key,
    required this.alunos,
    required this.theme,
    required this.vm,
    this.turmas = const [],
    required this.matriculaVm,
    required this.onHistorico,
    required this.onEdit,
    required this.onDelete,
    required this.onDocumentos,
    required this.onExportar,
  });

  @override
  State<CatequizandoTable> createState() => _CatequizandoTableState();
}

class _CatequizandoTableState extends State<CatequizandoTable> {
  void _sort(int col) {
    widget.vm.sortBy(col);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final alunos = widget.alunos;

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
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1.6),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(2),
            5: FixedColumnWidth(80),
            6: FixedColumnWidth(168),
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
                const SizedBox.shrink(),
                _sortableHeader('Nome', Icons.person_outline_rounded, 1),
                _sortableHeader('Turma', Icons.menu_book_rounded, 2),
                _sortableHeader('Status', Icons.info_outline_rounded, 3),
                _sortableHeader('Responsável', Icons.assignment_ind_outlined, 4),
                _sortableHeader('Idade', Icons.cake_outlined, 5),
                _headerCell('Ações', Icons.touch_app_outlined),
              ],
            ),
            // Linhas de dados
            ...alunos.asMap().entries.map(
              (entry) {
                final i = entry.key;
                final a = entry.value;
                final tempoLongo = widget.matriculaVm.getTemTempoLongo(a.id);

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
                        backgroundColor: colors.secondaryContainer.withOpacity(0.4),
                        child: Text(
                          a.nome.isNotEmpty ? a.nome[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.secondary,
                          ),
                        ),
                      ),
                    ),
                    _bodyCell(a.nome, isBold: true),
                    // Badge da Turma com suporte a Tempo Longo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: tempoLongo
                                ? Colors.orange.withOpacity(0.15)
                                : colors.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.matriculaVm.getNomeTurmaAtual(a.id, widget.turmas) ?? '',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: tempoLongo ? Colors.orange.shade800 : colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tempoLongo) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.schedule_rounded, size: 12, color: Colors.orange.shade800),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badge de Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: catequizandoStatusColor(a.status).withOpacity(0.12),
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
                                  color: catequizandoStatusColor(a.status),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                a.status,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: catequizandoStatusColor(a.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Telefone / Contato
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: colors.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              a.telefone,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Idade
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${a.idade}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onTertiaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Ações da linha (dropdown)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz_rounded, color: colors.onSurfaceVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        onSelected: (value) {
                          switch (value) {
                            case 'historico': widget.onHistorico(a); break;
                            case 'editar': widget.onEdit(a); break;
                            case 'exportar': widget.onExportar(a); break;
                            case 'documentos': widget.onDocumentos(a); break;
                            case 'excluir': widget.onDelete(a); break;
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'historico', child: _menuItem(Icons.history_rounded, 'Histórico', colors.tertiary)),
                          PopupMenuItem(value: 'editar', child: _menuItem(Icons.edit_outlined, 'Editar', colors.primary)),
                          const PopupMenuDivider(),
                          PopupMenuItem(value: 'exportar', child: _menuItem(Icons.download_rounded, 'Exportar Dados', colors.primary)),
                          PopupMenuItem(value: 'documentos', child: _menuItem(Icons.folder_outlined, 'Documentos', colors.tertiary)),
                          const PopupMenuDivider(),
                          PopupMenuItem(value: 'excluir', child: _menuItem(Icons.delete_outline_rounded, 'Excluir', colors.error)),
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
    final theme = widget.theme;
    final colorScheme = theme.colorScheme;
    final isActive = widget.vm.sortColumn.value == col;
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
                widget.vm.sortAscending.value ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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

class CatequizandoPagination extends StatelessWidget {
  final CatequizandoViewModel vm;
  final ThemeData theme;

  const CatequizandoPagination({super.key, required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
    });
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
      pages.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('...', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ));
    }

    for (var i = start; i < end; i++) {
      pages.add(_pageChip(i, current));
    }

    if (end < total) {
      pages.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('...', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ));
      pages.add(_pageChip(total - 1, current));
    }

    return pages;
  }

  Widget _pageChip(int page, int current) {
    final isActive = page == current;
    final colors = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 38,
        height: 38,
        child: isActive
            ? FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: colors.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(38, 38),
                ),
                child: Text(
                  '${page + 1}',
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: () => vm.goToPage(page),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(38, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: colors.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${page + 1}',
                  style: TextStyle(
                    fontSize: 13, 
                    color: colors.onSurface,
                  ),
                ),
              ),
      ),
    );
  }
}

Widget _menuItem(IconData icon, String label, Color color) {
  return Row(
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(color: color, fontSize: 13)),
    ],
  );
}
