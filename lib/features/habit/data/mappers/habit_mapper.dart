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
      frequencyPeriod: model.frequencyPeriod,
    );
  }

  static HabitModel toModel(Habit entity) {
    // ------- Defaults a prueba de nulls -------
    final String baseStatus =
        (entity.baseStatus.isEmpty) ? 'happy' : entity.baseStatus;

    final String tempStatus = entity.tempStatus ?? '';

    final String frequencyPeriod =
        (entity.frequencyPeriod == null || entity.frequencyPeriod!.isEmpty)
            ? 'day'
            : entity.frequencyPeriod!;

    final List<String> scheduleTimes = entity.scheduleTimes;

    // (Si alguno de estos pudiera venir null en tu Entity, también dales default:)
    final String id = entity.id; // asume no nulo
    final String name = entity.name; // asume no nulo
    final String petType = entity.petType; // asume no nulo
    final String roomId = entity.roomId; // asume no nulo

    return HabitModel(
      id: id,
      name: name,
      petType: petType,
      goal: entity.goal,
      progress: entity.progress,
      life: entity.life,
      points: entity.points,
      level: entity.level,
      experience: entity.experience,
      baseStatus: baseStatus, // ✅ nunca null
      tempStatus: tempStatus, // ✅ nunca null
      streak: entity.streak,
      lastCompletedDate: entity.lastCompletedDate,
      roomId: roomId,
      createdAt: entity.createdAt,
      frequencyCount: entity.frequencyCount,
      scheduleTimes: scheduleTimes, // ✅ nunca null
      frequencyPeriod: frequencyPeriod, // ✅ nunca null
    );
  }
}
