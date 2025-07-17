import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/auth/models/user_model.dart';

class Lugar {
  final String id;
  String nombre;
  List<MascotaHabito> mascotas;
  List<UserModel> members;
  UserModel owner;
  final DateTime createdAt;
  bool shared;

  Lugar({
    required this.id,
    required this.nombre,
    this.mascotas = const [],
    this.members = const [],
    required this.owner,
    DateTime? createdAt,
    this.shared = false,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'Lugar(id: $id, nombre: $nombre, mascotas: $mascotas, members: $members, owner: $owner, shared: $shared createdAt: $createdAt)';
  }
}
