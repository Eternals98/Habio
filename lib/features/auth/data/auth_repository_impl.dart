
import 'package:per_habit/features/auth/domain/entities/auth_user.dart';
import 'package:per_habit/features/auth/domain/repositories/auth_repository.dart';

import 'datasources/firebase_auth_datasource.dart';
import 'mappers/firebase_user_mapper.dart';

/// Implementación concreta de [AuthRepository] usando Firebase.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _firebase;

  AuthRepositoryImpl(this._firebase);

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _firebase.login(email, password);
    return FirebaseUserMapper.fromFirebase(user);
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    final user = await _firebase.register(email, password);
    return FirebaseUserMapper.fromFirebase(user);
  }

  @override
  Future<void> logout() => _firebase.logout();

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebase.authStateChanges().map((user) {
      if (user == null) return null;
      return FirebaseUserMapper.fromFirebase(user);
    });
  }

  @override
  Future<void> resetPassword({required String email}) {
    return _firebase.resetPassword(email);
  }
}
