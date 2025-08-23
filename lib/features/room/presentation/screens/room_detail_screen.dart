// lib/features/room/presentation/screens/room_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:flame/cache.dart';

import 'package:per_habit/features/game/habio_game.dart';
import 'package:per_habit/features/game/widgets/message_cache.dart';
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

  // ---- Estado para preload eficiente ----
  HabioGame? _game;
  Future<void>? _preloadFuture;
  String _preloadKey = '';

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

  Future<void> _onDeleteHabit(Habit habit) async {
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

  // ---------- PRECARGAS ----------
  Future<void> _preloadRoomAssets(Images images, List<Habit> habits) async {
    final paths =
        habits
            .map((h) => 'pets/${h.petType.trim().toLowerCase()}_full.png')
            .toSet()
            .toList();
    if (paths.isNotEmpty) {
      await images.loadAll(paths);
    }
  }

  String _computePreloadKey(List<Habit> habits) {
    final petSet =
        habits.map((h) => h.petType.trim().toLowerCase()).toSet().toList()
          ..sort();
    final pidSet =
        habits
            .map((h) => (h.personalityId).trim().toLowerCase())
            .toSet()
            .toList()
          ..sort();
    return '${petSet.join("|")}__${pidSet.join("|")}';
  }

  Future<void> _ensurePreloaded(HabioGame game, List<Habit> habits) async {
    final newKey = _computePreloadKey(habits);
    if (_preloadKey == newKey && _preloadFuture != null) {
      // Ya hay un preload en curso/terminado con la misma clave
      return _preloadFuture!;
    }

    _preloadKey = newKey;
    _preloadFuture = () async {
      // 1) sprites
      await _preloadRoomAssets(game.images, habits);
      // 2) mensajes
      final pids =
          habits.map((h) => (h.personalityId).trim().toLowerCase()).toSet();
      await PersonalityMessagesCache.preload(pids);
    }();

    return _preloadFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsByRoomProvider(widget.roomId));

    return habitsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            appBar: AppBar(title: Text(_room?.name ?? 'Room')),
            body: Center(child: Text("Error cargando hábitos: $e")),
          ),
      data: (habits) {
        // Crea el juego una sola vez y reutilízalo
        _game ??= HabioGame(roomId: widget.roomId, initialHabits: habits);

        return FutureBuilder<void>(
          future: _ensurePreloaded(_game!, habits),
          builder: (context, snap) {
            final body = GameWidget(game: _game!);

            // Si aún precarga, mostramos un overlay liviano
            final overlayLoading =
                (snap.connectionState == ConnectionState.waiting);

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
              body: Stack(
                fit: StackFit.expand,
                children: [
                  body,
                  if (overlayLoading)
                    Container(
                      color: Colors.black.withOpacity(0.06),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
