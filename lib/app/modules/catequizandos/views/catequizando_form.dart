import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';

Widget sectionHeader(String title, IconData icon, ThemeData theme) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
      const SizedBox(width: 10),
      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
    ],
  );
}

Widget radioGroup<T>({
  required String label,
  required T value,
  required List<T> options,
  required List<String> labels,
  required ThemeData theme,
  required ValueChanged<T> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Row(
        children: List.generate(options.length, (i) {
          final selected = value == options[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < options.length - 1 ? 12 : 0),
              child: InkWell(
                onTap: () => onChanged(options[i]),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
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
  final List<String> turmas;
  final double width;
  final void Function(Catequizando dados)? onSave;

  const CatequizandoForm({
    super.key,
    this.catequizando,
    this.vm,
    this.turmas = const [],
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
  late final TextEditingController _detalheRestricaoCtrl;
  late final TextEditingController _responsavelCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _turmaCtrl;
  late final TextEditingController _cepCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _bairroCtrl;
  late final GlobalKey<FormState> _formKey;

  late final MaskTextInputFormatter _telefoneFormatter;

  String _sexo = 'Masculino';
  DateTime? _dataNascimento;
  bool _batizado = false;
  bool? _fezPrimeiraEucaristia;
  String _parentesco = 'Mãe';
  bool _possuiRestricao = false;

  bool get _isEditing => widget.catequizando != null;

  @override
  void initState() {
    super.initState();
    final c = widget.catequizando;
    _nomeCtrl = TextEditingController(text: c?.nome ?? '');
    _localBatismoCtrl = TextEditingController(text: c?.localBatismo ?? '');
    _detalheRestricaoCtrl = TextEditingController(text: c?.detalheRestricao ?? '');
    _responsavelCtrl = TextEditingController(text: c?.responsavel ?? '');
    _telefoneCtrl = TextEditingController(text: c?.telefone ?? '');
    _turmaCtrl = TextEditingController(text: c?.turmaNome ?? '');
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
      _fezPrimeiraEucaristia = c.fezPrimeiraEucaristia;
      _parentesco = c.parentesco;
      _possuiRestricao = c.possuiRestricao;
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
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _dataNascimentoCtrl.dispose();
    _localBatismoCtrl.dispose();
    _detalheRestricaoCtrl.dispose();
    _responsavelCtrl.dispose();
    _telefoneCtrl.dispose();
    _turmaCtrl.dispose();
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
      turmaNome: _turmaCtrl.text.trim(),
      batizado: _batizado,
      localBatismo: _batizado ? _localBatismoCtrl.text.trim() : null,
      fezPrimeiraEucaristia: _batizado ? _fezPrimeiraEucaristia : null,
      responsavel: _responsavelCtrl.text.trim(),
      parentesco: _parentesco,
      telefone: _telefoneCtrl.text.trim(),
      cep: _cepCtrl.text.trim(),
      endereco: _enderecoCtrl.text.trim(),
      numero: _numeroCtrl.text.trim(),
      bairro: _bairroCtrl.text.trim(),
      possuiRestricao: _possuiRestricao,
      detalheRestricao: _possuiRestricao ? _detalheRestricaoCtrl.text.trim() : null,
      aceiteTermos: widget.catequizando?.aceiteTermos ?? false,
      assinaturaResponsavel: widget.catequizando?.assinaturaResponsavel,
      dataAssinatura: widget.catequizando?.dataAssinatura,
      documentosAnexados: widget.catequizando?.documentosAnexados ?? [],
    );
  }

  void _save() {
    final dados = _buildModel();
    if (dados == null) return;

    if (widget.onSave != null) {
      widget.onSave!(dados);
    } else if (widget.vm != null) {
      if (_isEditing) {
        widget.vm!.updateCatequizando(dados);
      } else {
        widget.vm!.addCatequizando(dados);
      }
      Navigator.of(context).pop();
    }
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
                      _isEditing ? 'Editar Catequizando' : 'Novo Catequizando',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeader('Identificação', Icons.person_search_rounded, theme),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeCtrl,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo',
                            hintText: 'Nome completo do catequizando',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _sexo,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Sexo',
                            prefixIcon: Icon(Icons.wc_rounded),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                            DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                          ],
                          onChanged: (v) => setState(() => _sexo = v!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dataNascimentoCtrl,
                          readOnly: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Data de Nascimento',
                            hintText: 'Selecionar data',
                            prefixIcon: Icon(Icons.cake_rounded),
                            suffixIcon: Icon(Icons.edit_calendar_rounded),
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
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: widget.turmas.contains(_turmaCtrl.text) ? _turmaCtrl.text : null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Turma',
                            hintText: 'Selecione a turma',
                            prefixIcon: Icon(Icons.auto_stories_rounded),
                          ),
                          items: widget.turmas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) {
                            _turmaCtrl.text = v ?? '';
                            setState(() {});
                          },
                          validator: (v) => v == null ? 'Selecione uma turma' : null,
                        ),
                        const SizedBox(height: 24),
                        sectionHeader('Histórico Sacramental', Icons.check_circle_outline_rounded, theme),
                        const SizedBox(height: 16),
                        radioGroup<bool>(
                          label: 'Já é Batizado(a)?',
                          value: _batizado,
                          options: const [true, false],
                          labels: const ['Sim', 'Não'],
                          theme: theme,
                          onChanged: (v) => setState(() => _batizado = v),
                        ),
                        if (_batizado) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _localBatismoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Local do Batismo (opcional)',
                              hintText: 'Igreja / Paróquia onde foi batizado',
                              prefixIcon: Icon(Icons.church_rounded),
                            ),
                          ),
                        ],
                        if (_batizado &&
                            (_turmaCtrl.text.toLowerCase().contains('perseverança') ||
                             _turmaCtrl.text.toLowerCase().contains('perseveranca') ||
                             _turmaCtrl.text.toLowerCase().contains('crisma'))) ...[
                          const SizedBox(height: 16),
                          radioGroup<bool>(
                            label: 'Já fez a Primeira Eucaristia?',
                            value: _fezPrimeiraEucaristia ?? false,
                            options: const [true, false],
                            labels: const ['Sim', 'Não'],
                            theme: theme,
                            onChanged: (v) => setState(() => _fezPrimeiraEucaristia = v),
                          ),
                        ],
                        const SizedBox(height: 24),
                        sectionHeader('Contatos e Responsáveis', Icons.contacts_rounded, theme),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _responsavelCtrl,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Responsável Principal',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _parentesco,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Parentesco',
                            prefixIcon: Icon(Icons.family_restroom_rounded),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefoneCtrl,
                          inputFormatters: [_telefoneFormatter],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Telefone / WhatsApp',
                            hintText: '(62) 99999-9999',
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(flex: 2, child: TextFormField(
                              controller: _cepCtrl,
                              decoration: const InputDecoration(
                                labelText: 'CEP',
                                hintText: '00000-000',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              keyboardType: TextInputType.streetAddress,
                            )),
                            const SizedBox(width: 12),
                            Expanded(flex: 1, child: TextFormField(
                              controller: _numeroCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Número',
                                hintText: 'S/N',
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _enderecoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Endereço (Rua)',
                            hintText: 'Nome da rua / logradouro',
                            prefixIcon: Icon(Icons.map_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bairroCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Bairro',
                            hintText: 'Nome do bairro',
                            prefixIcon: Icon(Icons.location_city_rounded),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 24),
                        sectionHeader('Saúde e Cuidados', Icons.healing_rounded, theme),
                        const SizedBox(height: 16),
                        radioGroup<bool>(
                          label: 'Possui alergia, problema de saúde ou restrição?',
                          value: _possuiRestricao,
                          options: const [true, false],
                          labels: const ['Sim', 'Não'],
                          theme: theme,
                          onChanged: (v) => setState(() => _possuiRestricao = v),
                        ),
                        if (_possuiRestricao) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _detalheRestricaoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Detalhamento',
                              hintText: 'Descreva as alergias, restrições ou cuidados necessários',
                              prefixIcon: Icon(Icons.edit_note_rounded),
                            ),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
