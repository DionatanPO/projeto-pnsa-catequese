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
  final _formKey = GlobalKey<FormState>();
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
    // Executa a validação do formulário
    if (!_formKey.currentState!.validate()) return;

    final turma = _turmaSelecionada.value;
    if (turma == null) return;

    if (_ehRecorrente && _dataFimCtrl.value == null) {
      Get.snackbar(
        'Campo obrigatório',
        'Por favor, selecione a data final para a recorrência.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _salvando.value = true;

    try {
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
    } finally {
      _salvando.value = false;
    }
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Helper para padronizar os campos visuais de entrada de dados
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
    final colorScheme = theme.colorScheme;

    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header modernizado
            Container(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                color: colorScheme.primaryContainer.withOpacity(0.3),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.event_note_rounded, color: colorScheme.onPrimary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Novo Encontro',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Agende um novo evento de forma simples',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown Seleção de Turma
                      DropdownButtonFormField<TurmaModel>(
                        value: _turmaSelecionada.value,
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          label: 'Turma',
                          prefixIcon: Icons.group_rounded,
                          colors: colorScheme,
                        ),
                        items: widget.turmas.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
                        onChanged: (v) => _turmaSelecionada.value = v,
                        validator: (v) => v == null ? 'Por favor, selecione uma turma' : null,
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Recorrência
                      DropdownButtonFormField<String>(
                        value: _recorrencia.value,
                        decoration: _buildInputDecoration(
                          label: 'Recorrência',
                          prefixIcon: Icons.repeat_rounded,
                          colors: colorScheme,
                        ),
                        items: _recorrencias.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) {
                          _recorrencia.value = v!;
                          if (!_ehRecorrente) _dataFimCtrl.value = null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Seção Inteligente de Datas
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 400 || !_ehRecorrente;

                          final dataInicioWidget = InkWell(
                            onTap: () => _selecionarData(isInicio: true),
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: _buildInputDecoration(
                                label: _ehRecorrente ? 'Data de Início' : 'Data',
                                prefixIcon: Icons.calendar_month_rounded,
                                colors: colorScheme,
                              ),
                              child: Text(
                                _formatarData(_dataInicioCtrl.value),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          );

                          final dataFimWidget = InkWell(
                            onTap: () => _selecionarData(isInicio: false),
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: _buildInputDecoration(
                                label: 'Data Final',
                                prefixIcon: Icons.date_range_rounded,
                                colors: colorScheme,
                              ),
                              child: Text(
                                _dataFimCtrl.value != null
                                    ? _formatarData(_dataFimCtrl.value!)
                                    : 'Selecionar...',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _dataFimCtrl.value != null 
                                      ? colorScheme.onSurface 
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );

                          if (isCompact) {
                            return Column(
                              children: [
                                dataInicioWidget,
                                if (_ehRecorrente) ...[
                                  const SizedBox(height: 20),
                                  dataFimWidget,
                                ],
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: dataInicioWidget),
                                const SizedBox(width: 16),
                                Expanded(child: dataFimWidget),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campo Descrição
                      TextFormField(
                        controller: _descCtrl,
                        decoration: _buildInputDecoration(
                          label: 'Descrição',
                          hint: 'Escreva um tema ou atividade para este encontro',
                          prefixIcon: Icons.notes_rounded,
                          colors: colorScheme,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Rodapé das Ações
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _salvando.value ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _salvando.value ? null : _salvar,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _salvando.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(_salvando.value ? 'Salvando...' : 'Salvar Encontro'),
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