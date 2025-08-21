import 'package:per_habit/core/config/helpers/status_helper.dart';
import 'package:per_habit/core/config/models/status_model.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

class AddExperienceToHabitUseCase {
  final HabitRepository repository;
  final LevelUpHabitUseCase levelUpHabit;

  AddExperienceToHabitUseCase({
    required this.repository,
    required this.levelUpHabit,
  });

  Future<void> call({
    required Habit habit,
    required int xpGain,
    required int xpToLevelUp,
    required List<int> rewardTable,
    required int maxLevel,
    required bool isFirstUseOfPetType,
  }) async {
    final newXP = habit.experience + xpGain;

    if (newXP >= xpToLevelUp) {
      await levelUpHabit(
        habit: habit,
        rewardTable: rewardTable,
        maxLevel: maxLevel,
        isFirstUseOfPetType: isFirstUseOfPetType,
      );
    } else {
      final updated = Habit(
        id: habit.id,
        name: habit.name,
        petType: habit.petType,
        goal: habit.goal,
        progress: habit.progress,
        life: habit.life,
        points: habit.points,
        level: habit.level,
        experience: newXP,
        baseStatus: habit.baseStatus,
        tempStatus: habit.tempStatus,
        streak: habit.streak,
        lastCompletedDate: habit.lastCompletedDate,
        roomId: habit.roomId,
        createdAt: habit.createdAt,
        frequencyCount: habit.frequencyCount,
        scheduleTimes: habit.scheduleTimes,
        frequencyPeriod: habit.frequencyPeriod,
      );
      await repository.updateHabit(updated);
    }
  }
}

class LevelUpHabitUseCase {
  final HabitRepository repository;

  LevelUpHabitUseCase(this.repository);

  /// [isFirstUseOfPetType]: true si es la primera vez que el usuario usa este tipo de mascota
  Future<Habit> call({
    required Habit habit,
    required List<int> rewardTable,
    required int maxLevel,
    required bool isFirstUseOfPetType,
  }) async {
    if (habit.level >= maxLevel) return habit;

    final newLevel = habit.level + 1;

    // Solo se otorgan monedas si es la primera vez que se usa este tipo de mascota
    final reward =
        isFirstUseOfPetType && rewardTable.length >= newLevel
            ? rewardTable[newLevel - 1]
            : 0;

    final updatedHabit = Habit(
      id: habit.id,
      name: habit.name,
      petType: habit.petType,
      goal: habit.goal,
      progress: habit.progress,
      life: habit.life,
      points: habit.points + reward,
      level: newLevel,
      experience: 0,
      baseStatus: habit.baseStatus,
      tempStatus: "excited",
      streak: habit.streak,
      lastCompletedDate: habit.lastCompletedDate,
      roomId: habit.roomId,
      createdAt: habit.createdAt,
      frequencyCount: habit.frequencyCount,
      scheduleTimes: habit.scheduleTimes,
      frequencyPeriod: habit.frequencyPeriod,
    );

    await repository.updateHabit(updatedHabit);
    return updatedHabit;
  }
}

class ClearTempStatusUseCase {
  final HabitRepository repository;

  ClearTempStatusUseCase(this.repository);

  Future<void> call(Habit habit) async {
    if (habit.tempStatus != null) {
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
        baseStatus: habit.baseStatus,
        tempStatus: null,
        streak: habit.streak,
        lastCompletedDate: habit.lastCompletedDate,
        roomId: habit.roomId,
        createdAt: habit.createdAt,
        frequencyCount: habit.frequencyCount,
        scheduleTimes: habit.scheduleTimes,
        frequencyPeriod: habit.frequencyPeriod,
      );

      await repository.updateHabit(updated);
    }
  }
}

class CreateHabitUseCase {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.createHabit(habit);
  }
}

class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.deleteHabit(habit);
  }
}

class GetHabitsByRoomUseCase {
  final HabitRepository repository;

  GetHabitsByRoomUseCase(this.repository);

  Stream<List<Habit>> call(String roomId) {
    return repository.getHabitsByRoom(roomId);
  }
}

class UpdateHabitUseCase {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.updateHabit(habit);
  }
}

class UpdatePetStatusUseCase {
  final HabitRepository repository;

  UpdatePetStatusUseCase(this.repository);

  Future<void> call(Habit habit, List<StatusModel> allStatuses) async {
    final newBaseStatus = StatusHelper.getBaseStatusFromLife(
      statuses: allStatuses,
      life: habit.life,
    );

    if (newBaseStatus != habit.baseStatus) {
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
        baseStatus: newBaseStatus,
        tempStatus: habit.tempStatus,
        streak: habit.streak,
        lastCompletedDate: habit.lastCompletedDate,
        roomId: habit.roomId,
        createdAt: habit.createdAt,
        frequencyCount: habit.frequencyCount,
        scheduleTimes: habit.scheduleTimes,
        frequencyPeriod: habit.frequencyPeriod,
      );

      await repository.updateHabit(updated);
    }
  }
}
