// ignore_for_file: file_names

import 'dart:math' as math;
import 'dart:ui';

import 'package:per_habit/features/room/models/room_model.dart';
import 'package:per_habit/features/auth/models/user_model.dart';
import 'package:per_habit/features/habit/types/mechanic.dart';
import 'package:per_habit/features/habit/types/personality.dart';
import 'package:per_habit/features/habit/types/petType.dart';

class PetHabit {
  final String id;
  String name;
  UserModel userModel;
  Room room;
  Mechanic mechanic;
  Personality personality;
  PetType petType;
  final DateTime createdAt;
  Offset position; // Add position for dragging

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

  factory PetHabit.random(String id, String name, UserModel user, Room room) {
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
