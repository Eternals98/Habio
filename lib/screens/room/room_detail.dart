import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:per_habit/models/mascotaHabito.dart';
import 'package:per_habit/models/pet.dart';
import 'package:per_habit/models/rooms.dart';
import 'package:per_habit/models/user_model.dart';
import 'package:per_habit/types/mechanic.dart';
import 'package:per_habit/types/personality.dart';
import 'package:per_habit/types/petType.dart';

class LugarDetalleScreen extends StatefulWidget {
  final Lugar lugar;

  const LugarDetalleScreen({super.key, required this.lugar});

  @override
  State<LugarDetalleScreen> createState() => _LugarDetalleScreenState();
}

class _LugarDetalleScreenState extends State<LugarDetalleScreen> {
  late List<MascotaHabito> _mascotas;
  Mechanic? _selectedMechanic;
  Personality? _selectedPersonality;
  PetType? _selectedPetType;

  @override
  void initState() {
    super.initState();
    _mascotas = List.from(widget.lugar.mascotas);
  }

  void _addHabito() async {
    _selectedMechanic = null;
    _selectedPersonality = null;
    _selectedPetType = null;

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
                      value: _selectedMechanic,
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
                          _selectedMechanic = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<Personality>(
                      hint: const Text('Selecciona Personalidad'),
                      value: _selectedPersonality,
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
                          _selectedPersonality = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<PetType>(
                      hint: const Text('Selecciona Tipo de Mascota'),
                      value: _selectedPetType,
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
                          _selectedPetType = newValue;
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
                        _selectedMechanic != null &&
                        _selectedPersonality != null &&
                        _selectedPetType != null) {
                      Navigator.of(context).pop(controller.text.trim());
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('Crear Random'),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.of(context).pop(controller.text.trim());
                      setDialogState(() {
                        _selectedMechanic =
                            Mechanic.values[math.Random().nextInt(
                              Mechanic.values.length,
                            )];
                        _selectedPersonality =
                            Personality.values[math.Random().nextInt(
                              Personality.values.length,
                            )];
                        _selectedPetType =
                            PetType.values[math.Random().nextInt(
                              PetType.values.length,
                            )];
                      });
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
        final newPet = Pet(
          id: math.Random().nextInt(1000000).toString(),
          mechanic:
              _selectedMechanic ??
              Mechanic.values[math.Random().nextInt(Mechanic.values.length)],
          personality:
              _selectedPersonality ??
              Personality.values[math.Random().nextInt(
                Personality.values.length,
              )],
          petType:
              _selectedPetType ??
              PetType.values[math.Random().nextInt(PetType.values.length)],
        );
        final newHabito = MascotaHabito(
          id: math.Random().nextInt(1000000).toString(),
          nombre: nombreHabito,
          pet: newPet,
          userModel: UserModel(
            uid: 'user_${math.Random().nextInt(1000)}',
            email: '',
          ),
          room: widget.lugar,
          position: const Offset(50, 50),
        );
        _mascotas.add(newHabito);
      });
    }
  }

  void _updatePosition(MascotaHabito habito, Offset newPosition) {
    setState(() {
      habito.position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lugar.nombre)),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_rounded, size: 100),
                const SizedBox(height: 20),
                Text('Detalles de "${widget.lugar.nombre}"'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Añadir Hábito'),
                  onPressed: _addHabito,
                ),
                const SizedBox(height: 20),
                if (_mascotas.isEmpty)
                  const Text(
                    'Aquí se mostrarán las mascotas (hábitos) de este lugar.',
                  ),
              ],
            ),
          ),
          ..._mascotas.map((habito) {
            return Positioned(
              left: habito.position.dx,
              top: habito.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  _updatePosition(
                    habito,
                    Offset(
                      (habito.position.dx + details.delta.dx).clamp(
                        0,
                        MediaQuery.of(context).size.width - 100,
                      ),
                      (habito.position.dy + details.delta.dy).clamp(
                        0,
                        MediaQuery.of(context).size.height - 100,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        habito.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habito.pet.petType.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
