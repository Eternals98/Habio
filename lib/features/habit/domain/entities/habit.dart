class Habit {
  final String id;
  final String name;
  final String petType;
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

  final int frequencyCount; // ← NUEVO
  final List<String> scheduleTimes;

  var frequencyPeriod; // ← NUEVO

  Habit({
    required this.id,
    required this.name,
    required this.petType,
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
    required String frequencyPeriod,
  });
}
