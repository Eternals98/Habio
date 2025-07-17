import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/room/models/room_model.dart';
import 'package:per_habit/features/auth/models/user_model.dart';
import 'package:per_habit/features/habit/types/mechanic.dart';
import 'package:per_habit/features/habit/types/personality.dart';
import 'package:per_habit/features/habit/types/petType.dart';

class MascotaHabitoService {
  // Crear un hábito
  Future<void> addHabito({
    required BuildContext context,
    required List<MascotaHabito> mascotas,
    required Lugar lugar,
    required Function setState,
  }) async {
    Mechanic? selectedMechanic;
    Personality? selectedPersonality;
    PetType? selectedPetType;

    final String? nombreHabito = await showDialog<String>(
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

    if (nombreHabito != null && nombreHabito.isNotEmpty) {
      setState(() {
        final newHabito = MascotaHabito(
          id: UniqueKey().toString(),
          nombre: nombreHabito,
          userModel: UserModel(
            uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
            email: '',
          ),
          room: lugar,
          mechanic:
              selectedMechanic ??
              MascotaHabito.random(
                UniqueKey().toString(),
                nombreHabito,
                UserModel(
                  uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
                  email: '',
                ),
                lugar,
              ).mechanic,
          personality:
              selectedPersonality ??
              MascotaHabito.random(
                UniqueKey().toString(),
                nombreHabito,
                UserModel(
                  uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
                  email: '',
                ),
                lugar,
              ).personality,
          petType:
              selectedPetType ??
              MascotaHabito.random(
                UniqueKey().toString(),
                nombreHabito,
                UserModel(
                  uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
                  email: '',
                ),
                lugar,
              ).petType,
          position: const Offset(50, 50),
          createdAt: DateTime.now(),
        );
        if (kDebugMode) {
          print(newHabito); // Log all attributes
        }
        mascotas.add(newHabito);
        lugar.mascotas = mascotas; // Update lugar's mascotas
      });
    }
  }

  // Actualizar un hábito
  Future<void> updateHabito({
    required BuildContext context,
    required MascotaHabito habito,
    required List<MascotaHabito> mascotas,
    required Lugar lugar,
    required Function setState,
  }) async {
    Mechanic? selectedMechanic = habito.mechanic;
    Personality? selectedPersonality = habito.personality;
    PetType? selectedPetType = habito.petType;

    final String? nuevoNombre = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(
          text: habito.nombre,
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

    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      setState(() {
        final index = mascotas.indexWhere((m) => m.id == habito.id);
        if (index != -1) {
          mascotas[index] = MascotaHabito(
            id: habito.id,
            nombre: nuevoNombre,
            userModel: habito.userModel,
            room: habito.room,
            mechanic: selectedMechanic!,
            personality: selectedPersonality!,
            petType: selectedPetType!,
            position: habito.position,
            createdAt: habito.createdAt, // Preserve existing createdAt
          );
          lugar.mascotas = mascotas; // Update lugar's mascotas
        }
      });
    }
  }

  // Eliminar un hábito
  Future<void> deleteHabito({
    required BuildContext context,
    required MascotaHabito habito,
    required List<MascotaHabito> mascotas,
    required Lugar lugar,
    required Function setState,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Hábito'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${habito.nombre}"?',
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
        mascotas.removeWhere((m) => m.id == habito.id);
        lugar.mascotas = mascotas; // Update lugar's mascotas
      });
    }
  }
}
