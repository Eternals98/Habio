// lib/features/habit/application/use_cases/add_experience_to_habit_use_case.dart

import 'package:per_habit/features/habit/application/level_up_habit_use_case.dart';
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
      );
      await repository.updateHabit(updated);
    }
  }
}
