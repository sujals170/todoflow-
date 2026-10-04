import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeCubit? cubit;
    try {
      cubit = context.read<ThemeCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = cubit!.isDarkMode(context);
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? Colors.amber : null,
          ),
          tooltip: isDark ? 'Switch to Light (White) Mode' : 'Switch to Dark Mode',
          onPressed: () => cubit!.toggleTheme(context),
        );
      },
    );
  }
}
