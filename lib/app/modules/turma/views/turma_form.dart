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

  final Set<String> _selectedCatequistas = {};
  String _selectedStatus = 'Ativa';

  bool get _isEditing => widget.turma != null;

  List<String> get _catequistasList {
    try {
      final catequistaVm = Get.find<CatequistaViewModel>();
      return catequistaVm.data.value.catequistas
          .where((c) => c.status == 'Ativo')
          .map((c) => c.nome)
          .toList()..sort();
    } catch (_) {
      return [];
    }
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

    _selectedCatequistas.addAll(widget.turma?.catequistas ?? []);
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
      catequistas: _selectedCatequistas.toList()..sort(),
      observacoes: _observacoesCtrl.text.trim(),
    );

    final error = _isEditing
        ? await widget.vm.updateTurma(model)
        : await widget.vm.addTurma(model);

    if (error != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error), 
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  // Helper para padronizar o design dos inputs
  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData prefixIcon,
    required ColorScheme colors,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, size: 20),
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.outlineVariant.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(maxWidth: widget.width),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: colors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho refinado
          Container(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              color: colors.primaryContainer.withOpacity(0.3),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_note_rounded : Icons.group_add_rounded,
                    color: colors.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Editar Turma' : 'Nova Turma',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEditing ? 'Atualize os dados desta turma' : 'Preencha as informações da nova turma',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Corpo do Formulário com Rolagem Segura
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nome da Turma
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Nome da turma',
                        hint: 'Ex: Turma A',
                        prefixIcon: Icons.class_outlined,
                        colors: colors,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 20),

                    // Ano Letivo e Etapa em linha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _anoCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Ano Letivo',
                              hint: 'Ex: 2026',
                              prefixIcon: Icons.calendar_today_rounded,
                              colors: colors,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                              if (int.tryParse(v.trim()) == null) return 'Digite um ano válido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _etapaCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Etapa',
                              hint: 'Ex: Eucaristia',
                              prefixIcon: Icons.auto_stories_outlined,
                              colors: colors,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Seleção dos Catequistas (multi-select)
                    Obx(() {
                      final catequistas = _catequistasList;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.assignment_ind_outlined, size: 20, color: colors.onSurfaceVariant),
                                      const SizedBox(width: 12),
                                      Text('Catequistas', style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                if (catequistas.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12, left: 32),
                                    child: Text('Nenhum catequista ativo disponível',
                                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant.withOpacity(0.5))),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: catequistas.map((c) => FilterChip(
                                        label: Text(c, style: const TextStyle(fontSize: 12)),
                                        selected: _selectedCatequistas.contains(c),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        onSelected: (sel) => setState(() {
                                          if (sel) { _selectedCatequistas.add(c); }
                                          else { _selectedCatequistas.remove(c); }
                                        }),
                                      )).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_selectedCatequistas.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: Text(
                                '${_selectedCatequistas.length} selecionado(s)',
                                style: TextStyle(fontSize: 11, color: colors.primary),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // Dia/Horário e Local/Sala em linha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _diaHorarioCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Dia e Horário',
                              hint: 'Ex: Sábados, 08:00',
                              prefixIcon: Icons.schedule_outlined,
                              colors: colors,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _localSalaCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Local/Sala',
                              hint: 'Ex: Sala 01',
                              prefixIcon: Icons.room_outlined,
                              colors: colors,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status da Turma
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: _buildInputDecoration(
                        label: 'Status',
                        prefixIcon: Icons.info_outline_rounded,
                        colors: colors,
                      ),
                      items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                    ),
                    const SizedBox(height: 20),

                    // Observações adicionais
                    TextFormField(
                      controller: _observacoesCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Observações',
                        prefixIcon: Icons.sticky_note_2_outlined,
                        colors: colors,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Botões de Ação do Rodapé
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Turma'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}