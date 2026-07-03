import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../viewmodels/coordenador_viewmodel.dart';
import '../models/coordenador_model.dart';

class CoordenadorForm extends StatefulWidget {
  final Coordenador? coordenador;
  final CoordenadorViewModel vm;
  final double width;

  const CoordenadorForm({
    super.key,
    this.coordenador,
    required this.vm,
    this.width = 480,
  });

  @override
  State<CoordenadorForm> createState() => _CoordenadorFormState();
}

class _CoordenadorFormState extends State<CoordenadorForm> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _areaCtrl;
  late String _currentStatus;
  late final GlobalKey<FormState> _formKey;

  late final MaskTextInputFormatter _phoneMask;

  bool get _isEditing => widget.coordenador != null;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.coordenador?.nome ?? '');
    _emailCtrl = TextEditingController(text: widget.coordenador?.email ?? '');
    _telefoneCtrl = TextEditingController(text: widget.coordenador?.telefone ?? '');
    _areaCtrl = TextEditingController(text: widget.coordenador?.area ?? '');
    _currentStatus = widget.coordenador?.status ?? 'Ativo';
    _formKey = GlobalKey<FormState>();

    _phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final model = Coordenador(
      id: widget.coordenador?.id ?? DateTime.now().toString(),
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefone: _telefoneCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      status: _currentStatus,
    );

    if (_isEditing) {
      widget.vm.updateCoordenador(model);
    } else {
      widget.vm.addCoordenador(model);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: widget.width,
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
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isEditing ? 'Editar Coordenador' : 'Novo Coordenador',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome', hintText: 'Nome completo'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'E-mail', hintText: 'email@pnsa.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _telefoneCtrl,
                        decoration: const InputDecoration(labelText: 'Telefone', hintText: '(62) 99999-9999'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_phoneMask],
                        validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _areaCtrl,
                        decoration: const InputDecoration(labelText: 'Área', hintText: 'Ex: Catequese Infantil'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currentStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: ['Ativo', 'Inativo'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _currentStatus = v!),
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }
}
