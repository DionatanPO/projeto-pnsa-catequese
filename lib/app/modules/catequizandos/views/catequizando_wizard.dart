import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/utils/certificate_generator.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';

class CatequizandoWizardPage extends StatefulWidget {
  final CatequizandoViewModel vm;
  final List<String> turmas;
  const CatequizandoWizardPage({super.key, required this.vm, required this.turmas});

  @override
  State<CatequizandoWizardPage> createState() => _CatequizandoWizardPageState();
}

class _CatequizandoWizardPageState extends State<CatequizandoWizardPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final dataNascimentoCtrl = TextEditingController();
  final localBatismoCtrl = TextEditingController();
  final detalheRestricaoCtrl = TextEditingController();
  final responsavelCtrl = TextEditingController();
  final telefoneCtrl = TextEditingController();
  final cepCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final numeroCtrl = TextEditingController();
  final bairroCtrl = TextEditingController();

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  // Assumindo que precisa de um CPF, se não for CPF, ajuste a máscara.
  // Como não vi CPF no formulário mas você pediu, vou adicionar a máscara caso adicione o campo.
  final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String _sexo = 'Masculino';
  DateTime? _dataNascimento;
  String? _turmaSelecionada;
  bool _batizado = true;
  bool? _fezPrimeiraEucaristia;
  String _parentesco = 'Mãe';
  bool _possuiRestricao = false;
  bool _aceiteTermos = false;
  bool _submitting = false;
  final List<PlatformFile> _arquivosAnexados = [];

  final _stepLabels = [
    'Identificação',
    'Histórico Sacramental',
    'Contatos',
    'Saúde',
    'Documentos',
    'Termos',
  ];

  @override
  void dispose() {
    for (final ctrl in [
      nomeCtrl, dataNascimentoCtrl, localBatismoCtrl, detalheRestricaoCtrl,
      responsavelCtrl, telefoneCtrl, cepCtrl, enderecoCtrl,
      numeroCtrl, bairroCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  bool get _podeAvancar {
    if (!_formKey.currentState!.validate()) return false;
    if (_currentStep == 0 && _dataNascimento == null) return false;
    return true;
  }

  bool get _requerEucaristia =>
      _turmaSelecionada != null &&
      (_turmaSelecionada!.toLowerCase().contains('perseverança') ||
       _turmaSelecionada!.toLowerCase().contains('perseveranca') ||
       _turmaSelecionada!.toLowerCase().contains('crisma'));

  void _avancar() {
    if (!_podeAvancar) return;
    if (_currentStep == 1 && _batizado && _requerEucaristia && _fezPrimeiraEucaristia == null) {
      Get.snackbar('Atenção', 'Informe se já fez a Primeira Eucaristia');
      return;
    }
    setState(() => _currentStep++);
  }

  void _voltar() {
    setState(() => _currentStep--);
  }

  Future<void> _finalizar() async {
    if (!_aceiteTermos) {
      Get.snackbar('Atenção', 'Aceite os termos para finalizar');
      return;
    }
    if (_dataNascimento == null) {
      Get.snackbar('Erro', 'Data de nascimento não informada');
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final c = Catequizando(
      nome: nomeCtrl.text.trim(),
      sexo: _sexo,
      dataNascimento: _dataNascimento!,
      turmaNome: _turmaSelecionada!,
      batizado: _batizado,
      localBatismo: _batizado ? localBatismoCtrl.text.trim() : null,
      fezPrimeiraEucaristia: _batizado && _requerEucaristia ? _fezPrimeiraEucaristia! : null,
      responsavel: responsavelCtrl.text.trim(),
      parentesco: _parentesco,
      telefone: telefoneCtrl.text.trim(),
      cep: cepCtrl.text.trim(),
      endereco: enderecoCtrl.text.trim(),
      numero: numeroCtrl.text.trim(),
      bairro: bairroCtrl.text.trim(),
      possuiRestricao: _possuiRestricao,
      detalheRestricao: _possuiRestricao ? detalheRestricaoCtrl.text.trim() : null,
      aceiteTermos: _aceiteTermos,
      documentosAnexados: _arquivosAnexados.map((f) => '${f.name} (${(f.extension ?? '').toUpperCase()}, ${_formatBytes(f.size)})').toList(),
    );

    widget.vm.addCatequizando(c);
    setState(() => _submitting = false);
    if (!mounted) return;
    
    // Pergunta se deseja emitir o certificado
    final emitir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso'),
        content: Text('${c.nome} foi cadastrado(a) com sucesso. Deseja emitir o certificado de cadastro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );

    if (emitir == true) {
      await CertificateGenerator.generate(c);
    }
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${c.nome} foi cadastrado(a) com sucesso.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLarge = MediaQuery.of(context).size.width > 900;

    if (isLarge) {
      return Scaffold(
        appBar: _buildDesktopAppBar(theme),
        body: Form(
          key: _formKey,
          child: Row(
            children: [
              _desktopSidebar(theme),
              Container(width: 1, color: theme.dividerColor.withOpacity(0.5)),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(40, 32, 40, 8),
                        child: _buildStepContent(theme),
                      ),
                    ),
                    _buildBottomBar(theme, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Catequizando'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _stepIndicator(theme, false),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: SingleChildScrollView(
                  child: _buildStepContent(theme),
                ),
              ),
            ),
            _buildBottomBar(theme, false),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(ThemeData theme) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add_rounded, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text('Novo Catequizando'),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _desktopSidebar(ThemeData theme) {
    return Container(
      width: 200,
      color: theme.colorScheme.surfaceContainerLow.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_stepLabels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return _sidebarStepItem(
            number: i + 1,
            label: _stepLabels[i],
            isActive: isActive,
            isDone: isDone,
            isLast: i == _stepLabels.length - 1,
            theme: theme,
          );
        }),
      ),
    );
  }

  Widget _sidebarStepItem({
    required int number,
    required String label,
    required bool isActive,
    required bool isDone,
    required bool isLast,
    required ThemeData theme,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? theme.colorScheme.primary
                      : isDone
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary)
                      : Text(
                          '$number',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isActive
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? theme.colorScheme.primary.withOpacity(0.4)
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5, bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? theme.colorScheme.primary
                          : isDone
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Passo atual',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(ThemeData theme, bool isLarge) {
    final total = _stepLabels.length;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: isLarge ? 40 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: _stepIndicatorContent(total, theme),
    );
  }

  Widget _stepIndicatorContent(int total, ThemeData theme) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? theme.colorScheme.primary
                      : isDone
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded, size: 18, color: theme.colorScheme.primary)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isActive
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 32, // Fixed height for the title area to ensure alignment
                child: Text(
                  _stepLabels[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        switch (_currentStep) {
          0 => _step1(theme),
          1 => _step2(theme),
          2 => _step3(theme),
          3 => _step4(theme),
          4 => _step5(theme),
          _ => _step6(theme),
        },
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 1: Identificação ──
  Widget _step1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Identificação', 'Dados pessoais e seleção de turma', Icons.person_search_rounded, theme),
        const SizedBox(height: 24),
        TextFormField(
          controller: nomeCtrl,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Nome Completo',
            hintText: 'Nome completo do catequizando',
            prefixIcon: Icon(Icons.person_rounded),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        TextFormField(
          controller: dataNascimentoCtrl,
          readOnly: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Data de Nascimento',
            hintText: 'Selecionar data',
            prefixIcon: Icon(Icons.cake_rounded),
            suffixIcon: Icon(Icons.edit_calendar_rounded),
          ),
          onTap: () => _selecionarData(theme),
          validator: (_) => _dataNascimento == null ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _turmaSelecionada,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Turma',
            hintText: 'Selecione a turma',
            prefixIcon: Icon(Icons.auto_stories_rounded),
          ),
          items: widget.turmas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) {
            setState(() {
              _turmaSelecionada = v;
              if (!_requerEucaristia) _fezPrimeiraEucaristia = null;
            });
          },
          validator: (v) => null, // Opcional, sem validação
        ),
      ],
    );
  }

  // ── Step 2: Histórico Sacramental ──
  Widget _step2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Histórico Sacramental', 'Batismo e Primeira Eucaristia', Icons.check_circle_outline_rounded, theme),
        const SizedBox(height: 24),
        _radioGroup<bool>(
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
            controller: localBatismoCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Local do Batismo (opcional)',
              hintText: 'Igreja / Paróquia onde foi batizado',
              prefixIcon: Icon(Icons.church_rounded),
            ),
          ),
        ],
        if (_batizado && _requerEucaristia) ...[
          const SizedBox(height: 20),
          _radioGroup<bool>(
            label: 'Já fez a Primeira Eucaristia?',
            value: _fezPrimeiraEucaristia ?? false,
            options: const [true, false],
            labels: const ['Sim', 'Não'],
            theme: theme,
            onChanged: (v) => setState(() => _fezPrimeiraEucaristia = v),
          ),
        ],
        if (_batizado) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Você poderá anexar a foto da Certidão de Batismo após o cadastro.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Step 3: Contatos e Responsáveis ──
  Widget _step3(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Contatos e Responsáveis', 'Informações do responsável legal', Icons.contacts_rounded, theme),
        const SizedBox(height: 24),
        TextFormField(
          controller: responsavelCtrl,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Nome do Responsável Principal',
            prefixIcon: Icon(Icons.person_rounded),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 20),
        TextFormField(
          controller: telefoneCtrl,
          inputFormatters: [telefoneFormatter],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Telefone / WhatsApp',
            hintText: '(62) 99999-9999',
            prefixIcon: Icon(Icons.phone_rounded),
          ),
          keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(flex: 2, child: TextFormField(
              controller: cepCtrl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              keyboardType: TextInputType.streetAddress,
            )),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: TextFormField(
              controller: numeroCtrl,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Número',
                hintText: 'S/N',
              ),
            )),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: enderecoCtrl,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Endereço (Rua)',
            hintText: 'Nome da rua / logradouro',
            prefixIcon: Icon(Icons.map_rounded),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: bairroCtrl,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Bairro',
            hintText: 'Nome do bairro',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  // ── Step 4: Saúde e Cuidados ──
  Widget _step4(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Saúde e Cuidados', 'Informações médicas importantes', Icons.healing_rounded, theme),
        const SizedBox(height: 24),
        _radioGroup<bool>(
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
            controller: detalheRestricaoCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Detalhamento',
              hintText: 'Descreva as alergias, restrições ou cuidados necessários',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ],
    );
  }

  // ── Step 5: Documentos Necessários ──
  Widget _step5(ThemeData theme) {
    final docs = [
      'Certidão de Nascimento e/ou RG e CPF',
      'Certidão de Batismo',
      'Comprovante de Endereço',
      'Documentos pessoais (com foto) dos pais',
    ];
    if (_batizado && _fezPrimeiraEucaristia == true) {
      docs.insert(3, 'Certidão de Primeira Eucaristia');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Documentos Necessários', 'Selecione os arquivos para anexar', Icons.folder_copy_rounded, theme),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _selecionarTodosDocumentos(),
            icon: Icon(Icons.cloud_upload_rounded),
            label: Text('Adicionar documentações'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Documentos necessários:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...docs.map((doc) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(doc, style: TextStyle(fontSize: 14))),
            ],
          ),
        )),
        if (_arquivosAnexados.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Arquivos anexados:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ..._arquivosAnexados.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file_rounded, size: 22, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(f.extension ?? '').toUpperCase()}  ·  ${_formatBytes(f.size)}',
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.error),
                      onPressed: () => setState(() => _arquivosAnexados.removeAt(i)),
                      tooltip: 'Remover arquivo',
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _selecionarTodosDocumentos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _arquivosAnexados.addAll(result.files));
    }
  }

  // ── Step 6: Termos e Confirmação ──
  Widget _step6(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Termo de Compromisso', 'Leia e aceite os termos', Icons.verified_rounded, theme),
        const SizedBox(height: 20),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TERMO DE COMPROMISSO', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text(
                    'Eu, ${responsavelCtrl.text.isNotEmpty ? responsavelCtrl.text : '_________________________'}, '
                    'responsável pelo catequizando acima descrito, declaro que estou ciente de que a catequese '
                    'é um processo contínuo de formação cristã, da igreja e da família, e comprometo-me a:',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _termItem('Incentivar a participação assídua nos encontros;'),
                  _termItem('Acompanhar e motivar a participação na Santa Missa;'),
                  _termItem('Comprometo-me a garantir a frequência mínima de 75% nos encontros;'),
                  _termItem('Justificar previamente qualquer falta ou dificuldade;'),
                  _termItem('Participar de reuniões e formações quando convocado(a);'),
                  _termItem('Colaborar com as atividades propostas pela Paróquia Nossa Senhora Auxiliadora;'),
                  const SizedBox(height: 8),
                  Text(
                    'Em caso de faltas excessivas, indisciplina grave ou desinteresse contínuo, '
                    'o catequizando não seguirá para o ano subsequente, inclusive o sacramento '
                    'poderá ser adiado para o próximo ano, ou até que seja cumprido todo itinerário proposto.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  _termItem('Autorizo o uso de imagem para fins pastorais e evangelizadores, sem fins lucrativos.'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _aceiteTermos,
          onChanged: (v) => setState(() => _aceiteTermos = v!),
          title: Text(
            'Li e aceito os termos acima',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.tertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ao marcar "Li e aceito os termos acima", '
                  'você confirma que as informações estão corretas e concorda com os termos.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _termItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, bool isLarge) {
    return Container(
      padding: EdgeInsets.fromLTRB(isLarge ? 40 : 24, 12, isLarge ? 40 : 24, isLarge ? 24 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: isLarge
          ? _bottomBarContent(theme, isLarge)
          : SafeArea(child: _bottomBarContent(theme, isLarge)),
    );
  }

  Widget _bottomBarContent(ThemeData theme, bool isLarge) {
    final btnPad = isLarge ? 20.0 : 14.0;
    return Row(
      children: [
        if (_currentStep > 0)
          OutlinedButton.icon(
            onPressed: _voltar,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Voltar'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: btnPad),
              textStyle: TextStyle(fontSize: isLarge ? 14 : 13),
            ),
          )
        else
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: btnPad),
            ),
            child: const Text('Cancelar'),
          ),
        const SizedBox(width: 12),
        if (_currentStep < 5)
          FilledButton.icon(
            onPressed: _avancar,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Avançar'),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: btnPad),
              textStyle: TextStyle(fontSize: isLarge ? 14 : 13),
            ),
          )
        else
          FilledButton.icon(
            onPressed: _submitting ? null : _finalizar,
            icon: _submitting
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(_submitting ? 'Salvando...' : 'Finalizar Inscrição'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: btnPad),
              textStyle: TextStyle(fontSize: isLarge ? 14 : 13),
            ),
          ),
      ],
    );
  }

  // ── Helpers ──

  Widget _stepHeader(String title, String subtitle, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _radioGroup<T>({
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

  int _calcularIdade(DateTime data) {
    final hoje = DateTime.now();
    int age = hoje.year - data.year;
    if (hoje.month < data.month ||
        (hoje.month == data.month && hoje.day < data.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selecionarData(ThemeData theme) async {
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
        dataNascimentoCtrl.text = '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year}  ·  ${_calcularIdade(data)} anos';
      });
    }
  }


}
