import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String bio;
  final List<String> roomsOwned;
  final List<String> roomsJoined;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoUrl = '',
    this.bio = '',
    this.roomsOwned = const [],
    this.roomsJoined = const [],
    DateTime? createdAt,
    DateTime? lastActive,
  }) : createdAt = createdAt ?? DateTime.now(),
      lastActive = lastActive ?? DateTime.now();

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      roomsOwned: List<String>.from(map['roomsOwned'] ?? []),
      roomsJoined: List<String>.from(map['roomsJoined'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'roomsOwned': roomsOwned,
      'roomsJoined': roomsJoined,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }
}
