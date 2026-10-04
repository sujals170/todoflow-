import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/profile_repository.dart';
import '../../../../models/user_profile.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileLoading());
    try {
      final profile = await _profileRepository.getProfile(userId);
      emit(ProfileLoaded(profile));
    } on AppException catch (e) {
      emit(ProfileError(e.message));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<UserProfile?> updateProfile({
    required String userId,
    required String fullName,
  }) async {
    if (state is ProfileLoaded) {
      final current = (state as ProfileLoaded).profile;
      emit(ProfileUpdating(current));
    } else {
      emit(const ProfileLoading());
    }

    try {
      final updated = await _profileRepository.updateProfile(
        userId: userId,
        fullName: fullName,
      );
      emit(ProfileLoaded(updated));
      return updated;
    } on AppException catch (e) {
      emit(ProfileError(e.message));
      return null;
    } catch (e) {
      emit(ProfileError(e.toString()));
      return null;
    }
  }
}
