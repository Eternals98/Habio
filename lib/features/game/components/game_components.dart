// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/entities/pet_type.dart';
import 'package:per_habit/features/habit/presentation/screens/edit_habit_screen.dart';

enum PetAnim {
  idle,
  idleBlink,
  walk,
  carryAir,
  carryLand,
  hurt,
  dizzy,
  celebrate,
  dead,
}

class HabitPetComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameRef<HabioGame> {
  // ---------- Datos del hábito ----------
  final String habitId;
  final PetType petType;
  String name;
  int level;
  final String frequencyPeriod; // 'day' | 'week'
  final int frequencyCount;

  // ---------- Visual ----------
  static const double petSize = 80;
  late SpriteAnimationGroupComponent<PetAnim> _visual;

  // Ajustes del spritesheet (AJUSTA A TU IMAGEN)
  static const int cols = 16; // <- columnas por fila
  static const int rows = 7; // <- total filas (mencionaste 7)
  static const double idleStep = 0.12;
  static const double walkStep = 0.10;
  static const double carryStep = 0.10;
  static const double landStep = 0.10;
  static const double hurtStep = 0.10;
  static const double dizzyStep = 0.12;
  static const double celebrateStep = 0.10;
  static const double deadStep = 0.12;
  // columnas por fila y filas totales ya los tienes
  static const int blinkStartCol = 12; // <-- ajusta
  static const int blinkCount = 4; // <-- ajusta

  // ---------- Física y movimiento ----------
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
  double _blinkCooldown = 3; // segundos hasta el próximo parpadeo

  // ---------- Progreso por período ----------
  int _doneInPeriod = 0;
  int _failCount = 0; // 0=normal, 1=hurt, 2=dizzy, 3=dead
  String _periodKey = '';
  double? _timer; // para celebrate / land / dead

  HabitPetComponent.fromHabit(Habit h, this.groundY)
    : habitId = h.id,
      petType = PetType.fromString(h.petType),
      name = h.name,
      level = h.level,
      frequencyPeriod = h.frequencyPeriod ?? 'day',
      frequencyCount = h.frequencyCount,
      super(size: Vector2.all(petSize), anchor: Anchor.center);

  // ------ helpers sprites ------
  late int frameW;
  late int frameH;

  SpriteAnimation _rowAnim(
    ui.Image img, {
    required int row,
    required int start,
    required int amount,
    required double step,
    bool loop = true,
  }) {
    final sprites = <Sprite>[];
    for (var i = 0; i < amount; i++) {
      final col = start + i;
      sprites.add(
        Sprite(
          img,
          srcPosition: Vector2(
            col * frameW.toDouble(),
            row * frameH.toDouble(),
          ),
          srcSize: Vector2(frameW.toDouble(), frameH.toDouble()),
        ),
      );
    }
    return SpriteAnimation.spriteList(sprites, stepTime: step, loop: loop);
  }

  Future<SpriteAnimation> _twoRows(
    ui.Image img, {
    required int rowA,
    required int rowB,
    required int colsA,
    required int colsB,
    required double step,
  }) async {
    final sprites = <Sprite>[];
    for (var c = 0; c < colsA; c++) {
      sprites.add(
        Sprite(
          img,
          srcPosition: Vector2(c * frameW.toDouble(), rowA * frameH.toDouble()),
          srcSize: Vector2(frameW.toDouble(), frameH.toDouble()),
        ),
      );
    }
    for (var c = 0; c < colsB; c++) {
      sprites.add(
        Sprite(
          img,
          srcPosition: Vector2(c * frameW.toDouble(), rowB * frameH.toDouble()),
          srcSize: Vector2(frameW.toDouble(), frameH.toDouble()),
        ),
      );
    }
    return SpriteAnimation.spriteList(sprites, stepTime: step);
  }

  // ------ periodo (día/semana) ------
  String _currentPeriodKey(DateTime now) {
    if (frequencyPeriod == 'week') {
      final monday = now.subtract(Duration(days: (now.weekday + 6) % 7));
      final y = monday.year;
      final w =
          ((DateTime(y, 1, 4).difference(monday).inDays) / 7)
              .abs()
              .floor(); // aproximado
      return '$y-W$w';
    } else {
      return '${now.year}-${now.month}-${now.day}';
    }
  }

  void _tickPeriodBoundary(DateTime now) {
    final key = _currentPeriodKey(now);
    if (_periodKey.isEmpty) {
      _periodKey = key;
      return;
    }
    if (key != _periodKey) {
      // cerró período anterior
      if (_doneInPeriod < frequencyCount) {
        _failCount = (_failCount + 1).clamp(0, 3);
        _applyStatusFromFail();
      } else {
        // éxito → limpiar faltas
        _failCount = 0;
        _applyStatusFromFail();
      }
      _doneInPeriod = 0;
      _periodKey = key;
    }
  }

  void _applyStatusFromFail() {
    switch (_failCount) {
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
        _timer = (cols * deadStep); // aprox duración
        break;
    }
  }

  Future<void> _celebrate() async {
    _visual.current = PetAnim.celebrate;
    _timer = (cols * celebrateStep); // aprox
  }

  void _completeNow() {
    // sumar progreso del período
    _doneInPeriod++;
    if (_doneInPeriod >= frequencyCount) {
      _failCount = 0; // éxito limpia faltas
    }
    _applyStatusFromFail();
    _celebrate();
    // (Si quieres persistir, aquí puedes llamar a tu controller vía un callback)
  }

  // ------ load ------
  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load(petType.imagePath);

    frameW = (image.width / cols).floor();
    frameH = (image.height / rows).floor();

    // filas (0-based):
    // 0 idle1, 1 idle2, 2 walk, 3 carry(air+land), 4 hurt/dizzy, 5 dead, 6 celebrate
    final idle = _rowAnim(
      image,
      row: 0,
      start: 0,
      amount: cols - 5,
      step: idleStep,
    );

    // Blink: solo los frames reales de la fila 1 (index 1), sin columnas vacías.
    final idleBlink = _rowAnim(
      image,
      row: 1,
      start: 0,
      amount: cols - 5,
      step: idleStep,
      loop: false, // one-shot
    );
    final walk = _rowAnim(
      image,
      row: 2,
      start: 0,
      amount: cols - 5,
      step: walkStep,
    );

    final carryAir = _rowAnim(
      image,
      row: 3,
      start: 0,
      amount: 5,
      step: carryStep,
    );
    final carryLand = _rowAnim(
      image,
      row: 3,
      start: 8,
      amount: max(0, cols - 11),
      step: landStep,
      loop: false,
    );

    final hurt = _rowAnim(
      image,
      row: 4,
      start: 0,
      amount: min(6, cols),
      step: hurtStep,
    );
    final dizzy = _rowAnim(
      image,
      row: 4,
      start: 6,
      amount: max(0, cols - 6),
      step: dizzyStep,
    );

    final dead = _rowAnim(
      image,
      row: 5,
      start: 0,
      amount: cols,
      step: deadStep,
      loop: false,
    );

    final celebrate = _rowAnim(
      image,
      row: 6,
      start: 0,
      amount: cols - 8,
      step: celebrateStep,
      loop: false,
    );

    _visual = SpriteAnimationGroupComponent<PetAnim>(
      animations: {
        PetAnim.idle: idle,
        PetAnim.idleBlink: idleBlink,
        PetAnim.walk: walk,
        PetAnim.carryAir: carryAir,
        PetAnim.carryLand: carryLand,
        PetAnim.hurt: hurt,
        PetAnim.dizzy: dizzy,
        PetAnim.celebrate: celebrate,
        PetAnim.dead: dead,
      },
      current: PetAnim.idle,
      size: size,
      anchor: Anchor.center,
    );
    add(_visual);

    // comportamiento inicial
    if (_rand.nextBool()) {
      _enterRest();
    } else {
      _enterMove();
    }

    _periodKey = _currentPeriodKey(DateTime.now());
    return super.onLoad();
  }

  // ------ movimiento ------
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

    // ── timers (celebrate / land / dead / idleBlink)
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
          _visual.current = PetAnim.idle; // volver a idle tras parpadeo
        }
      }
    }

    // ── gravedad
    if (!_isDragging) {
      vy += gravity * dt;
      position.y += vy * dt;
      if (position.y > groundY) {
        position.y = groundY;
        vy = 0;
      }
    }

    // ── avance de período (día/semana)
    _tickPeriodBoundary(DateTime.now());

    // ── parpadeo aleatorio (solo cuando está idle y sin otros timers)
    if (_visual.current == PetAnim.idle && _timer == null && !_isDragging) {
      _blinkCooldown -= dt;
      if (_blinkCooldown <= 0) {
        _visual.current = PetAnim.idleBlink;
        _timer = blinkCount * idleStep; // duración aprox del blink
        _blinkCooldown = 3 + _rand.nextDouble() * 5; // próximo blink en 3–8s
      }
    }

    // ── movimiento automático
    if (!_isDragging &&
        _visual.current != PetAnim.carryAir &&
        _visual.current != PetAnim.carryLand &&
        _visual.current != PetAnim.dead &&
        _visual.current != PetAnim.celebrate &&
        _visual.current != PetAnim.idleBlink) {
      // no interrumpir el blink
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
              : (_failCount == 1
                  ? PetAnim.hurt
                  : _failCount == 2
                  ? PetAnim.dizzy
                  : PetAnim.idle);

      // flip corregido (si frames "mirán" a la izq por defecto)
      _visual.scale.x = (_stepsLeft > 0) ? -_stepDirection : 1;
    }

    // mantener centrado
    _visual.position = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Nombre centrado
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
    tp.paint(
      canvas,
      Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2 - 20),
    );
  }

  // ------ interacción ------
  @override
  void onTapUp(TapUpEvent event) {
    if (_visual.current == PetAnim.dead) return;

    showDialog(
      context: gameRef.buildContext!,
      builder:
          (_) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mascota: ${petType.name}'),
                Text('Nivel: $level'),
                const SizedBox(height: 8),
                Text('Faltas: $_failCount'),
                Text(
                  'Progreso actual: $_doneInPeriod / $frequencyCount (${frequencyPeriod == 'week' ? 'semana' : 'día'})',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(gameRef.buildContext!),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(gameRef.buildContext!);

                  // Construimos un Habit válido para la pantalla de edición.
                  final editable = Habit(
                    id: habitId,
                    name: name,
                    petType: petType.name, // tu enum -> String guardado
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
                    roomId: gameRef.roomId, // <-- CLAVE: no vacío
                    createdAt: DateTime.now(),
                    frequencyCount: frequencyCount,
                    frequencyPeriod: frequencyPeriod,
                    // si el periodo es 'day' y quieres pasar horas actuales, colócalas aquí;
                    // si no, deja lista vacía y el form pone un default.
                    scheduleTimes: const [],
                  );

                  Navigator.push(
                    gameRef.buildContext!,
                    MaterialPageRoute(
                      builder: (_) => EditHabitScreen(habit: editable),
                    ),
                  );
                },
                child: const Text('Editar'),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(gameRef.buildContext!);
                  _completeNow(); // celebra y limpia faltas
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
