// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/habit/types/status.dart';
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

    if (nameHabit != null) {
      final String habitId =
          FirebaseFirestore.instance
              .collection('rooms')
              .doc(room)
              .collection('habits')
              .doc()
              .id;

      final PetHabit newHabit = PetHabit(
        id: habitId,
        name: nameHabit,
        userId: user,
        room: room,
        mechanic:
            selectedMechanic ??
            Mechanic.values.first, // fallback for random creation
        personality: selectedPersonality ?? Personality.values.first,
        petType: selectedPetType ?? PetType.values.first,
      );

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(room)
          .collection('habits')
          .doc(habitId)
          .set(newHabit.toMap());

      setState(() {
        petHabits.add(newHabit);
      });
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
                          Mechanic.values.map((mechanic) {
                            return DropdownMenuItem<Mechanic>(
                              value: mechanic,
                              child: Text(mechanic.name),
                            );
                          }).toList(),
                      onChanged: (newValue) {
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
                          Personality.values.map((personality) {
                            return DropdownMenuItem<Personality>(
                              value: personality,
                              child: Text(personality.name),
                            );
                          }).toList(),
                      onChanged: (newValue) {
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
                          PetType.values.map((petType) {
                            return DropdownMenuItem<PetType>(
                              value: petType,
                              child: Text(petType.name),
                            );
                          }).toList(),
                      onChanged: (newValue) {
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
      final updatedHabit = PetHabit(
        id: habit.id,
        name: newName,
        userId: habit.userId,
        room: habit.room,
        mechanic: selectedMechanic!,
        personality: selectedPersonality!,
        petType: selectedPetType!,
        position: habit.position,
        createdAt: habit.createdAt,
        life: habit.life,
        streak: habit.streak,
        expAcumulated: habit.expAcumulated,
        level: habit.level,
        status: habit.status,
        lastUpdated: DateTime.now(),
      );

      // Actualizar Firestore
      final habitRef = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(room.id)
          .collection('habits')
          .doc(habit.id);

      await habitRef.update(updatedHabit.toMap());

      // Actualizar localmente
      setState(() {
        final index = petHabits.indexWhere((m) => m.id == habit.id);
        if (index != -1) {
          petHabits[index] = updatedHabit;
          room.pets = petHabits;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hábito actualizado')));
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
      try {
        // 1. Eliminar en Firestore
        final docRef = FirebaseFirestore.instance
            .collection('rooms')
            .doc(habit.room)
            .collection('habits')
            .doc(habit.id);

        await docRef.delete();

        // 2. Eliminar localmente
        setState(() {
          petHabits.removeWhere((m) => m.id == habit.id);
          room.pets = petHabits;
        });

        // 3. Mostrar feedback
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hábito eliminado')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  void updateLifeStatus(PetHabit habit, {required bool cumplidoHoy}) {
    const int penalizacion = 10;
    const int recompensa = 5;

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final ultimaFecha = habit.lastUpdated;
    final diferenciaDias = hoy.difference(ultimaFecha).inDays;

    int nuevaVida = habit.life;

    if (diferenciaDias > 0) {
      nuevaVida -= penalizacion * diferenciaDias;
    }

    if (cumplidoHoy) {
      nuevaVida += recompensa;
      habit.streak += 1;
    } else {
      habit.streak = 0;
    }

    habit.life = nuevaVida.clamp(0, 100);
    habit.lastUpdated = ahora;

    // Actualiza estado
    if (habit.life >= 90) {
      habit.status = HabitStatus.feliz;
    } else if (habit.life >= 50) {
      habit.status = HabitStatus.normal;
    } else if (habit.life > 0) {
      habit.status = HabitStatus.enfermo;
    } else {
      habit.status = HabitStatus.muerto;
    }
  }

  Future<void> marcarHabitComoHecho({
    required BuildContext context,
    required PetHabit habit,
    required Room room,
    required Function setState,
  }) async {
    try {
      final now = DateTime.now();
      final lastDone = habit.lastUpdated;

      if (lastDone == DateTime.now()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este hábito ya fue completado hoy.')),
        );
        return;
      }

      habit.streak += 1;
      habit.life = (habit.life + 5).clamp(0, 100); // +5 vida diaria
      habit.lastUpdated = now;

      // Aquí podrías subir de nivel si quieres con lógica extra

      // Actualiza en Firestore
      final docRef = FirebaseFirestore.instance
          .collection('rooms')
          .doc(room.id)
          .collection('habits')
          .doc(habit.id);

      await docRef.update(habit.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Hábito marcado como hecho! 🎉')),
      );

      setState(() {}); // Actualiza la UI si es necesario
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
