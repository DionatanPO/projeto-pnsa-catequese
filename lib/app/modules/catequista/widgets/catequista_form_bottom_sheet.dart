import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get/get.dart';
import '../models/catequista_model.dart';
import '../viewmodels/catequista_viewmodel.dart';

class CatequistaFormBottomSheet extends StatefulWidget {
  final Catequista? catequista;
  final CatequistaViewModel vm;

  const CatequistaFormBottomSheet({
    super.key,
    this.catequista,
    required this.vm,
  });

  static void show(BuildContext context, CatequistaViewModel vm, {Catequista? catequista}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CatequistaFormBottomSheet(catequista: catequista, vm: vm),
    );
  }

  @override
  State<CatequistaFormBottomSheet> createState() => _CatequistaFormBottomSheetState();
}

class _CatequistaFormBottomSheetState extends State<CatequistaFormBottomSheet> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _dataNascimentoCtrl;
  late final TextEditingController _logradouroCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _bairroCtrl;
  late final TextEditingController _cidadeCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _cepCtrl;
  late final GlobalKey<FormState> _formKey;
  final _salvando = false.obs;

  late String _currentStatus;
  late bool _casado;
  late final MaskTextInputFormatter _phoneMask;
  late final MaskTextInputFormatter _cepMask;
  DateTime? _selectedDate;

  bool get _isEditing => widget.catequista != null;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.catequista?.nome ?? '');
    _emailCtrl = TextEditingController(text: widget.catequista?.email ?? '');
    _telefoneCtrl = TextEditingController(text: widget.catequista?.telefone ?? '');
    _dataNascimentoCtrl = TextEditingController(text: widget.catequista?.dataNascimento ?? '');
    _logradouroCtrl = TextEditingController(text: widget.catequista?.logradouro ?? '');
    _numeroCtrl = TextEditingController(text: widget.catequista?.numero ?? '');
    _bairroCtrl = TextEditingController(text: widget.catequista?.bairro ?? '');
    _cidadeCtrl = TextEditingController(text: widget.catequista?.cidade ?? '');
    _estadoCtrl = TextEditingController(text: widget.catequista?.estado ?? '');
    _cepCtrl = TextEditingController(text: widget.catequista?.cep ?? '');
    _currentStatus = widget.catequista?.status ?? 'Ativo';
    _casado = widget.catequista?.casado ?? false;
    _formKey = GlobalKey<FormState>();

    final nascimento = widget.catequista?.dataNascimento ?? '';
    if (nascimento.isNotEmpty) {
      final parts = nascimento.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.tryParse(parts[2]) ?? 2000,
          int.tryParse(parts[1]) ?? 1,
          int.tryParse(parts[0]) ?? 1,
        );
      }
    }

    _phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    _cepMask = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _dataNascimentoCtrl.dispose();
    _logradouroCtrl.dispose();
    _numeroCtrl.dispose();
    _bairroCtrl.dispose();
    _cidadeCtrl.dispose();
    _estadoCtrl.dispose();
    _cepCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeCtrl.text.trim();
    final existe = widget.vm.data.value.catequistas.any(
      (c) => c.nome.toLowerCase() == nome.toLowerCase() && c.id != widget.catequista?.id,
    );
    if (existe) {
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Catequista já cadastrado'),
        content: Text('Já existe um catequista com o nome "$nome".'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
      ));
      return;
    }

    _salvando.value = true;
    try {
      final model = Catequista(
        id: widget.catequista?.id ?? '',
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        status: _currentStatus,
        dataNascimento: _dataNascimentoCtrl.text.trim(),
        logradouro: _logradouroCtrl.text.trim(),
        numero: _numeroCtrl.text.trim(),
        bairro: _bairroCtrl.text.trim(),
        cidade: _cidadeCtrl.text.trim(),
        estado: _estadoCtrl.text.trim(),
        cep: _cepCtrl.text.trim(),
        casado: _casado,
      );

      if (_isEditing) {
        await widget.vm.updateCatequista(model);
      } else {
        await widget.vm.addCatequista(model);
      }

      if (context.mounted) Navigator.pop(context);
    } finally {
      _salvando.value = false;
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isWide ? 600 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(colors),
          _buildHeader(theme, colors),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Nome completo',
                        hint: 'Ex: João da Silva',
                        prefixIcon: Icons.person_outline_rounded,
                        colors: colors,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                        if (v.trim().split(' ').length < 2) return 'Digite o nome completo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 400;
                        final emailField = TextFormField(
                          controller: _emailCtrl,
                          decoration: _buildInputDecoration(
                            label: 'E-mail',
                            hint: 'exemplo@pnsa.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            colors: colors,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                            if (!emailRegex.hasMatch(v.trim())) return 'E-mail inválido';
                            return null;
                          },
                        );
                        final phoneField = TextFormField(
                          controller: _telefoneCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Telefone',
                            hint: '(62) 99999-9999',
                            prefixIcon: Icons.phone_outlined,
                            colors: colors,
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_phoneMask],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                            if (v.replaceAll(RegExp(r'\D'), '').length < 11) return 'Telefone incompleto';
                            return null;
                          },
                        );
                        if (isCompact) return Column(children: [emailField, const SizedBox(height: 16), phoneField]);
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: emailField),
                          const SizedBox(width: 16),
                          Expanded(child: phoneField),
                        ]);
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (date != null) {
                          _selectedDate = date;
                          _dataNascimentoCtrl.text =
                              '${date.day.toString().padLeft(2, '0')}/'
                              '${date.month.toString().padLeft(2, '0')}/'
                              '${date.year}';
                        }
                      },
                      child: TextFormField(
                        controller: _dataNascimentoCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Data de Nascimento',
                          hint: 'DD/MM/AAAA',
                          prefixIcon: Icons.cake_outlined,
                          colors: colors,
                        ),
                        enabled: false,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Endereço',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 400;
                        final logradouroField = TextFormField(
                          controller: _logradouroCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Logradouro',
                            hint: 'Rua, Av...',
                            prefixIcon: Icons.streetview_outlined,
                            colors: colors,
                          ),
                          textCapitalization: TextCapitalization.words,
                        );
                        final numeroField = TextFormField(
                          controller: _numeroCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Número',
                            hint: 'S/N',
                            prefixIcon: Icons.numbers_outlined,
                            colors: colors,
                          ),
                        );
                        if (isCompact) return Column(children: [logradouroField, const SizedBox(height: 16), numeroField]);
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 3, child: logradouroField),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: numeroField),
                        ]);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bairroCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Bairro',
                        hint: 'Centro',
                        prefixIcon: Icons.map_outlined,
                        colors: colors,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 400;
                        final cidadeField = TextFormField(
                          controller: _cidadeCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Cidade',
                            hint: 'Goiânia',
                            prefixIcon: Icons.location_city_outlined,
                            colors: colors,
                          ),
                          textCapitalization: TextCapitalization.words,
                        );
                        final estadoField = TextFormField(
                          controller: _estadoCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Estado',
                            hint: 'GO',
                            prefixIcon: Icons.map_rounded,
                            colors: colors,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 2,
                        );
                        final cepField = TextFormField(
                          controller: _cepCtrl,
                          decoration: _buildInputDecoration(
                            label: 'CEP',
                            hint: '74000-000',
                            prefixIcon: Icons.mail_outlined,
                            colors: colors,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_cepMask],
                        );
                        if (isCompact) {
                          return Column(children: [
                            cidadeField,
                            const SizedBox(height: 16),
                            estadoField,
                            const SizedBox(height: 16),
                            cepField,
                          ]);
                        }
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 2, child: cidadeField),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: estadoField),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: cepField),
                        ]);
                      },
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado Civil', style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<bool>(
                            segments: [
                              ButtonSegment<bool>(
                                value: false,
                                label: const Text('Solteiro(a)'),
                                icon: Icon(Icons.person_outline, color: colors.primary, size: 18),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: const Text('Casado(a)'),
                                icon: Icon(Icons.favorite_border_outlined, color: colors.tertiary, size: 18),
                              ),
                            ],
                            selected: {_casado},
                            onSelectionChanged: (newSelection) => setState(() => _casado = newSelection.first),
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: colors.primaryContainer,
                              selectedForegroundColor: colors.onPrimaryContainer,
                              side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status do cadastro', style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: 'Ativo',
                                label: const Text('Ativo'),
                                icon: Icon(Icons.check_circle_outline, color: colors.primary, size: 18),
                              ),
                              ButtonSegment<String>(
                                value: 'Inativo',
                                label: const Text('Inativo'),
                                icon: const Icon(Icons.block_outlined, size: 18),
                              ),
                            ],
                            selected: {_currentStatus},
                            onSelectionChanged: (newSelection) => setState(() => _currentStatus = newSelection.first),
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: colors.primaryContainer,
                              selectedForegroundColor: colors.onPrimaryContainer,
                              side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(theme, colors),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: colors.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isEditing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
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
                  _isEditing ? 'Editar Catequista' : 'Novo Catequista',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? 'Atualize as informações cadastrais' : 'Preencha os dados do cadastro',
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _salvando.value ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _salvando.value ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _salvando.value
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                : Icon(_isEditing ? Icons.save_rounded : Icons.check_rounded, size: 18),
            label: Text(_salvando.value ? 'Salvando...' : (_isEditing ? 'Salvar Alterações' : 'Cadastrar')),
          ),
        ],
      ),
    );
  }
}