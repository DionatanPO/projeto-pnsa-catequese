import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../viewmodels/coordenador_viewmodel.dart';
import '../models/coordenador_model.dart';

void showCoordenadorDialog(BuildContext context, CoordenadorViewModel vm, {Coordenador? coordenador}) {
  final isEditing = coordenador != null;
  final nomeCtrl = TextEditingController(text: coordenador?.nome ?? '');
  final emailCtrl = TextEditingController(text: coordenador?.email ?? '');
  final telefoneCtrl = TextEditingController(text: coordenador?.telefone ?? '');
  final areaCtrl = TextEditingController(text: coordenador?.area ?? '');
  final formKey = GlobalKey<FormState>();

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 560.0 : screenWidth > 600 ? 480.0 : screenWidth * 0.92;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: formKey,
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(isEditing ? Icons.edit_rounded : Icons.person_add_rounded, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Editar Coordenador' : 'Novo Coordenador',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome', hintText: 'Nome completo'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'E-mail', hintText: 'email@pnsa.com'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextFormField(
                            controller: telefoneCtrl,
                            decoration: const InputDecoration(labelText: 'Telefone', hintText: '(62) 99999-9999'),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [phoneMask],
                            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                          ),

                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: areaCtrl,
                    decoration: const InputDecoration(labelText: 'Área', hintText: 'Ex: Catequese Infantil'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final model = Coordenador(
                            id: coordenador?.id ?? DateTime.now().toString(),
                            nome: nomeCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            telefone: telefoneCtrl.text.trim(),
                            area: areaCtrl.text.trim(),
                          );
                          if (isEditing) {
                            vm.updateCoordenador(model);
                          } else {
                            vm.addCoordenador(model);
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: Text(isEditing ? 'Salvar Alterações' : 'Salvar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            decoration: InputDecoration(
              hintText: 'Buscar coordenador por nome ou área...',
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
              return _CoordenadorTable(coordenadores: list, theme: theme, vm: vm);
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

class _CoordenadorTable extends StatelessWidget {
  final List<Coordenador> coordenadores;
  final ThemeData theme;
  final CoordenadorViewModel vm;

  const _CoordenadorTable({required this.coordenadores, required this.theme, required this.vm});

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
          2: FlexColumnWidth(2),
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
              _headerCell('Nome', Icons.person_rounded),
              _headerCell('Área', Icons.work_outline_rounded),
              _headerCell('Email', Icons.email_rounded),
              _headerCell('Telefone', Icons.phone_rounded),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...coordenadores.asMap().entries.map(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.area,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
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
                            onPressed: () => showCoordenadorDialog(context, vm, coordenador: c),
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
                                        vm.removeCoordenador(c.id);
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

  Padding _headerCell(String label, IconData icon) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: isBold
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            : theme.textTheme.bodyMedium,
      ),
    );
  }
}
