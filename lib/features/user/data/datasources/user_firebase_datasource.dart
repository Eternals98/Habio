import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';


class UserFirestoreDatasource {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<UserProfileModel> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) {
      throw Exception('El perfil no existe');
    }
    return UserProfileModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateUser(UserProfileModel model) async {
    await _usersRef.doc(model.uid).set(model.toMap(), SetOptions(merge: true));
  }
}
