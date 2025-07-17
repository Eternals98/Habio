import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/room/models/room_model.dart';
import 'package:per_habit/features/habit/types/mechanic.dart';
import 'package:per_habit/features/habit/types/personality.dart';
import 'package:per_habit/features/habit/types/petType.dart';

class PetHabitService {
  // Crear un hábito
  Future<void> addHabit({
    required BuildContext context,
    required List<PetHabit> petHabits,
    required String room,
    required Function setState,
    required String user,
  }) async {
    Mechanic? selectedMechanic;
    Personality? selectedPersonality;
    PetType? selectedPetType;

    final String? nameHabit = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Crear Nuevo Hábito'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nombre del hábito (Ej: Meditar)',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Mechanic>(
                      hint: const Text('Selecciona Mecánica'),
                      value: selectedMechanic,
                      isExpanded: true,
                      items:
                          Mechanic.values.map((Mechanic mechanic) {
                            return DropdownMenuItem<Mechanic>(
                              value: mechanic,
                              child: Text(mechanic.name),
                            );
                          }).toList(),
                      onChanged: (Mechanic? newValue) {
                        setDialogState(() {
                          selectedMechanic = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Personality>(
                      hint: const Text('Selecciona Personalidad'),
                      value: selectedPersonality,
                      isExpanded: true,
                      items:
                          Personality.values.map((Personality personality) {
                            return DropdownMenuItem<Personality>(
                              value: personality,
                              child: Text(personality.name),
                            );
                          }).toList(),
                      onChanged: (Personality? newValue) {
                        setDialogState(() {
                          selectedPersonality = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<PetType>(
                      hint: const Text('Selecciona Tipo de Mascota'),
                      value: selectedPetType,
                      isExpanded: true,
                      items:
                          PetType.values.map((PetType petType) {
                            return DropdownMenuItem<PetType>(
                              value: petType,
                              child: Text(petType.name),
                            );
                          }).toList(),
                      onChanged: (PetType? newValue) {
                        setDialogState(() {
                          selectedPetType = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Crear'),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty &&
                        selectedMechanic != null &&
                        selectedPersonality != null &&
                        selectedPetType != null) {
                      Navigator.of(context).pop(controller.text.trim());
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('Crear Random'),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.of(context).pop(controller.text.trim());
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (nameHabit != null && nameHabit.isNotEmpty) {
      try {
        // Crear el nuevo PetHabit
        final newHabit = PetHabit(
          id: UniqueKey().toString(),
          name: nameHabit,
          userModel: user,
          room: room,
          mechanic:
              selectedMechanic ??
              PetHabit.random(
                UniqueKey().toString(),
                nameHabit,
                user,
                room,
              ).mechanic,
          personality:
              selectedPersonality ??
              PetHabit.random(
                UniqueKey().toString(),
                nameHabit,
                user,
                room,
              ).personality,
          petType:
              selectedPetType ??
              PetHabit.random(
                UniqueKey().toString(),
                nameHabit,
                user,
                room,
              ).petType,
          position: const Offset(50, 50),
          createdAt: DateTime.now(),
        );

        // Actualizar la lista local de petHabits
        setState(() {
          petHabits.add(newHabit);
          if (kDebugMode) {
            print(newHabit);
          }
        });

        // Actualizar el Room en Firestore
        final roomDoc =
            await FirebaseFirestore.instance
                .collection('rooms')
                .doc(room)
                .get();
        if (roomDoc.exists) {
          final currentPets =
              (roomDoc.data()?['pets'] as List<dynamic>?)
                  ?.map((pet) => PetHabit.fromMap(pet as Map<String, dynamic>))
                  .toList() ??
              [];
          currentPets.add(newHabit);

          await FirebaseFirestore.instance.collection('rooms').doc(room).update(
            {'pets': currentPets.map((pet) => pet.toMap()).toList()},
          );
        } else {
          throw Exception('Room no encontrado en Firestore');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el hábito: $e')),
          );
        }
      }
    }
  }

  // Actualizar un hábito
  Future<void> updateHabit({
    required BuildContext context,
    required PetHabit habit,
    required List<PetHabit> petHabits,
    required Room room,
    required Function setState,
  }) async {
    Mechanic? selectedMechanic = habit.mechanic;
    Personality? selectedPersonality = habit.personality;
    PetType? selectedPetType = habit.petType;

    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(
          text: habit.name,
        );
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Hábito'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nuevo nombre del hábito',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Mechanic>(
                      hint: const Text('Selecciona Mecánica'),
                      value: selectedMechanic,
                      isExpanded: true,
                      items:
                          Mechanic.values.map((Mechanic mechanic) {
                            return DropdownMenuItem<Mechanic>(
                              value: mechanic,
                              child: Text(mechanic.name),
                            );
                          }).toList(),
                      onChanged: (Mechanic? newValue) {
                        setDialogState(() {
                          selectedMechanic = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Personality>(
                      hint: const Text('Selecciona Personalidad'),
                      value: selectedPersonality,
                      isExpanded: true,
                      items:
                          Personality.values.map((Personality personality) {
                            return DropdownMenuItem<Personality>(
                              value: personality,
                              child: Text(personality.name),
                            );
                          }).toList(),
                      onChanged: (Personality? newValue) {
                        setDialogState(() {
                          selectedPersonality = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<PetType>(
                      hint: const Text('Selecciona Tipo de Mascota'),
                      value: selectedPetType,
                      isExpanded: true,
                      items:
                          PetType.values.map((PetType petType) {
                            return DropdownMenuItem<PetType>(
                              value: petType,
                              child: Text(petType.name),
                            );
                          }).toList(),
                      onChanged: (PetType? newValue) {
                        setDialogState(() {
                          selectedPetType = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Actualizar'),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty &&
                        selectedMechanic != null &&
                        selectedPersonality != null &&
                        selectedPetType != null) {
                      Navigator.of(context).pop(controller.text.trim());
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        final index = petHabits.indexWhere((m) => m.id == habit.id);
        if (index != -1) {
          petHabits[index] = PetHabit(
            id: habit.id,
            name: newName,
            userModel: habit.userModel,
            room: habit.room,
            mechanic: selectedMechanic!,
            personality: selectedPersonality!,
            petType: selectedPetType!,
            position: habit.position,
            createdAt: habit.createdAt, // Preserve existing createdAt
          );
          room.pets = petHabits; // Update lugar's mascotas
        }
      });
    }
  }

  // Eliminar un hábito
  Future<void> deleteHabit({
    required BuildContext context,
    required PetHabit habit,
    required List<PetHabit> petHabits,
    required Room room,
    required Function setState,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Hábito'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${habit.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        petHabits.removeWhere((m) => m.id == habit.id);
        room.pets = petHabits; // Update lugar's mascotas
      });
    }
  }
}
