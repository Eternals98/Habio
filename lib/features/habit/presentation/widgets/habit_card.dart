// lib/features/habit/presentation/widgets/habit_card.dart

import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isDragging;

  const HabitCard({super.key, required this.habit, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Draggable<Habit>(
      data: habit,
      feedback: Opacity(
        opacity: 0.7,
        child: _buildCard(context, dragging: true),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context, {bool dragging = false}) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: dragging ? Colors.grey[300] : Colors.blue[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            dragging
                ? []
                : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
      ),
      child: Center(
        child: Text(
          habit.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
