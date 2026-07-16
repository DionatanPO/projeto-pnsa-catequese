import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/catequista_viewmodel.dart';
import '../models/catequista_model.dart';
import '../widgets/catequista_form_bottom_sheet.dart';
import 'catequista_table.dart';

void showCatequistaDialog(BuildContext context, CatequistaViewModel vm, {Catequista? catequista}) {
  CatequistaFormBottomSheet.show(context, vm, catequista: catequista);
}

void showNovaCatequistaDialog(BuildContext context, CatequistaViewModel vm) {
  CatequistaFormBottomSheet.show(context, vm);
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
            decoration: AppTheme.searchInputDecoration(
              theme.colorScheme,
              hintText: 'Buscar catequista por nome...',
              suffixIcon: vm.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => vm.setSearch(''),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final list = vm.paginatedCatequistas;
          if (list.isEmpty) {
            return _buildEmptyState(
              theme: theme,
              icon: vm.searchQuery.value.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.person_outline_rounded,
              title: vm.searchQuery.value.isNotEmpty
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhum catequista cadastrado',
              subtitle: vm.searchQuery.value.isNotEmpty
                  ? 'Tente ajustar o termo de busca.'
                  : 'Clique no botão "+" para adicionar o primeiro catequista.',
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
              return CatequistaTable(
                catequistas: list,
                theme: theme,
                vm: vm,
                onEdit: (c) => showCatequistaDialog(context, vm, catequista: c),
              );
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (vm.totalPages <= 1) return const SizedBox.shrink();
          return PaginationControls(vm: vm);
        }),
      ],
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
                        _infoChip(Icons.cake_outlined, catequista.dataNascimento.isNotEmpty ? catequista.dataNascimento : 'Sem data', theme),
                        _infoChip(Icons.favorite_outline, catequista.casado ? 'Casado(a)' : 'Solteiro(a)', theme),
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


