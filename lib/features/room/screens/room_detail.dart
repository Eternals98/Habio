// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:per_habit/features/habit/services/habit_service.dart';
import 'package:per_habit/features/room/screens/home_screen.dart';
import 'package:per_habit/features/room/services/room_service.dart';
import 'package:per_habit/features/habit/models/habit_model.dart';
import 'package:per_habit/features/room/models/room_model.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room room;
  final List<Room> rooms;
  final Function setState;
  final int selectedIndex;
  final Function(int) scrollToSelected;

  const RoomDetailsScreen({
    super.key,
    required this.room,
    required this.rooms,
    required this.setState,
    required this.selectedIndex,
    required this.scrollToSelected,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late List<PetHabit> _petHabits;
  final RoomService _roomService = RoomService();
  final PetHabitService _petHabitService = PetHabitService();

  @override
  void initState() {
    super.initState();
    _petHabits = List.from(widget.room.pets);
  }

  void _addHabit() {
    _petHabitService.addHabit(
      context: context,
      petHabits: _petHabits,
      room: widget.room.id,
      setState: setState,
      user: widget.room.owner,
    );
  }

  void _updatePosition(PetHabit habit, Offset newPosition) {
    setState(() {
      habit.position = newPosition;
      widget.room.pets = _petHabits;
    });
  }

  void _editHabit(PetHabit habit) {
    _petHabitService.updateHabit(
      context: context,
      habit: habit,
      petHabits: _petHabits,
      room: widget.room,
      setState: setState,
    );
  }

  void _deleteHabit(PetHabit habit) {
    _petHabitService.deleteHabit(
      context: context,
      habit: habit,
      petHabits: _petHabits,
      room: widget.room,
      setState: setState,
    );
  }

  void _showHabitoDetails(PetHabit habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(habit.name),
          content: Text(
            '${habit.name} is a ${habit.petType.description} with ${habit.personality.description} who loves ${habit.mechanic.description}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _editRoom() {
    _roomService.updateRoom(
      context: context,
      room: widget.room,
      rooms: widget.rooms,
      setState: widget.setState,
      selectedIndex: widget.selectedIndex,
      scrollToSelected: widget.scrollToSelected,
    );
  }

  void _deleteRoom() async {
    try {
      // Llamar al servicio para eliminar el room
      await _roomService.deleteRoom(
        context: context,
        room: widget.room,
        rooms: widget.rooms,
        setState: widget.setState,
        selectedIndex: widget.selectedIndex,
        scrollToSelected: widget.scrollToSelected,
      );
      // Retrasar la navegación hasta que el frame esté completo
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el room: $e')),
        );
      }
    }
  }

  void _inviteMember() async {
    final updatedRoom = await _roomService.addMember(
      context: context,
      room: widget.room,
      rooms: widget.rooms,
      setState: widget.setState,
    );
    if (updatedRoom != null && context.mounted) {
      // Reemplazar la pantalla actual con el Room actualizado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => RoomDetailsScreen(
                room: updatedRoom,
                rooms: widget.rooms,
                setState: widget.setState,
                selectedIndex: widget.selectedIndex,
                scrollToSelected: widget.scrollToSelected,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _inviteMember,
            tooltip: 'Invitar Miembro',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editRoom,
            tooltip: 'Editar Room',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteRoom,
            tooltip: 'Eliminar Room',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_rounded, size: 100),
                const SizedBox(height: 20),
                Text('Detalles de "${widget.room.name}"'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Añadir Hábito'),
                  onPressed: _addHabit,
                ),
                const SizedBox(height: 20),
                if (_petHabits.isEmpty)
                  const Text(
                    'Aquí se mostrarán las pets (hábitos) de este room.',
                  ),
              ],
            ),
          ),
          ..._petHabits.map((habit) {
            return Positioned(
              left: habit.position.dx,
              top: habit.position.dy,
              child: GestureDetector(
                onTap: () => _showHabitoDetails(habit),
                onPanUpdate: (details) {
                  _updatePosition(
                    habit,
                    Offset(
                      (habit.position.dx + details.delta.dx).clamp(
                        0,
                        MediaQuery.of(context).size.width - 150,
                      ),
                      (habit.position.dy + details.delta.dy).clamp(
                        0,
                        MediaQuery.of(context).size.height - 150,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        habit.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.petType.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.personality.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.mechanic.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _editHabit(habit),
                            tooltip: 'Editar Hábito',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () => _deleteHabit(habit),
                            tooltip: 'Eliminar Hábito',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
