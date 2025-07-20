import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository repository;

  CreateHabitUseCase(this.repository);

  Future<void> call(Habit habit) async {
    await repository.createHabit(habit);
  }
}
