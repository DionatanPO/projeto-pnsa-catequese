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
  final _dataCtrl = DateTime.now().obs;
  final _descCtrl = TextEditingController();
  final _turmaSelecionada = Rx<TurmaModel?>(null);

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxWidth: 480),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: DropdownButtonFormField<TurmaModel>(
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dataCtrl.value,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (d != null) _dataCtrl.value = d;
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  child: Obx(() => Text(
                    '${_dataCtrl.value.day.toString().padLeft(2, '0')}/'
                    '${_dataCtrl.value.month.toString().padLeft(2, '0')}/'
                    '${_dataCtrl.value.year}',
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Tema, atividade...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final turma = _turmaSelecionada.value;
                      if (turma == null) return;
                      widget.encontrosVm.criarEncontro(turma.id, _dataCtrl.value, _descCtrl.text.trim());
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Salvar'),
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
