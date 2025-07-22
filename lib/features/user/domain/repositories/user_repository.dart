import 'package:per_habit/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<void> createUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String uid);
  Future<void> updateUserProfile(UserProfile profile);
}
