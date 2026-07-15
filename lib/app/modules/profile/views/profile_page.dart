import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  final ProfileViewModel vm;
  const ProfilePage({super.key, required this.vm});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650), // Um pouco mais lento para elegância
    );
    
    // Curva easeOutExpo para uma sensação "premium" e suave
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

    return GetBuilder<ProfileViewModel>(
      init: widget.vm,
      id: 'profile',
      builder: (_) {
        final profile = widget.vm.profile.value;
        
        // Proteção contra carregamento assíncrono
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640), // Ligeiramente mais largo para melhor respiro
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeaderCard(
                        theme: theme,
                        name: profile.name,
                        email: profile.email,
                        role: profile.role,
                      ),
                      const SizedBox(height: 32),
                      _AccountInfoCard(
                        theme: theme,
                        name: profile.name,
                        email: profile.email,
                        role: profile.role,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cartão de destaque com avatar, gradiente refinado e ação de editar.
class _ProfileHeaderCard extends StatelessWidget {
  final ThemeData theme;
  final String name;
  final String email;
  final String role;

  const _ProfileHeaderCard({
    required this.theme,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
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
          // Fundo com gradiente suave
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
          // Glow decorativo refinado
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
          // Botão de editar flutuante
          Positioned(
            top: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // TODO: Implementar navegação para edição de perfil
                  // Get.toNamed('/edit-profile');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.edit_rounded, size: 18, color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
            child: Column(
              children: [
                // Avatar com borda gradiente
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
                        color: primary.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Nome com ShaderMask (texto gradiente)
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primary, theme.colorScheme.tertiary],
                  ).createShader(bounds),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
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
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 20),
                // Badge de Cargo
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge_rounded, size: 18, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text(
                        role,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
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

/// Cartão com as informações detalhadas da conta e efeito de hover.
class _AccountInfoCard extends StatefulWidget {
  final ThemeData theme;
  final String name;
  final String email;
  final String role;

  const _AccountInfoCard({
    required this.theme,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  State<_AccountInfoCard> createState() => _AccountInfoCardState();
}

class _AccountInfoCardState extends State<_AccountInfoCard> {
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
                child: Icon(Icons.badge_outlined, size: 18, color: widget.theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Informações da Conta',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
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
                  child: Column(
                    children: [
                      _ProfileRow(theme: widget.theme, icon: Icons.person_outline_rounded, label: 'Nome Completo', value: widget.name),
                      const _RowDivider(),
                      _ProfileRow(theme: widget.theme, icon: Icons.alternate_email_rounded, label: 'Endereço de E-mail', value: widget.email),
                      const _RowDivider(),
                      _ProfileRow(theme: widget.theme, icon: Icons.work_outline_rounded, label: 'Cargo / Função', value: widget.role),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24), // Recuo aumentado para visual moderno
      child: Divider(height: 1, thickness: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), // Mais respiro vertical
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

/// Badge de ícone reutilizável com fundo em gradiente suave.
class _IconBadge extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color color;

  const _IconBadge({
    required this.theme,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}