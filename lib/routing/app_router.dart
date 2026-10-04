import 'package:go_router/go_router.dart';
import '../models/todo_item.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/todos/presentation/screens/home_screen.dart';
import '../features/todos/presentation/screens/todo_form_screen.dart';
import '../features/todos/presentation/screens/todo_detail_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/todo/new',
          builder: (context, state) => const TodoFormScreen(),
        ),
        GoRoute(
          path: '/todo/edit',
          builder: (context, state) {
            final item = state.extra as TodoItem?;
            return TodoFormScreen(initialItem: item);
          },
        ),
        GoRoute(
          path: '/todo/detail/:id',
          builder: (context, state) {
            final todoId = state.pathParameters['id'] ?? '';
            return TodoDetailScreen(todoId: todoId);
          },
        ),
      ],
    );
  }
}
