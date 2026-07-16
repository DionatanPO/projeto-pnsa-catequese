import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../turma/models/turma_model.dart';
import '../viewmodels/encontros_viewmodel.dart';
import 'calendario_inline.dart';

class NovoEncontroBottomSheet extends StatefulWidget {
  final EncontrosViewModel encontrosVm;
  final RxList<TurmaModel> turmas;

  const NovoEncontroBottomSheet({
    super.key,
    required this.encontrosVm,
    required this.turmas,
  });

  static void show(BuildContext context, EncontrosViewModel vm, RxList<TurmaModel> turmas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NovoEncontroBottomSheet(encontrosVm: vm, turmas: turmas),
    );
  }

  @override
  State<NovoEncontroBottomSheet> createState() => _NovoEncontroBottomSheetState();
}

class _NovoEncontroBottomSheetState extends State<NovoEncontroBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  final _turmaSelecionada = Rx<TurmaModel?>(null);
  final _dataSelecionada = DateTime.now().obs;
  final _recorrencia = 'Único'.obs;
  final _dataFim = Rx<DateTime?>(null);
  final _salvando = false.obs;

  final _recorrencias = ['Único', 'Semanal', 'Quinzenal', 'Mensal'];

  bool get _ehRecorrente => _recorrencia.value != 'Único';

  List<DateTime> get _datasPreview {
    if (!_ehRecorrente || _dataFim.value == null) return [_dataSelecionada.value];
    final datas = <DateTime>[];
    var atual = DateTime(_dataSelecionada.value.year, _dataSelecionada.value.month, _dataSelecionada.value.day);
    final fim = DateTime(_dataFim.value!.year, _dataFim.value!.month, _dataFim.value!.day);
    while (!atual.isAfter(fim)) {
      datas.add(atual);
      switch (_recorrencia.value) {
        case 'Semanal':
          atual = atual.add(const Duration(days: 7));
          break;
        case 'Quinzenal':
          atual = atual.add(const Duration(days: 14));
          break;
        case 'Mensal':
          atual = DateTime(atual.year, atual.month + 1, atual.day);
          break;
      }
    }
    return datas.take(10).toList();
  }

  List<DateTime> get _encontrosTurma {
    final turma = _turmaSelecionada.value;
    if (turma == null) return [];
    return widget.encontrosVm.encontrosDaTurma(turma.id).map((e) => e.data).toList();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final turma = _turmaSelecionada.value;
    if (turma == null) return;
    if (_ehRecorrente && _dataFim.value == null) {
      Get.snackbar('Campo obrigatório', 'Selecione a data final para a recorrência.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    _salvando.value = true;
    try {
      if (_ehRecorrente) {
        final fim = _dataFim.value!;
        final total = await widget.encontrosVm.criarEncontrosRecorrentes(
          turmaId: turma.id,
          dataInicio: _dataSelecionada.value,
          dataFim: fim,
          descricao: _descCtrl.text.trim(),
          recorrencia: _recorrencia.value,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
        Get.snackbar('Encontros criados', '$total encontro(s) para ${turma.nome}',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        await widget.encontrosVm.criarEncontro(turma.id, _dataSelecionada.value, _descCtrl.text.trim());
        if (context.mounted) Navigator.pop(context);
      }
    } finally {
      _salvando.value = false;
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Obx(() => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isWide ? 560 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
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
          _buildHandle(cs),
          _buildHeader(cs, theme),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTurmaField(cs),
                    const SizedBox(height: 16),
                    _buildRecorrenciaField(cs),
                    const SizedBox(height: 16),
                    _buildCalendarioSection(cs, theme),
                    const SizedBox(height: 16),
                    if (_ehRecorrente) ...[
                      _buildDataFimField(cs, theme),
                      const SizedBox(height: 16),
                      _buildPreviewDatas(cs, theme),
                      const SizedBox(height: 16),
                    ],
                    _buildDescricaoField(cs),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _buildActions(cs, theme),
        ],
      ),
    ));
  }

  Widget _buildHandle(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: cs.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_note_rounded, color: cs.onPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo Encontro',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _ehRecorrente ? 'Crie uma série de encontros recorrentes' : 'Agende um único encontro',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurmaField(ColorScheme cs) {
    return Obx(() => DropdownButtonFormField<TurmaModel>(
      value: _turmaSelecionada.value,
      isExpanded: true,
      decoration: _inputDec('Turma', Icons.group_rounded, cs),
      items: widget.turmas.map((t) => DropdownMenuItem(value: t, child: Text(t.nome))).toList(),
      onChanged: (v) {
        _turmaSelecionada.value = v;
        if (v != null && _dataSelecionada.value.isBefore(DateTime.now())) {
          _dataSelecionada.value = DateTime.now();
        }
      },
      validator: (v) => v == null ? 'Selecione uma turma' : null,
    ));
  }

  Widget _buildRecorrenciaField(ColorScheme cs) {
    return Obx(() => DropdownButtonFormField<String>(
      value: _recorrencia.value,
      decoration: _inputDec('Recorrência', Icons.repeat_rounded, cs),
      items: _recorrencias.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
      onChanged: (v) {
        _recorrencia.value = v!;
        if (!_ehRecorrente) _dataFim.value = null;
      },
    ));
  }

  Widget _buildCalendarioSection(ColorScheme cs, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              _ehRecorrente ? 'Data de Início' : 'Data do Encontro',
              style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(_fmt(_dataSelecionada.value), style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        CalendarioInline(
          dataSelecionada: _dataSelecionada.value,
          onDataChanged: (d) => _dataSelecionada.value = d,
          encontrosExistentes: _encontrosTurma,
        ),
      ],
    );
  }

  Widget _buildDataFimField(ColorScheme cs, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.date_range_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text('Data Final', style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(_dataFim.value != null ? _fmt(_dataFim.value!) : 'Selecionar...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _dataFim.value != null ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: _dataFim.value != null ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
        const SizedBox(height: 12),
        CalendarioInline(
          dataSelecionada: _dataFim.value ?? _dataSelecionada.value.add(const Duration(days: 7)),
          onDataChanged: (d) => _dataFim.value = d,
          encontrosExistentes: _encontrosTurma,
        ),
      ],
    );
  }

  Widget _buildPreviewDatas(ColorScheme cs, ThemeData theme) {
    final datas = _datasPreview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.preview_rounded, size: 18, color: cs.tertiary),
            const SizedBox(width: 8),
            Text('Pré-visualização (${datas.length} encontro${datas.length > 1 ? 's' : ''})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
            if (datas.length > 10) ...[
              const SizedBox(width: 8),
              Text('+${datas.length - 10} mais', style: theme.textTheme.bodySmall?.copyWith(color: cs.tertiary)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: datas.map((d) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.tertiary.withOpacity(0.3)),
            ),
            child: Text(_fmt(d), style: theme.textTheme.bodySmall?.copyWith(
              color: cs.tertiary, fontWeight: FontWeight.w600)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildDescricaoField(ColorScheme cs) {
    return TextFormField(
      controller: _descCtrl,
      decoration: _inputDec('Descrição (opcional)', Icons.notes_rounded, cs, hint: 'Tema, atividade, observações...'),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildActions(ColorScheme cs, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _salvando.value ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancelar', style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _salvando.value ? null : _salvar,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _salvando.value
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary))
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_salvando.value ? 'Salvando...' : (_ehRecorrente ? 'Criar Série' : 'Salvar Encontro')),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon, ColorScheme cs, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error),
      ),
    );
  }
}