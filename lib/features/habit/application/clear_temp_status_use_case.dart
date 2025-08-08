import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

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
      );

      await repository.updateHabit(updated);
    }
  }
}
