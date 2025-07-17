class UserModel {
  final String uid;
  final String email;
  final DateTime createdAt;

  UserModel({required this.uid, required this.email, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'createdAt': createdAt};
  }
}
