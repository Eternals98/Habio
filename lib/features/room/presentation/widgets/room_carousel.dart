import 'package:flutter/material.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/presentation/widgets/room_card.dart';

class RoomCarousel extends StatelessWidget {
  final List<Room> rooms;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  final void Function(Room room) onEdit;
  final void Function(Room room) onDelete;
  final void Function(Room room) onTap;

  const RoomCarousel({
    super.key,
    required this.rooms,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: rooms.length,
      controller: PageController(initialPage: selectedIndex),
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) {
        final room = rooms[index];
        return RoomCard(
          room: room,
          onEdit: () => onEdit(room),
          onDelete: () => onDelete(room),
          onTap: () => onTap(room),
        );
      },
    );
  }
}
