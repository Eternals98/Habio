import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
import 'package:per_habit/features/room/presentation/controllers/room_providers.dart';
import 'package:per_habit/features/room/presentation/widgets/room_canvas.dart'; // ✅ Nuevo widget
import 'package:reorderables/reorderables.dart';

class RoomCarousel extends ConsumerStatefulWidget {
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
  ConsumerState<RoomCarousel> createState() => _RoomCarouselState();
}

class _RoomCarouselState extends ConsumerState<RoomCarousel> {
  late List<Room> _orderedRooms;

  @override
  void initState() {
    super.initState();
    _orderedRooms = [...widget.rooms]; // Copia local para poder reordenar
  }

  @override
  void didUpdateWidget(covariant RoomCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rooms != widget.rooms) {
      _orderedRooms = [...widget.rooms];
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _orderedRooms.removeAt(oldIndex);
      _orderedRooms.insert(newIndex, item);
      widget.onPageChanged(newIndex);
    });

    // Guardar el nuevo orden
    Future.microtask(() {
      final controller = ref.read(roomControllerProvider.notifier);
      controller.reorderRooms(_orderedRooms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableWrap(
      spacing: 12,
      runSpacing: 12,
      padding: const EdgeInsets.all(16),
      onReorder: _onReorder,
      needsLongPressDraggable: false,
      children:
          _orderedRooms.map((room) {
            return RoomCanvas(
              key: ValueKey(room.id),
              room: room,
              onTap: () => widget.onTap(room),
              onEdit: () => widget.onEdit(room),
              onDelete: () => widget.onDelete(room),
            );
          }).toList(),
    );
  }
}
