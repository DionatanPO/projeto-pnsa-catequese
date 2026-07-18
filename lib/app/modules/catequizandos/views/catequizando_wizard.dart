import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:plataforma_pnsa_catequese/app/core/services/google_drive_service.dart';
import '../models/catequizando_model.dart';
import '../models/documento_anexado.dart';
import '../viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import 'catequizando_form.dart';
import '../../configuracao/views/configuracao_drive_page.dart';

class CatequizandoWizardPage extends StatefulWidget {
  final CatequizandoViewModel vm;
  final List<TurmaModel> turmas;
  final MatriculaViewModel matriculaVm;
  const CatequizandoWizardPage({
    super.key,
    required this.vm,
    required this.turmas,
    required this.matriculaVm,
  });

  @override
  State<CatequizandoWizardPage> createState() => _CatequizandoWizardPageState();
}

class _CatequizandoWizardPageState extends State<CatequizandoWizardPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final nomeCtrl = TextEditingController();
  final dataNascimentoCtrl = TextEditingController();
  final localBatismoCtrl = TextEditingController();
  final detalheEucaristiaCtrl = TextEditingController();
  final detalheCrismaCtrl = TextEditingController();
  final detalheRestricaoCtrl = TextEditingController();
  final observacoesCtrl = TextEditingController();
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
  String? _turmaSelecionadaId;
  bool _batizado = false;
  bool _fezPrimeiraEucaristia = false;
  bool _fezCrisma = false;
  String _parentesco = 'Mãe';
  bool _possuiRestricao = false;
  bool _submitting = false;
  String _status = 'Em Andamento';
  final List<PlatformFile> _arquivosAnexados = [];
  final GoogleDriveService _driveService = Get.find<GoogleDriveService>();
  String? _uploadStatus;

  final _stepLabels = [
    'Identificação',
    'Histórico Sacramental',
    'Contatos',
    'Saúde',
    'Documentos',
  ];

  @override
  void dispose() {
    for (final ctrl in [
      nomeCtrl, dataNascimentoCtrl, localBatismoCtrl, detalheRestricaoCtrl, observacoesCtrl,
      responsavelCtrl, telefoneCtrl, cepCtrl, enderecoCtrl,
      numeroCtrl, bairroCtrl,
    ]) {
      ctrl.dispose();
    }
    _driveService.dispose();
    super.dispose();
  }

  bool get _podeAvancar {
    if (!_formKey.currentState!.validate()) return false;
    if (_currentStep == 0 && _dataNascimento == null) return false;
    return true;
  }

  void _avancar() {
    if (!_podeAvancar) return;
    if (_currentStep == 0) {
      final nome = nomeCtrl.text.trim();
      final existe = widget.vm.catequizandos.any(
        (c) => c.nome.toLowerCase() == nome.toLowerCase(),
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
    setState(() => _currentStep++);
  }

  void _voltar() {
    setState(() => _currentStep--);
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

  Future<void> _finalizar() async {
    if (_dataNascimento == null) {
      Get.snackbar('Erro', 'Data de nascimento não informada');
      return;
    }
    setState(() => _submitting = true);

    List<DocumentoAnexado> docsEnviados = [];
    String? pastaCatequizandoId;

    if (_arquivosAnexados.isNotEmpty) {
      if (!_driveService.isReady) {
        setState(() => _submitting = false);
        await Get.dialog(AlertDialog(
          title: const Text('Drive não configurado'),
          content: const Text('Conecte a conta sistemapnsacatequese@gmail.com em "Config. Drive" para acessar os arquivos.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Fechar')),
            FilledButton(onPressed: () { Get.back(); Get.to(() => const ConfiguracaoDrivePage()); }, child: const Text('Config. Drive')),
          ],
        ));
        return;
      }

      try {
        setState(() => _uploadStatus = 'Criando pasta do catequizando...');
        pastaCatequizandoId = await _driveService.createFolder(
          nomeCtrl.text.trim(),
        );
        debugPrint('[Drive] Pasta criada: $pastaCatequizandoId');
      } catch (e) {
        debugPrint('[Drive] Erro ao criar pasta: $e');
        setState(() => _submitting = false);
        Get.snackbar('Erro', 'Falha ao criar pasta no Drive: $e');
        return;
      }

      for (int i = 0; i < _arquivosAnexados.length; i++) {
        final f = _arquivosAnexados[i];
        setState(() {
          _uploadStatus = 'Enviando ${f.name} (${i + 1}/${_arquivosAnexados.length})...';
        });

        try {
          Uint8List bytes;
          if (f.bytes != null) {
            bytes = f.bytes!;
          } else if (f.path != null) {
            bytes = await File(f.path!).readAsBytes();
          } else {
            debugPrint('[Drive] bytes e path nulos para ${f.name}');
            continue;
          }
          debugPrint('[Drive] Enviando: ${f.name}, tamanho: ${bytes.length}, pasta: $pastaCatequizandoId');

          final driveFile = await _driveService.uploadFile(
            bytes: bytes,
            nome: f.name,
            parentFolderId: pastaCatequizandoId,
          );

          debugPrint('[Drive] Arquivo enviado com sucesso: ${f.name} -> ID: ${driveFile.driveFileId}');
          docsEnviados.add(DocumentoAnexado(
            nome: f.name,
            extensao: f.extension ?? '',
            tamanho: f.size,
            driveFileId: driveFile.driveFileId,
            webViewLink: driveFile.webViewLink,
            downloadLink: driveFile.downloadLink,
          ));
        } catch (e) {
          debugPrint('[Drive] Erro ao enviar ${f.name}: $e');
          Get.snackbar(
            'Aviso',
            'Não foi possível enviar ${f.name}. O cadastro continuará sem este arquivo.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
      setState(() => _uploadStatus = null);
    }

    final c = Catequizando(
      nome: nomeCtrl.text.trim(),
      sexo: _sexo,
      dataNascimento: _dataNascimento!,
      batizado: _batizado,
      localBatismo: _batizado ? localBatismoCtrl.text.trim() : null,
      fezPrimeiraEucaristia: _fezPrimeiraEucaristia,
      detalheEucaristia: _fezPrimeiraEucaristia == true ? detalheEucaristiaCtrl.text.trim() : null,
      fezCrisma: _fezCrisma,
      detalheCrisma: _fezCrisma == true ? detalheCrismaCtrl.text.trim() : null,
      responsavel: responsavelCtrl.text.trim(),
      parentesco: _parentesco,
      telefone: telefoneCtrl.text.trim(),
      cep: cepCtrl.text.trim(),
      endereco: enderecoCtrl.text.trim(),
      numero: numeroCtrl.text.trim(),
      bairro: bairroCtrl.text.trim(),
      possuiRestricao: _possuiRestricao,
      detalheRestricao: _possuiRestricao ? detalheRestricaoCtrl.text.trim() : null,
      observacoes: observacoesCtrl.text.trim().isEmpty ? null : observacoesCtrl.text.trim(),
      status: _status,
      aceiteTermos: false,
      documentosAnexados: docsEnviados,
      driveFolderId: pastaCatequizandoId,
    );

    final novoId = await widget.vm.addCatequizando(c);
    if (_turmaSelecionadaId != null) {
      await widget.matriculaVm.matricular(novoId, _turmaSelecionadaId!);
    }
    setState(() => _submitting = false);
    if (!mounted) return;

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
      color: Colors.white,
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
    final colors = theme.colorScheme;
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
                  color: isActive || isDone
                      ? colors.primary.withOpacity(0.15)
                      : colors.surfaceContainerHighest,
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded, size: 16, color: colors.primary)
                      : Text(
                          '$number',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isActive ? colors.primary : colors.onSurfaceVariant,
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
                          ? colors.primary.withOpacity(0.4)
                          : colors.surfaceContainerHighest,
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
                      color: isActive || isDone
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Passo atual',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
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
    return Container(
      color: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
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
                        ? theme.colorScheme.onPrimary.withOpacity(0.25)
                        : isDone
                            ? theme.colorScheme.onPrimary.withOpacity(0.25)
                            : theme.colorScheme.onPrimary.withOpacity(0.15),
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, size: 18, color: theme.colorScheme.onPrimary)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: Text(
                    _stepLabels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
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
          _ => _step5(theme),
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
          value: _turmaSelecionadaId,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Turma',
            hintText: 'Selecione a turma',
            prefixIcon: Icon(Icons.auto_stories_rounded),
          ),
          items: widget.turmas.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nome))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _turmaSelecionadaId = v;
                    });
                  },
          validator: (v) => null,
        ),
        const SizedBox(height: 20),
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
      ],
    );
  }

  // ── Step 2: Histórico Sacramental ──
  Widget _step2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Histórico Sacramental', 'Batismo, Primeira Eucaristia e Crisma', Icons.check_circle_outline_rounded, theme),
        const SizedBox(height: 24),
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
            controller: localBatismoCtrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Detalhes do Batismo (opcional)',
              hintText: 'Igreja, data, padre...',
              prefixIcon: Icon(Icons.church_rounded),
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
            controller: detalheEucaristiaCtrl,
            decoration: const InputDecoration(
              labelText: 'Detalhes da Primeira Eucaristia (opcional)',
              hintText: 'Igreja, data, padre...',
              prefixIcon: Icon(Icons.edit_note_rounded),
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
            controller: detalheCrismaCtrl,
            decoration: const InputDecoration(
              labelText: 'Detalhes da Crisma (opcional)',
              hintText: 'Igreja, data, padre...',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
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
        const SizedBox(height: 24),
        _stepHeader('Observações Gerais', 'Informações adicionais', Icons.notes_rounded, theme),
        const SizedBox(height: 20),
        TextFormField(
          controller: observacoesCtrl,
          decoration: const InputDecoration(
            labelText: 'Observações Gerais',
            hintText: 'Descreva as observações',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
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
            label: Text('Adicionar documentos (PDF, Word — máx. 2 MB)'),
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
    if (!_driveService.isReady) {
      await Get.dialog(AlertDialog(
        title: const Text('Drive não configurado'),
        content: const Text('Conecte a conta sistemapnsacatequese@gmail.com em "Config. Drive" para anexar arquivos.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Fechar')),
          FilledButton(onPressed: () { Get.back(); Get.to(() => const ConfiguracaoDrivePage()); }, child: const Text('Config. Drive')),
        ],
      ));
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    const maxBytes = 2097152;
    final extOk = {'pdf', 'doc', 'docx'};
    final validFiles = result.files.where((f) {
      final ext = (f.extension ?? '').toLowerCase();
      if (!extOk.contains(ext)) {
        Get.snackbar('Formato inválido', '${f.name} não é PDF ou Word.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      if (f.size > maxBytes) {
        Get.snackbar('Arquivo muito grande', '${f.name} ultrapassa 2 MB.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      return true;
    }).toList();
    if (validFiles.isNotEmpty) {
      setState(() => _arquivosAnexados.addAll(validFiles));
    }
  }

  // ── Step 6: Termos e Confirmação ──
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
        if (_currentStep < 4)
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
            label: Text(_uploadStatus != null ? 'Enviando...' : 'Finalizar Inscrição'),
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

  Widget _statusLegenda(ThemeData theme, String status, String descricao) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white70,
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
