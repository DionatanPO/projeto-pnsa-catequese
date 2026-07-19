import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../encontros/models/chamada_model.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../models/catequizando_model.dart';

void showFrequenciaBottomSheet(
  BuildContext context, {
  required Catequizando aluno,
  required EncontrosViewModel encontrosVm,
  required MatriculaViewModel matriculaVm,
  required List<TurmaModel> turmas,
}) {
  final turmaId = matriculaVm.getTurmaAtualId(aluno.id);
  final turmaNome = matriculaVm.getNomeTurmaAtual(aluno.id, turmas);
  final dataInicio = matriculaVm.getDataInicioMatriculaAtual(aluno.id);

  if (turmaId == null) {
    Get.snackbar(
      'Sem turma ativa',
      '${aluno.nome} não está matriculado em nenhuma turma.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final encontros = encontrosVm.encontrosDaTurma(turmaId)
    ..sort((a, b) => b.data.compareTo(a.data));

  final encontrosNoPeriodo = encontros.where((e) {
    if (dataInicio != null && e.data.isBefore(dataInicio)) return false;
    return true;
  }).toList();

  final chamadas = <Chamada>[];
  final encontrosSemChamada = <({DateTime data, String descricao, String id})>[];
  final encontrosComChamada = <({DateTime data, String descricao, String id, Chamada chamada})>[];

  for (final e in encontrosNoPeriodo) {
    final cs = encontrosVm.chamadaRepo.getByEncontro(e.id);
    final c = cs.firstWhereOrNull((c) => c.catequizandoId == aluno.id);
    if (c != null) {
      chamadas.add(c);
      encontrosComChamada.add((data: e.data, descricao: e.descricao, id: e.id, chamada: c));
    } else {
      encontrosSemChamada.add((data: e.data, descricao: e.descricao, id: e.id));
    }
  }

  final totalComChamada = encontrosComChamada.length;
  final totalPresentes = chamadas.where((c) => c.presente).length;
  final frequencia = totalComChamada > 0 ? (totalPresentes / totalComChamada) * 100 : 0.0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.secondaryContainer.withOpacity(0.4),
                  child: Text(
                    aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequência',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aluno.nome,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Como a frequência é calculada?\n\n'
                      'A frequência considera todos os encontros da turma\n'
                      'desde a matrícula atual que já tiveram chamada\n'
                      'lançada.\n\n'
                      'Fórmula: (presenças ÷ encontros com chamada) × 100\n\n'
                      'Encontros futuros ou sem chamada lançada aparecem\n'
                      'como "Pendente" e não entram no cálculo.',
                  decoration: BoxDecoration(
                    color: colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontSize: 13,
                  ),
                  padding: const EdgeInsets.all(16),
                  preferBelow: false,
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Turma info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    turmaNome ?? 'Turma',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (dataInicio != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      'desde ${DateFormat('MMM/yyyy').format(dataInicio)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Percentage circle
            Center(
              child: SizedBox(
                width: 160, height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160, height: 160,
                      child: CircularProgressIndicator(
                        value: totalComChamada > 0 ? frequencia / 100 : 0,
                        strokeWidth: 10,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          frequencia >= 75
                              ? Colors.green.shade600
                              : frequencia >= 50
                                  ? Colors.orange.shade600
                                  : Colors.red.shade600,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${frequencia.toStringAsFixed(0)}%',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: frequencia >= 75
                                ? Colors.green.shade600
                                : frequencia >= 50
                                    ? Colors.orange.shade600
                                    : Colors.red.shade600,
                          ),
                        ),
                        Text(
                          '${totalPresentes} presenças de ${totalComChamada} encontros',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Status legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legenda(colorScheme, Colors.green.shade600, 'Presente'),
                const SizedBox(width: 20),
                _legenda(colorScheme, Colors.red.shade400, 'Falta'),
                const SizedBox(width: 20),
                _legenda(colorScheme, colorScheme.outlineVariant, 'Sem chamada'),
              ],
            ),
            const SizedBox(height: 16),

            // List header
            Row(
              children: [
                Text(
                  'Encontros',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${encontrosNoPeriodo.length} encontros no total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (encontrosNoPeriodo.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Nenhum encontro encontrado para esta turma.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...encontrosNoPeriodo.map((e) {
                final c = chamadas.firstWhereOrNull((c) => c.encontroId == e.id);
                final temChamada = c != null;
                final presente = c?.presente ?? false;

                Color statusColor;
                IconData statusIcon;
                if (!temChamada) {
                  statusColor = colorScheme.outlineVariant;
                  statusIcon = Icons.remove_rounded;
                } else if (presente) {
                  statusColor = Colors.green.shade600;
                  statusIcon = Icons.check_circle_rounded;
                } else {
                  statusColor = Colors.red.shade400;
                  statusIcon = Icons.cancel_rounded;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(statusIcon, size: 20, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(e.data),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (e.descricao.isNotEmpty)
                                  Text(
                                    e.descricao,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            temChamada
                                ? (presente ? 'Presente' : 'Falta')
                                : 'Pendente',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    ),
  );
}

Widget _legenda(ColorScheme colorScheme, Color cor, String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
