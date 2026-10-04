import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/responsive_layout.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final Widget body;
  final VoidCallback? onSearchShortcut;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.body,
    this.onSearchShortcut,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/profile');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final theme = Theme.of(context);

    // Global desktop keyboard shortcuts
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          context.push('/todo/new');
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          widget.onSearchShortcut?.call();
        },
      },
      child: Focus(
        autofocus: true,
        child: isDesktop ? _buildDesktopLayout(theme) : _buildMobileLayout(theme),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            extended: MediaQuery.of(context).size.width >= 1100,
            leading: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.small(
                  elevation: 2,
                  onPressed: () => context.push('/todo/new'),
                  tooltip: 'Create Task (Ctrl+N)',
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 16),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outline_rounded),
                selectedIcon: Icon(Icons.check_circle_rounded),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Scaffold(
      body: widget.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline_rounded),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
