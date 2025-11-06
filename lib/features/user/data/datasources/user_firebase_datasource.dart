import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';

class UserFirestoreDatasource {
  UserFirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  Future<void> createUser(UserProfileModel user) async {
    await _usersRef.doc(user.id).set(user.toMap());
  }

  Future<UserProfileModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUser(UserProfileModel user) async {
    await _usersRef.doc(user.id).update(user.toMap());
  }
}
