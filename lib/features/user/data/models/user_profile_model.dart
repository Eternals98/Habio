import 'package:per_habit/features/inventary/data/models/inventory_model.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.bio,
    required super.photoUrl,
    required super.habipoints,
    super.onboardingCompleted = false,
    super.inventario,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return UserProfileModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      habipoints: map['habipoints'] ?? 0,
      inventario: InventarioModel.fromMap(map['inventario'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'onboardingCompleted': onboardingCompleted,
      'habipoints': habipoints,
      'inventario': (inventario as InventarioModel).toMap(),
    };
  }
}
