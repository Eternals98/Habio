import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';

class Room {
  final String id;
  String name;
  List<PetHabit> pets;
  List<String> members;
  String owner;
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

  // Convertir Room a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pets': pets.map((pet) => pet.toMap()).toList(),
      'members': members,
      'owner': owner,
      'createdAt': Timestamp.fromDate(createdAt),
      'shared': shared,
    };
  }

  // Crear un Room desde un mapa de Firestore
  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      pets:
          (map['pets'] as List<dynamic>?)
              ?.map((pet) => PetHabit.fromMap(pet as Map<String, dynamic>))
              .toList() ??
          [],
      members: (map['members'] as List<dynamic>?)?.cast<String>() ?? [],
      owner: map['owner'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shared: map['shared'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Lugar(id: $id, name: $name, mascotas: $pets, members: $members, owner: $owner, shared: $shared createdAt: $createdAt)';
  }
}
