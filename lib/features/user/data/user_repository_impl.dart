import 'package:per_habit/features/user/data/datasources/user_firebase_datasource.dart';
import 'package:per_habit/features/user/data/mappers/user_profile_mapper.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDatasource _datasource; // ✅ Campo privado

  UserRepositoryImpl(this._datasource); // ✅ Constructor

  @override
  Future<void> createUserProfile(UserProfile profile) {
    final model = UserProfileMapper.toModel(profile);
    return _datasource.createUser(model); // ✅ Usar _datasource
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final model = await _datasource.getUser(uid);
    return UserProfileMapper.fromModel(model);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) {
    final model = UserProfileMapper.toModel(profile);
    return _datasource.updateUser(model);
  }
}
