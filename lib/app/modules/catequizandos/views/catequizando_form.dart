import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/utils/certificate_generator.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';

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

Widget _statusLegenda(ThemeData theme, String status, String descricao) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 2),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.tertiary,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            children: [
              TextSpan(text: '$status: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: descricao),
            ],
          ),
        ),
      ),
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
  late final TextEditingController _detalheRestricaoCtrl;
  late final TextEditingController _responsavelCtrl;
  late final TextEditingController _telefoneCtrl;
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
  String? _selectedTurmaId;
  String _status = 'Em Andamento';

  bool get _isEditing => widget.catequizando != null;

  bool get _requerEucaristia {
    if (_selectedTurmaId == null) return false;
    final turma = widget.turmas.firstWhereOrNull((t) => t.id == _selectedTurmaId);
    final nome = turma?.nome.toLowerCase() ?? '';
    return nome.contains('perseverança') ||
        nome.contains('perseveranca') ||
        nome.contains('crisma');
  }

  @override
  void initState() {
    super.initState();
    final c = widget.catequizando;
    _nomeCtrl = TextEditingController(text: c?.nome ?? '');
    _localBatismoCtrl = TextEditingController(text: c?.localBatismo ?? '');
    _detalheRestricaoCtrl = TextEditingController(text: c?.detalheRestricao ?? '');
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
      _fezPrimeiraEucaristia = c.fezPrimeiraEucaristia;
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
    _detalheRestricaoCtrl.dispose();
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
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Apenas ficha de cadastro'),
                subtitle: const Text('Exportar somente os dados cadastrais'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportPdf(withHistory: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Ficha completa com histórico'),
                subtitle: const Text('Inclui o histórico de matrículas'),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportPdf(withHistory: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportPdf({required bool withHistory}) async {
    final dados = _buildModel();
    if (dados == null) return;
    await CertificateGenerator.generateFicha(dados, withHistory: withHistory);
  }

  void _showStatusLegenda() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Significado de cada status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusLegenda(theme, 'Em Andamento', 'Cursando normalmente. Padrão ao cadastrar.'),
            const SizedBox(height: 12),
            _statusLegenda(theme, 'Formado', 'Concluiu o ciclo completo de catequese.'),
            const SizedBox(height: 12),
            _statusLegenda(theme, 'Desistente', 'Abandonou o processo por vontade própria.'),
            const SizedBox(height: 12),
            _statusLegenda(theme, 'Transferido', 'Saiu para outra paróquia / comunidade.'),
            const SizedBox(height: 12),
            _statusLegenda(theme, 'Inativo', 'Sem matrícula ativa, mas pode retornar.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
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
                          value: _selectedTurmaId,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Turma',
                            hintText: 'Selecione a turma',
                            prefixIcon: Icon(Icons.auto_stories_rounded),
                          ),
                          items: widget.turmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                          onChanged: (v) {
                            setState(() => _selectedTurmaId = v);
                          },
                          validator: (v) => v == null ? 'Selecione uma turma' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status do Catequizando',
                            prefixIcon: Icon(Icons.info_outline_rounded),
                          ),
                          items: Catequizando.statusOptions.map((s) =>
                            DropdownMenuItem(value: s, child: Text(s))
                          ).toList(),
                          onChanged: (v) => setState(() => _status = v!),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.help_outline_rounded, size: 18, color: theme.colorScheme.primary),
                              tooltip: 'Significado de cada status',
                              onPressed: _showStatusLegenda,
                            ),
                          ),
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
                        if (_batizado && _requerEucaristia) ...[
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
                  children: [
                    if (_isEditing)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: const Text('Exportar PDF'),
                        onPressed: _showExportOptions,
                      )
                    else
                      const Spacer(),
                    const Spacer(),
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
