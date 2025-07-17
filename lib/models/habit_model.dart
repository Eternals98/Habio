// ignore_for_file: file_names

import 'dart:math' as math;
import 'dart:ui';

import 'package:per_habit/models/room_model.dart';
import 'package:per_habit/models/user_model.dart';
import 'package:per_habit/types/mechanic.dart';
import 'package:per_habit/types/personality.dart';
import 'package:per_habit/types/petType.dart';

class MascotaHabito {
  final String id;
  String nombre;
  UserModel userModel;
  Lugar room;
  Mechanic mechanic;
  Personality personality;
  PetType petType;
  final DateTime createdAt;
  Offset position; // Add position for dragging

  MascotaHabito({
    required this.id,
    required this.nombre,
    required this.userModel,
    required this.room,
    required this.mechanic,
    required this.personality,
    required this.petType,
    this.position = Offset.zero,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MascotaHabito.random(
    String id,
    String name,
    UserModel user,
    Lugar room,
  ) {
    final random = math.Random();
    return MascotaHabito(
      id: id,
      nombre: name,
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
    return 'Habito(id: $id, nombre: $nombre, usuario: $userModel, room: $room, mechanic: $mechanic, personality: $personality, petType: $petType createdAt: $createdAt)';
  }
}
