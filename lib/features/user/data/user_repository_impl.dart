
import 'package:per_habit/features/user/data/datasources/user_firebase_datasource.dart';
import 'package:per_habit/features/user/data/mappers/user_profile_mapper.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';
import 'package:per_habit/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserFirestoreDatasource datasource;

  UserRepositoryImpl(this.datasource);

  @override
  Future<UserProfile> getProfile(String uid) async {
    final model = await datasource.getUser(uid);
    return UserProfileMapper.fromModel(model);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = UserProfileMapper.toModel(profile);
    await datasource.updateUser(model);
  }
}
