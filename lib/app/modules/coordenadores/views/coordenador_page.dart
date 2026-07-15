import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/coordenador_viewmodel.dart';
import '../models/coordenador_model.dart';
import 'coordenador_form.dart';
import 'coordenador_table.dart';

void showCoordenadorDialog(BuildContext context, CoordenadorViewModel vm, {Coordenador? coordenador}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 560.0 : screenWidth > 600 ? 480.0 : screenWidth * 0.92;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: CoordenadorForm(coordenador: coordenador, vm: vm, width: dialogWidth),
    ),
  );
}

void showNovaCoordenadorDialog(BuildContext context, CoordenadorViewModel vm) {
  showCoordenadorDialog(context, vm);
}

class CoordenadorPage extends StatelessWidget {
  final CoordenadorViewModel vm;
  const CoordenadorPage({super.key, required this.vm});

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
              hintText: 'Buscar coordenador por nome ou área...',
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
          final list = vm.filteredCoordenadores;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Nenhum coordenador encontrado',
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
                return Column(
                  children: list.map((c) => _CoordenadorCard(coordenador: c, theme: theme, vm: vm)).toList(),
                );
              }
              return CoordenadorTable(
                coordenadores: list,
                theme: theme,
                vm: vm,
                onEdit: (c) => showCoordenadorDialog(context, vm, coordenador: c),
              );
            },
          );
        }),
      ],
    );
  }
}

class _CoordenadorCard extends StatelessWidget {
  final Coordenador coordenador;
  final ThemeData theme;
  final CoordenadorViewModel vm;

  const _CoordenadorCard({required this.coordenador, required this.theme, required this.vm});

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
                  coordenador.nome[0].toUpperCase(),
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
                      coordenador.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                      Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(Icons.work_outline_rounded, coordenador.area, theme),
                        _infoChip(Icons.email_outlined, coordenador.email, theme),
                        _infoChip(Icons.info_outline_rounded, coordenador.status, theme),
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
                          coordenador.telefone,
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
                      _smallIconButton(Icons.edit_outlined, theme.colorScheme.primary, 'Editar', () => showCoordenadorDialog(context, vm, coordenador: coordenador)),
                      const SizedBox(width: 4),
                      _smallIconButton(Icons.delete_outline, theme.colorScheme.error, 'Excluir', () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Confirmar Exclusão'),
                            content: Text('Deseja excluir "${coordenador.nome}"?'),
                            actions: [
                              TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                              FilledButton(
                                onPressed: () {
                                  vm.removeCoordenador(coordenador.id);
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


