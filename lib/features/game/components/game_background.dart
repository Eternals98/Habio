// ignore_for_file: deprecated_member_use

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/game/habio_game.dart';

class GameBackground extends Component with HasGameRef<HabioGame> {
  @override
  void render(Canvas canvas) {
    final sky = Paint()..color = Colors.lightBlue.shade100;
    canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), sky);

    final ground = Paint()..color = Colors.green.shade300;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        gameRef.groundY,
        gameRef.size.x,
        gameRef.size.y - gameRef.groundY,
      ),
      ground,
    );
  }
}
