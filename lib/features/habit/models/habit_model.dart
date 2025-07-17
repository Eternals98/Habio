// ignore_for_file: file_names

import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/habit/types/mechanic.dart';
import 'package:per_habit/features/habit/types/personality.dart';
import 'package:per_habit/features/habit/types/petType.dart';

class PetHabit {
  final String id;
  String name;
  String userModel;
  String room;
  Mechanic mechanic;
  Personality personality;
  PetType petType;
  final DateTime createdAt;
  Offset position;

  PetHabit({
    required this.id,
    required this.name,
    required this.userModel,
    required this.room,
    required this.mechanic,
    required this.personality,
    required this.petType,
    this.position = Offset.zero,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir PetHabit a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userModel': userModel,
      'room': room,
      'mechanic': mechanic.toMap(),
      'personality': personality.toMap(),
      'petType': petType.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'position': {'dx': position.dx, 'dy': position.dy},
    };
  }

  // Crear un PetHabit desde un mapa de Firestore
  factory PetHabit.fromMap(Map<String, dynamic> map) {
    return PetHabit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      userModel: (map['userModel']),
      room: map['room'] ?? '',
      mechanic: Mechanic.fromMap(map['mechanic'] as String),
      personality: Personality.fromMap(map['personality'] as String),
      petType: PetType.fromMap(map['petType'] as String),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      position: Offset(
        (map['position']?['dx'] as num?)?.toDouble() ?? 0.0,
        (map['position']?['dy'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  // Método random para crear un PetHabit aleatorio
  factory PetHabit.random(String id, String name, String user, String room) {
    final random = math.Random();
    return PetHabit(
      id: id,
      name: name,
      userModel: user,
      room: room,
      mechanic: Mechanic.values[random.nextInt(Mechanic.values.length)],
      personality:
          Personality.values[random.nextInt(Personality.values.length)],
      petType: PetType.values[random.nextInt(PetType.values.length)],
      position: const Offset(50, 50),
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, user: $userModel, room: $room, mechanic: $mechanic, personality: $personality, petType: $petType createdAt: $createdAt)';
  }
}
