// ignore_for_file: deprecated_member_use
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'package:per_habit/features/game/components/pet/pet_anim.dart';
import 'package:per_habit/features/game/components/pet/pet_tracker.dart';
import 'package:per_habit/features/game/components/pet/pet_visual.dart';
import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/game/widgets/message_cache.dart';
import 'package:per_habit/features/game/widgets/speech_bubble_component.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/presentation/screens/edit_habit_screen.dart';

class HabitPetComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HabioGame> {
  // ---------- Datos ----------
  final Habit habit;
  String get habitId => habit.id;
  String name;
  int level;
  final String frequencyPeriod;
  final int frequencyCount;

  void Function(String habitId, int failsInARow)? onMissedPeriod;
  void Function(String habitId)? onCompletedPeriod;

  // ---------- Visual ----------
  static const double petSize = 120;
  static const double nameHeight = 20;
  late SpriteAnimationGroupComponent<PetAnim> _visual;

  static const int cols = 16;
  static const int rows = 7;
  static const double idleStep = 0.12;
  static const double walkStep = 0.10;
  static const double carryStep = 0.10;
  static const double landStep = 0.10;
  static const double hurtStep = 0.10;
  static const double dizzyStep = 0.12;
  static const double celebrateStep = 0.10;
  static const double deadStep = 0.12;
  static const int blinkCount = 4;

  bool _isDragging = false;
  double vy = 0;
  static const double gravity = 700;
  final double groundY;
  final Random _rand = Random();
  int _stepsLeft = 0;
  double _stepDirection = 0;
  double _currentStepProgress = 0;
  static const double stepDuration = 0.3;
  static const double _stepDistance = 10;
  double _stepStartX = 0;
  double _restTimeLeft = 0;
  double _blinkCooldown = 3;

  final PeriodTracker _period;
  double? _timer;

  // ---------- Mensajes ----------
  Map<String, List<String>> _messages = {};
  bool _saidOnEnter = false;
  bool _saidOnLoad = false;
  SpeechBubbleComponent? _activeBubble;

  String get _personalityIdSafe {
    final pid = (habit.personalityId).trim().toLowerCase();
    return pid.isEmpty ? 'carinoso' : pid;
    // Importante: este id debe coincidir con los docIds que precargaste.
  }

  String _fallbackMessage(String kind) {
    switch (kind) {
      case 'onEnter':
        return '¡Hola! ¿list@ para avanzar?';
      case 'onLoad':
        return 'Listo por aquí ✨';
      case 'onComplete':
        return '¡Genial! Objetivo cumplido 🏆';
      case 'onMissed':
        return 'No pasa nada, mañana seguimos 💪';
      default:
        return '';
    }
  }

  void _say(String kind) {
    final list = _messages[kind] ?? const <String>[];
    final text =
        (list.isNotEmpty)
            ? list[_rand.nextInt(list.length)]
            : _fallbackMessage(kind);
    if (text.isEmpty) return;

    _activeBubble?.removeFromParent();

    final bubble =
        SpeechBubbleComponent(
            text: text,
            maxWidth: 220,
            lifetime: 2.6,
            fadeSec: 0.18,
            tailSize: 10,
            elevation: 4,
          )
          ..anchor = Anchor.bottomCenter
          ..position = Vector2(size.x / 2, -6)
          ..priority = 1000;

    add(bubble);
    _activeBubble = bubble;
  }

  HabitPetComponent.fromHabit(Habit h, this.groundY)
    : habit = h,
      name = h.name,
      level = h.level,
      frequencyPeriod = h.frequencyPeriod,
      frequencyCount = h.frequencyCount,
      _period = PeriodTracker(
        frequencyPeriod: h.frequencyPeriod,
        frequencyCount: h.frequencyCount,
      ),
      super(
        size: Vector2(petSize, petSize + nameHeight),
        anchor: Anchor.center,
      );

  void _applyStatusFromFail() {
    switch (_period.failCount) {
      case 0:
        if (_visual.current == PetAnim.hurt ||
            _visual.current == PetAnim.dizzy) {
          _visual.current = PetAnim.idle;
        }
        break;
      case 1:
        _visual.current = PetAnim.hurt;
        break;
      case 2:
        _visual.current = PetAnim.dizzy;
        break;
      case 3:
        _visual.current = PetAnim.dead;
        _timer = (cols * deadStep);
        break;
    }
  }

  Future<void> _celebrate() async {
    _visual.current = PetAnim.celebrate;
    _timer = (cols * celebrateStep);
  }

  void _completeNow() {
    _period.addCompletion();
    _applyStatusFromFail();
    _celebrate();
    _say('onComplete');
  }

  @override
  Future<void> onLoad() async {
    // *** NO Firestore aquí ***
    // 1) Cargamos mensajes desde caché (instantáneo)
    _messages =
        PersonalityMessagesCache.getSync(_personalityIdSafe) ??
        const {'onEnter': [], 'onLoad': [], 'onComplete': [], 'onMissed': []};
    // Si por algún motivo no estaba (no se precargó), caliéntalo en background para futuras apariciones:
    if (_messages['onEnter']!.isEmpty &&
        _messages['onLoad']!.isEmpty &&
        _messages['onComplete']!.isEmpty &&
        _messages['onMissed']!.isEmpty) {
      // No bloquea el frame:
      // ignore: unawaited_futures
      PersonalityMessagesCache.warmAsync(_personalityIdSafe);
    }

    // 2) Sprite (si ya hiciste preload de imágenes, esto es muy rápido)
    final petId = habit.petType.trim().toLowerCase();
    final imagePath = 'pets/${petId}_full.png';

    _visual = await PetVisual.createFromPath(
      images: gameRef.images,
      imagePath: imagePath,
      petSize: petSize,
      cols: cols,
      rows: rows,
      idleStep: idleStep,
      walkStep: walkStep,
      carryStep: carryStep,
      landStep: landStep,
      hurtStep: hurtStep,
      dizzyStep: dizzyStep,
      celebrateStep: celebrateStep,
      deadStep: deadStep,
    );
    add(_visual);
    _visual.position = Vector2(size.x / 2, nameHeight + petSize / 2);

    // 3) Comportamiento inicial
    if (_rand.nextBool()) {
      _enterRest();
    } else {
      _enterMove();
    }

    // 4) Mensajes (después de añadir el sprite, para que el globo se vea)
    if (!_saidOnEnter) {
      _saidOnEnter = true;
      _say('onEnter');
    }
    // Un pequeño delay opcional para onLoad (evita que se solapen)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!_saidOnLoad) {
        _saidOnLoad = true;
        _say('onLoad');
      }
    });

    _period.initWith(DateTime.now());
    return super.onLoad();
  }

  // --- resto igual ---
  void _enterRest() {
    _restTimeLeft = 3 + _rand.nextInt(8).toDouble();
    _stepsLeft = 0;
  }

  void _enterMove() {
    _stepsLeft = 2 + _rand.nextInt(4);
    _stepDirection = _rand.nextBool() ? 1 : -1;
    _currentStepProgress = 0;
    _stepStartX = position.x;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_timer != null) {
      _timer = _timer! - dt;
      if (_timer! <= 0) {
        _timer = null;
        if (_visual.current == PetAnim.carryLand) {
          _visual.current = (_stepsLeft > 0) ? PetAnim.walk : PetAnim.idle;
        } else if (_visual.current == PetAnim.celebrate) {
          _visual.current = (_stepsLeft > 0) ? PetAnim.walk : PetAnim.idle;
        } else if (_visual.current == PetAnim.dead) {
          removeFromParent();
          return;
        } else if (_visual.current == PetAnim.idleBlink) {
          _visual.current = PetAnim.idle;
        }
      }
    }

    if (!_isDragging) {
      vy += gravity * dt;
      position.y += vy * dt;
      if (position.y > groundY) {
        position.y = groundY;
        vy = 0;
      }
    }

    final change = _period.tick(DateTime.now());
    if (change == PeriodChange.missed) {
      onMissedPeriod?.call(habitId, _period.failCount);
      _applyStatusFromFail();
      _say('onMissed');
    } else if (change == PeriodChange.completed) {
      onCompletedPeriod?.call(habitId);
      _applyStatusFromFail();
      _celebrate();
      _say('onComplete');
    }

    if (_visual.current == PetAnim.idle && _timer == null && !_isDragging) {
      _blinkCooldown -= dt;
      if (_blinkCooldown <= 0) {
        _visual.current = PetAnim.idleBlink;
        _timer = blinkCount * idleStep;
        _blinkCooldown = 3 + _rand.nextDouble() * 5;
      }
    }

    if (!_isDragging &&
        _visual.current != PetAnim.carryAir &&
        _visual.current != PetAnim.carryLand &&
        _visual.current != PetAnim.dead &&
        _visual.current != PetAnim.celebrate &&
        _visual.current != PetAnim.idleBlink) {
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
        _restTimeLeft -= dt;
        if (_restTimeLeft <= 0) _enterMove();
      }

      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);

      _visual.current =
          (_stepsLeft > 0)
              ? PetAnim.walk
              : (_period.failCount == 1
                  ? PetAnim.hurt
                  : _period.failCount == 2
                  ? PetAnim.dizzy
                  : PetAnim.idle);

      _visual.scale.x = (_stepsLeft > 0) ? -_stepDirection : 1;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tp = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = (size.x - tp.width) / 2;
    const dy = 2.0;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_visual.current == PetAnim.dead) return;
    final ctx = gameRef.buildContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mascota: ${habit.petType}'),
                Text('Nivel: $level'),
                const SizedBox(height: 8),
                Text('Faltas: ${_period.failCount}'),
                Text(
                  'Progreso actual: ${_period.doneInPeriod} / $frequencyCount '
                  '(${frequencyPeriod == 'week' ? 'semana' : 'día'})',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  final editable = Habit(
                    id: habitId,
                    name: name,
                    petType: habit.petType,
                    personalityId: habit.personalityId,
                    goal: frequencyCount,
                    progress: 0,
                    life: 100,
                    points: 0,
                    level: level,
                    experience: 0,
                    baseStatus: 'happy',
                    tempStatus: '',
                    streak: 0,
                    lastCompletedDate: null,
                    roomId: gameRef.roomId,
                    createdAt: DateTime.now(),
                    frequencyCount: frequencyCount,
                    frequencyPeriod: frequencyPeriod,
                    scheduleTimes: const [],
                  );
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => EditHabitScreen(habit: editable),
                    ),
                  );
                },
                child: const Text('Editar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _completeNow();
                },
                child: const Text('Completar ahora'),
              ),
            ],
          ),
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    if (_visual.current != PetAnim.dead) {
      _visual.current = PetAnim.carryAir;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _isDragging = true;
    position += event.localDelta;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
    position.y = position.y.clamp(0, gameRef.size.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    if (_visual.current != PetAnim.dead) {
      _visual.current = PetAnim.carryLand;
      _timer = max(0, cols - 5) * landStep;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    if (_visual.current != PetAnim.dead) {
      _visual.current = PetAnim.carryLand;
      _timer = max(0, cols - 5) * landStep;
    }
  }
}
