import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:get/get.dart';
import '../models/coordenador_model.dart';
import '../viewmodels/coordenador_viewmodel.dart';

class CoordenadorFormBottomSheet extends StatefulWidget {
  final Coordenador? coordenador;
  final CoordenadorViewModel vm;

  const CoordenadorFormBottomSheet({
    super.key,
    this.coordenador,
    required this.vm,
  });

  static void show(BuildContext context, CoordenadorViewModel vm, {Coordenador? coordenador}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoordenadorFormBottomSheet(coordenador: coordenador, vm: vm),
    );
  }

  @override
  State<CoordenadorFormBottomSheet> createState() => _CoordenadorFormBottomSheetState();
}

class _CoordenadorFormBottomSheetState extends State<CoordenadorFormBottomSheet> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _areaCtrl;
  late final GlobalKey<FormState> _formKey;
  bool _salvando = false;

  late String _currentStatus;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final editingOther = widget.coordenador?.id ?? '';
    final existe = widget.vm.data.value.coordenadores.any(
      (c) => c.email.toLowerCase() == email.toLowerCase() && c.id != editingOther,
    );
    if (existe) {
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Coordenador já cadastrado'),
        content: Text('Já existe um coordenador com o e-mail "$email".'),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
      ));
      return;
    }

    setState(() => _salvando = true);
    try {
      final model = Coordenador(
        id: editingOther,
        nome: _nomeCtrl.text.trim(),
        email: email,
        telefone: _telefoneCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        status: _currentStatus,
      );

      if (_isEditing) {
        await widget.vm.updateCoordenador(model);
      } else {
        await widget.vm.addCoordenador(model);
      }

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email-already-in-use') {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Conta já existente'),
          content: Text('O e-mail "$email" já possui uma conta no sistema.'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
        ));
      } else {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Erro ao cadastrar'),
          content: Text(e.message ?? 'Erro desconhecido'),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
        ));
      }
    } catch (e) {
      if (!mounted) return;
      Get.dialog(AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erro ao cadastrar'),
        content: Text(e.toString()),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Ok'))],
      ));
    } finally {
      setState(() => _salvando = false);
    }
  }

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
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isWide ? 560 : double.infinity,
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
                        hint: 'Ex: Carlos Alberto',
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
                            hint: 'email@pnsa.com',
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 400;
                        final areaField = TextFormField(
                          controller: _areaCtrl,
                          decoration: _buildInputDecoration(
                            label: 'Área',
                            hint: 'Ex: Catequese Infantil',
                            prefixIcon: Icons.category_outlined,
                            colors: colors,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        );
                        final statusField = DropdownButtonFormField<String>(
                          value: _currentStatus,
                          decoration: _buildInputDecoration(
                            label: 'Status',
                            prefixIcon: Icons.info_outline_rounded,
                            colors: colors,
                          ),
                          items: ['Ativo', 'Inativo'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => _currentStatus = v!),
                        );
                        if (isCompact) return Column(children: [areaField, const SizedBox(height: 16), statusField]);
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: areaField),
                          const SizedBox(width: 16),
                          Expanded(child: statusField),
                        ]);
                      },
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
              _isEditing ? Icons.manage_accounts_rounded : Icons.person_add_alt_1_rounded,
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
                  _isEditing ? 'Editar Coordenador' : 'Novo Coordenador',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? 'Atualize as informações de coordenação' : 'Preencha os dados do coordenador',
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
            onPressed: _salvando ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancelar', style: TextStyle(color: colors.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _salvando ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _salvando
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onPrimary))
                : Icon(_isEditing ? Icons.save_rounded : Icons.check_rounded, size: 18),
            label: Text(_salvando ? 'Salvando...' : (_isEditing ? 'Salvar Alterações' : 'Cadastrar')),
          ),
        ],
      ),
    );
  }
}