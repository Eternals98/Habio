import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

class UpdateHabitUseCase {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.updateHabit(habit);
  }
}
