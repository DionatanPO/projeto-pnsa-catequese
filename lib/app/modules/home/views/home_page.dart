import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../catequista/views/catequista_page.dart';
import '../../turma/views/turma_page.dart';
import '../../encontros/views/encontro_page.dart';
import '../../encontros/views/encontros_page.dart';
import '../../catequizandos/views/catequizando_page.dart';
import '../../catequizandos/views/catequizando_wizard.dart';
import '../../relatorio/views/relatorio_page.dart';
import '../../coordenadores/views/coordenador_page.dart';
import '../../profile/views/profile_page.dart';
import '../../sobre/views/sobre_page.dart';

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

const _menuLabels = ['Início', 'Catequistas', 'Turmas', 'Catequizandos', 'Encontros', 'Relatórios', 'Coordenadores', 'Perfil', 'Sobre'];

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
    icon: Icon(Icons.event_outlined),
    selectedIcon: Icon(Icons.event_rounded),
    label: Text('Encontros'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart_rounded),
    label: Text('Relatórios'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.admin_panel_settings_outlined),
    selectedIcon: Icon(Icons.admin_panel_settings_rounded),
    label: Text('Coordenadores'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person_rounded),
    label: Text('Perfil'),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.info_outline_rounded),
    selectedIcon: Icon(Icons.info_rounded),
    label: Text('Sobre'),
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
    case 6:
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
      builder: (_) {
        final visible = vm.visibleIndices;
        final visualSelected = vm.mapActualToVisual(vm.selectedIndex);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              onSurface: theme.colorScheme.onPrimary,
              onSurfaceVariant: theme.colorScheme.onPrimary.withOpacity(0.65),
            ),
            navigationRailTheme: NavigationRailThemeData(
              backgroundColor: theme.colorScheme.primary,
              indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.18),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: NavigationRail(
            selectedIndex: visualSelected,
            onDestinationSelected: (i) => vm.selectedIndex = vm.mapVisualToActual(i),
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            extended: extended,
            minExtendedWidth: 220,
            groupAlignment: -1.0,
            leading: _SideMenuHeader(extended: extended, theme: theme),
            destinations: visible.map((i) => _destinations[i]).toList(),
            trailing: _SideMenuFooter(extended: extended, theme: theme),
          ),
        );
      },
    );
  }
}

class _SideMenuHeader extends StatelessWidget {
  final bool extended;
  final ThemeData theme;

  const _SideMenuHeader({required this.extended, required this.theme});

  String _initials(String nome) {
    if (nome.isEmpty) return '?';
    return nome.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'administrador': return 'Administrador';
      case 'coordenador': return 'Coordenador';
      default: return 'Catequista';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().firestoreUser.value;
    final nome = user?.nome ?? '';
    final email = user?.email ?? '';
    final role = user?.role ?? '';

    return Padding(
      padding: EdgeInsets.only(top: extended ? 20 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
      CircleAvatar(
            radius: extended ? 26 : 18,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.16),
            child: Text(
              _initials(nome),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: extended ? 20 : 13,
              ),
            ),
          ),
          if (extended) ...[
            const SizedBox(height: 10),
            Text(
              nome,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: TextStyle(
                color: theme.colorScheme.onPrimary.withOpacity(0.55),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _roleLabel(role),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
          SizedBox(height: extended ? 20 : 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: extended ? 16 : 8),
            height: 1,
            color: theme.colorScheme.onPrimary.withOpacity(0.10),
          ),
        ],
      ),
    );
  }
}

class _SideMenuFooter extends StatelessWidget {
  final bool extended;
  final ThemeData theme;

  const _SideMenuFooter({required this.extended, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: extended ? 16 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: extended ? 16 : 8, vertical: 8),
            height: 1,
            color: theme.colorScheme.onPrimary.withOpacity(0.10),
          ),
          InkWell(
            onTap: () => Get.find<AuthController>().logout(),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 16 : 8,
                vertical: 10,
              ),
              child: extended
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: theme.colorScheme.onPrimary.withOpacity(0.55)),
                        const SizedBox(width: 10),
                        Text('Sair', style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                      ],
                    )
                  : Icon(Icons.logout_rounded, size: 20, color: theme.colorScheme.onPrimary.withOpacity(0.55)),
            ),
          ),
        ],
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
        drawer: _AppDrawer(vm: vm, theme: theme),
        body: _buildBody(vm, theme),
        floatingActionButton: _buildFab(context, vm),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const _AppDrawer({required this.vm, required this.theme});

  String _initials(String nome) {
    if (nome.isEmpty) return '?';
    return nome.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'administrador': return 'Administrador';
      case 'coordenador': return 'Coordenador';
      default: return 'Catequista';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().firestoreUser.value;
    final nome = user?.nome ?? '';
    final email = user?.email ?? '';
    final role = user?.role ?? '';

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.88),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.18),
                      child: Text(
                        _initials(nome),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      nome,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withOpacity(0.65),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _roleLabel(role),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final i in vm.visibleIndices)
                  _DrawerItem(
                    icon: i == vm.selectedIndex
                        ? (_getSelectedIcon(i) ?? _menuIcons[i])
                        : _menuIcons[i],
                    label: _menuLabels[i],
                    selected: vm.selectedIndex == i,
                    theme: theme,
                    onTap: () {
                      vm.selectedIndex = i;
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
          SafeArea(
            top: false,
            child: _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Sair',
              theme: theme,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                Get.find<AuthController>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDestructive;
  final ThemeData theme;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDestructive
        ? Colors.transparent
        : selected
            ? theme.colorScheme.primaryContainer.withOpacity(0.6)
            : Colors.transparent;
    final iconColor = isDestructive
        ? theme.colorScheme.error
        : selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
    final textColor = isDestructive
        ? theme.colorScheme.error
        : selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;
    final fontWeight = selected ? FontWeight.w600 : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: 22),
          title: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 14,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

const _menuIcons = [
  Icons.home_rounded,
  Icons.menu_book_rounded,
  Icons.group_rounded,
  Icons.school_rounded,
  Icons.event_rounded,
  Icons.bar_chart_rounded,
  Icons.admin_panel_settings_rounded,
  Icons.person_rounded,
  Icons.info_outline_rounded,
];

IconData? _getSelectedIcon(int index) {
  switch (index) {
    case 0: return Icons.home_rounded;
    case 1: return Icons.menu_book_rounded;
    case 2: return Icons.group_rounded;
    case 3: return Icons.school_rounded;
    case 4: return Icons.event_rounded;
    case 5: return Icons.bar_chart_rounded;
    case 6: return Icons.admin_panel_settings_rounded;
    case 7: return Icons.person_rounded;
    case 8: return Icons.info_rounded;
    default: return null;
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
          return RelatorioPage(
            relatorioVm: vm.relatorioVm,
            catequizandoVm: vm.catequizandoVm,
            turmaVm: vm.turmaVm,
            encontrosVm: vm.encontrosVm,
            matriculaVm: vm.matriculaVm,
          );
        case 6:
          return vm.isRestricted(6)
              ? _InicioContent(vm: vm, theme: theme)
              : CoordenadorPage(vm: vm.coordenadorVm);
        case 7:
          return ProfilePage(vm: vm.profileVm);
        case 8:
          return const SobrePage();
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
