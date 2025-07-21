import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/presentation/widgets/habit_form.dart';

class EditHabitScreen extends StatelessWidget {
  final Habit habit;
  const EditHabitScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Hábito')),
      body: HabitForm(roomId: habit.roomId, initialHabit: habit),
    );
  }
}
