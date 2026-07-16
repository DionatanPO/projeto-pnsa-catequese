import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../catequista/views/catequista_page.dart';
import '../../turma/views/turma_page.dart';
import '../../avisos/views/aviso_page.dart';
import '../../encontros/views/encontro_page.dart';
import '../../encontros/views/encontros_page.dart';
import '../../catequizandos/views/catequizando_page.dart';
import '../../catequizandos/views/catequizando_wizard.dart';
import '../../relatorio/views/relatorio_page.dart';
import '../../coordenadores/views/coordenador_page.dart';
import '../../profile/views/profile_page.dart';
import '../../sobre/views/sobre_page.dart';
import '../../configuracao/views/configuracao_drive_page.dart';
import 'app_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.put(HomeViewModel());
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1080) {
          return _ExtraWideLayout(vm: vm, theme: theme);
        } else if (width >= 720) {
          return _WideLayout(vm: vm, theme: theme);
        }
        return _NarrowLayout(vm: vm, theme: theme);
      },
    );
  }
}



Widget? _buildFab(BuildContext context, HomeViewModel vm) {
  switch (vm.selectedIndex) {
    case 1:
      return FloatingActionButton.extended(
        onPressed: () => showNovaCatequistaDialog(context, vm.catequistaVm),
        icon: const Icon(Icons.add),
        label: const Text('Novo Catequista'),
      );
    case 2:
      return FloatingActionButton.extended(
        onPressed: () => showNovaTurmaDialog(context, vm.turmaVm),
        icon: const Icon(Icons.add),
        label: const Text('Nova Turma'),
      );
    case 3:
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatequizandoWizardPage(
                vm: vm.catequizandoVm,
                turmas: vm.turmaVm.turmas,
                matriculaVm: vm.matriculaVm,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Catequizando'),
      );
    case 4:
      return FloatingActionButton.extended(
        onPressed: () => showNovoEncontroDialog(context, vm.encontrosVm, turmas: vm.turmaVm.turmasAtivas.obs),
        icon: const Icon(Icons.add),
        label: const Text('Novo Encontro'),
      );
    case 5:
      return const SizedBox.shrink();
    case 7:
      return FloatingActionButton.extended(
        onPressed: () => showNovaCoordenadorDialog(context, vm.coordenadorVm),
        icon: const Icon(Icons.add),
        label: const Text('Novo Coordenador'),
      );
    default:
      return null;
  }
}

AppBar _buildAppBar(HomeViewModel vm, ThemeData theme, {bool center = false}) {
  return AppBar(
    title: GetBuilder<HomeViewModel>(
      id: 'selectedIndex',
      builder: (_) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/app_icon.png', width: 22, height: 22),
          const SizedBox(width: 10),
          Text(menuLabels[vm.selectedIndex]),
        ],
      ),
    ),
    centerTitle: center,
  );
}

class _ExtraWideLayout extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const _ExtraWideLayout({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
      id: 'selectedIndex',
      builder: (_) => Scaffold(
        body: Row(
          children: [
            AppSideMenu(vm: vm, theme: theme, extended: true),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildBody(vm, theme),
            ),
          ],
        ),
        floatingActionButton: _buildFab(context, vm),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const _WideLayout({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
      id: 'selectedIndex',
      builder: (_) => Scaffold(
        body: Row(
          children: [
            AppSideMenu(vm: vm, theme: theme),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildBody(vm, theme),
            ),
          ],
        ),
        floatingActionButton: _buildFab(context, vm),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const _NarrowLayout({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
      id: 'selectedIndex',
      builder: (_) => Scaffold(
        appBar: _buildAppBar(vm, theme, center: true),
        drawer: AppDrawer(vm: vm, theme: theme),
        body: _buildBody(vm, theme),
        floatingActionButton: _buildFab(context, vm),
      ),
    );
  }
}

Widget _buildBody(HomeViewModel vm, ThemeData theme) {
  return GetBuilder<HomeViewModel>(
    id: 'selectedIndex',
    builder: (_) {
      switch (vm.selectedIndex) {
        case 0:
          return _InicioContent(vm: vm, theme: theme);
        case 1:
          return vm.isRestricted(1)
              ? _InicioContent(vm: vm, theme: theme)
              : CatequistaPage(vm: vm.catequistaVm);
        case 2:
          return TurmaPage(vm: vm.turmaVm, catequizandoVm: vm.catequizandoVm);
        case 3:
          return CatequizandoPage(vm: vm.catequizandoVm, turmas: vm.turmaVm.turmas, matriculaVm: vm.matriculaVm);
        case 4:
          return EncontrosPage(encontrosVm: vm.encontrosVm, turmas: vm.turmaVm.turmas, catequizandoVm: vm.catequizandoVm);
        case 5:
          return AvisoPage(catequistaVm: vm.catequistaVm);
        case 6:
          return RelatorioPage(
            relatorioVm: vm.relatorioVm,
            catequizandoVm: vm.catequizandoVm,
            turmaVm: vm.turmaVm,
            encontrosVm: vm.encontrosVm,
            matriculaVm: vm.matriculaVm,
          );
        case 7:
          return vm.isRestricted(7)
              ? _InicioContent(vm: vm, theme: theme)
              : CoordenadorPage(vm: vm.coordenadorVm);
        case 8:
          return ProfilePage(vm: vm.profileVm);
        case 9:
          return const SobrePage();
        case 10:
          return const ConfiguracaoDrivePage();
        default:
          return const SizedBox.shrink();
      }
    },
  );
}

class _InicioContent extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const _InicioContent({required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return Obx(() {
      final data = vm.catequistaVm.data.value;
      return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/images/app_icon.png', width: 32, height: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo à PNSA',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestão de Catequese',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary.withOpacity(0.5), size: 28),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Visão Geral',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Acompanhe os indicadores da catequista',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _MetricCard(icon: Icons.group_rounded, label: 'Turmas', value: '${data.totalTurmas}', color: theme.colorScheme.primary, iconBg: theme.colorScheme.primaryContainer)),
                    const SizedBox(width: 16),
                    Expanded(child: _MetricCard(icon: Icons.people_rounded, label: 'Catequizandos', value: '${data.totalCatequizandos}', color: theme.colorScheme.tertiary, iconBg: theme.colorScheme.tertiaryContainer)),
                    const SizedBox(width: 16),
                    Expanded(child: _MetricCard(icon: Icons.school_rounded, label: 'Catequistas', value: '${data.totalCatequistas}', color: theme.colorScheme.secondary, iconBg: theme.colorScheme.secondaryContainer)),
                  ],
                );
              }
              return Column(
                children: [
                  _MetricCard(icon: Icons.group_rounded, label: 'Turmas', value: '${data.totalTurmas}', color: theme.colorScheme.primary, iconBg: theme.colorScheme.primaryContainer),
                  const SizedBox(height: 16),
                  _MetricCard(icon: Icons.people_rounded, label: 'Catequizandos', value: '${data.totalCatequizandos}', color: theme.colorScheme.tertiary, iconBg: theme.colorScheme.tertiaryContainer),
                  const SizedBox(height: 16),
                  _MetricCard(icon: Icons.school_rounded, label: 'Catequistas', value: '${data.totalCatequistas}', color: theme.colorScheme.secondary, iconBg: theme.colorScheme.secondaryContainer),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // --- Status Section ---
          Text(
            'Catequizandos por Status',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Distribuição dos catequizandos conforme a situação atual',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final catequizandos = vm.catequizandoVm.catequizandos;
              final statusData = [
                ('Em Andamento', catequizandos.where((c) => c.status == 'Em Andamento').length, Colors.blue),
                ('Formado', catequizandos.where((c) => c.status == 'Formado').length, Colors.green),
                ('Desistente', catequizandos.where((c) => c.status == 'Desistente').length, Colors.red),
                ('Transferido', catequizandos.where((c) => c.status == 'Transferido').length, Colors.orange),
                ('Inativo', catequizandos.where((c) => c.status == 'Inativo').length, Colors.grey),
              ];
              if (isWide) {
                return Row(
                  children: statusData.map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _StatusCard(label: s.$1, value: s.$2, color: s.$3),
                    ),
                  )).toList(),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statusData.map((s) => SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _StatusCard(label: s.$1, value: s.$2, color: s.$3),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 32),

          // --- Sacramentos Section ---
          Text(
            'Catequizandos por Histórico Sacramental',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Quantidade de catequizandos por sacramento recebido',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final catequizandos = vm.catequizandoVm.catequizandos;
              final sacraData = [
                ('Batizados', catequizandos.where((c) => c.batizado).length, theme.colorScheme.primary),
                ('Primeira Eucaristia', catequizandos.where((c) => c.fezPrimeiraEucaristia == true).length, theme.colorScheme.tertiary),
                ('Crisma', catequizandos.where((c) => c.fezCrisma == true).length, theme.colorScheme.secondary),
              ];
              if (isWide) {
                return Row(
                  children: sacraData.map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _StatusCard(label: s.$1, value: s.$2, color: s.$3),
                    ),
                  )).toList(),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sacraData.map((s) => SizedBox(
                  width: (constraints.maxWidth - 8) / 2,
                  child: _StatusCard(label: s.$1, value: s.$2, color: s.$3),
                )).toList(),
              );
            },
          ),
        ],
      );
    });
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$value',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconBg;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
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
