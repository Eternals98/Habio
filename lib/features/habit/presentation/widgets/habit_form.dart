// lib/features/habit/presentation/widgets/habit_form.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';
import 'package:per_habit/features/habit/presentation/widgets/pet_type_selector.dart';
import 'package:per_habit/features/habit/presentation/widgets/personality_selector.dart';

import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/providers/config_provider.dart'; // userInventoryStreamProvider, petTypesProvider, personalitiesProvider
import 'package:per_habit/features/auth/presentation/controllers/auth_providers.dart'; // authControllerProvider

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
  static const String kFreePetId = 'teddy';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  PetTypeModel? selectedPet;
  PersonalityModel? selectedPersonality;

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
      period = FrequencyPeriodX.fromString(habit.frequencyPeriod);
      frequencyCount = habit.frequencyCount;

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

  bool _isPetAllowed(Set<String> allowedIds, String petId) {
    return petId == kFreePetId || allowedIds.contains(petId);
  }

  Future<void> _submit(Set<String> allowedIds) async {
    if (!_formKey.currentState!.validate()) return;

    // En creación exigimos mascota y personalidad
    if (!isEdit && (selectedPet == null || selectedPersonality == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona mascota y personalidad')),
      );
      return;
    }

    // Validar que la mascota esté permitida (inventario o teddy gratis)
    if (!isEdit && !_isPetAllowed(allowedIds, selectedPet!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes esa mascota en tu inventario.'),
        ),
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
      petType: isEdit ? widget.initialHabit!.petType : selectedPet!.id,
      goal: frequencyCount,
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
      frequencyCount: frequencyCount,
      frequencyPeriod: period.id, // 'day' | 'week'
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

  /// Crea mascota + personalidad al azar usando lo disponible
  Future<void> _createRandom(Set<String> allowedIds) async {
    if (!_formKey.currentState!.validate()) {
      // Requiere al menos el nombre
      return;
    }

    try {
      // 1) Traer petTypes disponibles (DB) y filtrarlos por allowedIds/teddy
      final petTypes = await ref.read(
        petTypesProvider.future,
      ); // disponibles: true
      final pool =
          petTypes.where((p) => _isPetAllowed(allowedIds, p.id)).toList();
      if (pool.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tienes mascotas disponibles aún.')),
        );
        return;
      }

      // 2) Personalidades
      final personalities = await ref.read(personalitiesProvider.future);
      if (personalities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay personalidades configuradas.')),
        );
        return;
      }

      final rnd = Random();
      final pet = pool[rnd.nextInt(pool.length)];
      final pers = personalities[rnd.nextInt(personalities.length)];

      setState(() {
        selectedPet = pet;
        selectedPersonality = pers;
      });

      // 3) Crear directamente con la selección aleatoria
      await _submit(allowedIds);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creando al azar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabledInEdit = isEdit;

    // Usuario actual (para leer inventario)
    final user = ref.watch(authControllerProvider).user;
    final uid = user?.uid ?? '';

    // Inventario por stream (actualiza en vivo)
    final invAsync =
        uid.isEmpty
            ? const AsyncValue<List<dynamic>>.data(const [])
            : ref.watch(userInventoryStreamProvider(uid));

    // Construir set de mascotas permitidas desde inventario + teddy gratis
    final allowedPetIds = <String>{
      kFreePetId, // siempre disponible
      ...invAsync.maybeWhen(
        data:
            (items) =>
                items
                    .where(
                      (it) => (it.category == 'mascota') && (it.cantidad > 0),
                    )
                    .map((it) => it.id)
                    .cast<String>(),
        orElse: () => const <String>[],
      ),
    };

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
            onSelected: (p) {
              if (!disabledInEdit && !_isPetAllowed(allowedPetIds, p.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Esta mascota no está en tu inventario. Gánala/compra para usarla.',
                    ),
                  ),
                );
                return;
              }
              setState(() => selectedPet = p);
            },
            enabled: !disabledInEdit,
          ),
          const SizedBox(height: 6),
          invAsync.when(
            data:
                (_) => Text(
                  'Puedes crear hábitos con: ${allowedPetIds.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            loading: () => const Text('Cargando inventario…'),
            error: (_, __) => const Text('Inventario no disponible'),
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
                _syncTimesWithCount();
              });
            },
            items:
                (period == FrequencyPeriod.day
                        ? List.generate(5, (i) => i + 1)
                        : List.generate(14, (i) => i + 1))
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
          ),

          // Horas solo si es por día
          if (period == FrequencyPeriod.day) ...[
            const SizedBox(height: 8),
            Column(
              children: List.generate(
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

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Guardar cambios' : 'Crear hábito'),
                  onPressed: () => _submit(allowedPetIds),
                ),
              ),
              const SizedBox(width: 12),
              if (!isEdit)
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.casino),
                    label: const Text('Crear con aleatorio'),
                    onPressed: () => _createRandom(allowedPetIds),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
