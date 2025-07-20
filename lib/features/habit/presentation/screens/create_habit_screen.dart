import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/presentation/widgets/habit_form.dart';

class CreateHabitScreen extends StatelessWidget {
  final String roomId;
  const CreateHabitScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Hábito')),
      body: HabitForm(roomId: roomId),
    );
  }
}
