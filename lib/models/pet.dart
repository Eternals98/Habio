import 'dart:math' as math;

import 'package:per_habit/types/mechanic.dart';
import 'package:per_habit/types/personality.dart';
import 'package:per_habit/types/petType.dart';

class Pet {
  final String id;
  Mechanic mechanic;
  Personality personality;
  PetType petType;

  Pet({
    required this.id,
    required this.mechanic,
    required this.personality,
    required this.petType,
  });

  factory Pet.random(String id) {
    final random = math.Random();
    return Pet(
      id: id,
      mechanic: Mechanic.values[random.nextInt(Mechanic.values.length)],
      personality:
          Personality.values[random.nextInt(Personality.values.length)],
      petType: PetType.values[random.nextInt(PetType.values.length)],
    );
  }
}
