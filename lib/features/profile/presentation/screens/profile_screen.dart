import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/theme_toggle_button.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/domain/auth_state.dart';
import '../cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, String currentName, String userId) {
    final nameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Full Name',
                validator: (val) {
                  if (val == null || val.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final updated = await context.read<ProfileCubit>().updateProfile(
                      userId: userId,
                      fullName: nameController.text.trim(),
                    );
                if (updated != null && context.mounted) {
                  context.read<AuthCubit>().updateLocalProfile(updated);
                  Navigator.of(dialogCtx).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user;
        final profile = authState.profile;
        final fullName = profile?.fullName ?? 'User';
        final email = profile?.email.isNotEmpty == true ? profile!.email : (user.email ?? '');
        final createdAtStr = profile != null
            ? DateFormat.yMMMMd().format(profile.createdAt)
            : 'Recently';

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              const ThemeToggleButton(),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign Out',
                onPressed: () => _confirmSignOut(context),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: theme.colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                              onPressed: () => _showEditProfileDialog(context, fullName, user.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined),
                            title: const Text('Member Since'),
                            subtitle: Text(createdAtStr),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.fingerprint_rounded),
                            title: const Text('User ID'),
                            subtitle: Text(
                              user.id,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_reset_rounded),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/change-password'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.settings_outlined),
                          title: const Text('Application Settings'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Sign Out',
                    isOutlined: true,
                    icon: Icons.logout_rounded,
                    textColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.error,
                    onPressed: () => _confirmSignOut(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
