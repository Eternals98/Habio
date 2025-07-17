import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/auth/models/user_model.dart';
import 'package:logger/logger.dart';

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String uid) async {
    final logger = Logger();

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data()!);
      } else {
        return null;
      }
    } catch (e, stack) {
      logger.e('Error al obtener el usuario', error: e, stackTrace: stack);
      return null;
    }
  }
}
