import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  static const _version = '1.0.0+1';
  static const _parish = 'Paróquia Nossa Senhora Auxiliadora';
  static const _city = 'Iporá - GO';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 850;
    final hPad = width < 600 ? 16.0 : 32.0;

    // Seção: Sobre o Sistema
    final sectionAbout = _Section(
      theme: theme,
      title: 'Sobre o Sistema',
      subtitle: 'Informações gerais',
      children: [
        _InfoRow(theme: theme, icon: Icons.church_rounded, label: 'Paróquia', value: _parish),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _InfoRow(theme: theme, icon: Icons.location_on_rounded, label: 'Cidade', value: _city),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _InfoRow(theme: theme, icon: Icons.tag_rounded, label: 'Versão', value: _version),
      ],
    );

    // Seção: Tecnologia
    final sectionTech = _Section(
      theme: theme,
      title: 'Tecnologia',
      subtitle: 'Stack utilizada',
      children: [
        _TechTile(theme: theme, icon: Icons.flutter_dash_rounded, label: 'Flutter', value: 'UI multiplataforma'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _TechTile(theme: theme, icon: Icons.electric_bolt_rounded, label: 'GetX', value: 'Gerenciamento de estado'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _TechTile(theme: theme, icon: Icons.design_services_rounded, label: 'Material 3', value: 'Design System'),
      ],
    );

    // Seção: Plataformas
    final sectionPlatforms = _Section(
      theme: theme,
      title: 'Plataformas',
      subtitle: 'Dispositivos suportados',
      children: [
        _PlatformTile(theme: theme, icon: Icons.web_rounded, label: 'Web'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _PlatformTile(theme: theme, icon: Icons.phone_android_rounded, label: 'Android'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _PlatformTile(theme: theme, icon: Icons.desktop_windows_rounded, label: 'Windows'),
      ],
    );

    // Seção: Funcionalidades
    final sectionFeatures = _Section(
      theme: theme,
      title: 'Funcionalidades',
      subtitle: 'Módulos do sistema',
      children: [
        _FeatureChip(theme: theme, icon: Icons.people_rounded, label: 'Cadastro de Catequistas'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _FeatureChip(theme: theme, icon: Icons.group_rounded, label: 'Gestão de Turmas'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _FeatureChip(theme: theme, icon: Icons.school_rounded, label: 'Cadastro de Catequizandos'),
        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
        _FeatureChip(theme: theme, icon: Icons.event_rounded, label: 'Registro de Encontros'),
      ],
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(theme: theme),
                  const SizedBox(height: 32),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              sectionAbout,
                              const SizedBox(height: 24),
                              sectionPlatforms,
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              sectionTech,
                              const SizedBox(height: 24),
                              sectionFeatures,
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    sectionAbout,
                    const SizedBox(height: 24),
                    sectionTech,
                    const SizedBox(height: 24),
                    sectionPlatforms,
                    const SizedBox(height: 24),
                    sectionFeatures,
                  ],
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.church_rounded,
                            size: 24,
                            color: theme.colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Desenvolvido para a glória de Deus e o bem da catequese',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PNSA Catequese © 2026',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ThemeData theme;
  const _HeaderCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 450;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.25),
            theme.colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 24 : 32,
          horizontal: isSmall ? 16 : 24,
        ),
        child: Flex(
          direction: isSmall ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 64,
                      height: 64,
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.church_rounded,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isSmall ? 0 : 20, height: isSmall ? 16 : 0),
            Expanded(
              flex: isSmall ? 0 : 1,
              child: Column(
                crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    'PNSA Catequese',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistema de Gestão para Catequese',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isSmall ? TextAlign.center : TextAlign.start,
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmall ? 0 : 16, height: isSmall ? 16 : 0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'v${SobrePage._version}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _Section({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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

class _FeatureChip extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.theme,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 20, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

class _TechTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _TechTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.tertiary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _PlatformTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;

  const _PlatformTile({
    required this.theme,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Suportado',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
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