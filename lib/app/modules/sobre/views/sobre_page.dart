import 'package:flutter/material.dart';

class SobrePage extends StatefulWidget {
  const SobrePage({super.key});

  static const _version = '1.0.0+1';
  static const _parish = 'Paróquia Nossa Senhora Auxiliadora';
  static const _city = 'Iporá - GO';

  @override
  State<SobrePage> createState() => _SobrePageState();
}

class _SobrePageState extends State<SobrePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Um pouco mais lento para elegância
    );
    
    // Curva easeOutExpo é mais suave e "premium" que easeOutCubic
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 850;
    final hPad = width < 600 ? 20.0 : 40.0; // Aumentei um pouco o padding lateral

    final sectionAbout = _Section(
      theme: theme,
      title: 'Sobre o Sistema',
      subtitle: 'Informações gerais',
      icon: Icons.info_outline_rounded,
      children: [
        _InfoRow(theme: theme, icon: Icons.church_rounded, label: 'Paróquia', value: SobrePage._parish),
        const _RowDivider(),
        _InfoRow(theme: theme, icon: Icons.location_on_rounded, label: 'Cidade', value: SobrePage._city),
        const _RowDivider(),
        _InfoRow(theme: theme, icon: Icons.tag_rounded, label: 'Versão', value: SobrePage._version),
      ],
    );

    final sectionTech = _Section(
      theme: theme,
      title: 'Tecnologia',
      subtitle: 'Stack utilizada',
      icon: Icons.memory_rounded,
      children: [
        _TechTile(theme: theme, icon: Icons.flutter_dash_rounded, label: 'Flutter', value: 'UI multiplataforma'),
        const _RowDivider(),
        _TechTile(theme: theme, icon: Icons.bolt_rounded, label: 'GetX', value: 'Gerenciamento de estado'),
        const _RowDivider(),
        _TechTile(theme: theme, icon: Icons.design_services_rounded, label: 'Material 3', value: 'Design System'),
      ],
    );

    final sectionPlatforms = _Section(
      theme: theme,
      title: 'Plataformas',
      subtitle: 'Dispositivos suportados',
      icon: Icons.devices_rounded,
      children: [
        _PlatformTile(theme: theme, icon: Icons.web_rounded, label: 'Web'),
        const _RowDivider(),
        _PlatformTile(theme: theme, icon: Icons.phone_android_rounded, label: 'Android'),
        const _RowDivider(),
        _PlatformTile(theme: theme, icon: Icons.desktop_windows_rounded, label: 'Windows'),
      ],
    );

    final sectionFeatures = _Section(
      theme: theme,
      title: 'Funcionalidades',
      subtitle: 'Módulos do sistema',
      icon: Icons.dashboard_customize_rounded,
      children: [
        _FeatureChip(theme: theme, icon: Icons.people_rounded, label: 'Cadastro de Catequistas'),
        const _RowDivider(),
        _FeatureChip(theme: theme, icon: Icons.group_rounded, label: 'Gestão de Turmas'),
        const _RowDivider(),
        _FeatureChip(theme: theme, icon: Icons.school_rounded, label: 'Cadastro de Catequizandos'),
        const _RowDivider(),
        _FeatureChip(theme: theme, icon: Icons.event_rounded, label: 'Registro de Encontros'),
      ],
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080), // Ligeiramente mais largo para desktop
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Rolagem mais suave no mobile
              padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 48),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeaderCard(),
                      const SizedBox(height: 40),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  sectionAbout,
                                  const SizedBox(height: 28),
                                  sectionPlatforms,
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                children: [
                                  sectionTech,
                                  const SizedBox(height: 28),
                                  sectionFeatures,
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        sectionAbout,
                        const SizedBox(height: 28),
                        sectionTech,
                        const SizedBox(height: 28),
                        sectionPlatforms,
                        const SizedBox(height: 28),
                        sectionFeatures,
                      ],
                      const SizedBox(height: 56),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho com gradiente refinado e efeito de borda sutil (Glassmorphism hint)
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.width < 450;
    final primary = theme.colorScheme.primary;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.4),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Glow decorativo mais suave
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primary.withOpacity(0.15), primary.withOpacity(0.0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isSmall ? 32 : 40,
              horizontal: isSmall ? 24 : 32,
            ),
            child: Flex(
              direction: isSmall ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, theme.colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      color: theme.colorScheme.surface,
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 72,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.church_rounded, size: 36, color: primary),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 0 : 24, height: isSmall ? 20 : 0),
                Expanded(
                  flex: isSmall ? 0 : 1,
                  child: Column(
                    crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primary, theme.colorScheme.tertiary],
                        ).createShader(bounds),
                        child: Text(
                          'PNSA Catequese',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestão para Catequese',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        textAlign: isSmall ? TextAlign.center : TextAlign.start,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isSmall ? 0 : 24, height: isSmall ? 24 : 0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'v${SobrePage._version}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
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

/// Seção com efeito de hover sutil para desktop
class _Section extends StatefulWidget {
  final ThemeData theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.theme.colorScheme.primary.withOpacity(0.15),
                      widget.theme.colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.theme.colorScheme.primary.withOpacity(0.1)),
                ),
                child: Icon(widget.icon, size: 18, color: widget.theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.theme.colorScheme.outlineVariant.withOpacity(_isHovered ? 0.4 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.colorScheme.shadow.withOpacity(_isHovered ? 0.08 : 0.04),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 12 : 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: widget.theme.colorScheme.primary.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Column(children: widget.children),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Recuo para visual moderno
      child: Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.theme, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _IconBadge(theme: theme, icon: icon, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
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

  const _FeatureChip({required this.theme, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _IconBadge(theme: theme, icon: icon, color: theme.colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary),
          ),
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

  const _TechTile({required this.theme, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _IconBadge(theme: theme, icon: icon, color: theme.colorScheme.tertiary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
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

  const _PlatformTile({required this.theme, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _IconBadge(
            theme: theme,
            icon: icon,
            color: theme.colorScheme.onSurfaceVariant,
            background: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Suportado',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
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

class _IconBadge extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color color;
  final Color? background;

  const _IconBadge({required this.theme, required this.icon, required this.color, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: background == null 
          ? LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.tertiary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
          ),
          child: Icon(Icons.church_rounded, size: 24, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        Text(
          'PNSA Catequese © ${DateTime.now().year}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}