import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/user/application/get_user_profile_use_case.dart';
import 'package:per_habit/features/user/application/update_user_profile_use_case.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Estado del perfil de usuario
typedef UserState = AsyncValue<UserProfile?>;

class UserController extends StateNotifier<UserState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;

  UserController({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    try {
      final profile = await getUserProfile(user.uid);
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = const AsyncValue.loading();
    try {
      await updateUserProfile(newProfile);
      state = AsyncValue.data(newProfile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
