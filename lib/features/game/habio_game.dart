import 'dart:async';

import 'package:flame/game.dart';
import 'package:per_habit/features/game/components/game_background.dart';
import 'package:per_habit/features/game/components/game_components.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class HabioGame extends FlameGame {
  final String roomId;
  final List<Habit> initialHabits;

  HabioGame({required this.roomId, this.initialHabits = const []});

  late double groundY;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(GameBackground());

    groundY = size.y * 0.7;

    double x = 80;
    for (final h in initialHabits) {
      final pet = HabitPetComponent.fromHabit(h, groundY)
        ..position = Vector2(x, groundY);
      add(pet);
      x += 120;
    }
  }
}
