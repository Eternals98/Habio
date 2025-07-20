
import 'package:per_habit/features/user/data/models/user_profile_model.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

class UserProfileMapper {
  static UserProfile fromModel(UserProfileModel model) {
    return UserProfile(
      uid: model.uid,
      email: model.email,
      displayName: model.displayName,
      avatarUrl: model.avatarUrl,
      onboardingCompleted: model.onboardingCompleted,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      onboardingCompleted: entity.onboardingCompleted,
    );
  }
}
