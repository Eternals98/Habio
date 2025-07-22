import 'package:per_habit/features/inventary/domain/entities/inventory.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String photoUrl;
  final bool onboardingCompleted;
  final Inventario inventario;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoUrl,
    this.onboardingCompleted = false,
    Inventario? inventario,
  }) : inventario = inventario ?? Inventario();

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? photoUrl,
    bool? onboardingCompleted,
    Inventario? inventario,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      inventario: inventario ?? this.inventario,
    );
  }
}
