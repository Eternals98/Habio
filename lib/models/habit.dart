// ignore_for_file: file_names

import 'dart:ui';

import 'package:per_habit/models/pet.dart';
import 'package:per_habit/models/room.dart';
import 'package:per_habit/models/user_model.dart';

class MascotaHabito {
  final String id;
  String nombre;
  Pet pet;
  UserModel userModel;
  Lugar room;
  Offset position; // Add position for dragging

  MascotaHabito({
    required this.id,
    required this.nombre,
    required this.pet,
    required this.userModel,
    required this.room,
    this.position = Offset.zero,
  });
}
