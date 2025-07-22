import 'package:per_habit/features/user/data/datasources/user_firebase_datasource.dart';
import 'package:per_habit/features/user/data/mappers/user_profile_mapper.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<void> createUserProfile(UserProfile profile) {
    final model = UserProfileMapper.toModel(profile);
    return _datasource.createUser(model);
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final model = await _datasource.getUser(uid);
      return UserProfileMapper.fromModel(model!);
    } catch (e) {
      return null; // Devolver null si no se encuentra el perfil
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) {
    final model = UserProfileMapper.toModel(profile);
    return _datasource.updateUser(model);
  }
}
