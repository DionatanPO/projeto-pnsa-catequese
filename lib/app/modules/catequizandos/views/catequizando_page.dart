import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:file_picker/file_picker.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';

void showDocumentosDialog(BuildContext context, CatequizandoViewModel vm,
    {required Catequizando catequizando}) {
  final theme = Theme.of(context);
  final docs = RxList<String>.from(catequizando.documentosAnexados);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder_copy_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Documentos', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        Text(catequizando.nome, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      allowMultiple: true,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      for (final f in result.files) {
                        docs.add('${f.name} (${(f.extension ?? '').toUpperCase()}, ${_formatBytes(f.size)})');
                      }
                    }
                  },
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Adicionar documentos'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                          const SizedBox(height: 8),
                          Text('Nenhum documento anexado', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final doc = docs[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.insert_drive_file_rounded, color: theme.colorScheme.primary),
                        ),
                        title: Text(doc, style: const TextStyle(fontSize: 13)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: Icon(Icons.download_rounded, color: theme.colorScheme.primary),
                                onPressed: () {
                                  Get.snackbar(
                                    'Download',
                                    'Clique com o botão direito e salve o arquivo, ou aguarde a funcionalidade de download direto.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                tooltip: 'Baixar',
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                onPressed: () => docs.removeAt(i),
                                tooltip: 'Remover',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final updated = Catequizando(
                      id: catequizando.id,
                      nome: catequizando.nome,
                      dataNascimento: catequizando.dataNascimento,
                      turmaNome: catequizando.turmaNome,
                      sexo: catequizando.sexo,
                      batizado: catequizando.batizado,
                      localBatismo: catequizando.localBatismo,
                      fezPrimeiraEucaristia: catequizando.fezPrimeiraEucaristia,
                      responsavel: catequizando.responsavel,
                      parentesco: catequizando.parentesco,
                      telefone: catequizando.telefone,
                      cep: catequizando.cep,
                      endereco: catequizando.endereco,
                      numero: catequizando.numero,
                      bairro: catequizando.bairro,
                      possuiRestricao: catequizando.possuiRestricao,
                      detalheRestricao: catequizando.detalheRestricao,
                      aceiteTermos: catequizando.aceiteTermos,
                      assinaturaResponsavel: catequizando.assinaturaResponsavel,
                      dataAssinatura: catequizando.dataAssinatura,
                      documentosAnexados: docs.toList(),
                    );
                    vm.updateCatequizando(updated);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showEditarCatequizandoDialog(BuildContext context, CatequizandoViewModel vm,
    {required Catequizando catequizando, List<String> turmas = const []}) {
  final nomeCtrl = TextEditingController(text: catequizando.nome);
  final dataNascimentoCtrl = TextEditingController();
  final localBatismoCtrl = TextEditingController(text: catequizando.localBatismo ?? '');
  final detalheRestricaoCtrl = TextEditingController(text: catequizando.detalheRestricao ?? '');
  final responsavelCtrl = TextEditingController(text: catequizando.responsavel);
  final telefoneCtrl = TextEditingController(text: catequizando.telefone);
  final turmaCtrl = TextEditingController(text: catequizando.turmaNome);
  final cepCtrl = TextEditingController(text: catequizando.cep);
  final enderecoCtrl = TextEditingController(text: catequizando.endereco);
  final numeroCtrl = TextEditingController(text: catequizando.numero);
  final bairroCtrl = TextEditingController(text: catequizando.bairro);

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final formKey = GlobalKey<FormState>();

  String _sexo = catequizando.sexo;
  DateTime? _dataNascimento = catequizando.dataNascimento;
  bool _batizado = catequizando.batizado;
  bool? _fezPrimeiraEucaristia = catequizando.fezPrimeiraEucaristia;
  String _parentesco = catequizando.parentesco;
  bool _possuiRestricao = catequizando.possuiRestricao;

  _dataNascimento = catequizando.dataNascimento;
  dataNascimentoCtrl.text = '${catequizando.dataNascimento.day.toString().padLeft(2, '0')}/'
      '${catequizando.dataNascimento.month.toString().padLeft(2, '0')}/'
      '${catequizando.dataNascimento.year}';

  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = screenWidth > 900 ? 640.0 : screenWidth > 600 ? 560.0 : screenWidth * 0.95;

  int _calcularIdade(DateTime data) {
    final hoje = DateTime.now();
    int age = hoje.year - data.year;
    if (hoje.month < data.month ||
        (hoje.month == data.month && hoje.day < data.day)) {
      age--;
    }
    return age;
  }

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerLow,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: SizedBox(
                width: dialogWidth,
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
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Editar Catequizando',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Identificação', Icons.person_search_rounded, Theme.of(context)),
                            const SizedBox(height: 16),
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
                              onChanged: (v) => setDialogState(() => _sexo = v!),
                            ),
                            const SizedBox(height: 16),
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
                              onTap: () async {
                                final data = await showDatePicker(
                                  context: context,
                                  initialDate: _dataNascimento ?? DateTime(2010),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  locale: const Locale('pt', 'BR'),
                                );
                                if (data != null) {
                                  setDialogState(() {
                                    _dataNascimento = data;
                                    dataNascimentoCtrl.text = '${data.day.toString().padLeft(2, '0')}/'
                                        '${data.month.toString().padLeft(2, '0')}/'
                                        '${data.year}  ·  ${_calcularIdade(data)} anos';
                                  });
                                }
                              },
                              validator: (_) => _dataNascimento == null ? 'Campo obrigatório' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: turmas.contains(turmaCtrl.text) ? turmaCtrl.text : null,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(
                                labelText: 'Turma',
                                hintText: 'Selecione a turma',
                                prefixIcon: Icon(Icons.auto_stories_rounded),
                              ),
                              items: turmas.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) {
                                turmaCtrl.text = v ?? '';
                                setDialogState(() {});
                              },
                              validator: (v) => v == null ? 'Selecione uma turma' : null,
                            ),
                            const SizedBox(height: 24),
                            _sectionHeader('Histórico Sacramental', Icons.check_circle_outline_rounded, Theme.of(context)),
                            const SizedBox(height: 16),
                            _radioGroup<bool>(
                              label: 'Já é Batizado(a)?',
                              value: _batizado,
                              options: const [true, false],
                              labels: const ['Sim', 'Não'],
                              theme: Theme.of(context),
                              onChanged: (v) => setDialogState(() => _batizado = v),
                            ),
                            if (_batizado) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: localBatismoCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Local do Batismo (opcional)',
                                  hintText: 'Igreja / Paróquia onde foi batizado',
                                  prefixIcon: Icon(Icons.church_rounded),
                                ),
                              ),
                            ],
                            if (_batizado &&
                                (turmaCtrl.text.toLowerCase().contains('perseverança') ||
                                 turmaCtrl.text.toLowerCase().contains('perseveranca') ||
                                 turmaCtrl.text.toLowerCase().contains('crisma'))) ...[
                              const SizedBox(height: 16),
                              _radioGroup<bool>(
                                label: 'Já fez a Primeira Eucaristia?',
                                value: _fezPrimeiraEucaristia ?? false,
                                options: const [true, false],
                                labels: const ['Sim', 'Não'],
                                theme: Theme.of(context),
                                onChanged: (v) => setDialogState(() => _fezPrimeiraEucaristia = v),
                              ),
                            ],
                            const SizedBox(height: 24),
                            _sectionHeader('Contatos e Responsáveis', Icons.contacts_rounded, Theme.of(context)),
                            const SizedBox(height: 16),
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
                              onChanged: (v) => setDialogState(() => _parentesco = v!),
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(flex: 2, child: TextFormField(
                                  controller: cepCtrl,
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
                                  decoration: const InputDecoration(
                                    labelText: 'Número',
                                    hintText: 'S/N',
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: enderecoCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Endereço (Rua)',
                                hintText: 'Nome da rua / logradouro',
                                prefixIcon: Icon(Icons.map_rounded),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: bairroCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Bairro',
                                hintText: 'Nome do bairro',
                                prefixIcon: Icon(Icons.location_city_rounded),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 24),
                            _sectionHeader('Saúde e Cuidados', Icons.healing_rounded, Theme.of(context)),
                            const SizedBox(height: 16),
                            _radioGroup<bool>(
                              label: 'Possui alergia, problema de saúde ou restrição?',
                              value: _possuiRestricao,
                              options: const [true, false],
                              labels: const ['Sim', 'Não'],
                              theme: Theme.of(context),
                              onChanged: (v) => setDialogState(() => _possuiRestricao = v),
                            ),
                            if (_possuiRestricao) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: detalheRestricaoCtrl,
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
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            if (_dataNascimento == null) {
                              Get.snackbar('Erro', 'Data de nascimento não informada');
                              return;
                            }
                            final updated = Catequizando(
                              id: catequizando.id,
                              nome: nomeCtrl.text.trim(),
                              sexo: _sexo,
                              dataNascimento: _dataNascimento!,
                              turmaNome: turmaCtrl.text.trim(),
                              batizado: _batizado,
                              localBatismo: _batizado ? localBatismoCtrl.text.trim() : null,
                              fezPrimeiraEucaristia: _batizado ? _fezPrimeiraEucaristia : null,
                              responsavel: responsavelCtrl.text.trim(),
                              parentesco: _parentesco,
                              telefone: telefoneCtrl.text.trim(),
                              cep: cepCtrl.text.trim(),
                              endereco: enderecoCtrl.text.trim(),
                              numero: numeroCtrl.text.trim(),
                              bairro: bairroCtrl.text.trim(),
                              possuiRestricao: _possuiRestricao,
                              detalheRestricao: _possuiRestricao ? detalheRestricaoCtrl.text.trim() : null,
                              aceiteTermos: catequizando.aceiteTermos,
                              assinaturaResponsavel: catequizando.assinaturaResponsavel,
                              dataAssinatura: catequizando.dataAssinatura,
                              documentosAnexados: catequizando.documentosAnexados,
                            );
                            vm.updateCatequizando(updated);
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Salvar Alterações'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _sectionHeader(String title, IconData icon, ThemeData theme) {
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

class CatequizandoPage extends StatelessWidget {
  final CatequizandoViewModel vm;
  final List<String> turmas;
  const CatequizandoPage({super.key, required this.vm, this.turmas = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        const SizedBox(height: 16),
        Obx(
          () => TextField(
            onChanged: vm.setSearch,
            decoration: InputDecoration(
              hintText: 'Buscar catequizando por nome, turma ou responsável...',
              prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
              suffixIcon: vm.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () => vm.setSearch(''),
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final list = vm.filteredCatequizandos;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Nenhum catequizando encontrado',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: list.map((a) => _CatequizandoCard(aluno: a, theme: theme, vm: vm, turmas: turmas)).toList(),
                );
              }
              return _CatequizandoTable(alunos: list, theme: theme, vm: vm, turmas: turmas);
            },
          );
        }),
      ],
    );
  }
}

class _CatequizandoCard extends StatelessWidget {
  final Catequizando aluno;
  final ThemeData theme;
  final CatequizandoViewModel vm;
  final List<String> turmas;

  const _CatequizandoCard({required this.aluno, required this.theme, required this.vm, this.turmas = const []});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  aluno.nome[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _infoChip(Icons.menu_book_rounded, aluno.turma, theme),
                        _infoChip(Icons.person_outline, aluno.responsavel, theme),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${aluno.idade}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          'anos',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                          onPressed: () => showEditarCatequizandoDialog(context, vm, catequizando: aluno, turmas: turmas),
                          tooltip: 'Editar',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: Text('Deseja excluir "${aluno.nome}"?'),
                                actions: [
                                  TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                  FilledButton(
                                    onPressed: () {
                                      vm.removeCatequizando(aluno.id);
                                      Get.back();
                                    },
                                    style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Excluir',
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.folder_outlined, color: theme.colorScheme.tertiary),
                          onPressed: () => showDocumentosDialog(context, vm, catequizando: aluno),
                          tooltip: 'Documentos',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _CatequizandoTable extends StatelessWidget {
  final List<Catequizando> alunos;
  final ThemeData theme;
  final CatequizandoViewModel vm;
  final List<String> turmas;

  const _CatequizandoTable({required this.alunos, required this.theme, required this.vm, this.turmas = const []});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2.5),
          4: FixedColumnWidth(80),
          5: FixedColumnWidth(130),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3), width: 0.5),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.85),
                ],
              ),
            ),
            children: [
              const SizedBox.shrink(),
              _headerCell('Nome', Icons.person_rounded),
              _headerCell('Turma', Icons.menu_book_rounded),
              _headerCell('Responsável', Icons.phone_rounded),
              _headerCell('Idade', Icons.cake_rounded),
              _headerCell('Ações', Icons.touch_app_rounded),
            ],
          ),
          ...alunos.asMap().entries.map(
            (entry) {
              final i = entry.key;
              final a = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? theme.colorScheme.surfaceContainerLow.withOpacity(0.4)
                      : Colors.transparent,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        a.nome[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  _bodyCell(a.nome, isBold: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        a.turma,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            a.telefone,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${a.idade}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.tertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
                            onPressed: () => showEditarCatequizandoDialog(context, vm, catequizando: a, turmas: turmas),
                            tooltip: 'Editar',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text('Deseja excluir "${a.nome}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
                                    FilledButton(
                                      onPressed: () {
                                        vm.removeCatequizando(a.id);
                                        Get.back();
                                      },
                                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            tooltip: 'Excluir',
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.folder_outlined, size: 18, color: theme.colorScheme.tertiary),
                            onPressed: () => showDocumentosDialog(context, vm, catequizando: a),
                            tooltip: 'Documentos',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Padding _headerCell(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Padding _bodyCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: isBold
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
            : theme.textTheme.bodyMedium,
      ),
    );
  }
}
