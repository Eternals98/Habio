import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

class GetHabitsByRoomUseCase {
  final HabitRepository repository;

  GetHabitsByRoomUseCase(this.repository);

  Stream<List<Habit>> call(String roomId) {
    return repository.getHabitsByRoom(roomId);
  }
}
