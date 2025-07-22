import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:per_habit/core/theme/app_colors.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomCanvas extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoomCanvas({
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
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              'assets/images/room_icons/room_base.svg',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            // Nombre en diagonal izquierda (ajustado manualmente)
            Positioned(
              left: 10,
              top: 10,
              child: Transform.rotate(
                angle: -0.4,
                child: const Text(
                  'Nombre', // Este será reemplazado dinámicamente más adelante
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Privacidad en diagonal derecha
            Positioned(
              right: 10,
              top: 20,
              child: Transform.rotate(
                angle: 0.5,
                child: Row(
                  children: [
                    Icon(
                      room.shared ? Icons.groups : Icons.lock_outline,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room.shared ? 'Compartido' : 'Privado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 3,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
