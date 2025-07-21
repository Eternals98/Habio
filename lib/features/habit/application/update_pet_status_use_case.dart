import 'package:per_habit/core/config/helpers/status_helper.dart';
import 'package:per_habit/core/config/models/status_model.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

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
        position: habit.position, // Ensure to keep the position intacta
      );

      await repository.updateHabit(updated);
    }
  }
}
