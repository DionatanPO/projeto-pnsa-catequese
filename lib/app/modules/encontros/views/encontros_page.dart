import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../models/encontro_model.dart';
import '../viewmodels/encontros_viewmodel.dart';
import '../widgets/chamada_bottom_sheet.dart';
import '../widgets/editar_encontro_bottom_sheet.dart';

void showEditarEncontroDialog(BuildContext context, Encontro encontro, String turmaNome, EncontrosViewModel encontrosVm) {
  showEditarEncontroBottomSheet(context, encontro, turmaNome, encontrosVm);
}

const _monthsShort = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

class EncontrosPage extends StatelessWidget {
  final EncontrosViewModel encontrosVm;
  final RxList<TurmaModel> turmas;
  final CatequizandoViewModel catequizandoVm;

  const EncontrosPage({
    super.key,
    required this.encontrosVm,
    required this.turmas,
    required this.catequizandoVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    encontrosVm.rebuildList(turmas);

    return GetBuilder<EncontrosViewModel>(
      init: encontrosVm,
      id: 'encontros',
      builder: (_) {
        final grouped = encontrosVm.encontrosAgrupadosPorTurma;
        final totalEncontros = encontrosVm.totalEncontrosFiltrados;
        final hasSearch = encontrosVm.searchQuery.value.isNotEmpty;

        return Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Obx(() => TextField(
                onChanged: encontrosVm.setSearch,
                decoration: AppTheme.searchInputDecoration(
                  colorScheme,
                  hintText: 'Buscar encontros...',
                  suffixIcon: encontrosVm.searchQuery.value.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => encontrosVm.setSearch(''))
                      : null,
                ),
              )),
              const SizedBox(height: 16),
              Expanded(
                child: totalEncontros == 0
                    ? _buildEmptyState(
                        theme: theme,
                        icon: hasSearch ? Icons.search_off_rounded : Icons.calendar_today_outlined,
                        title: hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum encontro registrado',
                        subtitle: hasSearch
                            ? 'Tente ajustar o termo de busca.'
                            : 'Clique em "Novo" para criar o primeiro encontro.',
                      )
                    : ListView(
                        children: [
                          if (hasSearch) _buildResultSummary(totalEncontros, theme),
                          ...grouped.entries.map((entry) => _TurmaEncontrosSection(
                            turmaNome: entry.key,
                            encontros: entry.value,
                            encontrosVm: encontrosVm,
                            catequizandoVm: catequizandoVm,
                          )),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildResultSummary(int total, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$total encontro${total != 1 ? 's' : ''} encontrado${total != 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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

class _TurmaEncontrosSection extends StatelessWidget {
  final String turmaNome;
  final List<({Encontro encontro, String turmaNome})> encontros;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const _TurmaEncontrosSection({
    required this.turmaNome,
    required this.encontros,
    required this.encontrosVm,
    required this.catequizandoVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  turmaNome,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${encontros.length} encontro${encontros.length != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: encontros.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _EncontroCard(
            item: encontros[i],
            encontrosVm: encontrosVm,
            catequizandoVm: catequizandoVm,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EncontroCard extends StatelessWidget {
  final ({Encontro encontro, String turmaNome}) item;
  final EncontrosViewModel encontrosVm;
  final CatequizandoViewModel catequizandoVm;

  const _EncontroCard({
    required this.item,
    required this.encontrosVm,
    required this.catequizandoVm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final e = item.encontro;
    final chamadas = encontrosVm.chamadaRepo.getByEncontro(e.id);
    final temChamada = chamadas.isNotEmpty;

    final cardColor = temChamada
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFFDE7);
    final borderColor = temChamada
        ? const Color(0xFFA5D6A7).withOpacity(0.5)
        : const Color(0xFFFFF176).withOpacity(0.4);
    final dateColor = temChamada ? const Color(0xFF4CAF50) : const Color(0xFFF9A825);
    final dateBg = temChamada ? const Color(0xFFC8E6C9) : const Color(0xFFFFF9C4);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => ChamadaBottomSheet.show(context, e, item.turmaNome, encontrosVm, catequizandoVm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: dateBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text('${e.data.day}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: dateColor)),
                        Text(_monthsShort[e.data.month - 1], style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: dateColor, fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: dateBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(item.turmaNome, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: temChamada ? const Color(0xFFA5D6A7).withOpacity(0.5) : const Color(0xFFFFF176).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    temChamada ? Icons.check_circle_rounded : Icons.pending_rounded,
                                    size: 10,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    temChamada ? 'Chamada' : 'Pendente',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_horiz_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                              onSelected: (v) {
                                if (v == 'edit') showEditarEncontroDialog(context, e, item.turmaNome, encontrosVm);
                                if (v == 'delete') {
                                  bool deleting = false;
                                  Get.dialog(
                                    StatefulBuilder(
                                      builder: (ctx, setDialogState) => AlertDialog(
                                        title: const Text('Excluir Encontro'),
                                        content: Text('Deseja excluir o encontro de '
                                            '${e.data.day.toString().padLeft(2, '0')}/'
                                            '${e.data.month.toString().padLeft(2, '0')}/'
                                            '${e.data.year}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: deleting ? null : () => Get.back(),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            onPressed: deleting
                                                ? null
                                                : () async {
                                                    setDialogState(() => deleting = true);
                                                    try {
                                                      await encontrosVm.removerEncontro(e);
                                                      if (ctx.mounted) Navigator.of(ctx).pop();
                                                    } finally {
                                                      setDialogState(() => deleting = false);
                                                    }
                                                  },
                                            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                                            child: deleting
                                                ? SizedBox(
                                                    width: 18, height: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: colorScheme.onError,
                                                    ),
                                                  )
                                                : const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Excluir')])),
                              ],
                            ),
                          ],
                        ),
                        if (e.descricao.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(e.descricao, style: theme.textTheme.bodySmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ],
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
}
