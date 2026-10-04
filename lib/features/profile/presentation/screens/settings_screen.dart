import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../widgets/custom_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is irreversible. All your profile details, tasks, and data will be permanently wiped from the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                final authRepo = context.read<AuthRepository>();
                await authRepo.deleteAccount();
                if (context.mounted) {
                  context.read<AuthCubit>().logout();
                  context.go('/welcome');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                Text(
                  'Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, currentMode) {
                          return ListTile(
                            leading: const Icon(Icons.palette_outlined),
                            title: const Text('Theme Mode'),
                            subtitle: Text(
                              currentMode == ThemeMode.light
                                  ? 'Light (White)'
                                  : currentMode == ThemeMode.dark
                                      ? 'Dark Mode'
                                      : 'System Default',
                            ),
                            trailing: SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined, size: 16),
                                  label: Text('Light'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined, size: 16),
                                  label: Text('Dark'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.settings_brightness_outlined, size: 16),
                                  label: Text('Auto'),
                                ),
                              ],
                              selected: {currentMode},
                              onSelectionChanged: (set) {
                                context.read<ThemeCubit>().setThemeMode(set.first);
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_outlined),
                        title: const Text('Task Due Reminders'),
                        subtitle: const Text('Receive notifications for upcoming tasks'),
                        value: true,
                        onChanged: (val) {
                          // Toggle preference
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(Icons.info_outline_rounded),
                        title: Text('Version'),
                        trailing: Text('1.0.0+1', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.cloud_done_outlined),
                        title: Text('Cloud Engine'),
                        trailing: Text('Supabase (PostgreSQL + RLS)', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Danger Zone',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account and Personal Data',
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Permanently delete your profile, authentication session, and all associated tasks.',
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Delete Account',
                          isOutlined: true,
                          backgroundColor: theme.colorScheme.error,
                          textColor: theme.colorScheme.error,
                          onPressed: () => _showDeleteAccountConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
