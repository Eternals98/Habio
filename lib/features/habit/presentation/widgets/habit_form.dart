import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
// ignore: unused_import
import 'package:per_habit/features/habit/presentation/controllers/habit_controller.dart';
import 'package:per_habit/features/habit/presentation/widgets/pet_type_selector.dart';
import 'package:per_habit/features/habit/presentation/widgets/personality_selector.dart';

class HabitForm extends ConsumerStatefulWidget {
  final String roomId;
  final Habit? initialHabit;

  const HabitForm({super.key, required this.roomId, this.initialHabit});

  @override
  ConsumerState<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  PetTypeModel? selectedPet;
  PersonalityModel? selectedPersonality;

  int frequencyCount = 1;
  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  bool get isEdit => widget.initialHabit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.initialHabit;
    if (habit != null) {
      _nameController.text = habit.name;
      frequencyCount = habit.frequencyCount;
      selectedTimes =
          habit.scheduleTimes.map((s) {
            final parts = s.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList();
    }

    ref.read(habitControllerProvider.notifier).setRoom(widget.roomId);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        selectedPet == null ||
        selectedPersonality == null) {
      return;
    }

    final scheduleTimes =
        selectedTimes
            .map(
              (e) =>
                  '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}',
            )
            .toList();

    final habit = Habit(
      id: widget.initialHabit?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      petType: selectedPet!.id,
      goal: frequencyCount,
      progress: widget.initialHabit?.progress ?? 0,
      life: widget.initialHabit?.life ?? 100,
      points: widget.initialHabit?.points ?? 0,
      level: widget.initialHabit?.level ?? 1,
      experience: widget.initialHabit?.experience ?? 0,
      baseStatus: widget.initialHabit?.baseStatus ?? 'happy',
      tempStatus: widget.initialHabit?.tempStatus,
      streak: widget.initialHabit?.streak ?? 0,
      lastCompletedDate: widget.initialHabit?.lastCompletedDate,
      roomId: widget.roomId,
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
      frequencyCount: frequencyCount,
      scheduleTimes: scheduleTimes,
    );

    final controller = ref.read(habitControllerProvider.notifier);
    if (isEdit) {
      await controller.updateHabit(habit);
    } else {
      await controller.createHabit(habit);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre del hábito'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Ingresa un nombre' : null,
          ),
          const SizedBox(height: 16),
          PetTypeSelector(
            selected: selectedPet,
            onSelected: (p) => setState(() => selectedPet = p),
          ),
          const SizedBox(height: 16),
          PersonalitySelector(
            selected: selectedPersonality,
            onSelected: (p) => setState(() => selectedPersonality = p),
          ),
          const SizedBox(height: 16),
          Text('Veces al día:'),
          DropdownButton<int>(
            value: frequencyCount,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                frequencyCount = value;
                if (selectedTimes.length < value) {
                  selectedTimes.addAll(
                    List.generate(
                      value - selectedTimes.length,
                      (_) => const TimeOfDay(hour: 8, minute: 0),
                    ),
                  );
                } else {
                  selectedTimes = selectedTimes.take(value).toList();
                }
              });
            },
            items:
                List.generate(5, (i) => i + 1)
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(frequencyCount, (i) {
              final time = selectedTimes[i];
              return Row(
                children: [
                  Text('Hora ${i + 1}: ${time.format(context)}'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (picked != null) {
                        setState(() => selectedTimes[i] = picked);
                      }
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(isEdit ? Icons.save : Icons.add),
            label: Text(isEdit ? 'Guardar cambios' : 'Crear hábito'),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
