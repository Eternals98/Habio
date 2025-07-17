import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    try {
      return Room(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? 'Sin nombre',
        pets:
            (map['pets'] as List<dynamic>?)?.map((pet) {
              return PetHabit.fromMap(pet as Map<String, dynamic>);
            }).toList() ??
            [],
        members: List<String>.from(map['members'] ?? []),
        owner: map['owner'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        shared: map['shared'] as bool? ?? false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error en Room.fromMap: $e, datos: $map');
      }
      rethrow;
    }
  }

  @override
  String toString() {
    return 'Lugar(id: $id, name: $name, mascotas: $pets, members: $members, owner: $owner, shared: $shared createdAt: $createdAt)';
  }
}
