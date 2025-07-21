import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/user/application/get_user_profile_use_case.dart';
import 'package:per_habit/features/user/application/update_user_profile_use_case.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

/// Estado del perfil de usuario
class UserState {
  final bool loading;
  final UserProfile? profile;
  final String? error;

  const UserState({
    this.loading = false,
    this.profile,
    this.error,
  });

  UserState copyWith({
    bool? loading,
    UserProfile? profile,
    String? error,
  }) {
    return UserState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

/// Controlador para manejar estado y acciones del perfil de usuario
class UserController extends StateNotifier<UserState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;

  UserController({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(const UserState());

  Future<void> loadProfile(String uid) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final profile = await getUserProfile(uid);
      state = state.copyWith(loading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await updateUserProfile(newProfile);
      state = state.copyWith(loading: false, profile: newProfile);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
