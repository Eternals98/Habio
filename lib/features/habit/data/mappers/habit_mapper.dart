// lib/features/habit/data/mappers/habit_mapper.dart
import 'package:per_habit/features/habit/data/models/habit_model.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class HabitMapper {
  static Habit toEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.name,
      petType: model.petType,

      /// ✅ mapear personalityId desde el model
      personalityId: model.personalityId,

      goal: model.goal,
      progress: model.progress,
      life: model.life,
      points: model.points,
      level: model.level,
      experience: model.experience,
      baseStatus: model.baseStatus,
      tempStatus: model.tempStatus,
      streak: model.streak,
      lastCompletedDate: model.lastCompletedDate,
      roomId: model.roomId,
      createdAt: model.createdAt,

      frequencyCount: model.frequencyCount,
      scheduleTimes: model.scheduleTimes,
      frequencyPeriod: model.frequencyPeriod, // 'day' | 'week'
    );
  }

  static HabitModel toModel(Habit entity) {
    // Defaults defensivos
    final String baseStatus =
        (entity.baseStatus.isEmpty) ? 'happy' : entity.baseStatus;

    final String? tempStatus = entity.tempStatus;

    final String frequencyPeriod =
        (entity.frequencyPeriod.isEmpty) ? 'day' : entity.frequencyPeriod;

    final List<String> scheduleTimes = entity.scheduleTimes;

    return HabitModel(
      id: entity.id,
      name: entity.name,
      petType: entity.petType,

      /// ✅ persistir personalityId
      personalityId: entity.personalityId,

      goal: entity.goal,
      progress: entity.progress,
      life: entity.life,
      points: entity.points,
      level: entity.level,
      experience: entity.experience,
      baseStatus: baseStatus,
      tempStatus: tempStatus,
      streak: entity.streak,
      lastCompletedDate: entity.lastCompletedDate,
      roomId: entity.roomId,
      createdAt: entity.createdAt,
      frequencyCount: entity.frequencyCount,
      scheduleTimes: scheduleTimes,
      frequencyPeriod: frequencyPeriod,
    );
  }
}
