import 'package:per_habit/features/inventary/domain/entities/inventory.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final bool onboardingCompleted;
  final Inventario inventario;
  final int habipoints;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    this.onboardingCompleted = false,
    Inventario? inventario,
    required this.habipoints,
  }) : inventario = inventario ?? Inventario(userId: id);

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? photoUrl,
    bool? onboardingCompleted,
    int? habipoints,
    Inventario? inventario,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      habipoints: habipoints ?? this.habipoints,
      inventario: inventario ?? this.inventario,
    );
  }
}
