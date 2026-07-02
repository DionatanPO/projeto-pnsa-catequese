import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';
void showGerenciarCatequizandosDialog(BuildContext context, TurmaModel turma, CatequizandoViewModel catequizandoVm) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final catequizandosDaTurma = catequizandoVm.catequizandos.where((a) => a.turmaNome == turma.nome).toList();
  final catequizandosFora = catequizandoVm.catequizandos.where((a) => a.turmaNome != turma.nome).toList();

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 650),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.people_rounded, color: colorScheme.onPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gerenciar Catequizandos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${turma.nome} — ${catequizandosDaTurma.length} catequizandos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (catequizandosDaTurma.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Nenhum catequizando nesta turma')),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: catequizandosDaTurma.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final catequizando = catequizandosDaTurma[i];
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: colorScheme.secondaryContainer,
                                  child: Text(
                                    catequizando.nome.trim().isNotEmpty
                                        ? catequizando.nome.trim()[0].toUpperCase()
                                        : '?',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        catequizando.nome,
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            catequizando.telefone,
                                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.remove_circle_outline, size: 20, color: colorScheme.error),
                                    onPressed: () {
                                      final updated = Catequizando(
                                        id: catequizando.id,
                                        nome: catequizando.nome,
                                        sexo: catequizando.sexo,
                                        dataNascimento: catequizando.dataNascimento,
                                        turmaNome: '',
                                        batizado: catequizando.batizado,
                                        localBatismo: catequizando.localBatismo,
                                        fezPrimeiraEucaristia: catequizando.fezPrimeiraEucaristia,
                                        responsavel: catequizando.responsavel,
                                        parentesco: catequizando.parentesco,
                                        telefone: catequizando.telefone,
                                        cep: catequizando.cep,
                                        endereco: catequizando.endereco,
                                        numero: catequizando.numero,
                                        bairro: catequizando.bairro,
                                        possuiRestricao: catequizando.possuiRestricao,
                                        detalheRestricao: catequizando.detalheRestricao,
                                        aceiteTermos: catequizando.aceiteTermos,
                                        assinaturaResponsavel: catequizando.assinaturaResponsavel,
                                        dataAssinatura: catequizando.dataAssinatura,
                                        documentosAnexados: catequizando.documentosAnexados,
                                      );
                                      catequizandoVm.updateCatequizando(updated);
                                      setState(() {
                                        catequizandosDaTurma.removeAt(i);
                                      });
                                    },
                                    tooltip: 'Remover da turma',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
                  ),
                  child: Row(
                    children: [
                      if (catequizandosFora.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: ctx,
                              builder: (ctx2) {
                                final selecionados = <String>{};

                                return StatefulBuilder(
                                  builder: (context2, setState2) => Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    insetPadding: const EdgeInsets.all(16),
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: colorScheme.surface,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                              gradient: LinearGradient(
                                                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.onPrimary.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(Icons.person_add_rounded, color: colorScheme.onPrimary, size: 24),
                                                ),
                                                const SizedBox(width: 16),
                                                Text(
                                                  'Adicionar Catequizandos',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: colorScheme.onPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (catequizandosFora.isEmpty)
                                              const Expanded(
                                                child: Center(child: Text('Nenhum catequizando disponível')),
                                            )
                                          else
                                            Expanded(
                                              child: ListView.separated(
                                                padding: const EdgeInsets.all(16),
                                                itemCount: catequizandosFora.length,
                                                separatorBuilder: (_, __) => const Divider(height: 1),
                                                itemBuilder: (_, i) {
                                                  final a = catequizandosFora[i];
                                                  final selected = selecionados.contains(a.id);
                                                  return CheckboxListTile(
                                                    value: selected,
                                                    onChanged: (v) {
                                                      setState2(() {
                                                        if (v == true) {
                                                          selecionados.add(a.id);
                                                        } else {
                                                          selecionados.remove(a.id);
                                                        }
                                                      });
                                                    },
                                                    title: Text(a.nome, style: const TextStyle(fontSize: 14)),
                                                    subtitle: Text(a.responsavel, style: theme.textTheme.bodySmall),
                                                    secondary: CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: colorScheme.secondaryContainer,
                                                      child: Text(
                                                        a.nome[0].toUpperCase(),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: colorScheme.onSecondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                                            decoration: BoxDecoration(
                                              border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3))),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx2).pop(),
                                                  child: const Text('Cancelar'),
                                                ),
                                                const SizedBox(width: 12),
                                                FilledButton.icon(
                                                  onPressed: () {
                                                    for (final id in selecionados) {
                                                      final original = catequizandoVm.catequizandos.firstWhere((a) => a.id == id);
                                                      final updated = Catequizando(
                                                        id: original.id,
                                                        nome: original.nome,
                                                        sexo: original.sexo,
                                                        dataNascimento: original.dataNascimento,
                                                        turmaNome: turma.nome,
                                                        batizado: original.batizado,
                                                        localBatismo: original.localBatismo,
                                                        fezPrimeiraEucaristia: original.fezPrimeiraEucaristia,
                                                        responsavel: original.responsavel,
                                                        parentesco: original.parentesco,
                                                        telefone: original.telefone,
                                                        cep: original.cep,
                                                        endereco: original.endereco,
                                                        numero: original.numero,
                                                        bairro: original.bairro,
                                                        possuiRestricao: original.possuiRestricao,
                                                        detalheRestricao: original.detalheRestricao,
                                                        aceiteTermos: original.aceiteTermos,
                                                        assinaturaResponsavel: original.assinaturaResponsavel,
                                                        dataAssinatura: original.dataAssinatura,
                                                        documentosAnexados: original.documentosAnexados,
                                                      );
                                                      catequizandoVm.updateCatequizando(updated);
                                                    }
                                                    Navigator.of(ctx2).pop();
                                                    Navigator.of(ctx).pop();
                                                    showGerenciarCatequizandosDialog(context, turma, catequizandoVm);
                                                  },
                                                  icon: const Icon(Icons.add_rounded, size: 18),
                                                  label: Text('Adicionar (${selecionados.length})'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text('Adicionar Catequizando'),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void showTurmaDialog(BuildContext context, TurmaViewModel vm, {TurmaModel? turma}) {
  final isEditing = turma != null;
  
  final nomeCtrl = TextEditingController(text: turma?.nome ?? '');
  final anoCtrl = TextEditingController(text: turma?.ano.toString() ?? '');
  final etapaCtrl = TextEditingController(text: turma?.etapa ?? '');
  final diaHorarioCtrl = TextEditingController(text: turma?.diaHorario ?? '');
  final localSalaCtrl = TextEditingController(text: turma?.localSala ?? '');
  final capacidadeCtrl = TextEditingController(text: turma?.capacidade.toString() ?? '');
  final observacoesCtrl = TextEditingController(text: turma?.observacoes ?? '');
  
  // Lista fictícia de catequistas - idealmente viria do seu ViewModel/Backend
  final List<String> catequistas = ['Maria José Silva', 'João Pereira', 'Ana Souza'];
  final List<String> statusOptions = ['Ativa', 'Concluída', 'Suspensa'];

  String? selectedCatequista = catequistas.contains(turma?.catequista) ? turma!.catequista : null;
  String selectedStatus = turma?.status ?? 'Ativa';

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
                        child: Icon(
                          isEditing ? Icons.edit_rounded : Icons.group_add_rounded, 
                          color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Editar Turma' : 'Nova Turma',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da turma', hintText: 'Ex: Turma A'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: anoCtrl,
                          decoration: const InputDecoration(labelText: 'Ano Letivo', hintText: 'Ex: 2026'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: etapaCtrl,
                          decoration: const InputDecoration(labelText: 'Etapa', hintText: 'Ex: Eucaristia'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCatequista,
                    decoration: const InputDecoration(labelText: 'Catequista', hintText: 'Selecione o catequista'),
                    items: catequistas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => selectedCatequista = v,
                    validator: (v) => v == null ? 'Selecione um catequista' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: diaHorarioCtrl,
                    decoration: const InputDecoration(labelText: 'Dia e Horário', hintText: 'Ex: Sábados, 08:00'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: localSalaCtrl,
                          decoration: const InputDecoration(labelText: 'Local/Sala', hintText: 'Ex: Sala 01'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: capacidadeCtrl,
                          decoration: const InputDecoration(labelText: 'Quantidade', hintText: 'Ex: 25'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => selectedStatus = v!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: observacoesCtrl,
                    decoration: const InputDecoration(labelText: 'Observações'),
                    maxLines: 3,
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
                          final model = TurmaModel(
                            id: turma?.id ?? DateTime.now().toString(),
                            nome: nomeCtrl.text.trim(),
                            ano: int.parse(anoCtrl.text.trim()),
                            etapa: etapaCtrl.text.trim(),
                            diaHorario: diaHorarioCtrl.text.trim(),
                            localSala: localSalaCtrl.text.trim(),
                            capacidade: int.parse(capacidadeCtrl.text.trim()),
                            status: selectedStatus,
                            catequista: selectedCatequista!,
                            observacoes: observacoesCtrl.text.trim(),
                          );
                          if (isEditing) {
                            vm.updateTurma(model);
                          } else {
                            vm.addTurma(model);
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

void showNovaTurmaDialog(BuildContext context, TurmaViewModel vm) {
  showTurmaDialog(context, vm);
}

class TurmaPage extends StatelessWidget {
  final TurmaViewModel vm;
  final CatequizandoViewModel catequizandoVm;
  const TurmaPage({super.key, required this.vm, required this.catequizandoVm});

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
                return _TurmaTable(list: list, theme: theme, vm: vm, catequizandoVm: catequizandoVm);
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
  final TurmaViewModel vm;
  final CatequizandoViewModel catequizandoVm;

  const _TurmaTable({required this.list, required this.theme, required this.vm, required this.catequizandoVm});

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
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FixedColumnWidth(100),
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
              _headerCell('Quantidade', Icons.people_rounded),
              _headerCell('Status', Icons.info_outline_rounded),
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
                  _bodyCell(t.diaHorario),
                  _bodyCell('${t.capacidade}'),
                  _bodyCell(t.status),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: 30,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.people_outline, size: 18, color: theme.colorScheme.tertiary),
                            onPressed: () {
                              showGerenciarCatequizandosDialog(context, t, catequizandoVm);
                            },
                              tooltip: 'Ver Catequizandos',
                            ),
                          ),
                        ),
Flexible(
                          child: SizedBox(
                            width: 30,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                              onPressed: () {
                                showTurmaDialog(context, vm, turma: t);
                              },
                              tooltip: 'Editar',
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: 30,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: Text('Deseja excluir a turma "${t.nome}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                      FilledButton(
                                        onPressed: () {
                                          vm.removeTurma(t.id);
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
                                Text(t.diaHorario, style: theme.textTheme.bodySmall),
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
