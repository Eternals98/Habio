// lib/features/habit/data/models/habit_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String name;
  final String petType;
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
  final Map<String, double> position;

  HabitModel({
    required this.id,
    required this.name,
    required this.petType,
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
    required this.position,
  });

  factory HabitModel.fromMap(String id, Map<String, dynamic> map) {
    return HabitModel(
      id: id,
      name: map['name'],
      petType: map['petType'],
      goal: map['goal'],
      progress: map['progress'],
      life: map['life'],
      points: map['points'],
      level: map['level'],
      experience: map['experience'],
      baseStatus: map['baseStatus'] ?? 'normal',
      tempStatus: map['tempStatus'],
      streak: map['streak'] ?? 0,
      lastCompletedDate:
          map['lastCompletedDate'] != null
              ? (map['lastCompletedDate'] as Timestamp).toDate()
              : null,
      roomId: map['roomId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      frequencyCount: map['frequencyCount'] ?? 1,
      scheduleTimes: List<String>.from(map['scheduleTimes'] ?? []),
      position: Map<String, double>.from(
        map['position'] ?? {'x': 0.0, 'y': 0.0},
      ), 
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'petType': petType,
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
      'position': position,
    };
  }
}
