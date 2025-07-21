// lib/features/habit/data/habit_repository_impl.dart
import 'package:per_habit/features/habit/data/datasources/habit_datasource.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';
import 'package:per_habit/features/habit/domain/reposotories/habit_repository.dart';

import 'mappers/habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitDatasource remoteDatasource;

  HabitRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> createHabit(Habit habit) async {
    final model = HabitMapper.toModel(habit);
    await remoteDatasource.createHabit(model);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final model = HabitMapper.toModel(habit);
    await remoteDatasource.updateHabit(model);
  }

@override
  Future<void> deleteHabit(Habit habit) async {
    await remoteDatasource.deleteHabit(habit.id, habit.roomId);
  }

  @override
  Stream<List<Habit>> getHabitsByRoom(String roomId) {
    return remoteDatasource
        .getHabitsByRoom(roomId)
        .map((models) => models.map(HabitMapper.toEntity).toList());
  }
}
