import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../viewmodels/home_viewmodel.dart';

const menuLabels = [
  'Início', 'Catequistas', 'Turmas', 'Catequizandos', 'Encontros',
  'Relatórios', 'Coordenadores', 'Perfil', 'Sobre', 'Config. Drive',
];

const destinations = [
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
  NavigationRailDestination(
    icon: Icon(Icons.cloud_outlined),
    selectedIcon: Icon(Icons.cloud_rounded),
    label: Text('Config. Drive'),
  ),
];

const menuIcons = [
  Icons.home_rounded,
  Icons.menu_book_rounded,
  Icons.group_rounded,
  Icons.school_rounded,
  Icons.event_rounded,
  Icons.bar_chart_rounded,
  Icons.admin_panel_settings_rounded,
  Icons.person_rounded,
  Icons.info_outline_rounded,
  Icons.cloud_rounded,
];

IconData? getSelectedIcon(int index) {
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
    case 9: return Icons.cloud_rounded;
    default: return null;
  }
}

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

class AppSideMenu extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;
  final bool extended;

  const AppSideMenu({
    super.key,
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
            navigationRailTheme: NavigationRailThemeData(
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              selectedIconTheme: IconThemeData(
                color: theme.colorScheme.primary, 
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(
                color: theme.colorScheme.onSurfaceVariant, 
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          child: NavigationRail(
            selectedIndex: visualSelected,
            onDestinationSelected: (i) =>
                vm.selectedIndex = vm.mapVisualToActual(i),
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            extended: extended,
            minExtendedWidth: 240,
            groupAlignment: -0.85,
            leading: AppSideMenuHeader(extended: extended, theme: theme),
            destinations: visible.map((i) => destinations[i]).toList(),
            trailing: AppSideMenuFooter(extended: extended, theme: theme),
          ),
        );
      },
    );
  }
}

class AppSideMenuHeader extends StatelessWidget {
  final bool extended;
  final ThemeData theme;

  const AppSideMenuHeader({
    super.key, 
    required this.extended, 
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final user = Get.find<AuthController>().firestoreUser.value;
    final nome = user?.nome ?? '';
    final role = user?.role ?? '';

    return Padding(
      padding: EdgeInsets.only(
        top: extended ? 24 : 12, 
        bottom: extended ? 20 : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withOpacity(0.15)),
            ),
            child: CircleAvatar(
              radius: extended ? 32 : 20,
              backgroundColor: colors.primaryContainer.withOpacity(0.4),
              child: Text(
                _initials(nome),
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: extended ? 22 : 14,
                ),
              ),
            ),
          ),
          if (extended) ...[
            const SizedBox(height: 16),
            Text(
              nome,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _roleLabel(role).toUpperCase(),
              style: TextStyle(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
          SizedBox(height: extended ? 24 : 16),
        ],
      ),
    );
  }
}

class AppSideMenuFooter extends StatelessWidget {
  final bool extended;
  final ThemeData theme;

  const AppSideMenuFooter({
    super.key, 
    required this.extended, 
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    if (extended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: 208,
          child: ListTile(
            onTap: () => Get.find<AuthController>().logout(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            hoverColor: colors.errorContainer.withOpacity(0.15),
            leading: Icon(Icons.logout_rounded, size: 20, color: colors.error),
            title: Text(
              'Sair',
              style: TextStyle(
                color: colors.error,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Tooltip(
          message: 'Sair',
          child: IconButton(
            onPressed: () => Get.find<AuthController>().logout(),
            style: IconButton.styleFrom(
              foregroundColor: colors.error,
              backgroundColor: colors.errorContainer.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
        ),
      );
    }
  }
}

class AppDrawer extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const AppDrawer({super.key, required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final user = Get.find<AuthController>().firestoreUser.value;
    final nome = user?.nome ?? '';
    final email = user?.email ?? '';
    final role = user?.role ?? '';

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        children: [
          // Header Modernizado Flat (M3 Flat Design)
          Container(
            width: double.infinity,
            color: colors.surfaceContainerLow,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.primaryContainer.withOpacity(0.4),
                      child: Text(
                        _initials(nome),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nome,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _roleLabel(role),
                        style: TextStyle(
                          color: colors.onSecondaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
                  AppDrawerItem(
                    icon: i == vm.selectedIndex
                        ? (getSelectedIcon(i) ?? menuIcons[i])
                        : menuIcons[i],
                    label: menuLabels[i],
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
            color: colors.outlineVariant.withOpacity(0.3),
          ),
          SafeArea(
            top: false,
            child: AppDrawerItem(
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

class AppDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDestructive;
  final ThemeData theme;
  final VoidCallback onTap;

  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    final bgColor = isDestructive
        ? Colors.transparent
        : selected
            ? colors.primaryContainer.withOpacity(0.5)
            : Colors.transparent;
    final iconColor = isDestructive
        ? colors.error
        : selected
            ? colors.primary
            : colors.onSurfaceVariant;
    final textColor = isDestructive
        ? colors.error
        : selected
            ? colors.primary
            : colors.onSurface;
    final fontWeight = selected ? FontWeight.bold : FontWeight.w600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor, size: 20),
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