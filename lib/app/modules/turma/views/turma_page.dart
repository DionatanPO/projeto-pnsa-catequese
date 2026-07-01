import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';

void showNovaTurmaDialog(BuildContext context, TurmaViewModel vm) {
  final nomeCtrl = TextEditingController();
  final catequistaCtrl = TextEditingController();
  final horarioCtrl = TextEditingController();
  final catequizandosCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
                        child: Icon(Icons.group_add_rounded, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Nova Turma',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da turma', hintText: 'Ex: 1ª Eucaristia - A'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                    const SizedBox(height: 20),
                  TextFormField(
                    controller: catequistaCtrl,
                    decoration: const InputDecoration(labelText: 'Catequista', hintText: 'Ex: Maria José Silva'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                    const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: horarioCtrl,
                          decoration: const InputDecoration(labelText: 'Horário', hintText: 'Ex: Sábado 08:00'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: catequizandosCtrl,
                          decoration: const InputDecoration(labelText: 'Catequizandos', hintText: 'Ex: 20'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                            if (int.tryParse(v.trim()) == null) return 'Informe um número válido';
                            return null;
                          },
                        ),
                      ),
                    ],
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
                          vm.addTurma(TurmaModel(
                            nome: nomeCtrl.text.trim(),
                            catequista: catequistaCtrl.text.trim(),
                            horario: horarioCtrl.text.trim(),
                            totalCatequizandos: int.parse(catequizandosCtrl.text.trim()),
                          ));
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Salvar'),
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

class TurmaPage extends StatelessWidget {
  final TurmaViewModel vm;
  const TurmaPage({super.key, required this.vm});

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
              hintText: 'Buscar por nome, catequista ou horário...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: vm.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => vm.setSearch(''),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        GetBuilder<TurmaViewModel>(
          init: vm,
          id: 'turmas',
          builder: (_) {
            final list = vm.filteredTurmas;
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'Nenhuma turma encontrada',
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
                  return _TurmaListMobile(list: list, theme: theme);
                }
                return _TurmaTable(list: list, theme: theme);
              },
            );
          },
        ),
      ],
    );
  }
}

class _TurmaTable extends StatelessWidget {
  final List<TurmaModel> list;
  final ThemeData theme;

  const _TurmaTable({required this.list, required this.theme});

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
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FixedColumnWidth(90),
          4: FixedColumnWidth(100),
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
              _headerCell('Turma', Icons.group_rounded),
              _headerCell('Catequista', Icons.person_rounded),
              _headerCell('Horário', Icons.access_time_rounded),
              _headerCell('Alunos', Icons.people_rounded),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...list.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final t = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? theme.colorScheme.surfaceContainerLow.withOpacity(0.4)
                      : Colors.transparent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.menu_book_rounded, size: 16, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          t.nome,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  _bodyCell(t.catequista),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t.horario,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${t.totalCatequizandos}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                          fontSize: 13,
                        ),
                      ),
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
                            onPressed: () {},
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                            onPressed: () {},
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

class _TurmaListMobile extends StatelessWidget {
  final List<TurmaModel> list;
  final ThemeData theme;

  const _TurmaListMobile({required this.list, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: list
          .map(
            (t) => Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.nome,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text(t.catequista, style: theme.textTheme.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                const SizedBox(width: 4),
                                Text(t.horario, style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${t.totalCatequizandos}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 17,
                                  icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                                  onPressed: () {},
                                  tooltip: 'Editar',
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 17,
                                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                  onPressed: () {},
                                  tooltip: 'Excluir',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
