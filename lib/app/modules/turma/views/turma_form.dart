import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/turma_viewmodel.dart';
import '../models/turma_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';

class TurmaForm extends StatefulWidget {
  final TurmaModel? turma;
  final TurmaViewModel vm;
  final double width;

  const TurmaForm({
    super.key,
    this.turma,
    required this.vm,
    this.width = 480,
  });

  @override
  State<TurmaForm> createState() => _TurmaFormState();
}

class _TurmaFormState extends State<TurmaForm> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _anoCtrl;
  late final TextEditingController _etapaCtrl;
  late final TextEditingController _diaHorarioCtrl;
  late final TextEditingController _localSalaCtrl;
  late final TextEditingController _observacoesCtrl;
  late final GlobalKey<FormState> _formKey;

  final List<String> _statusOptions = ['Ativa', 'Concluída', 'Suspensa'];

  String? _selectedCatequista;
  String _selectedStatus = 'Ativa';

  bool get _isEditing => widget.turma != null;

  List<String> get _catequistas {
    final catequistaVm = Get.find<CatequistaViewModel>();
    return catequistaVm.data.value.catequistas
        .where((c) => c.status == 'Ativo')
        .map((c) => c.nome)
        .toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.turma?.nome ?? '');
    _anoCtrl = TextEditingController(text: widget.turma?.ano.toString() ?? '');
    _etapaCtrl = TextEditingController(text: widget.turma?.etapa ?? '');
    _diaHorarioCtrl = TextEditingController(text: widget.turma?.diaHorario ?? '');
    _localSalaCtrl = TextEditingController(text: widget.turma?.localSala ?? '');
    _observacoesCtrl = TextEditingController(text: widget.turma?.observacoes ?? '');
    _formKey = GlobalKey<FormState>();

    _selectedCatequista = widget.turma != null && _catequistas.contains(widget.turma!.catequista)
        ? widget.turma!.catequista
        : null;
    _selectedStatus = widget.turma?.status ?? 'Ativa';
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _anoCtrl.dispose();
    _etapaCtrl.dispose();
    _diaHorarioCtrl.dispose();
    _localSalaCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final model = TurmaModel(
      id: widget.turma?.id ?? '',
      nome: _nomeCtrl.text.trim(),
      ano: int.parse(_anoCtrl.text.trim()),
      etapa: _etapaCtrl.text.trim(),
      diaHorario: _diaHorarioCtrl.text.trim(),
      localSala: _localSalaCtrl.text.trim(),
      status: _selectedStatus,
      catequista: _selectedCatequista!,
      observacoes: _observacoesCtrl.text.trim(),
    );

    final error = _isEditing
        ? await widget.vm.updateTurma(model)
        : await widget.vm.addTurma(model);

    if (error != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      return;
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditing ? Icons.edit_rounded : Icons.group_add_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isEditing ? 'Editar Turma' : 'Nova Turma',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome da turma', hintText: 'Ex: Turma A'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _anoCtrl,
                            decoration: const InputDecoration(labelText: 'Ano Letivo', hintText: 'Ex: 2026'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _etapaCtrl,
                            decoration: const InputDecoration(labelText: 'Etapa', hintText: 'Ex: Eucaristia'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedCatequista,
                      decoration: const InputDecoration(labelText: 'Catequista', hintText: 'Selecione o catequista'),
                      items: _catequistas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCatequista = v),
                      validator: (v) => v == null ? 'Selecione um catequista' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _diaHorarioCtrl,
                      decoration: const InputDecoration(labelText: 'Dia e Horário', hintText: 'Ex: Sábados, 08:00'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _localSalaCtrl,
                      decoration: const InputDecoration(labelText: 'Local/Sala', hintText: 'Ex: Sala 01'),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _observacoesCtrl,
                      decoration: const InputDecoration(labelText: 'Observações'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _save,
                          child: Text(_isEditing ? 'Salvar Alterações' : 'Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
