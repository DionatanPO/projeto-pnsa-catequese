import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/relatorio_viewmodel.dart';

class RelatorioPage extends StatelessWidget {
  final RelatorioViewModel vm;
  const RelatorioPage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
          const SizedBox(height: 16),
          GetBuilder<RelatorioViewModel>(
            init: vm,
            id: 'relatorios',
            builder: (_) {
              final list = vm.relatorios;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 600 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: columns > 1 ? 1.6 : 2.8,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _RelatorioCard(
                      relatorio: list[i],
                      theme: theme,
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
  }
}

class _RelatorioCard extends StatelessWidget {
  final dynamic relatorio;
  final ThemeData theme;

  const _RelatorioCard({required this.relatorio, required this.theme});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.people_rounded,
      Icons.calendar_month_rounded,
      Icons.school_rounded,
      Icons.group_rounded,
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icons[relatorio.total % icons.length], color: theme.colorScheme.primary),
                  const Spacer(),
                  Text(
                    '${relatorio.total}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                relatorio.titulo,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                relatorio.descricao,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
