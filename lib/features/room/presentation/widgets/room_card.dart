import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => _RoomOptions(onEdit: onEdit, onDelete: onDelete),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 📦 Imagen SVG como fondo principal
          SvgPicture.asset(
            'assets/images/room_icons/room_base.svg',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),

          // 🧷 Nombre pegado a la pared izquierda (rotado)
          Positioned(
            top: 34,
            left: 26,
            child: Transform.rotate(
              angle: -0.45, // Rota ligeramente hacia la izquierda
              child: Text(
                room.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
                ),
              ),
            ),
          ),

          // 🧷 Estado en la pared derecha (rotado hacia otro lado)
          Positioned(
            top: 38,
            right: 10,
            child: Transform.rotate(
              angle: 0.40,
              child: Row(
                children: [
                  Icon(
                    room.shared ? Icons.groups : Icons.lock_outline,
                    size: 14,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 2),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.shared ? 'Compartido' : 'Privado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomOptions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomOptions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Editar'),
          onTap: () {
            Navigator.pop(context);
            onEdit();
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Eliminar'),
          onTap: () {
            Navigator.pop(context);
            onDelete();
          },
        ),
      ],
    );
  }
}
