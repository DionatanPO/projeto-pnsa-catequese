import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequista/models/catequista_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';

class AvisoPage extends StatelessWidget {
  final CatequistaViewModel catequistaVm;
  final EncontrosViewModel encontrosVm;
  final MatriculaViewModel matriculaVm;
  final CatequizandoViewModel catequizandoVm;
  final List<TurmaModel> turmas;

  const AvisoPage({
    super.key,
    required this.catequistaVm,
    required this.encontrosVm,
    required this.matriculaVm,
    required this.catequizandoVm,
    this.turmas = const [],
  });

  List<Catequista> get _aniversariantes {
    final mesAtual = DateTime.now().month;
    return catequistaVm.data.value.catequistas
        .where((c) {
          final parts = c.dataNascimento.split('/');
          if (parts.length != 3) return false;
          final mes = int.tryParse(parts[1]);
          return mes == mesAtual;
        })
        .toList()
      ..sort((a, b) {
        final da = int.tryParse(a.dataNascimento.split('/')[0]) ?? 0;
        final db = int.tryParse(b.dataNascimento.split('/')[0]) ?? 0;
        return da.compareTo(db);
      });
  }

  List<({Catequizando aluno, double frequencia, String turmaNome})>
      get _alunosBaixaFrequencia {
    final alunos = catequizandoVm.catequizandos
        .where((a) => a.status == 'Em Andamento')
        .toList();

    if (alunos.isEmpty) return [];

    final Map<String, List<String>> alunosPorTurma = {};
    for (final a in alunos) {
      final turmaId = matriculaVm.getTurmaAtualId(a.id);
      if (turmaId != null) {
        alunosPorTurma.putIfAbsent(turmaId, () => []).add(a.id);
      }
    }

    final Map<String, String> turmaIdNome = {
      for (final t in turmas) t.id: t.nome,
    };

    final result =
        <({Catequizando aluno, double frequencia, String turmaNome})>[];

    for (final entry in alunosPorTurma.entries) {
      final turmaId = entry.key;
      final alunoIds = entry.value;
      final encontros = encontrosVm.encontrosDaTurma(turmaId);

      if (encontros.isEmpty) continue;

      for (final alunoId in alunoIds) {
        int presentes = 0;
        int totalChamadas = 0;

        for (final e in encontros) {
          final chamadas = encontrosVm.chamadaRepo.getByEncontro(e.id);
          final c = chamadas.firstWhereOrNull((c) => c.catequizandoId == alunoId);
          if (c != null) {
            totalChamadas++;
            if (c.presente) presentes++;
          }
        }

        if (totalChamadas > 0) {
          final freq = (presentes / totalChamadas) * 100;
          if (freq < 75) {
            final aluno = alunos.firstWhereOrNull((a) => a.id == alunoId);
            if (aluno != null) {
              result.add((
                aluno: aluno,
                frequencia: freq,
                turmaNome: turmaIdNome[turmaId] ?? '',
              ));
            }
          }
        }
      }
    }

    result.sort((a, b) => a.frequencia.compareTo(b.frequencia));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        const SizedBox(height: 16),

        Obx(() {
          final aniversariantes = _aniversariantes;
          if (aniversariantes.isEmpty) {
            return Column(
              children: [
                _buildHeader(theme, meses, aniversariantes.length),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'Nenhum aniversariante este mês',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, meses, aniversariantes.length),
              const SizedBox(height: 12),
              ...aniversariantes.map((c) => _AniversarianteCard(c: c, theme: theme)),
            ],
          );
        }),

        const SizedBox(height: 24),

        Obx(() {
          final baixaFreq = _alunosBaixaFrequencia;
          if (baixaFreq.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBaixaFrequenciaHeader(theme, baixaFreq.length),
              const SizedBox(height: 12),
              ...baixaFreq.map((item) => _BaixaFrequenciaCard(
                item: item,
                theme: theme,
                catequizandoVm: catequizandoVm,
              )),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, List<String> meses, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary,
            theme.colorScheme.tertiary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onTertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cake_rounded, color: theme.colorScheme.onTertiary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aniversariantes do Mês',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meses[DateTime.now().month - 1]} — $count catequista(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaixaFrequenciaHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequência Baixa',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count catequizando(s) abaixo de 75% de presença',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AniversarianteCard extends StatelessWidget {
  final Catequista c;
  final ThemeData theme;
  const _AniversarianteCard({required this.c, required this.theme});

  int _idade() {
    final parts = c.dataNascimento.split('/');
    if (parts.length != 3) return 0;
    final dt = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
    if (dt == null) return 0;
    final hoje = DateTime.now();
    int age = hoje.year - dt.year;
    if (hoje.month < dt.month || (hoje.month == dt.month && hoje.day < dt.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final parts = c.dataNascimento.split('/');
    final dia = parts.length == 3 ? parts[0] : '??';
    final mes = parts.length == 3 ? parts[1] : '??';
    final idade = _idade();
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.tertiaryContainer,
          child: Text(dia, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onTertiaryContainer)),
        ),
        title: Text(c.nome, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('$dia/$mes — $idade ${idade == 1 ? "ano" : "anos"}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        trailing: Icon(Icons.celebration_outlined, color: theme.colorScheme.tertiary, size: 20),
      ),
    );
  }
}

class _BaixaFrequenciaCard extends StatelessWidget {
  final ({Catequizando aluno, double frequencia, String turmaNome}) item;
  final ThemeData theme;
  final CatequizandoViewModel catequizandoVm;

  const _BaixaFrequenciaCard({
    required this.item,
    required this.theme,
    required this.catequizandoVm,
  });

  Color _corFrequencia() {
    if (item.frequencia < 50) return Colors.red.shade600;
    return Colors.orange.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final cor = _corFrequencia();
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cor.withOpacity(0.12),
              child: Text(
                item.aluno.nome.isNotEmpty ? item.aluno.nome[0].toUpperCase() : '?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.aluno.nome,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 11, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        item.turmaNome,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant, fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.frequencia.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
