import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

class UserProfileMapper {
  static UserProfile fromModel(UserProfileModel model) {
    return UserProfile(
      id: model.id,
      email: model.email,
      displayName: model.displayName,
      bio: model.bio,
      photoUrl: model.photoUrl,
      onboardingCompleted: model.onboardingCompleted,
      habipoints: model.habipoints,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      bio: entity.bio,
      photoUrl: entity.photoUrl,
      onboardingCompleted: entity.onboardingCompleted,
      habipoints: entity.habipoints,
    );
  }
}
