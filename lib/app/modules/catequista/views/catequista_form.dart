import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../viewmodels/catequista_viewmodel.dart';
import '../models/catequista_model.dart';

class CatequistaForm extends StatefulWidget {
  final Catequista? catequista;
  final CatequistaViewModel vm;
  final double width;

  const CatequistaForm({
    super.key,
    this.catequista,
    required this.vm,
    this.width = 480,
  });

  @override
  State<CatequistaForm> createState() => _CatequistaFormState();
}

class _CatequistaFormState extends State<CatequistaForm> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  late String _currentStatus;
  late final GlobalKey<FormState> _formKey;

  late final MaskTextInputFormatter _phoneMask;
  bool _isLoading = false;

  bool get _isEditing => widget.catequista != null;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.catequista?.nome ?? '');
    _emailCtrl = TextEditingController(text: widget.catequista?.email ?? '');
    _telefoneCtrl = TextEditingController(text: widget.catequista?.telefone ?? '');
    _currentStatus = widget.catequista?.status ?? 'Ativo';
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
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final model = Catequista(
        id: widget.catequista?.id ?? '',
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telefone: _telefoneCtrl.text.trim(),
        status: _currentStatus,
      );

      if (_isEditing) {
        await widget.vm.updateCatequista(model);
      } else {
        await widget.vm.addCatequista(model);
      }
      
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      // Opcional: Adicionar tratamento de erro visual aqui se necessário
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper para padronizar as decorações dos campos de texto de forma limpa
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
          // Cabeçalho unificado com o padrão visual do app
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEditing ? 'Atualize as informações cadastrais' : 'Preencha os dados do cadastro',
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
                    // Campo Nome
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
                    const SizedBox(height: 20),

                    // Seção Email e Telefone adaptável
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
                            if (v.replaceAll(RegExp(r'\D'), '').length < 11) {
                              return 'Telefone incompleto';
                            }
                            return null;
                          },
                        );

                        if (isCompact) {
                          return Column(
                            children: [
                              emailField,
                              const SizedBox(height: 20),
                              phoneField,
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: emailField),
                              const SizedBox(width: 16),
                              Expanded(child: phoneField),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Status - Uso de SegmentedButton (Material 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status do cadastro',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
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
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _currentStatus = newSelection.first;
                              });
                            },
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: colors.primaryContainer,
                              selectedForegroundColor: colors.onPrimaryContainer,
                              side: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

          // Botões de Ação do Rodapé padronizados
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save_rounded : Icons.check_rounded, size: 18),
                  label: Text(_isLoading ? 'Salvando...' : (_isEditing ? 'Salvar Alterações' : 'Cadastrar')),
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