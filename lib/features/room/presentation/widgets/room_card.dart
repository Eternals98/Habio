import 'package:flutter/material.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    room.shared ? Icons.groups : Icons.lock_outline,
                    size: 18,
                    color: room.shared ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    room.shared ? 'Compartido' : 'Privado',
                    style: TextStyle(
                      color: room.shared ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
