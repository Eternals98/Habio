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

// 👇 Quitamos el enum PetType (volvemos a DB):
// import 'package:per_habit/features/habit/domain/entities/pet_type.dart';

enum FrequencyPeriod { day, week }

extension FrequencyPeriodX on FrequencyPeriod {
  String get id => this == FrequencyPeriod.day ? 'day' : 'week';
  static FrequencyPeriod fromString(String? s) {
    if (s == 'week') return FrequencyPeriod.week;
    return FrequencyPeriod.day;
  }
}

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

  // Volvemos a usar modelos del backend:
  PetTypeModel? selectedPet;
  PersonalityModel? selectedPersonality;

  // Frecuencia
  FrequencyPeriod period = FrequencyPeriod.day; // 'day' | 'week'
  int frequencyCount = 1; // veces por día/semana
  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  bool get isEdit => widget.initialHabit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.initialHabit;
    if (habit != null) {
      _nameController.text = habit.name;

      // Lee periodo y cantidades existentes (si el campo no existía, por default 'day')
      period = FrequencyPeriodX.fromString(habit.frequencyPeriod);
      frequencyCount = habit.frequencyCount;

      // Solo usamos horas si es por día
      if (period == FrequencyPeriod.day && habit.scheduleTimes.isNotEmpty) {
        selectedTimes =
            habit.scheduleTimes.map((s) {
              final parts = s.split(':');
              return TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }).toList();
      } else {
        selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
      }

      // NOTA: en edición, mascota y personalidad se desactivan, así que no es necesario
      // pre-cargar selectedPet/selectedPersonality desde el provider aquí.
    }

    _syncTimesWithCount(); // evita RangeError
    ref.read(habitControllerProvider.notifier).setRoom(widget.roomId);
  }

  void _syncTimesWithCount() {
    if (period == FrequencyPeriod.day) {
      if (selectedTimes.length < frequencyCount) {
        selectedTimes.addAll(
          List.generate(
            frequencyCount - selectedTimes.length,
            (_) => const TimeOfDay(hour: 8, minute: 0),
          ),
        );
      } else if (selectedTimes.length > frequencyCount) {
        selectedTimes = selectedTimes.sublist(0, frequencyCount);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // En creación exigimos mascota y personalidad
    if (!isEdit && (selectedPet == null || selectedPersonality == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona mascota y personalidad')),
      );
      return;
    }

    final scheduleTimes =
        period == FrequencyPeriod.day
            ? selectedTimes
                .map(
                  (e) =>
                      '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}',
                )
                .toList()
            : <String>[]; // por semana no guardamos horas

    final habit = Habit(
      id: widget.initialHabit?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      // Volvemos a guardar el ID del tipo desde DB (no enum):
      petType: isEdit ? widget.initialHabit!.petType : selectedPet!.id,
      goal: frequencyCount, // si lo usas, mantenlo en sync con frequencyCount
      progress: widget.initialHabit?.progress ?? 0,
      life: widget.initialHabit?.life ?? 100,
      points: widget.initialHabit?.points ?? 0,
      level: widget.initialHabit?.level ?? 1,
      experience: widget.initialHabit?.experience ?? 0,
      baseStatus: widget.initialHabit?.baseStatus ?? 'happy',
      tempStatus: widget.initialHabit?.tempStatus ?? '',
      streak: widget.initialHabit?.streak ?? 0,
      lastCompletedDate: widget.initialHabit?.lastCompletedDate,
      roomId: widget.roomId,
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),

      // Frecuencia flexible
      frequencyCount: frequencyCount, // veces por día/semana
      frequencyPeriod:
          period.id, // 'day' | 'week' (agrega el campo en tu modelo/mapper)
      scheduleTimes: scheduleTimes, // vacío si 'week'
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
    final disabledInEdit = isEdit; // deshabilitar selección en edición

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nombre
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre del hábito'),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
          ),
          const SizedBox(height: 16),

          // Mascota (desde DB; deshabilitada en edición)
          PetTypeSelector(
            selected: selectedPet,
            onSelected: (p) => setState(() => selectedPet = p),
            enabled: !disabledInEdit,
          ),
          const SizedBox(height: 16),

          // Personalidad (desde DB; deshabilitada en edición)
          PersonalitySelector(
            selected: selectedPersonality,
            onSelected: (p) => setState(() => selectedPersonality = p),
            enabled: !disabledInEdit,
          ),
          const SizedBox(height: 16),

          // Periodo
          Text(
            'Periodo de frecuencia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<FrequencyPeriod>(
            segments: const [
              ButtonSegment(value: FrequencyPeriod.day, label: Text('Por día')),
              ButtonSegment(
                value: FrequencyPeriod.week,
                label: Text('Por semana'),
              ),
            ],
            selected: {period},
            onSelectionChanged: (s) {
              setState(() {
                period = s.first;

                // (Opcional) límites máximos visuales
                if (period == FrequencyPeriod.day && frequencyCount > 5) {
                  frequencyCount = 5;
                }
                if (period == FrequencyPeriod.week && frequencyCount > 14) {
                  frequencyCount = 14;
                }

                _syncTimesWithCount();
              });
            },
          ),
          const SizedBox(height: 16),

          // Cantidad
          Text(
            period == FrequencyPeriod.day
                ? 'Veces por día'
                : 'Veces por semana',
          ),
          DropdownButton<int>(
            value: frequencyCount,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                frequencyCount = value;
                _syncTimesWithCount(); // evita RangeError al pintar horas
              });
            },
            items:
                (period == FrequencyPeriod.day
                        ? List.generate(5, (i) => i + 1) // 1..5 por día
                        : List.generate(14, (i) => i + 1)) // 1..14 por semana
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
          ),

          // Horas solo si es por día
          if (period == FrequencyPeriod.day) ...[
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                // “cinturón y tirantes” por si algo quedó desfasado un frame
                (frequencyCount <= selectedTimes.length)
                    ? frequencyCount
                    : selectedTimes.length,
                (i) {
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
                },
              ),
            ),
          ],

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
