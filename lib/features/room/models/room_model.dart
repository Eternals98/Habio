import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/auth/models/user_model.dart';

class Room {
  final String id;
  String name;
  List<PetHabit> pets;
  List<UserModel> members;
  UserModel owner;
  final DateTime createdAt;
  bool shared;

  Room({
    required this.id,
    required this.name,
    this.pets = const [],
    this.members = const [],
    required this.owner,
    DateTime? createdAt,
    this.shared = false,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'Lugar(id: $id, name: $name, mascotas: $pets, members: $members, owner: $owner, shared: $shared createdAt: $createdAt)';
  }
}
