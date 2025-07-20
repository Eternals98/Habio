// lib/features/habit/presentation/widgets/pet_habit_canvas.dart

import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class PetHabitCanvas extends StatelessWidget {
  final List<Habit> habits;
  final void Function(Habit habit) onEdit;
  final void Function(Habit habit) onDelete;
  final void Function(Habit habit) onTap;
  final void Function(Habit habit, Map<String, double> newPosition)
  onPositionChanged;
  

  const PetHabitCanvas({
    super.key,
    required this.habits,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          habits.map((habit) {
            final pos = Offset(
              habit.position['x'] ?? 0.0,
              habit.position['y'] ?? 0.0,
            );

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onTap: () => onTap(habit),
                onPanUpdate: (details) {
                  final newOffset = Offset(
                    (pos.dx + details.delta.dx).clamp(
                      0,
                      MediaQuery.of(context).size.width - 150,
                    ),
                    (pos.dy + details.delta.dy).clamp(
                      0,
                      MediaQuery.of(context).size.height - 150,
                    ),
                  );

                  onPositionChanged(habit, {
                    'x': newOffset.dx,
                    'y': newOffset.dy,
                  });
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
                            onPressed: () => onEdit(habit),
                            icon: const Icon(Icons.edit, size: 16),
                          ),
                          IconButton(
                            onPressed: () => onDelete(habit),
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
