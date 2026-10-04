import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../repositories/profile_repository.dart';
import '../../../models/user_profile.dart';
import '../../../core/errors/app_exception.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final supa.SupabaseClient _client;

  SupabaseProfileRepository({supa.SupabaseClient? client})
      : _client = client ?? supa.Supabase.instance.client;

  @override
  Future<UserProfile> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException(message: 'User profile not found.');
      }

      return UserProfile.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to load profile. Please try again.',
        originalError: e,
      );
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String fullName,
  }) async {
    try {
      final response = await _client
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update profile. Please try again.',
        originalError: e,
      );
    }
  }
}
