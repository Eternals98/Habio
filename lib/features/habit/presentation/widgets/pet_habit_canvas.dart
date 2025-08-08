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

class _PetHabitCanvasState extends ConsumerState<PetHabitCanvas> {
  late Map<String, Offset> _positions; // Almacena posiciones locales
  late Map<String, Timer>
  _movementTimers; // Controla los movimientos aleatorios
  final double _groundY = 300.0; // Y fija como "suelo"
  late double _maxY; // Máximo y calculado dinámicamente
  final Random _random = Random();
  final Map<String, List<Future>> _fallAnimations =
      {}; // Para rastrear animaciones de caída

  @override
  void initState() {
    super.initState();
    _positions = {};
    _movementTimers = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maxY =
        (MediaQuery.of(context).size.height - 150 - 56) / 10; // Recalcular maxY
    _initializeOrUpdatePositions();
    _startRandomMovements();
  }

  void _initializeOrUpdatePositions() {
    final currentHabitIds = widget.habits.map((h) => h.id).toSet();
    final existingIds = _positions.keys.toSet();

    if (!setEquals(currentHabitIds, existingIds)) {
      _positions.clear();
      final usedX = <double>{};
      final screenWidth = MediaQuery.of(context).size.width - 150;
      for (final habit in widget.habits) {
        double x;
        do {
          x = _random.nextDouble() * screenWidth;
        } while (usedX.contains(x));
        usedX.add(x);
        _positions[habit.id] = Offset(x, _groundY);
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
    final currentPos = _positions[habitId];
    if (currentPos?.dy != _groundY ||
        (_movementTimers[habitId]?.isActive ?? false)) {
      return; // No mover si no está en y=300 o ya está activo
    }
    if (_movementTimers[habitId]?.isActive ?? false) {
      _movementTimers[habitId]?.cancel();
    }
    final delay = Duration(seconds: _random.nextInt(5) + 2); // 2-6 segundos
    _movementTimers[habitId] = Timer(delay, () async {
      if (mounted && _positions[habitId]?.dy == _groundY) {
        await _performRandomSteps(habitId);
        _scheduleNextMove(habitId); // Programar el próximo movimiento
      }
    });
  }

  Future<void> _performRandomSteps(String habitId) async {
    if (_positions[habitId]?.dy != _groundY)
      return; // No mover si no está en y=300
    final stepCount = _random.nextInt(4) + 2; // 2 a 5 pasos
    for (int i = 0; i < stepCount; i++) {
      if (mounted) {
        setState(() {
          final currentPos = _positions[habitId]!;
          final step = _random.nextDouble() * 30 - 15; // -15 a 15 píxeles
          _positions[habitId] = Offset(
            (currentPos.dx + step).clamp(
              0,
              MediaQuery.of(context).size.width - 150,
            ),
            currentPos.dy, // Mantiene y=300
          );
        });
        if (i < stepCount - 1) {
          await Future.delayed(
            const Duration(milliseconds: 200),
          ); // Pausa entre pasos
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant PetHabitCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maxY =
        (MediaQuery.of(context).size.height - 150 - 56) / 10; // Recalcular maxY
    _initializeOrUpdatePositions();
    _startRandomMovements();
  }

  @override
  void dispose() {
    for (final timer in _movementTimers.values) {
      timer.cancel();
    }
    for (final futures in _fallAnimations.values) {
      for (final future in futures) {
        future.then((_) => null); // Cancelar animaciones pendientes
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          widget.habits.map((habit) {
            final pos = _positions[habit.id] ?? Offset(0, _groundY);
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onTap: () => widget.onTap(habit),
                onPanUpdate: (details) {
                  if (kDebugMode) {
                    print(
                      'PanUpdate: ${details.delta}, Position: ${_positions[habit.id]}',
                    );
                  }
                  setState(() {
                    final newX =
                        (pos.dx + details.delta.dx)
                            .clamp(0, MediaQuery.of(context).size.width - 150)
                            .toDouble();
                    var newY = (pos.dy + details.delta.dy).toDouble();
                    if (newY > _groundY) {
                      newY = _groundY; // Limita subir más allá de 300
                    }
                    if (newY <= _maxY) {
                      newY = _maxY; // Límite inferior (techo)
                    }
                    final newOffset = Offset(newX, newY);
                    _positions[habit.id] = newOffset;
                    // Si y < 300, cancelar movimiento aleatorio
                    if (newY < _groundY &&
                        (_movementTimers[habit.id]?.isActive ?? false)) {
                      _movementTimers[habit.id]?.cancel();
                    }
                  });
                },
                onPanStart: (details) {
                  if (kDebugMode) {
                    print('Fall animation canceled for ${habit.id}');
                  }
                  ref
                      .read(habitControllerProvider.notifier)
                      .setDragging(true); // Pausar stream
                  // Cancelar animación de caída si está en curso
                  _fallAnimations[habit.id]?.forEach(
                    (future) => future.then((_) => null),
                  );
                  _fallAnimations.remove(habit.id);
                },
                onPanEnd: (details) {
                  final currentPos = _positions[habit.id]!;
                  if (currentPos.dy < _groundY) {
                    final difference =
                        _groundY - currentPos.dy; // Diferencia a recorrer
                    final step = difference / 200; // Dividir en 20 pasos
                    final fallFutures = <Future>[];
                    for (int i = 1; i <= 200; i++) {
                      final future = Future.delayed(
                        Duration(milliseconds: i * 5),
                        () {
                          if (mounted) {
                            setState(() {
                              final newY = currentPos.dy + (step * i);
                              _positions[habit.id] = Offset(
                                currentPos.dx,
                                newY <= _groundY ? newY : _groundY,
                              );
                            });
                          }
                        },
                      );
                      fallFutures.add(future);
                    }
                    _fallAnimations[habit.id] = fallFutures;
                    // Asegurar que termine exactamente en _groundY y reanudar movimiento
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      if (mounted) {
                        setState(() {
                          _positions[habit.id] = Offset(
                            currentPos.dx,
                            _groundY,
                          );
                        });
                        if (_positions[habit.id]?.dy == _groundY &&
                            !(_movementTimers[habit.id]?.isActive ?? false)) {
                          _scheduleNextMove(habit.id);
                        }
                        ref
                            .read(habitControllerProvider.notifier)
                            .setDragging(false); // Reanudar stream
                        _fallAnimations.remove(
                          habit.id,
                        ); // Limpiar animación terminada
                      }
                    });
                  } else {
                    // Reanudar movimiento si ya está en el suelo
                    if (_positions[habit.id]?.dy == _groundY &&
                        !(_movementTimers[habit.id]?.isActive ?? false)) {
                      _scheduleNextMove(habit.id);
                    }
                    ref
                        .read(habitControllerProvider.notifier)
                        .setDragging(false); // Reanudar stream
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
          }).toList(),
    );
  }
}
