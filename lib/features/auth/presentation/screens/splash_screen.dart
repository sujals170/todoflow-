import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../../domain/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    if (!mounted) return;
    final state = context.read<AuthCubit>().state;
    _navigateBasedOnState(state);

    // Fallback: If still on splash after 1 second, navigate appropriately
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final currentState = context.read<AuthCubit>().state;
        if (currentState is Authenticated) {
          context.go('/home');
        } else {
          context.go('/welcome');
        }
      }
    });
  }

  void _navigateBasedOnState(AuthState state) {
    if (!mounted) return;
    if (state is Authenticated) {
      context.go('/home');
    } else if (state is Unauthenticated || state is AuthError) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _navigateBasedOnState(state);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TodoFlow',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
