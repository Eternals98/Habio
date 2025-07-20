import 'package:per_habit/features/habit/data/models/habit_model.dart';
import 'package:per_habit/features/habit/domain/entities/habit.dart';

class HabitMapper {
  static Habit toEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.name,
      petType: model.petType,
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
      position: model.position,
    );
  }

  static HabitModel toModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      petType: entity.petType,
      goal: entity.goal,
      progress: entity.progress,
      life: entity.life,
      points: entity.points,
      level: entity.level,
      experience: entity.experience,
      baseStatus: entity.baseStatus,
      tempStatus: entity.tempStatus,
      streak: entity.streak,
      lastCompletedDate: entity.lastCompletedDate,
      roomId: entity.roomId,
      createdAt: entity.createdAt,
      frequencyCount: entity.frequencyCount,
      scheduleTimes: entity.scheduleTimes,
      position: entity.position,
    );
  }
}
