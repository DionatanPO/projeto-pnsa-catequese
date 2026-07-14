import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  final ProfileViewModel vm;
  const ProfilePage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<ProfileViewModel>(
      init: vm,
      id: 'profile',
      builder: (_) {
        final profile = vm.profile.value;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person_rounded,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            profile.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.email,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Chip(
                            label: Text(profile.role),
                            avatar: Icon(
                              Icons.school_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações da Conta',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: 32),
                          _ProfileRow(label: 'Nome', value: profile.name),
                          const SizedBox(height: 16),
                          _ProfileRow(label: 'E-mail', value: profile.email),
                          const SizedBox(height: 16),
                          _ProfileRow(label: 'Cargo', value: profile.role),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
