import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../catequista/models/catequista_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';

class AvisoPage extends StatelessWidget {
  final CatequistaViewModel catequistaVm;
  const AvisoPage({super.key, required this.catequistaVm});

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
