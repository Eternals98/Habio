// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/entities/pet_type.dart';

enum PetState { idle, walk, carry }

class HabitPetComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HabioGame> {
  String habitId;
  PetType petType;
  String name;
  int level;
  static const double petSize = 80;
  bool _isDragging = false;
  // Física
  double vy = 0; // velocidad vertical
  static const double gravity = 700; // aumenté un poco
  final double groundY;
  // Movimiento automático
  final Random _rand = Random();
  int _stepsLeft = 0;
  double _stepDirection = 0;
  double _currentStepProgress = 0;
  static const double stepDuration = 0.3; // duración de cada paso
  static const double _stepDistance = 10; // px por paso
  double _stepStartX = 0;
  // Reposo
  double _restTimeLeft = 0;
  // Visual
  late Component _visualComponent;

  HabitPetComponent.fromHabit(Habit h, this.groundY)
    : habitId = h.id,
      petType = PetType.fromString(h.petType),
      name = h.name,
      level = h.level,
      super(size: Vector2.all(petSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    ui.Image? image = await gameRef.images.load(petType.imagePath) as ui.Image?;
    if (image != null) {
      final idle = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(0, 0),
        ),
      );
      final walk = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(
            4 * 24,
            0,
          ), // Ajusta si frames walk no son 4-7
        ),
      );
      final carry = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 1, // o más si es animado
          stepTime: 0.2,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(0, 48), // Ajusta: fila de "carry"
        ),
      );
      _visualComponent = SpriteAnimationGroupComponent(
        animations: {
          PetState.idle: idle,
          PetState.walk: walk,
          PetState.carry: carry,
        },
        current: PetState.idle,
        size: size,
        anchor: Anchor.center,
      );
    } else {
      _visualComponent = RectangleComponent(
        size: size,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.blue,
      );
    }
    add(_visualComponent);
    // Decidir si inicia en reposo o movimiento
    if (_rand.nextBool()) {
      _enterRest();
    } else {
      _enterMove();
    }
    return super.onLoad();
  }

  void _enterRest() {
    _restTimeLeft = 3 + _rand.nextInt(8).toDouble(); // 3-10 seg
    _stepsLeft = 0;
  }

  void _enterMove() {
    _stepsLeft = 2 + _rand.nextInt(4); // 2-5 pasos
    _stepDirection = _rand.nextBool() ? 1 : -1;
    _currentStepProgress = 0;
    _stepStartX = position.x;
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
    // Movimiento automático
    if (!_isDragging) {
      if (_stepsLeft > 0) {
        _currentStepProgress += dt / stepDuration;
        if (_currentStepProgress > 1) _currentStepProgress = 1;
        position.x =
            _stepStartX + _stepDirection * _stepDistance * _currentStepProgress;
        if (_currentStepProgress >= 1) {
          _stepsLeft--;
          _stepStartX = position.x;
          _currentStepProgress = 0;
          if (_stepsLeft == 0) _enterRest();
        }
      } else {
        // Reposo
        _restTimeLeft -= dt;
        if (_restTimeLeft <= 0) _enterMove();
      }
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
    }
    // Actualizar visual basado en estado
    if (!_isDragging) {
      bool isResting = _stepsLeft == 0;
      if (_visualComponent is RectangleComponent) {
        (_visualComponent as RectangleComponent).paint.color =
            isResting ? Colors.blue : Colors.green;
      } else if (_visualComponent is SpriteAnimationGroupComponent) {
        final group = _visualComponent as SpriteAnimationGroupComponent;
        group.current = isResting ? PetState.idle : PetState.walk;
        if (!isResting) {
          group.scale.x = _stepDirection;
        } else {
          group.scale.x = 1;
        }
      }
    }
    // Mantener visual centrado
    (_visualComponent as PositionComponent).position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Nombre centrado
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
    tp.paint(
      canvas,
      Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2 - 20),
    ); // Ajustado arriba si necesario
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
    super.onDragStart(event);
    _isDragging = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _isDragging = true;
    position += event.localDelta;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
    position.y = position.y.clamp(0, gameRef.size.y);

    // Si está siendo arrastrado y está por encima del suelo → estado carry
    if (position.y < groundY &&
        _visualComponent is SpriteAnimationGroupComponent) {
      final group = _visualComponent as SpriteAnimationGroupComponent;
      group.current = PetState.carry;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;

    // Volver al estado de movimiento o reposo
    if (_visualComponent is SpriteAnimationGroupComponent) {
      final group = _visualComponent as SpriteAnimationGroupComponent;
      if (_stepsLeft > 0) {
        group.current = PetState.walk;
        group.scale.x = _stepDirection;
      } else {
        group.current = PetState.idle;
        group.scale.x = 1;
      }
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;

    if (_visualComponent is SpriteAnimationGroupComponent) {
      final group = _visualComponent as SpriteAnimationGroupComponent;
      if (_stepsLeft > 0) {
        group.current = PetState.walk;
        group.scale.x = _stepDirection;
      } else {
        group.current = PetState.idle;
        group.scale.x = 1;
      }
    }
  }
}
