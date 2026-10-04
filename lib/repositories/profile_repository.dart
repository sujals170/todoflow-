import '../models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);
  Future<UserProfile> updateProfile({
    required String userId,
    required String fullName,
  });
}
