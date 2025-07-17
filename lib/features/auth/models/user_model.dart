import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final DateTime createdAt;

  UserModel({required this.uid, required this.email, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'createdAt': createdAt};
  }
}
