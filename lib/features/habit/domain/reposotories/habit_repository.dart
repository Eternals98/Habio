import 'package:per_habit/features/habit/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(Habit habit); // ← cambio aquí
  Stream<List<Habit>> getHabitsByRoom(String roomId);
}
