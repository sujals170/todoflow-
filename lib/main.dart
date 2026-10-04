import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/profile/data/supabase_profile_repository.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/todos/data/supabase_todo_repository.dart';
import 'features/todos/presentation/cubit/todo_cubit.dart';
import 'repositories/auth_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/todo_repository.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env)
  await EnvConfig.init();

  // Initialize Supabase with Session persistence
  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  } catch (e) {
    debugPrint('Supabase initialization notice: $e');
  }

  final authRepository = SupabaseAuthRepository();
  final profileRepository = SupabaseProfileRepository();
  final todoRepository = SupabaseTodoRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<TodoRepository>.value(value: todoRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: authRepository,
              profileRepository: profileRepository,
            ),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              profileRepository: profileRepository,
            ),
          ),
          BlocProvider<TodoCubit>(
            create: (context) => TodoCubit(
              todoRepository: todoRepository,
            ),
          ),
        ],
        child: const TodoApp(),
      ),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'TodoFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
