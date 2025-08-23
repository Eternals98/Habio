// lib/features/habit/data/models/habit_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String name;
  final String petType;

  // ✅ Nuevo: personalidad guardada en el hábito
  final String personalityId;

  final int goal;
  final int progress;
  final int life;
  final int points;
  final int level;
  final int experience;
  final String roomId;
  final DateTime createdAt;
  final String baseStatus;
  final String? tempStatus;
  final int streak;
  final DateTime? lastCompletedDate;
  final int frequencyCount;
  final List<String> scheduleTimes;
  final String frequencyPeriod;

  HabitModel({
    required this.id,
    required this.name,
    required this.petType,
    required this.personalityId, // <- nuevo obligatorio
    required this.goal,
    required this.progress,
    required this.life,
    required this.points,
    required this.level,
    required this.experience,
    required this.roomId,
    required this.createdAt,
    required this.baseStatus,
    required this.tempStatus,
    required this.streak,
    required this.lastCompletedDate,
    required this.frequencyCount,
    required this.scheduleTimes,
    required this.frequencyPeriod,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HabitModel(
      id: doc.id,
      name: data['name'] ?? '',
      petType: data['petType'] ?? 'default',
      personalityId: data['personalityId'] ?? 'happy', // ✅ fallback
      goal: data['goal'] ?? 1,
      progress: data['progress'] ?? 0,
      life: data['life'] ?? 100,
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
      experience: data['experience'] ?? 0,
      baseStatus: data['baseStatus'] ?? 'normal',
      tempStatus: data['tempStatus'],
      streak: data['streak'] ?? 0,
      lastCompletedDate:
          data['lastCompletedDate'] != null
              ? (data['lastCompletedDate'] as Timestamp).toDate()
              : null,
      roomId: data['roomId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequencyCount: (data['frequencyCount'] as num?)?.toInt() ?? 1,
      scheduleTimes: List<String>.from(data['scheduleTimes'] ?? const []),
      frequencyPeriod: data['frequencyPeriod'] ?? 'day', // ✅ fix
    );
  }

  factory HabitModel.fromMap(String id, Map<String, dynamic> map) {
    return HabitModel(
      id: id,
      name: map['name'] ?? '',
      petType: map['petType'] ?? 'default',
      personalityId: map['personalityId'] ?? 'happy', // ✅
      goal: map['goal'] ?? 1,
      progress: map['progress'] ?? 0,
      life: map['life'] ?? 100,
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      baseStatus: map['baseStatus'] ?? 'normal',
      tempStatus: map['tempStatus'],
      streak: map['streak'] ?? 0,
      lastCompletedDate:
          map['lastCompletedDate'] != null
              ? (map['lastCompletedDate'] as Timestamp).toDate()
              : null,
      roomId: map['roomId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      frequencyCount: (map['frequencyCount'] as num?)?.toInt() ?? 1,
      scheduleTimes: List<String>.from(map['scheduleTimes'] ?? const []),
      frequencyPeriod: map['frequencyPeriod'] ?? 'day', // ✅ fix (estaba mal)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'petType': petType,
      'personalityId': personalityId, // ✅ nuevo campo persistido
      'goal': goal,
      'progress': progress,
      'life': life,
      'points': points,
      'level': level,
      'experience': experience,
      'baseStatus': baseStatus,
      'tempStatus': tempStatus,
      'streak': streak,
      'lastCompletedDate':
          lastCompletedDate != null
              ? Timestamp.fromDate(lastCompletedDate!)
              : null,
      'roomId': roomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'frequencyCount': frequencyCount,
      'scheduleTimes': scheduleTimes,
      'frequencyPeriod': frequencyPeriod, // ✅ faltaba
    };
  }
}
