import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

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
      position: habit.position, // Aseguramos que la posición se mantenga
    );

    await repository.updateHabit(updatedHabit);
    return updatedHabit;
  }
}
