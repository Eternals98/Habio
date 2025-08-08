// lib/features/habit/presentation/controllers/habit_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';
import 'package:per_habit/features/habit/application/create_habit_use_case.dart';
import 'package:per_habit/features/habit/application/update_habit_use_case.dart';
import 'package:per_habit/features/habit/application/delete_habit_use_case.dart';
import 'package:per_habit/features/habit/application/get_habits_by_room_use_case.dart';
import 'package:per_habit/features/habit/application/add_experience_to_habit_use_case.dart';
import 'package:per_habit/features/habit/application/level_up_habit_use_case.dart';
import 'package:per_habit/features/habit/application/clear_temp_status_use_case.dart';
import 'package:per_habit/features/habit/application/update_pet_status_use_case.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/core/config/helpers/status_helper.dart';
import 'package:per_habit/features/habit/presentation/controllers/habit_provider.dart';

class HabitController extends AutoDisposeAsyncNotifier<List<Habit>> {
  late final HabitRepository _repository;

  late final CreateHabitUseCase _create;
  late final UpdateHabitUseCase _update;
  late final DeleteHabitUseCase _delete;
  late final GetHabitsByRoomUseCase _getByRoom;
  late final LevelUpHabitUseCase _levelUp;
  late final AddExperienceToHabitUseCase _addXP;
  late final ClearTempStatusUseCase _clearTemp;
  late final UpdatePetStatusUseCase _updateStatus;

  bool _isDragging = false; // Bandera para pausar el stream durante el arrastre
  String? _roomId;
  StreamSubscription<List<Habit>>? _subscription;

  @override
  Future<List<Habit>> build() async {
    _repository = ref.read(habitRepositoryProvider);

    _create = CreateHabitUseCase(_repository);
    _update = UpdateHabitUseCase(_repository);
    _delete = DeleteHabitUseCase(_repository);
    _getByRoom = GetHabitsByRoomUseCase(_repository);
    _levelUp = LevelUpHabitUseCase(_repository);
    _addXP = AddExperienceToHabitUseCase(
      repository: _repository,
      levelUpHabit: _levelUp,
    );
    _clearTemp = ClearTempStatusUseCase(_repository);
    _updateStatus = UpdatePetStatusUseCase(_repository);

    // 🔁 Limpieza al autoDispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }

  void setRoom(String roomId) {
    _roomId = roomId;
    ref.keepAlive();
    _listenToHabits();
  }

  void _listenToHabits() {
    if (_roomId == null) return;

    _subscription?.cancel();
    _subscription = _getByRoom(_roomId!).listen((habits) {
      if (!_isDragging) {
        // Solo actualizar si no se está arrastrando
        state = AsyncData(habits);
      }
    });
  }

  void setDragging(bool isDragging) {
    _isDragging = isDragging;
    if (!_isDragging && _roomId != null) {
      _listenToHabits(); // Reanudar stream al soltar
    }
  }

  Future<void> createHabit(Habit habit) async {
    await _create(habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _update(habit);
  }

  Future<void> deleteHabit(Habit habit) async {
    await _delete(habit);
  }

  Future<void> addExperience({
    required Habit habit,
    required int xpGain,
    required int xpToLevelUp,
    required List<int> rewardTable,
    required int maxLevel,
    required bool isFirstUseOfPetType,
  }) async {
    await _addXP.call(
      habit: habit,
      xpGain: xpGain,
      xpToLevelUp: xpToLevelUp,
      rewardTable: rewardTable,
      maxLevel: maxLevel,
      isFirstUseOfPetType: isFirstUseOfPetType,
    );
  }

  Future<void> clearTempStatus(Habit habit) async {
    await _clearTemp(habit);
  }

  Future<void> updateBaseStatus(Habit habit) async {
    final statuses = await ref.read(statusesProvider.future);
    final newStatus = StatusHelper.getBaseStatusFromLife(
      statuses: statuses,
      life: habit.life,
    );

    final updated = Habit(
      id: habit.id,
      name: habit.name,
      petType: habit.petType,
      goal: habit.goal,
      progress: habit.progress,
      life: habit.life,
      points: habit.points,
      level: habit.level,
      experience: habit.experience,
      baseStatus: newStatus,
      tempStatus: habit.tempStatus,
      streak: habit.streak,
      lastCompletedDate: habit.lastCompletedDate,
      roomId: habit.roomId,
      createdAt: habit.createdAt,
      frequencyCount: habit.frequencyCount,
      scheduleTimes: habit.scheduleTimes,
    );

    await _update(updated);
  }

  Future<void> updatePetStatusWithUseCase(Habit habit) async {
    final statuses = await ref.read(statusesProvider.future);
    await _updateStatus.call(habit, statuses);
  }

  Future<void> forceLevelUp(
    Habit habit, {
    required List<int> rewardTable,
    required int maxLevel,
    required bool isFirstUseOfPetType,
  }) async {
    await _levelUp.call(
      habit: habit,
      rewardTable: rewardTable,
      maxLevel: maxLevel,
      isFirstUseOfPetType: isFirstUseOfPetType,
    );
  }
}
