import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/profile_repository.dart';
import '../../../../models/user_profile.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthCubit({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Listen to real-time Supabase auth state events
    _authSubscription = _authRepository.authStateChanges.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserProfile(session.user);
      } else {
        emit(const Unauthenticated());
      }
    });

    // Check existing session at startup
    final currentSession = _authRepository.currentSession;
    if (currentSession != null) {
      _loadUserProfile(currentSession.user);
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _loadUserProfile(supa.User user) async {
    try {
      final profile = await _profileRepository.getProfile(user.id);
      emit(Authenticated(user: user, profile: profile));
    } catch (_) {
      // Even if profile fetch is momentarily delayed, emit authenticated user
      emit(Authenticated(
        user: user,
        profile: UserProfile(
          id: user.id,
          fullName: user.userMetadata?['full_name'] as String? ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _loadUserProfile(response.user!);
      } else {
        emit(const AuthError('Login completed but no user session was returned.'));
      }
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(const AuthLoading());
    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (response.user != null) {
        if (response.session != null) {
          await _loadUserProfile(response.user!);
        } else {
          // Immediately sign in with password to bypass email verification links
          try {
            final loginResponse = await _authRepository.signIn(
              email: email,
              password: password,
            );
            if (loginResponse.user != null) {
              await _loadUserProfile(loginResponse.user!);
              return;
            }
          } catch (_) {
            emit(const AuthError(
              'Email confirmation is required by Supabase. To disable links: Open Supabase Dashboard -> Authentication -> Providers -> Email -> Turn OFF "Confirm email".',
            ));
          }
        }
      }
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void updateLocalProfile(UserProfile updatedProfile) {
    if (state is Authenticated) {
      final current = state as Authenticated;
      emit(Authenticated(user: current.user, profile: updatedProfile));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
