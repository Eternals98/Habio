import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:per_habit/core/theme/app_colors.dart';
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
      child: Container(
        width: 180,
        height: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.secondaryBackground,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/room_icons/room_base.svg',
                  width: 72,
                  height: 72,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(127),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          room.shared ? Icons.groups : Icons.lock_outline,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          room.shared ? 'Compartido' : 'Privado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
