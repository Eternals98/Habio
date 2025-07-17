// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/features/room/models/room_model.dart';
import 'package:per_habit/features/auth/models/user_model.dart';

class RoomService {
  // Crear un lugar
  Future<void> addRoom({
    required BuildContext context,
    required List<Room> rooms,
    required Function setState,
    required String owner,
    required Function(int) scrollToSelected,
  }) async {
    final String? nameRoom = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Crear Nuevo Lugar'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Nombre del lugar (Ej: Estudio)",
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Crear'),
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

    if (nameRoom != null && nameRoom.isNotEmpty) {
      try {
        final newRoom = Room(
          id: UniqueKey().toString(),
          name: nameRoom,
          owner: owner,
          createdAt: DateTime.now(),
          shared: false,
        );

        // Guardar el nuevo Room en Firestore
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(newRoom.id)
            .set(newRoom.toMap());

        // Actualizar la lista local de rooms
        setState(() {
          rooms.add(newRoom);
          if (kDebugMode) {
            print(newRoom.toString());
          }
          final selectedIndex = rooms.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              scrollToSelected(selectedIndex);
            }
          });
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al crear el room: $e')));
        }
      }
    }
  }

  // Actualizar un lugar
  Future<void> updateRoom({
    required BuildContext context,
    required Room room,
    required List<Room> rooms,
    required Function setState,
    required int selectedIndex,
    required Function(int) scrollToSelected,
  }) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(
          text: room.name,
        );
        return AlertDialog(
          title: const Text('Editar Lugar'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Nuevo nombre del lugar",
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Actualizar'),
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

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        final index = rooms.indexWhere((l) => l.id == room.id);
        if (index != -1) {
          rooms[index] = Room(
            id: room.id,
            name: newName,
            pets: room.pets,
            members: room.members,
            owner: room.owner,
            createdAt: room.createdAt,
            shared: room.shared,
          );
        }
        if (kDebugMode) {
          print(rooms[index].toString());
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            scrollToSelected(selectedIndex);
          }
        });
      });
    }
  }

  // Añadir un miembro
  Future<void> addMember({
    required BuildContext context,
    required Room room,
    required List<Room> rooms,
    required Function setState,
  }) async {
    final String? email = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Invitar Miembro'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Correo del usuario (Ej: usuario@ejemplo.com)",
            ),
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Invitar'),
              onPressed: () {
                if (controller.text.trim().isNotEmpty &&
                    RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(controller.text.trim())) {
                  Navigator.of(context).pop(controller.text.trim());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingrese un correo válido'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (email != null && email.isNotEmpty) {
      try {
        // Buscar el usuario en Firestore
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final newMember = UserModel.fromMap(doc.data());
          if (kDebugMode) {
            print(newMember.uid);
          }

          // Actualizar la lista local de rooms
          setState(() {
            final index = rooms.indexWhere((l) => l.id == room.id);
            if (index != -1) {
              final updatedMembers = List<String>.from(room.members)
                ..add(newMember.uid); // Agregar el uid del nuevo miembro
              rooms[index] = Room(
                id: room.id,
                name: room.name,
                pets: room.pets,
                members: updatedMembers,
                owner: room.owner,
                createdAt: room.createdAt,
                shared: true,
              );
              if (kDebugMode) {
                print(rooms[index].toString());
              }
            }
          });

          // Actualizar el Room en Firestore
          await FirebaseFirestore.instance
              .collection('rooms')
              .doc(room.id)
              .update({
                'members': FieldValue.arrayUnion([
                  newMember.uid,
                ]), // Agregar el uid a members
                'shared': true,
              });
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al agregar miembro: $e');
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar miembro: $e')),
          );
        }
      }
    }
  }

  // Eliminar un lugar
  Future<void> deleteRoom({
    required BuildContext context,
    required Room room,
    required List<Room> rooms,
    required Function setState,
    required int selectedIndex,
    required Function(int) scrollToSelected,
  }) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Lugar'),
          content: Text(
            '¿Estás seguro de que quieres eliminar "${room.name}"?',
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
        // Eliminar el documento de Firestore
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(room.id)
            .delete();

        // Actualizar la lista de rooms
        setState(() {
          rooms.removeWhere((l) => l.id == room.id);
          int newIndex = selectedIndex;
          if (selectedIndex >= rooms.length && rooms.isNotEmpty) {
            newIndex = rooms.length - 1;
          } else if (rooms.isEmpty) {
            newIndex = -1;
          }
          if (rooms.isNotEmpty && context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                scrollToSelected(newIndex);
              }
            });
          }
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar el room: $e')),
          );
        }
      }
    }
  }
}
