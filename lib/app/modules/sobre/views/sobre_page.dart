import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  static const _version = '1.0.0+1';
  static const _parish = 'Paróquia Nossa Senhora Auxiliadora';
  static const _city = 'Paraguáis';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, hPad),
      children: [
        _HeaderCard(theme: theme),
        const SizedBox(height: 24),
        _Section(
          theme: theme,
          title: 'Sobre o Sistema',
          subtitle: 'Informações gerais da plataforma',
          children: [
            _InfoRow(theme: theme, icon: Icons.church_rounded, label: 'Paróquia', value: _parish),
            _InfoRow(theme: theme, icon: Icons.location_on_rounded, label: 'Cidade', value: _city),
            _InfoRow(theme: theme, icon: Icons.tag_rounded, label: 'Versão', value: _version),
            _InfoRow(theme: theme, icon: Icons.widgets_rounded, label: 'Framework', value: 'Flutter 3.24'),
            _InfoRow(theme: theme, icon: Icons.code_rounded, label: 'Linguagem', value: 'Dart'),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          theme: theme,
          title: 'Funcionalidades',
          subtitle: 'Módulos disponíveis no sistema',
          children: [
            _FeatureChip(theme: theme, icon: Icons.people_rounded, label: 'Cadastro de Catequistas'),
            _FeatureChip(theme: theme, icon: Icons.group_rounded, label: 'Gestão de Turmas'),
            _FeatureChip(theme: theme, icon: Icons.school_rounded, label: 'Cadastro de Catequizandos'),
            _FeatureChip(theme: theme, icon: Icons.event_rounded, label: 'Registro de Encontros'),
            _FeatureChip(theme: theme, icon: Icons.checklist_rounded, label: 'Controle de Frequência'),
            _FeatureChip(theme: theme, icon: Icons.bar_chart_rounded, label: 'Relatórios e Estatísticas'),
            _FeatureChip(theme: theme, icon: Icons.admin_panel_settings_rounded, label: 'Gestão de Coordenadores'),
            _FeatureChip(theme: theme, icon: Icons.picture_as_pdf_rounded, label: 'Exportação de Fichas em PDF'),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          theme: theme,
          title: 'Tecnologia',
          subtitle: 'Stack utilizada no desenvolvimento',
          children: [
            _TechTile(theme: theme, icon: Icons.flutter_dash_rounded, label: 'Flutter', value: 'UI multiplataforma'),
            _TechTile(theme: theme, icon: Icons.electric_bolt_rounded, label: 'GetX', value: 'Estado, rotas e injeção de dependência'),
            _TechTile(theme: theme, icon: Icons.design_services_rounded, label: 'Material Design 3', value: 'Design system moderno e responsivo'),
            _TechTile(theme: theme, icon: Icons.picture_as_pdf_rounded, label: 'PDF', value: 'Geração de documentos com pdf/printing'),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          theme: theme,
          title: 'Plataformas',
          subtitle: 'Dispositivos suportados',
          children: [
            _PlatformTile(theme: theme, icon: Icons.web_rounded, label: 'Web'),
            _PlatformTile(theme: theme, icon: Icons.phone_android_rounded, label: 'Android'),
            _PlatformTile(theme: theme, icon: Icons.phone_iphone_rounded, label: 'iOS'),
            _PlatformTile(theme: theme, icon: Icons.desktop_windows_rounded, label: 'Windows'),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Icon(Icons.church_rounded, size: 28, color: theme.colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                'Desenvolvido para a glória de Deus e o bem da catequese',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PNSA Catequese © 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ThemeData theme;
  const _HeaderCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.church_rounded, size: 48, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              'PNSA Catequese',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sistema de Gestão para Catequese Paroquial',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'v${SobrePage._version}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
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
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: children),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 18, color: theme.colorScheme.primary.withOpacity(0.5)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.tertiary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Suportado',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
