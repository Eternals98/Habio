import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:per_habit/models/room_model.dart';
import 'package:per_habit/models/user_model.dart';

class LugarService {
  // Crear un lugar
  Future<void> addLugar({
    required BuildContext context,
    required List<Lugar> lugares,
    required Function setState,
    required Function(int) scrollToSelected,
  }) async {
    final String? nombreLugar = await showDialog<String>(
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

    if (nombreLugar != null && nombreLugar.isNotEmpty) {
      setState(() {
        final nuevoLugar = Lugar(
          id: UniqueKey().toString(),
          nombre: nombreLugar,
          owner: UserModel(uid: "11w", email: "leeank"),
          createdAt: DateTime.now(),
          shared: false,
        );
        if (kDebugMode) {
          print(nuevoLugar.toString());
        }
        lugares.add(nuevoLugar);
        final selectedIndex = lugares.length - 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            scrollToSelected(selectedIndex);
          }
        });
      });
    }
  }

  // Actualizar un lugar
  Future<void> updateLugar({
    required BuildContext context,
    required Lugar lugar,
    required List<Lugar> lugares,
    required Function setState,
    required int selectedIndex,
    required Function(int) scrollToSelected,
  }) async {
    final String? nuevoNombre = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(
          text: lugar.nombre,
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

    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      setState(() {
        final index = lugares.indexWhere((l) => l.id == lugar.id);
        if (index != -1) {
          lugares[index] = Lugar(
            id: lugar.id,
            nombre: nuevoNombre,
            mascotas: lugar.mascotas,
            members: lugar.members,
            owner: lugar.owner,
            createdAt: lugar.createdAt,
            shared: lugar.shared, // Preserve existing createdAt
          );
        }
        if (kDebugMode) {
          print(lugares[index].toString());
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
    required Lugar lugar,
    required List<Lugar> lugares,
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
        final index = lugares.indexWhere((l) => l.id == lugar.id);
        if (index != -1) {
          final newMember = UserModel(
            uid: UniqueKey().toString(),
            email: email,
          );
          final updatedMembers = List<UserModel>.from(lugar.members)
            ..add(newMember);
          lugares[index] = Lugar(
            id: lugar.id,
            nombre: lugar.nombre,
            mascotas: lugar.mascotas,
            members: updatedMembers,
            owner: lugar.owner,
            createdAt: lugar.createdAt,
            shared: true, // Set shared to true when adding a member
          );
          if (kDebugMode) {
            print(lugares[index].toString());
          }
        }
      });
    }
  }

  // Eliminar un lugar
  void deleteLugar({
    required BuildContext context,
    required Lugar lugar,
    required List<Lugar> lugares,
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
            '¿Estás seguro de que quieres eliminar "${lugar.nombre}"?',
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
        lugares.removeWhere((l) => l.id == lugar.id);
        int newIndex = selectedIndex;
        if (selectedIndex >= lugares.length && lugares.isNotEmpty) {
          newIndex = lugares.length - 1;
        } else if (lugares.isEmpty) {
          newIndex = -1;
        }
        if (lugares.isNotEmpty && context.mounted) {
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
