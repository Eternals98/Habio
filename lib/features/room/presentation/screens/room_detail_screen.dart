// lib/features/room/presentation/screens/room_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/habit/application/habit.services.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
// ignore: unused_import
import 'package:per_habit/features/habit/presentation/controllers/habit_controller.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';
import 'package:per_habit/features/habit/presentation/screens/create_habit_screen.dart';
import 'package:per_habit/features/habit/presentation/screens/edit_habit_screen.dart';
import 'package:flame/game.dart';
import 'package:per_habit/features/navigation/presentation/widgets/app_bar_actions.dart';
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
  }

  Future<void> _loadRoom() async {
    final room = await ref
        .read(roomControllerProvider.notifier)
        .getRoomById(widget.roomId);
    if (mounted) setState(() => _room = room);
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

  @override
  Widget build(BuildContext context) {
    // 🔹 Tomamos la lista de hábitos desde Riverpod
    final habitsAsync = ref.watch(habitsByRoomProvider(widget.roomId));

    return habitsAsync.when(
      data: (habits) {
        final game = HabioGame(
          roomId: widget.roomId,
          initialHabits: habits, // Pasamos los hábitos al juego
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(_room?.name ?? 'Room'),
            actions: [AppBarActions()],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _onAddHabit,
            label: const Text('Añadir Hábito'),
            icon: const Icon(Icons.add),
          ),
          body: GameWidget(game: game), // 🔹 Solo el juego
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error cargando hábitos: $e")),
    );
  }
}
