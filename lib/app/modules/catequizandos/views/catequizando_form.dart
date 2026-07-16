import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';

// Helper para títulos de seções do formulário
Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
  final colors = theme.colorScheme;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title, 
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
      ],
    ),
  );
}

// Helper para legendas explicativas do Status no Dialog
Widget _statusLegenda(ThemeData theme, String status, String descricao) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            children: [
              TextSpan(text: '$status: ', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                text: descricao, 
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// Grupo de rádio (segmentos) customizado e moderno
Widget radioGroup<T>({
  required String label,
  required T value,
  required List<T> options,
  required List<String> labels,
  required ThemeData theme,
  required ValueChanged<T> onChanged,
}) {
  final colors = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label, 
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: List.generate(options.length, (i) {
          final selected = value == options[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < options.length - 1 ? 12 : 0),
              child: InkWell(
                onTap: () => onChanged(options[i]),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primaryContainer.withOpacity(0.3)
                        : colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? colors.primary : colors.outlineVariant.withOpacity(0.4),
                      width: selected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: selected ? colors.primary : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                          color: selected ? colors.primary : colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ],
  );
}

class CatequizandoForm extends StatefulWidget {
  final Catequizando? catequizando;
  final CatequizandoViewModel? vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel? matriculaVm;
  final double width;
  final void Function(Catequizando dados, String? turmaId)? onSave;

  const CatequizandoForm({
    super.key,
    this.catequizando,
    this.vm,
    this.turmas = const [],
    this.matriculaVm,
    this.width = 560,
    this.onSave,
  });

  @override
  State<CatequizandoForm> createState() => _CatequizandoFormState();
}

class _CatequizandoFormState extends State<CatequizandoForm> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _dataNascimentoCtrl;
  late final TextEditingController _localBatismoCtrl;
  late final TextEditingController _detalheEucaristiaCtrl;
  late final TextEditingController _detalheCrismaCtrl;
  late final TextEditingController _detalheRestricaoCtrl;
  late final TextEditingController _observacoesCtrl;
  late final TextEditingController _responsavelCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _cepCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _bairroCtrl;
  late final GlobalKey<FormState> _formKey;

  late final MaskTextInputFormatter _telefoneFormatter;
  bool _isLoading = false;

  String _sexo = 'Masculino';
  DateTime? _dataNascimento;
  bool _batizado = false;
  bool _fezPrimeiraEucaristia = false;
  bool _fezCrisma = false;
  String _parentesco = 'Mãe';
  bool _possuiRestricao = false;
  String? _selectedTurmaId;
  String _status = 'Em Andamento';

  bool get _isEditing => widget.catequizando != null;

  @override
  void initState() {
    super.initState();
    final c = widget.catequizando;
    _nomeCtrl = TextEditingController(text: c?.nome ?? '');
    _localBatismoCtrl = TextEditingController(text: c?.localBatismo ?? '');
    _detalheEucaristiaCtrl = TextEditingController(text: c?.detalheEucaristia ?? '');
    _detalheCrismaCtrl = TextEditingController(text: c?.detalheCrisma ?? '');
    _detalheRestricaoCtrl = TextEditingController(text: c?.detalheRestricao ?? '');
    _observacoesCtrl = TextEditingController(text: c?.observacoes ?? '');
    _responsavelCtrl = TextEditingController(text: c?.responsavel ?? '');
    _telefoneCtrl = TextEditingController(text: c?.telefone ?? '');
    _cepCtrl = TextEditingController(text: c?.cep ?? '');
    _enderecoCtrl = TextEditingController(text: c?.endereco ?? '');
    _numeroCtrl = TextEditingController(text: c?.numero ?? '');
    _bairroCtrl = TextEditingController(text: c?.bairro ?? '');
    _formKey = GlobalKey<FormState>();

    _telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    if (c != null) {
      _sexo = c.sexo;
      _dataNascimento = c.dataNascimento;
      _batizado = c.batizado;
      _fezPrimeiraEucaristia = c.fezPrimeiraEucaristia ?? false;
      _fezCrisma = c.fezCrisma ?? false;
      _parentesco = c.parentesco;
      _possuiRestricao = c.possuiRestricao;
      _status = c.status;
    }

    if (c?.dataNascimento != null) {
      _dataNascimentoCtrl = TextEditingController(
        text: '${c!.dataNascimento.day.toString().padLeft(2, '0')}/'
            '${c.dataNascimento.month.toString().padLeft(2, '0')}/'
            '${c.dataNascimento.year}',
      );
    } else {
      _dataNascimentoCtrl = TextEditingController();
    }

    if (c != null && widget.matriculaVm != null) {
      final turmaNome = widget.matriculaVm!.getNomeTurmaAtual(c.id, widget.turmas);
      if (turmaNome != null) {
        final turma = widget.turmas.firstWhereOrNull((t) => t.nome == turmaNome);
        _selectedTurmaId = turma?.id;
      }
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _dataNascimentoCtrl.dispose();
    _localBatismoCtrl.dispose();
    _detalheEucaristiaCtrl.dispose();
    _detalheCrismaCtrl.dispose();
    _detalheRestricaoCtrl.dispose();
    _observacoesCtrl.dispose();
    _responsavelCtrl.dispose();
    _telefoneCtrl.dispose();
    _cepCtrl.dispose();
    _enderecoCtrl.dispose();
    _numeroCtrl.dispose();
    _bairroCtrl.dispose();
    super.dispose();
  }

  int _calcularIdade(DateTime data) {
    final hoje = DateTime.now();
    int age = hoje.year - data.year;
    if (hoje.month < data.month || (hoje.month == data.month && hoje.day < data.day)) {
      age--;
    }
    return age;
  }

  Catequizando? _buildModel() {
    if (!_formKey.currentState!.validate()) return null;
    if (_dataNascimento == null) {
      Get.snackbar('Erro', 'Data de nascimento não informada');
      return null;
    }
    return Catequizando(
      id: widget.catequizando?.id ?? DateTime.now().toString(),
      nome: _nomeCtrl.text.trim(),
      sexo: _sexo,
      dataNascimento: _dataNascimento!,
      batizado: _batizado,
      localBatismo: _batizado ? _localBatismoCtrl.text.trim() : null,
      fezPrimeiraEucaristia: _fezPrimeiraEucaristia,
      detalheEucaristia: _fezPrimeiraEucaristia == true ? _detalheEucaristiaCtrl.text.trim() : null,
      fezCrisma: _fezCrisma,
      detalheCrisma: _fezCrisma == true ? _detalheCrismaCtrl.text.trim() : null,
      responsavel: _responsavelCtrl.text.trim(),
      parentesco: _parentesco,
      telefone: _telefoneCtrl.text.trim(),
      cep: _cepCtrl.text.trim(),
      endereco: _enderecoCtrl.text.trim(),
      numero: _numeroCtrl.text.trim(),
      bairro: _bairroCtrl.text.trim(),
      possuiRestricao: _possuiRestricao,
      detalheRestricao: _possuiRestricao ? _detalheRestricaoCtrl.text.trim() : null,
      observacoes: _observacoesCtrl.text.trim().isEmpty ? null : _observacoesCtrl.text.trim(),
      status: _status,
      aceiteTermos: widget.catequizando?.aceiteTermos ?? false,
      assinaturaResponsavel: widget.catequizando?.assinaturaResponsavel,
      dataAssinatura: widget.catequizando?.dataAssinatura,
      documentosAnexados: widget.catequizando?.documentosAnexados ?? [],
    );
  }

  Future<void> _save() async {
    final dados = _buildModel();
    if (dados == null) return;

    if (widget.vm != null) {
      final nome = dados.nome.trim();
      final existe = widget.vm!.catequizandos.any(
        (c) => c.nome.toLowerCase() == nome.toLowerCase() && c.id != dados.id,
      );
      if (existe) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Catequizando já cadastrado'),
            content: Text('Já existe um catequizando com o nome "$nome".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Ok'),
              ),
            ],
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (widget.onSave != null) {
        widget.onSave!(dados, _selectedTurmaId);
      } else if (widget.vm != null) {
        if (_isEditing) {
          await widget.vm!.updateCatequizando(dados);
          if (_selectedTurmaId != null && widget.matriculaVm != null) {
            await widget.matriculaVm!.matricular(dados.id, _selectedTurmaId!);
          }
        } else {
          final novoId = await widget.vm!.addCatequizando(dados);
          if (_selectedTurmaId != null && widget.matriculaVm != null) {
            await widget.matriculaVm!.matricular(novoId, _selectedTurmaId!);
          }
        }
        if (mounted) Navigator.of(context).pop();
      }
    } catch (_) {
      // Opcional: Tratar exceção aqui
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showStatusLegenda() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            const Text('Significado de cada status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusLegenda(theme, 'Em Andamento', 'Cursando normalmente. Padrão ao cadastrar.'),
            const SizedBox(height: 14),
            _statusLegenda(theme, 'Formado', 'Concluiu o ciclo completo de catequese.'),
            const SizedBox(height: 14),
            _statusLegenda(theme, 'Desistente', 'Abandonou o processo por vontade própria.'),
            const SizedBox(height: 14),
            _statusLegenda(theme, 'Transferido', 'Saiu para outra paróquia / comunidade.'),
            const SizedBox(height: 14),
            _statusLegenda(theme, 'Inativo', 'Sem matrícula ativa, mas pode retornar.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  // Helper para padronizar o visual dos inputs em todo o formulário
  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData prefixIcon,
    required ColorScheme colors,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, size: 20),
      suffixIcon: suffixIcon,
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
                        _isEditing ? 'Editar Catequizando' : 'Novo Catequizando',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isEditing ? 'Atualize as informações do cadastro' : 'Preencha as informações do novo cadastro',
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

          // Corpo do Formulário com Rolagem Segura e Layout Adaptativo
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Identificação', Icons.person_search_rounded, theme),
                    const SizedBox(height: 12),

                    // Campo Nome completo
                    TextFormField(
                      controller: _nomeCtrl,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration(
                        label: 'Nome Completo',
                        hint: 'Nome completo do catequizando',
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

                    // Linha com Sexo e Data de Nascimento lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _sexo,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration(
                              label: 'Sexo',
                              prefixIcon: Icons.wc_rounded,
                              colors: colors,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                              DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                            ],
                            onChanged: (v) => setState(() => _sexo = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _dataNascimentoCtrl,
                            readOnly: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration(
                              label: 'Data de Nascimento',
                              hint: 'Selecionar data',
                              prefixIcon: Icons.cake_outlined,
                              suffixIcon: const Icon(Icons.edit_calendar_rounded, size: 20),
                              colors: colors,
                            ),
                            onTap: () async {
                              final data = await showDatePicker(
                                context: context,
                                initialDate: _dataNascimento ?? DateTime(2010),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                locale: const Locale('pt', 'BR'),
                              );
                              if (data != null) {
                                setState(() {
                                  _dataNascimento = data;
                                  _dataNascimentoCtrl.text = '${data.day.toString().padLeft(2, '0')}/'
                                      '${data.month.toString().padLeft(2, '0')}/'
                                      '${data.year}  ·  ${_calcularIdade(data)} anos';
                                });
                              }
                            },
                            validator: (_) => _dataNascimento == null ? 'Campo obrigatório' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Linha com Turma e Status lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTurmaId,
                            isExpanded: true,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration(
                              label: 'Turma',
                              hint: 'Selecione a turma',
                              prefixIcon: Icons.auto_stories_rounded,
                              colors: colors,
                            ),
                            items: widget.turmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                            onChanged: (v) {
                              setState(() => _selectedTurmaId = v);
                            },
                            validator: (v) => v == null ? 'Selecione uma turma' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            decoration: _buildInputDecoration(
                              label: 'Status do Catequizando',
                              prefixIcon: Icons.info_outline_rounded,
                              colors: colors,
                            ),
                            items: Catequizando.statusOptions.map((s) =>
                              DropdownMenuItem(value: s, child: Text(s))
                            ).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Link para a legenda de status
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _showStatusLegenda,
                        icon: Icon(Icons.help_outline_rounded, size: 16, color: colors.primary),
                        label: Text('Ver significados dos status', style: TextStyle(color: colors.primary, fontSize: 12)),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // SEÇÃO: HISTÓRICO SACRAMENTAL
                    _buildSectionHeader('Histórico Sacramental', Icons.check_circle_outline_rounded, theme),
                    const SizedBox(height: 12),
                    radioGroup<bool>(
                      label: 'Já é Batizado(a)?',
                      value: _batizado,
                      options: const [true, false],
                      labels: const ['Sim', 'Não'],
                      theme: theme,
                      onChanged: (v) => setState(() => _batizado = v),
                    ),
                    if (_batizado) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _localBatismoCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Detalhes do Batismo (opcional)',
                          hint: 'Igreja, data, padre...',
                          prefixIcon: Icons.church_rounded,
                          colors: colors,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    radioGroup<bool>(
                      label: 'Já fez a Primeira Eucaristia?',
                      value: _fezPrimeiraEucaristia,
                      options: const [true, false],
                      labels: const ['Sim', 'Não'],
                      theme: theme,
                      onChanged: (v) => setState(() => _fezPrimeiraEucaristia = v),
                    ),
                    if (_fezPrimeiraEucaristia == true) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _detalheEucaristiaCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Detalhes da Primeira Eucaristia (opcional)',
                          hint: 'Igreja, data, padre...',
                          prefixIcon: Icons.edit_note_rounded,
                          colors: colors,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    radioGroup<bool>(
                      label: 'Já recebeu a Crisma?',
                      value: _fezCrisma,
                      options: const [true, false],
                      labels: const ['Sim', 'Não'],
                      theme: theme,
                      onChanged: (v) => setState(() => _fezCrisma = v),
                    ),
                    if (_fezCrisma == true) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _detalheCrismaCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Detalhes da Crisma (opcional)',
                          hint: 'Igreja, data, padre...',
                          prefixIcon: Icons.edit_note_rounded,
                          colors: colors,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // SEÇÃO: CONTATOS E RESPONSÁVEIS
                    _buildSectionHeader('Contatos e Responsáveis', Icons.contacts_rounded, theme),
                    const SizedBox(height: 12),

                    // Linha com Responsável e Parentesco lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _responsavelCtrl,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration(
                              label: 'Nome do Responsável Principal',
                              prefixIcon: Icons.person_outline_rounded,
                              colors: colors,
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _parentesco,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: _buildInputDecoration(
                              label: 'Parentesco',
                              prefixIcon: Icons.family_restroom_rounded,
                              colors: colors,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Mãe', child: Text('Mãe')),
                              DropdownMenuItem(value: 'Pai', child: Text('Pai')),
                              DropdownMenuItem(value: 'Avó', child: Text('Avó')),
                              DropdownMenuItem(value: 'Avô', child: Text('Avô')),
                              DropdownMenuItem(value: 'Tio(a)', child: Text('Tio(a)')),
                              DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                            ],
                            onChanged: (v) => setState(() => _parentesco = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Telefone / WhatsApp
                    TextFormField(
                      controller: _telefoneCtrl,
                      inputFormatters: [_telefoneFormatter],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration(
                        label: 'Telefone / WhatsApp',
                        hint: '(62) 99999-9999',
                        prefixIcon: Icons.phone_outlined,
                        colors: colors,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Endereço (Rua)
                    TextFormField(
                      controller: _enderecoCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Endereço (Rua)',
                        hint: 'Nome da rua / logradouro',
                        prefixIcon: Icons.map_rounded,
                        colors: colors,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Linha com CEP, Número e Bairro lado a lado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cepCtrl,
                            decoration: _buildInputDecoration(
                              label: 'CEP',
                              hint: '00000-000',
                              prefixIcon: Icons.mail_outline_rounded,
                              colors: colors,
                            ),
                            keyboardType: TextInputType.streetAddress,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _numeroCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Número',
                              hint: 'S/N',
                              prefixIcon: Icons.numbers_rounded,
                              colors: colors,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _bairroCtrl,
                            decoration: _buildInputDecoration(
                              label: 'Bairro',
                              hint: 'Nome do bairro',
                              prefixIcon: Icons.location_city_rounded,
                              colors: colors,
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SEÇÃO: SAÚDE E CUIDADOS
                    _buildSectionHeader('Saúde e Cuidados', Icons.healing_rounded, theme),
                    const SizedBox(height: 12),
                    radioGroup<bool>(
                      label: 'Possui alergia, problema de saúde ou restrição?',
                      value: _possuiRestricao,
                      options: const [true, false],
                      labels: const ['Sim', 'Não'],
                      theme: theme,
                      onChanged: (v) => setState(() => _possuiRestricao = v),
                    ),
                    if (_possuiRestricao) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _detalheRestricaoCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Detalhamento',
                          hint: 'Descreva as alergias, restrições ou cuidados necessários',
                          prefixIcon: Icons.edit_note_rounded,
                          colors: colors,
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // SEÇÃO: OBSERVAÇÕES GERAIS
                    _buildSectionHeader('Observações Gerais', Icons.notes_rounded, theme),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _observacoesCtrl,
                      decoration: _buildInputDecoration(
                        label: 'Observações Gerais',
                        hint: 'Descreva as observações',
                        prefixIcon: Icons.notes_rounded,
                        colors: colors,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Botões de Ação do Rodapé com estado de carregamento
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