// lib/features/room/presentation/screens/room_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
// ignore: unused_import
import 'package:per_habit/features/habit/presentation/controllers/habit_controller.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';
import 'package:per_habit/features/habit/presentation/screens/create_habit_screen.dart';
import 'package:per_habit/features/habit/presentation/screens/edit_habit_screen.dart';
import 'package:per_habit/features/habit/presentation/widgets/pet_habit_canvas.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
// ignore: unused_import
import 'package:per_habit/features/room/presentation/controllers/room_controller.dart';
import 'package:per_habit/features/room/presentation/controllers/room_providers.dart';

class RoomDetailsScreen extends ConsumerStatefulWidget {
  final String roomId;

  const RoomDetailsScreen({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends ConsumerState<RoomDetailsScreen> {
  Room? _room;

  @override
  void initState() {
    super.initState();
    _loadRoom();
    ref.read(habitControllerProvider.notifier).setRoom(widget.roomId);
  }

  Future<void> _loadRoom() async {
    final room = await ref
        .read(roomControllerProvider.notifier)
        .getRoomById(widget.roomId);
    setState(() => _room = room);
  }

  void _onAddHabit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateHabitScreen(roomId: widget.roomId),
      ),
    );
  }

  void _onEditHabit(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditHabitScreen(habit: habit)),
    );
  }

  void _onDeleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Eliminar hábito?'),
            content: Text('¿Estás seguro de eliminar "${habit.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ref.read(habitControllerProvider.notifier).deleteHabit(habit);
    }
  }

  void _onShowHabitDetails(Habit habit) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(habit.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mascota: ${habit.petType}'),
                Text('Nivel: ${habit.level}'),
                Text('Vida: ${habit.life}'),
                Text('Estado: ${habit.baseStatus}'),
                Text('Veces al día: ${habit.frequencyCount}'),
                Text('Horarios: ${habit.scheduleTimes.join(', ')}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  void _onEditRoom() async {
    final nameController = TextEditingController(text: _room?.name ?? '');

    final updatedName = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar nombre de la Room'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, nameController.text.trim()),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );

    if (updatedName != null && updatedName.isNotEmpty && _room != null) {
      final updatedRoom = _room!.copyWith(name: updatedName);
      await ref
          .read(roomControllerProvider.notifier)
          .rename(updatedRoom.id, updatedName);
      setState(() => _room = updatedRoom);
    }
  }

  void _onHabitPositionChanged(Habit habit, Map<String, double> newPosition) {
    ref
        .read(habitControllerProvider.notifier)
        .updateHabitPosition(habit, newPosition);
  }

  void _onInviteMember() async {
    final emailController = TextEditingController();

    final invitedEmail = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Invitar por correo'),
            content: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, emailController.text.trim()),
                child: const Text('Invitar'),
              ),
            ],
          ),
    );

    if (invitedEmail != null && invitedEmail.isNotEmpty) {
      await ref
          .read(roomControllerProvider.notifier)
          .invite(widget.roomId, invitedEmail);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitación enviada')));
      }
    }
  }

  void _onDeleteRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Eliminar Room?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ref.read(roomControllerProvider.notifier).deleteRoom(widget.roomId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_room?.name ?? 'Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invitar miembro',
            onPressed: () {
              _onInviteMember();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar room',
            onPressed: () {
              _onEditRoom();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar room',
            onPressed: () {
              _onDeleteRoom();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddHabit,
        label: const Text('Añadir Hábito'),
        icon: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        data: (habits) {
          return PetHabitCanvas(
            habits: habits,
            onEdit: _onEditHabit,
            onDelete: _onDeleteHabit,
            onTap: _onShowHabitDetails,
            onPositionChanged: _onHabitPositionChanged,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error cargando hábitos: $e')),
      ),
    );
  }
}
