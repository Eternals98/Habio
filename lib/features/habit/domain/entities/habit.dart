// lib/features/habit/domain/entities/habit.dart
class Habit {
  final String id;
  final String name;
  final String petType;

  /// ✅ Nuevo: personalidad del hábito
  final String personalityId;

  final int goal;
  final int progress;
  final int life;
  final int points;
  final int level;
  final int experience;
  final String baseStatus;
  final String? tempStatus;
  final int streak;
  final DateTime? lastCompletedDate;
  final String roomId;
  final DateTime createdAt;

  /// Frecuencia flexible
  final int frequencyCount; // veces por periodo
  final List<String> scheduleTimes; // HH:mm si 'day', vacío si 'week'
  final String frequencyPeriod; // 'day' | 'week'

  Habit({
    required this.id,
    required this.name,
    required this.petType,
    required this.personalityId, // ✅ obligatorio
    required this.goal,
    required this.progress,
    required this.life,
    required this.points,
    required this.level,
    required this.experience,
    required this.baseStatus,
    required this.tempStatus,
    required this.streak,
    required this.lastCompletedDate,
    required this.roomId,
    required this.createdAt,
    required this.frequencyCount,
    required this.scheduleTimes,
    required this.frequencyPeriod, // ✅ era var; ahora String
  });
}
