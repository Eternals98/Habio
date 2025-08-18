// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class HabitPetComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HabioGame> {
  String habitId;
  String petType;
  String name;
  int level;

  static const double petSize = 80;
  bool _isDragging = false;

  // Física
  double vy = 0; // velocidad vertical
  static const double gravity = 400; // px/s^2
  final double groundY;

  // Movimiento automático
  Timer? _moveTimer;
  final Random _rand = Random();
  int _stepsLeft = 0;
  double _stepDirection = 0;

  HabitPetComponent.fromHabit(Habit h, this.groundY)
    : habitId = h.id,
      petType = h.petType,
      name = h.name,
      level = h.level,
      super(size: Vector2.all(petSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _scheduleNextMove();
    return super.onLoad();
  }

  void _scheduleNextMove() {
    final duration = Duration(milliseconds: 500 + _rand.nextInt(1500));
    _stepsLeft = (1 + _rand.nextInt(5)); // max 5 pasos
    _stepDirection = _rand.nextBool() ? 1 : -1;

    _moveTimer = Timer(
      duration.inMilliseconds / 1000,
      repeat: false,
      onTick: () {
        // Ejecutar un paso
        _moveStep();
        _scheduleNextMove();
      },
    )..start();
  }

  void _moveStep() {
    if (_stepsLeft > 0 && !_isDragging) {
      position.x += _stepDirection * 10; // 10px por paso
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
      _stepsLeft--;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Física: gravedad
    if (!_isDragging) {
      vy += gravity * dt;
      position.y += vy * dt;

      if (position.y > groundY) {
        position.y = groundY;
        vy = 0;
      }
    }

    _moveTimer?.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(12),
    );
    final paint = Paint()..color = Colors.orange;
    canvas.drawRRect(r, paint);

    final textSpan = TextSpan(
      text: name,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_isDragging) {
      showDialog(
        context: gameRef.buildContext!,
        builder:
            (_) => AlertDialog(
              title: Text(name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('Mascota: $petType'), Text('Nivel: $level')],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(gameRef.buildContext!),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
    position.y = position.y.clamp(0, gameRef.size.y); // puede arrastrar en Y
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isDragging = false;
  }
}
