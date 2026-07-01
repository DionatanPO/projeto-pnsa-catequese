import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../catequista/views/catequista_page.dart';
import '../../turma/views/turma_page.dart';
import '../../catequizandos/views/catequizando_page.dart';
import '../../catequizandos/views/catequizando_wizard.dart';
import '../../relatorio/views/relatorio_page.dart';
import '../../profile/views/profile_page.dart';

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

const _menuLabels = ['Início', 'Catequistas', 'Turmas', 'Catequizandos', 'Relatórios', 'Perfil'];

const _destinations = [
  NavigationRailDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: Text('Início'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.people_outline),
    selectedIcon: Icon(Icons.people_rounded),
    label: Text('Catequistas'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.group_outlined),
    selectedIcon: Icon(Icons.group_rounded),
    label: Text('Turmas'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.school_outlined),
    selectedIcon: Icon(Icons.school_rounded),
    label: Text('Catequizandos'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart_rounded),
    label: Text('Relatórios'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person_rounded),
    label: Text('Perfil'),
  ),
];

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
          final turmas = vm.turmaVm.turmas.map((t) => t.nome).toList();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatequizandoWizardPage(vm: vm.catequizandoVm, turmas: turmas),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Catequizando'),
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
          Icon(Icons.church_rounded, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(_menuLabels[vm.selectedIndex]),
        ],
      ),
    ),
    centerTitle: center,
  );
}

class _SideMenu extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;
  final bool extended;

  const _SideMenu({
    required this.vm,
    required this.theme,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
      id: 'selectedIndex',
      builder: (_) => NavigationRail(
        selectedIndex: vm.selectedIndex,
        onDestinationSelected: (i) => vm.selectedIndex = i,
        labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
        extended: extended,
        minExtendedWidth: 200,
        leading: Padding(
          padding: EdgeInsets.only(top: extended ? 16 : 8, bottom: extended ? 24 : 8),
          child: Column(
            children: [
              Icon(Icons.church_rounded, size: extended ? 40 : 24, color: theme.colorScheme.primary),
              if (extended) ...[
                const SizedBox(height: 8),
                Text(
                  'PNSA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        destinations: _destinations,
      ),
    );
  }
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
        appBar: _buildAppBar(vm, theme),
        body: Row(
          children: [
            _SideMenu(vm: vm, theme: theme, extended: true),
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
        appBar: _buildAppBar(vm, theme),
        body: Row(
          children: [
            _SideMenu(vm: vm, theme: theme),
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.church_rounded, size: 40, color: theme.colorScheme.onPrimary),
                    const SizedBox(height: 12),
                    Text(
                      'PNSA Catequistas',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < _menuLabels.length; i++)
                ListTile(
                  leading: Icon(
                    _menuIcons[i],
                    color: vm.selectedIndex == i ? theme.colorScheme.primary : null,
                  ),
                  title: Text(
                    _menuLabels[i],
                    style: TextStyle(
                      fontWeight: vm.selectedIndex == i ? FontWeight.w600 : null,
                    ),
                  ),
                  selected: vm.selectedIndex == i,
                  onTap: () {
                    vm.selectedIndex = i;
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
        body: _buildBody(vm, theme),
        floatingActionButton: _buildFab(context, vm),
      ),
    );
  }
}

const _menuIcons = [
  Icons.home_rounded,
  Icons.menu_book_rounded,
  Icons.group_rounded,
  Icons.school_rounded,
  Icons.bar_chart_rounded,
  Icons.person_rounded,
];

Widget _buildBody(HomeViewModel vm, ThemeData theme) {
  return GetBuilder<HomeViewModel>(
    id: 'selectedIndex',
    builder: (_) {
      switch (vm.selectedIndex) {
        case 0:
          return _InicioContent(vm: vm, theme: theme);
        case 1:
          return CatequistaPage(vm: vm.catequistaVm);
        case 2:
          return TurmaPage(vm: vm.turmaVm);
        case 3:
          return CatequizandoPage(vm: vm.catequizandoVm);
        case 4:
          return RelatorioPage(vm: vm.relatorioVm);
        case 5:
          return ProfilePage(vm: vm.profileVm);
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
    final data = vm.catequistaVm.data.value;
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.church_rounded, size: 32, color: theme.colorScheme.onPrimary),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sistema de Gestão de Catequistas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary.withOpacity(0.5), size: 28),
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
        ],
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
