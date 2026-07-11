import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../turma/models/turma_model.dart';
import '../viewmodels/encontros_viewmodel.dart';

class EncontroForm extends StatefulWidget {
  final EncontrosViewModel encontrosVm;
  final RxList<TurmaModel> turmas;

  const EncontroForm({
    super.key,
    required this.encontrosVm,
    required this.turmas,
  });

  @override
  State<EncontroForm> createState() => _EncontroFormState();
}

class _EncontroFormState extends State<EncontroForm> {
  final _dataInicioCtrl = DateTime.now().obs;
  final _dataFimCtrl = Rx<DateTime?>(null);
  final _descCtrl = TextEditingController();
  final _turmaSelecionada = Rx<TurmaModel?>(null);
  final _recorrencia = 'Único'.obs;
  final _salvando = false.obs;

  final _recorrencias = ['Único', 'Diário', 'Semanal', 'Anual'];

  bool get _ehRecorrente => _recorrencia.value != 'Único';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData({required bool isInicio}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataInicioCtrl.value : (_dataFimCtrl.value ?? _dataInicioCtrl.value),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (d != null) {
      if (isInicio) {
        _dataInicioCtrl.value = d;
      } else {
        _dataFimCtrl.value = d;
      }
    }
  }

  Future<void> _salvar() async {
    final turma = _turmaSelecionada.value;
    if (turma == null) return;

    _salvando.value = true;

    if (_ehRecorrente) {
      final dataFim = _dataFimCtrl.value;
      if (dataFim == null) return;

      final total = await widget.encontrosVm.criarEncontrosRecorrentes(
        turmaId: turma.id,
        dataInicio: _dataInicioCtrl.value,
        dataFim: dataFim,
        descricao: _descCtrl.text.trim(),
        recorrencia: _recorrencia.value,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();
      Get.snackbar(
        'Encontros criados',
        '$total encontro(s) criado(s) para a turma ${turma.nome}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await widget.encontrosVm.criarEncontro(turma.id, _dataInicioCtrl.value, _descCtrl.text.trim());
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event_rounded, color: colorScheme.onPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Novo Encontro',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<TurmaModel>(
                      value: _turmaSelecionada.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Turma',
                        prefixIcon: Icon(Icons.group_rounded),
                      ),
                      items: widget.turmas.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
                      onChanged: (v) => _turmaSelecionada.value = v,
                      validator: (v) => v == null ? 'Selecione uma turma' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _recorrencia.value,
                      decoration: const InputDecoration(
                        labelText: 'Recorrência',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                      items: _recorrencias.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) {
                        _recorrencia.value = v!;
                        if (!_ehRecorrente) _dataFimCtrl.value = null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selecionarData(isInicio: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: _ehRecorrente ? 'Data de Início' : 'Data',
                          prefixIcon: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        child: Text(
                          '${_dataInicioCtrl.value.day.toString().padLeft(2, '0')}/'
                          '${_dataInicioCtrl.value.month.toString().padLeft(2, '0')}/'
                          '${_dataInicioCtrl.value.year}',
                        ),
                      ),
                    ),
                    if (_ehRecorrente) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selecionarData(isInicio: false),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data Final',
                            prefixIcon: Icon(Icons.date_range_rounded, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          child: Text(
                            _dataFimCtrl.value != null
                                ? '${_dataFimCtrl.value!.day.toString().padLeft(2, '0')}/'
                                    '${_dataFimCtrl.value!.month.toString().padLeft(2, '0')}/'
                                    '${_dataFimCtrl.value!.year}'
                                : 'Selecionar...',
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Tema, atividade...',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _salvando.value ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _salvando.value ? null : _salvar,
                    icon: _salvando.value
                        ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(_salvando.value ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
