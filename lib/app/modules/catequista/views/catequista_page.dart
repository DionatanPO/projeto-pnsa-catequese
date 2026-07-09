import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/catequista_viewmodel.dart';
import '../models/catequista_model.dart';
import 'catequista_form.dart';

void showCatequistaDialog(BuildContext context, CatequistaViewModel vm, {Catequista? catequista}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 560.0 : screenWidth > 600 ? 480.0 : screenWidth * 0.92;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: CatequistaForm(catequista: catequista, vm: vm, width: dialogWidth),
    ),
  );
}

void showNovaCatequistaDialog(BuildContext context, CatequistaViewModel vm) {
  showCatequistaDialog(context, vm);
}

class CatequistaPage extends StatelessWidget {
  final CatequistaViewModel vm;
  const CatequistaPage({super.key, required this.vm});

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
            decoration: InputDecoration(
              hintText: 'Buscar catequista por nome...',
              prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
              suffixIcon: vm.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => vm.setSearch(''),
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final list = vm.paginatedCatequistas;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Nenhum catequista encontrado',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _CatequistaCard(catequista: list[i], theme: theme, vm: vm),
                );
              }
              return _CatequistaTable(catequistas: list, theme: theme, vm: vm);
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (vm.totalPages <= 1) return const SizedBox.shrink();
          return _PaginationControls(vm: vm);
        }),
      ],
    );
  }
}

class _CatequistaCard extends StatelessWidget {
  final Catequista catequista;
  final ThemeData theme;
  final CatequistaViewModel vm;

  const _CatequistaCard({required this.catequista, required this.theme, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  catequista.nome[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catequista.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(Icons.email_outlined, catequista.email, theme),
                        _infoChip(Icons.info_outline_rounded, catequista.status, theme),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined, size: 12, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          catequista.telefone,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _smallIconButton(Icons.edit_outlined, theme.colorScheme.primary, 'Editar', () => showCatequistaDialog(context, vm, catequista: catequista)),
                      const SizedBox(width: 4),
                      _smallIconButton(Icons.delete_outline, theme.colorScheme.error, 'Excluir', () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: Text('Deseja excluir "${catequista.nome}"?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                              FilledButton(
                                onPressed: () {
                                  vm.removeCatequista(catequista.id);
                                  Get.back();
                                },
                                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _smallIconButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 17,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

class _CatequistaTable extends StatelessWidget {
  final List<Catequista> catequistas;
  final ThemeData theme;
  final CatequistaViewModel vm;

  const _CatequistaTable({required this.catequistas, required this.theme, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.6),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2.5),
          4: FlexColumnWidth(2),
          5: FixedColumnWidth(90),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
              ),
            ),
            children: [
              const SizedBox.shrink(),
              _sortableHeader('Nome', Icons.person_rounded, 1),
              _sortableHeader('Status', Icons.info_outline_rounded, 2),
              _sortableHeader('Email', Icons.email_rounded, 3),
              _sortableHeader('Telefone', Icons.phone_rounded, 4),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...catequistas.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final c = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? theme.colorScheme.surfaceContainerLow.withOpacity(0.4)
                      : Colors.transparent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        c.nome[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  _bodyCell(c.nome, isBold: true),
                  _bodyCell(c.status),
                  _bodyCell(c.email),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.primary.withOpacity(0.6)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            c.telefone,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                            onPressed: () => showCatequistaDialog(context, vm, catequista: c),
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text('Deseja excluir "${c.nome}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        vm.removeCatequista(c.id);
                                        Get.back();
                                      },
                                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
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
    );
  }

  Widget _sortableHeader(String label, IconData icon, int col) {
    final isActive = vm.sortColumn.value == col;
    return InkWell(
      onTap: () => vm.sortBy(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                vm.sortAscending.value ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: isBold
            ? t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            : t.textTheme.bodyMedium,
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final CatequistaViewModel vm;
  const _PaginationControls({required this.vm});

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
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: isCurrent
                ? FilledButton(
                    onPressed: null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(36, 36),
                    ),
                    child: Text('${i + 1}'),
                  )
                : OutlinedButton(
                    onPressed: () => vm.goToPage(i),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(36, 36),
                    ),
                    child: Text('${i + 1}'),
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
