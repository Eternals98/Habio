// lib/features/room/presentation/screens/room_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';

import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';
import 'package:per_habit/features/habit/presentation/screens/create_habit_screen.dart';
import 'package:per_habit/features/habit/presentation/screens/edit_habit_screen.dart';
import 'package:per_habit/features/navigation/presentation/widgets/app_bar_actions.dart';
import 'package:per_habit/features/room/domain/entities/room.dart';
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
    // Nuevo: formateo según periodo
    final period = (habit.frequencyPeriod == 'week') ? 'semana' : 'día';
    final freqLabel = '${habit.frequencyCount} por $period';
    final hasTimes =
        habit.frequencyPeriod != 'week' && habit.scheduleTimes.isNotEmpty;
    final timesLabel = hasTimes ? habit.scheduleTimes.join(', ') : '—';

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
                Text('Estado base: ${habit.baseStatus}'),
                const SizedBox(height: 8),
                Text('Frecuencia: $freqLabel'),
                if (habit.frequencyPeriod != 'week')
                  Text('Horarios: $timesLabel'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onEditHabit(habit);
                },
                child: const Text('Editar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onDeleteHabit(habit);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos la lista de hábitos desde Riverpod
    final habitsAsync = ref.watch(habitsByRoomProvider(widget.roomId));

    return habitsAsync.when(
      data: (habits) {
        final game = HabioGame(
          roomId: widget.roomId,
          initialHabits: habits, // Pasamos los hábitos al juego
          // (Más adelante podemos inyectar callbacks para editar/eliminar desde el juego)
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(_room?.name ?? 'Room'),
            actions: const [AppBarActions()],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _onAddHabit,
            label: const Text('Añadir Hábito'),
            icon: const Icon(Icons.add),
          ),
          body: GameWidget(game: game), // Solo el juego
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error cargando hábitos: $e")),
    );
  }
}
