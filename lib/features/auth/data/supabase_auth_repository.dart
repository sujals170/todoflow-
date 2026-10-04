import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../repositories/auth_repository.dart';
import '../../../core/errors/app_exception.dart';

class SupabaseAuthRepository implements AuthRepository {
  final supa.SupabaseClient _client;

  SupabaseAuthRepository({supa.SupabaseClient? client})
      : _client = client ?? supa.Supabase.instance.client;

  @override
  Stream<supa.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  supa.User? get currentUser => _client.auth.currentUser;

  @override
  supa.Session? get currentSession => _client.auth.currentSession;

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  Future<supa.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
        },
      );
      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: _mapAuthErrorMessage(e.message),
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Registration failed. Please check your network and try again.',
        originalError: e,
      );
    }
  }

  @override
  Future<supa.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: _mapAuthErrorMessage(e.message),
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Sign in failed. Please check your connection and credentials.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Sign out failed.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'todoapp://reset-password',
      );
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: _mapAuthErrorMessage(e.message),
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to send password reset email. Please try again.',
        originalError: e,
      );
    }
  }

  @override
  Future<supa.UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        supa.UserAttributes(password: newPassword),
      );
      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(
        message: _mapAuthErrorMessage(e.message),
        code: e.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to update password.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw const AuthException(message: 'No active session.');

      // With cascade delete, deleting the profile or calling Supabase auth RPC cleans up associated records
      await _client.from('profiles').delete().eq('id', userId);
      await signOut();
    } catch (e) {
      throw AuthException(
        message: 'Could not delete account. Please try again later.',
        originalError: e,
      );
    }
  }

  /// Map Supabase errors to clean, secure user-facing messages
  String _mapAuthErrorMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid grant')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('email already in use')) {
      return 'An account with this email address already exists.';
    }
    if (lower.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    return rawMessage;
  }
}
