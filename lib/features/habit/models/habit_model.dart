// ignore_for_file: file_names

import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:per_habit/features/habit/types/mechanic.dart';
import 'package:per_habit/features/habit/types/personality.dart';
import 'package:per_habit/features/habit/types/petType.dart';
import 'package:per_habit/features/habit/types/status.dart';

class PetHabit {
  final String id;
  String name;
  String userId;
  String room;
  Mechanic mechanic;
  Personality personality;
  PetType petType;
  final DateTime createdAt;
  Offset position;
  int life;
  int streak;
  double expAcumulated;
  int level;
  DateTime lastUpdated;
  HabitStatus status;

  PetHabit({
    required this.id,
    required this.name,
    required this.userId,
    required this.room,
    required this.mechanic,
    required this.personality,
    required this.petType,
    this.position = Offset.zero,
    this.life = 80,
    this.streak = 0,
    this.expAcumulated = 0.0,
    this.level = 0,
    this.status = HabitStatus.normal,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  // Convertir PetHabit a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'room': room,
      'mechanic': mechanic.toMap(),
      'personality': personality.toMap(),
      'petType': petType.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'position': {'dx': position.dx, 'dy': position.dy},
      'life': life,
      'streak': streak,
      'lastUpdated': lastUpdated.toIso8601String(),
      'status': status.name,
    };
  }

  // Crear un PetHabit desde un mapa de Firestore
  factory PetHabit.fromMap(Map<String, dynamic> map) {
    return PetHabit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      userId: (map['userId']),
      room: map['room'] ?? '',
      mechanic: Mechanic.fromMap(map['mechanic'] as String),
      personality: Personality.fromMap(map['personality'] as String),
      petType: PetType.fromMap(map['petType'] as String),
      life: map['life'] ?? 80,
      streak: map['streak'] ?? 0,
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.parse(map['lastUpdated'])
              : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      position: Offset(
        (map['position']?['dx'] as num?)?.toDouble() ?? 0.0,
        (map['position']?['dy'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  // Método random para crear un PetHabit aleatorio
  factory PetHabit.random(
    String id,
    String name,
    String user,
    String room,
    Map<String, int> petInventory,
  ) {
    final logger = Logger();
    final random = math.Random();
    // Filtrar PetTypes con inventario > 0 o perro
    final availablePets =
        PetType.values
            .where(
              (pet) =>
                  pet == PetType.perro || (petInventory[pet.name] ?? 0) > 0,
            )
            .toList();

    logger.i(
      'Available PetTypes: ${availablePets.map((p) => p.name).toList()}',
    );
    if (availablePets.isEmpty) {
      logger.e('No hay mascotas disponibles en el inventario');
      throw Exception('No hay mascotas disponibles en el inventario');
    }

    final selectedPetType = availablePets[random.nextInt(availablePets.length)];
    logger.i('Selected PetType: ${selectedPetType.name}');

    return PetHabit(
      id: id,
      name: name,
      userId: user,
      room: room,
      mechanic: Mechanic.values[random.nextInt(Mechanic.values.length)],
      personality:
          Personality.values[random.nextInt(Personality.values.length)],
      petType: selectedPetType,
      position: const Offset(50, 50),
      createdAt: DateTime.now(),
    );
  }
  @override
  String toString() {
    return 'Habit(id: $id, name: $name, user: $userId, room: $room, mechanic: $mechanic, personality: $personality, petType: $petType createdAt: $createdAt)';
  }
}
