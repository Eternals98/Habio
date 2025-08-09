// lib/features/habit/presentation/widgets/pet_habit_canvas.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';

class PetHabitCanvas extends ConsumerStatefulWidget {
  final List<Habit> habits;
  final void Function(Habit habit) onEdit;
  final void Function(Habit habit) onDelete;
  final void Function(Habit habit) onTap;

  const PetHabitCanvas({
    super.key,
    required this.habits,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  ConsumerState<PetHabitCanvas> createState() => _PetHabitCanvasState();
}

class _PetHabitCanvasState extends ConsumerState<PetHabitCanvas>
    with TickerProviderStateMixin {
  late Map<String, ValueNotifier<Offset>> _positionNotifiers;
  late Map<String, Timer> _movementTimers;
  late Map<String, AnimationController> _fallControllers;
  late Map<String, Animation<double>> _fallAnimations;

  final double _groundY = 400.0;
  late double _maxY;
  final Random _random = Random();
  final Map<String, bool> _isFalling = {};
  Offset? _dragStartOffset;
  Offset? _habitStartOffset;

  @override
  void initState() {
    super.initState();
    _positionNotifiers = {};
    _movementTimers = {};
    _fallControllers = {};
    _fallAnimations = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxY = (MediaQuery.of(context).size.height - 150 - 56) / 10;
    _initializeOrUpdatePositions();
    _startRandomMovements();
  }

  void _initializeOrUpdatePositions() {
    final currentHabitIds = widget.habits.map((h) => h.id).toSet();
    final existingIds = _positionNotifiers.keys.toSet();

    if (!setEquals(currentHabitIds, existingIds)) {
      _positionNotifiers.clear();
      final usedX = <double>{};
      final screenWidth = MediaQuery.of(context).size.width - 150;
      for (final habit in widget.habits) {
        double x;
        do {
          x = _random.nextDouble() * screenWidth;
        } while (usedX.contains(x));
        usedX.add(x);
        _positionNotifiers[habit.id] = ValueNotifier(Offset(x, _groundY));
      }
    }
  }

  void _startRandomMovements() {
    for (final habit in widget.habits) {
      if (!_movementTimers.containsKey(habit.id) ||
          !(_movementTimers[habit.id]?.isActive ?? false)) {
        _scheduleNextMove(habit.id);
      }
    }
  }

  void _scheduleNextMove(String habitId) {
    final currentPos = _positionNotifiers[habitId]?.value;
    if (currentPos?.dy != _groundY ||
        (_movementTimers[habitId]?.isActive ?? false)) {
      return;
    }
    _movementTimers[habitId]?.cancel();
    final delay = Duration(seconds: _random.nextInt(5) + 2);
    _movementTimers[habitId] = Timer(delay, () async {
      if (mounted && _positionNotifiers[habitId]?.value.dy == _groundY) {
        await _performRandomSteps(habitId);
        _scheduleNextMove(habitId);
      }
    });
  }

  Future<void> _performRandomSteps(String habitId) async {
    if (_positionNotifiers[habitId]?.value.dy != _groundY) return;
    final stepCount = _random.nextInt(4) + 2;
    for (int i = 0; i < stepCount; i++) {
      if (mounted) {
        _positionNotifiers[habitId]?.value = Offset(
          (_positionNotifiers[habitId]!.value.dx +
                  (_random.nextDouble() * 30 - 15))
              .clamp(0, MediaQuery.of(context).size.width - 150),
          _groundY,
        );
        if (i < stepCount - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }
  }

  void _startFall(String habitId) {
    final posNotifier = _positionNotifiers[habitId]!;
    final startY = posNotifier.value.dy;

    if (startY >= _groundY) return;

    _fallControllers[habitId]?.dispose();

    final distance = _groundY - startY;
    final duration = Duration(
      milliseconds: (distance * 2).toInt().clamp(100, 800),
    );

    final controller = AnimationController(vsync: this, duration: duration);
    final animation = Tween<double>(
      begin: startY,
      end: _groundY,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    animation.addListener(() {
      posNotifier.value = Offset(posNotifier.value.dx, animation.value);
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isFalling[habitId] = false;
        _scheduleNextMove(habitId);
        ref.read(habitControllerProvider.notifier).setDragging(false);
      }
    });

    _fallAnimations[habitId] = animation;
    _isFalling[habitId] = true;
    _fallControllers[habitId] = controller;
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant PetHabitCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maxY = (MediaQuery.of(context).size.height - 150 - 56) / 10;
    _initializeOrUpdatePositions();
    _startRandomMovements();
  }

  @override
  void dispose() {
    for (final timer in _movementTimers.values) {
      timer.cancel();
    }
    for (final notifier in _positionNotifiers.values) {
      notifier.dispose();
    }
    for (final controller in _fallControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          widget.habits.map((habit) {
            final posNotifier = _positionNotifiers.putIfAbsent(
              habit.id,
              () => ValueNotifier(Offset(0, _groundY)),
            );
            return AnimatedBuilder(
              animation: posNotifier,
              builder: (context, child) {
                final pos = posNotifier.value;
                return Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onTap: () => widget.onTap(habit),
                    onPanStart: (details) {
                      _isFalling[habit.id] = false;
                      _fallControllers[habit.id]?.stop();

                      _dragStartOffset = details.localPosition;
                      _habitStartOffset = posNotifier.value;

                      ref
                          .read(habitControllerProvider.notifier)
                          .setDragging(true);
                    },
                    onPanUpdate: (details) {
                      if (_dragStartOffset != null &&
                          _habitStartOffset != null) {
                        final dx =
                            details.localPosition.dx - _dragStartOffset!.dx;
                        final dy =
                            details.localPosition.dy - _dragStartOffset!.dy;

                        double newX = (_habitStartOffset!.dx + dx).clamp(
                          0,
                          MediaQuery.of(context).size.width - 150,
                        );
                        double newY = (_habitStartOffset!.dy + dy);

                        if (newY > _groundY) newY = _groundY;
                        if (newY <= _maxY) newY = _maxY;

                        posNotifier.value = Offset(newX, newY);

                        if (newY < _groundY) {
                          _movementTimers[habit.id]?.cancel();
                        }
                      }
                    },
                    onPanEnd: (details) {
                      _dragStartOffset = null;
                      _habitStartOffset = null;

                      final currentPos = posNotifier.value;
                      if (currentPos.dy < _groundY) {
                        _startFall(habit.id);
                      } else {
                        _scheduleNextMove(habit.id);
                        ref
                            .read(habitControllerProvider.notifier)
                            .setDragging(false);
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(habit.petType),
                          Text('Nivel ${habit.level}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => widget.onEdit(habit),
                                icon: const Icon(Icons.edit, size: 16),
                              ),
                              IconButton(
                                onPressed: () => widget.onDelete(habit),
                                icon: const Icon(Icons.delete, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}
