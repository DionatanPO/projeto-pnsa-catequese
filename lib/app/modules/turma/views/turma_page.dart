import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';
import 'turma_form.dart';

void showTransferirDialog(BuildContext context, Catequizando catequizando, TurmaModel turmaAtual, List<TurmaModel> todasTurmas) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final matriculaVm = Get.find<MatriculaViewModel>();
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                      child: Icon(Icons.swap_horiz_rounded, color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transferir Catequizando', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                          Text(catequizando.nome, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turma atual:', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma',
                        hintText: 'Selecione a turma de destino',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                      validator: (v) => v == null ? 'Selecione uma turma' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A matrícula atual será marcada como "Transferida" e uma nova matrícula será criada na turma de destino.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: selectedTurmaId == null
                          ? null
                          : () {
                              matriculaVm.transferir(catequizando.id, selectedTurmaId!);
                              Navigator.of(ctx).pop();
                            },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Transferir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool> showTransferirDialogMulti(BuildContext context, List<Catequizando> catequizandos, TurmaModel turmaAtual, List<TurmaModel> todasTurmas, MatriculaViewModel matriculaVm) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();
  final count = catequizandos.length;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                      child: Icon(Icons.swap_horiz_rounded, color: colorScheme.onPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transferir Catequizandos', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                          Text('$count catequizando(s) selecionado(s)', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turma atual:', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma',
                        hintText: 'Selecione a turma de destino',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                      validator: (v) => v == null ? 'Selecione uma turma' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'As matrículas atuais serão marcadas como "Transferida" e novas matrículas serão criadas na turma de destino.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: selectedTurmaId == null
                          ? null
                          : () async {
                              for (final c in catequizandos) {
                                await matriculaVm.transferir(c.id, selectedTurmaId!);
                              }
                              if (ctx.mounted) Navigator.of(ctx).pop(true);
                            },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Transferir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

void showConcluirComTransferenciaDialog(
  BuildContext context,
  List<Catequizando> catequizandos,
  TurmaModel turmaAtual,
  List<TurmaModel> todasTurmas,
  MatriculaViewModel matriculaVm, {
  VoidCallback? onDone,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isSingle = catequizandos.length == 1;
  String? selectedTurmaId;
  final outrasTurmas = todasTurmas.where((t) => t.id != turmaAtual.id && t.status == 'Ativa').toList();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
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
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSingle ? 'Concluir Catequizando' : 'Concluir Catequizandos',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            isSingle ? catequizandos.first.nome : '${catequizandos.length} catequizando(s)',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(turmaAtual.nome, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSingle
                          ? 'O catequizando concluiu esta turma. Deseja transferi-lo para outra turma?'
                          : 'Os catequizandos concluíram esta turma. Deseja transferi-los para outra turma?',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSingle
                          ? 'Deseja transferi-lo para outra turma?'
                          : 'Deseja transferi-los para outra turma?',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedTurmaId,
                      decoration: const InputDecoration(
                        labelText: 'Nova Turma (opcional)',
                        hintText: 'Selecione para transferir',
                        prefixIcon: Icon(Icons.auto_stories_rounded),
                      ),
                      items: outrasTurmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                      onChanged: (v) => setState(() => selectedTurmaId = v),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedTurmaId != null
                                  ? 'A matrícula atual será concluída e uma nova será criada na turma de destino.'
                                  : 'Selecione uma turma acima para transferir, ou clique em "Concluir" para apenas encerrar a matrícula.',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        for (final c in catequizandos) {
                          if (selectedTurmaId != null) {
                            await matriculaVm.matricular(c.id, selectedTurmaId!);
                          } else {
                            await matriculaVm.concluir(c.id);
                          }
                        }
                        onDone?.call();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      icon: Icon(
                        selectedTurmaId != null ? Icons.swap_horiz_rounded : Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: Text(selectedTurmaId != null ? 'Concluir e Transferir' : 'Concluir'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showGerenciarCatequizandosDialog(BuildContext context, TurmaModel turma, CatequizandoViewModel catequizandoVm) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final matriculaVm = Get.find<MatriculaViewModel>();

  final catequizandosDaTurma = matriculaVm.getAlunosDaTurma(turma.id, catequizandoVm.catequizandos);
  final catequizandosFora = catequizandoVm.catequizandos.where(
    (a) => !catequizandosDaTurma.any((da) => da.id == a.id),
  ).toList();

  showDialog(
    context: context,
    builder: (ctx) {
      final selecionados = <String>{};

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
                      if (catequizandosDaTurma.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${selecionados.length} sel.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (catequizandosDaTurma.isNotEmpty && selecionados.length < catequizandosDaTurma.length)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() => selecionados.addAll(catequizandosDaTurma.map((a) => a.id)));
                          },
                          icon: Icon(Icons.select_all_rounded, size: 18, color: colorScheme.primary),
                          label: Text('Selecionar todos', style: TextStyle(fontSize: 12, color: colorScheme.primary)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                        if (selecionados.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => setState(() => selecionados.clear()),
                            icon: Icon(Icons.deselect_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                            label: Text('Limpar seleção', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: catequizandosDaTurma.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final catequizando = catequizandosDaTurma[i];
                        final selected = selecionados.contains(catequizando.id);
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selected ? colorScheme.primary : colorScheme.outlineVariant.withOpacity(0.3),
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  selecionados.remove(catequizando.id);
                                } else {
                                  selecionados.add(catequizando.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selected,
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          selecionados.add(catequizando.id);
                                        } else {
                                          selecionados.remove(catequizando.id);
                                        }
                                      });
                                    },
                                  ),
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: selected
                                        ? colorScheme.primaryContainer
                                        : colorScheme.secondaryContainer,
                                    child: Text(
                                      catequizando.nome.trim().isNotEmpty
                                          ? catequizando.nome.trim()[0].toUpperCase()
                                          : '?',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: selected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          catequizando.nome,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_rounded, size: 13, color: colorScheme.onSurfaceVariant),
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
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (action) {
                                      switch (action) {
                                        case 'concluir':
                                          showConcluirComTransferenciaDialog(
                                            context,
                                            [catequizando],
                                            turma,
                                            Get.find<TurmaViewModel>().turmas,
                                            matriculaVm,
                                            onDone: () {
                                              setState(() {
                                                catequizandosDaTurma.removeAt(i);
                                                selecionados.remove(catequizando.id);
                                              });
                                            },
                                          );
                                          break;
                                        case 'transferir':
                                          final turmaVm = Get.find<TurmaViewModel>();
                                          showTransferirDialog(context, catequizando, turma, turmaVm.turmas);
                                          break;
                                        case 'remover':
                                          matriculaVm.desmatricular(catequizando.id);
                                          setState(() {
                                            catequizandosDaTurma.removeAt(i);
                                            selecionados.remove(catequizando.id);
                                          });
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'concluir', child: ListTile(
                                        leading: Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                                        title: Text('Concluir', style: TextStyle(fontSize: 13)),
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                      const PopupMenuItem(value: 'transferir', child: ListTile(
                                        leading: Icon(Icons.swap_horiz_rounded),
                                        title: Text('Transferir', style: TextStyle(fontSize: 13)),
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(value: 'remover', child: ListTile(
                                        leading: Icon(Icons.remove_circle_outline_rounded, color: colorScheme.error),
                                        title: Text('Remover da turma', style: TextStyle(fontSize: 13, color: colorScheme.error)),
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                    ],
                                  ),
                                ],
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
                  child: selecionados.isEmpty
                      ? Row(
                          children: [
                            if (catequizandosFora.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: ctx,
                                    builder: (ctx2) {
                                      final novosSelecionados = <String>{};

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
                                                        final sel = novosSelecionados.contains(a.id);
                                                        return CheckboxListTile(
                                                          value: sel,
                                                          onChanged: (v) {
                                                            setState2(() {
                                                              if (v == true) {
                                                                novosSelecionados.add(a.id);
                                                              } else {
                                                                novosSelecionados.remove(a.id);
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
                                                            for (final id in novosSelecionados) {
                                                              matriculaVm.matricular(id, turma.id);
                                                            }
                                                            Navigator.of(ctx2).pop();
                                                            Navigator.of(ctx).pop();
                                                            showGerenciarCatequizandosDialog(context, turma, catequizandoVm);
                                                          },
                                                        icon: const Icon(Icons.add_rounded, size: 18),
                                                        label: Text('Adicionar (${novosSelecionados.length})'),
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
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${selecionados.length} selecionado(s)',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final turmaVm = Get.find<TurmaViewModel>();
                                final selecionadosObjs = catequizandosDaTurma.where((a) => selecionados.contains(a.id)).toList();
                                final transferred = await showTransferirDialogMulti(context, selecionadosObjs, turma, turmaVm.turmas, matriculaVm);
                                if (transferred) {
                                  setState(() {
                                    catequizandosDaTurma.removeWhere((a) => selecionados.contains(a.id));
                                    selecionados.clear();
                                  });
                                }
                              },
                              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                              label: const Text('Transferir'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                final selecionadosObjs = catequizandosDaTurma.where((a) => selecionados.contains(a.id)).toList();
                                final turmaVm = Get.find<TurmaViewModel>();
                                showConcluirComTransferenciaDialog(
                                  context,
                                  selecionadosObjs,
                                  turma,
                                  turmaVm.turmas,
                                  matriculaVm,
                                  onDone: () {
                                    setState(() {
                                      catequizandosDaTurma.removeWhere((a) => selecionados.contains(a.id));
                                      selecionados.clear();
                                    });
                                  },
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green),
                              label: const Text('Concluir'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Confirmar'),
                                    content: Text('Remover ${selecionados.length} catequizando(s) da turma?'),
                                    actions: [
                                      TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                      FilledButton(
                                        onPressed: () {
                                          for (final id in selecionados) {
                                            matriculaVm.desmatricular(id);
                                          }
                                          setState(() {
                                            catequizandosDaTurma.removeWhere((a) => selecionados.contains(a.id));
                                            selecionados.clear();
                                          });
                                          Get.back();
                                        },
                                        style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                                        child: const Text('Remover'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                              label: const Text('Remover'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
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
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 560.0 : screenWidth > 600 ? 480.0 : screenWidth * 0.92;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: TurmaForm(turma: turma, vm: vm, width: dialogWidth),
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

Color _turmaStatusColor(String status) {
  switch (status) {
    case 'Ativa': return Colors.green;
    case 'Concluída': return Colors.blue;
    case 'Suspensa': return Colors.orange;
    default: return Colors.grey;
  }
}

class _TurmaTable extends StatefulWidget {
  final List<TurmaModel> list;
  final ThemeData theme;
  final TurmaViewModel vm;
  final CatequizandoViewModel catequizandoVm;

  const _TurmaTable({required this.list, required this.theme, required this.vm, required this.catequizandoVm});

  @override
  State<_TurmaTable> createState() => _TurmaTableState();
}

class _TurmaTableState extends State<_TurmaTable> {
  int _sortColumn = -1;
  bool _sortAscending = true;

  String _getSortKey(TurmaModel t, int col) {
    switch (col) {
      case 0: return t.nome;
      case 1: return t.catequista;
      case 2: return t.diaHorario;
      case 3: return t.capacidade.toString().padLeft(5, '0');
      case 4: return t.status;
      case 5: return t.observacoes ?? '';
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

  List<TurmaModel> get _sortedList {
    if (_sortColumn < 0) return widget.list;
    final sorted = List<TurmaModel>.from(widget.list);
    sorted.sort((a, b) {
      final r = _getSortKey(a, _sortColumn).compareTo(_getSortKey(b, _sortColumn));
      return _sortAscending ? r : -r;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final sorted = _sortedList;

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
          3: FlexColumnWidth(0.8),
          4: FlexColumnWidth(0.8),
          5: FlexColumnWidth(2),
          6: FixedColumnWidth(100),
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
              _sortableHeader('Turma', Icons.group_rounded, 0),
              _sortableHeader('Catequista', Icons.person_rounded, 1),
              _sortableHeader('Horário', Icons.access_time_rounded, 2),
              _sortableHeader('Qtde', Icons.people_rounded, 3),
              _sortableHeader('Status', Icons.info_outline_rounded, 4),
              _sortableHeader('Detalhes', Icons.description_outlined, 5),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...sorted.asMap().entries.map(
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
                        Expanded(
                          child: Text(
                            t.nome,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _bodyCell(t.catequista),
                  _bodyCell(t.diaHorario),
                  _bodyCell('${t.capacidade}'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _turmaStatusColor(t.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: _turmaStatusColor(t.status)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.status,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _turmaStatusColor(t.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _bodyCell(t.observacoes != null && t.observacoes!.isNotEmpty ? t.observacoes! : '-', maxLines: 2),
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
                              showGerenciarCatequizandosDialog(context, t, widget.catequizandoVm);
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
                                showTurmaDialog(context, widget.vm, turma: t);
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
                                          widget.vm.removeTurma(t.id);
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

  Widget _sortableHeader(String label, IconData icon, int col) {
    final theme = widget.theme;
    final isActive = _sortColumn == col;
    return InkWell(
      onTap: () => _sort(col),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
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
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false, int? maxLines}) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
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
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t.nome,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _turmaStatusColor(t.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5, height: 5,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: _turmaStatusColor(t.status)),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        t.status,
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: _turmaStatusColor(t.status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
