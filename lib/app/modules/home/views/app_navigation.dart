import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../catequista/models/catequista_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';

int _birthdayCount(List<Catequista> list) {
  final mes = DateTime.now().month;
  return list.where((c) {
    final parts = c.dataNascimento.split('/');
    if (parts.length != 3) return false;
    return int.tryParse(parts[1]) == mes;
  }).length;
}

const menuLabels = [
  'Início', 'Catequistas', 'Turmas', 'Catequizandos', 'Encontros',
  'Avisos', 'Relatórios', 'Coordenadores', 'Perfil', 'Sobre', 'Config. Drive',
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
    icon: Icon(Icons.campaign_outlined),
    selectedIcon: Icon(Icons.campaign_rounded),
    label: Text('Avisos'),
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
  Icons.campaign_rounded,
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
    case 5: return Icons.campaign_rounded;
    case 6: return Icons.bar_chart_rounded;
    case 7: return Icons.admin_panel_settings_rounded;
    case 8: return Icons.person_rounded;
    case 9: return Icons.info_rounded;
    case 10: return Icons.cloud_rounded;
    default: return null;
  }
}

class _AppSideLogo extends StatelessWidget {
  final bool extended;
  final ThemeData theme;

  const _AppSideLogo({required this.extended, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(top: extended ? 24 : 12, bottom: extended ? 20 : 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: extended ? 48 : 36,
              height: extended ? 48 : 36,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.church_rounded, size: extended ? 36 : 28, color: primary),
            ),
          ),
          if (extended) ...[
            const SizedBox(height: 8),
            Text(
              'PNSA Catequese',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
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
            child: Obx(() {
              final count = _birthdayCount(Get.find<CatequistaViewModel>().data.value.catequistas);
              return NavigationRail(
              selectedIndex: visualSelected,
              onDestinationSelected: (i) =>
                  vm.selectedIndex = vm.mapVisualToActual(i),
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              extended: extended,
              minExtendedWidth: 240,
              groupAlignment: -1.0,
              leading: _AppSideLogo(extended: extended, theme: theme),
              destinations: visible.map((i) {
                if (i == 5) {
                  return NavigationRailDestination(
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.campaign_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.campaign_rounded),
                    ),
                    label: const Text('Avisos'),
                  );
                }
                return destinations[i];
              }).toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () => Get.find<AuthController>().logout(),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0, 
                          horizontal: extended ? 16.0 : 8.0,
                        ),
                        child: extended 
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                                const SizedBox(width: 16),
                                Text('Sair', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                                const SizedBox(height: 4),
                                Text('Sair', style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            }),
        );
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  final HomeViewModel vm;
  final ThemeData theme;

  const AppDrawer({super.key, required this.vm, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  for (final i in vm.visibleIndices)
                    if (i == 5)
                      Obx(() {
                        final count = _birthdayCount(Get.find<CatequistaViewModel>().data.value.catequistas);
                        return AppDrawerItem(
                          icon: i == vm.selectedIndex
                              ? (getSelectedIcon(i) ?? menuIcons[i])
                              : menuIcons[i],
                          label: menuLabels[i],
                          selected: vm.selectedIndex == i,
                          theme: theme,
                          badgeCount: count,
                          onTap: () {
                            vm.selectedIndex = i;
                            Navigator.pop(context);
                          },
                        );
                      })
                    else
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
            AppDrawerItem(
              icon: Icons.logout_rounded,
              label: 'Sair',
              theme: theme,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                Get.find<AuthController>().logout();
              },
            ),
          ],
        ),
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
  final int badgeCount;

  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
    this.selected = false,
    this.isDestructive = false,
    this.badgeCount = 0,
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
          leading: badgeCount > 0
              ? Badge(
                  isLabelVisible: true,
                  label: Text('$badgeCount'),
                  child: Icon(icon, color: iconColor, size: 20),
                )
              : Icon(icon, color: iconColor, size: 20),
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
