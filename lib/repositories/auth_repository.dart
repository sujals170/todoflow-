import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  Session? get currentSession;
  bool get isAuthenticated;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserResponse> updatePassword(String newPassword);

  Future<void> deleteAccount();
}
