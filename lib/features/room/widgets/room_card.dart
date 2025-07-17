import 'package:flutter/material.dart';
import 'package:per_habit/features/room/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final double width;
  final double height;
  final double margin;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAbrir;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoomCard({
    required this.room,
    required this.width,
    required this.height,
    required this.margin,
    required this.isSelected,
    required this.onTap,
    required this.onAbrir,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: margin, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(width: 3) : Border.all(width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              room.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Icon(Icons.category_rounded),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: onAbrir, child: const Text("Abrir")),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
