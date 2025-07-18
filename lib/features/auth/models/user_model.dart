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
  final Map<String, int>
  petInventory; // Nuevo atributo para inventario de mascotas

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
    this.petInventory = const {}, // Inicializa como mapa vacío
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now();

  // Convertir UserModel a un mapa para Firestore
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'bio': bio,
    'roomsOwned': roomsOwned,
    'roomsJoined': roomsJoined,
    'createdAt': createdAt,
    'lastActive': lastActive,
    'petInventory': petInventory,
  };

  // Crear un UserModel desde un mapa de Firestore
  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
    uid: data['uid'] ?? '',
    email: data['email'] ?? '',
    displayName: data['displayName'] ?? '',
    photoUrl: data['photoUrl'] ?? '',
    bio: data['bio'] ?? '',
    roomsOwned: List<String>.from(data['roomsOwned'] ?? []),
    roomsJoined: List<String>.from(data['roomsJoined'] ?? []),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    petInventory: Map<String, int>.from(data['petInventory'] ?? {}),
  );
}
