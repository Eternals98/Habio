import 'package:flutter/material.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomDetailsHeader extends StatelessWidget {
  final Room room;

  const RoomDetailsHeader({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: 'Invitar miembro',
          onPressed: () {
            // TODO: lógica para invitar miembro
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Editar room',
          onPressed: () {
            // TODO: lógica para editar room
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Eliminar room',
          onPressed: () {
            // TODO: lógica para eliminar room
          },
        ),
      ],
    );
  }
}
