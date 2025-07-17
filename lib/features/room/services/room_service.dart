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
      setState(() {
        final newRoom = Room(
          id: UniqueKey().toString(),
          name: nameRoom,
          owner: UserModel(uid: "11w", email: "leeank"),
          createdAt: DateTime.now(),
          shared: false,
        );
        if (kDebugMode) {
          print(newRoom.toString());
        }
        rooms.add(newRoom);
        final selectedIndex = rooms.length - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            scrollToSelected(selectedIndex);
          }
        });
      });
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
            shared: room.shared, // Preserve existing createdAt
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
      setState(() {
        final index = rooms.indexWhere((l) => l.id == room.id);
        if (index != -1) {
          final newMember = UserModel(
            uid: UniqueKey().toString(),
            email: email,
          );
          final updatedMembers = List<UserModel>.from(room.members)
            ..add(newMember);
          rooms[index] = Room(
            id: room.id,
            name: room.name,
            pets: room.pets,
            members: updatedMembers,
            owner: room.owner,
            createdAt: room.createdAt,
            shared: true, // Set shared to true when adding a member
          );
          if (kDebugMode) {
            print(rooms[index].toString());
          }
        }
      });
    }
  }

  // Eliminar un lugar
  void deleteRoom({
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
    }
  }
}
