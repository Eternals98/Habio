import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/habit/data/models/habit_model.dart';

abstract class HabitDatasource {
  Future<void> createHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String habitId, String roomId);
  Stream<List<HabitModel>> getHabitsByRoom(String roomId);
}

class HabitDatasourceImpl implements HabitDatasource {
  final FirebaseFirestore firestore;

  HabitDatasourceImpl(this.firestore);

  @override
  Future<void> createHabit(HabitModel habit) async {
    final docRef = firestore
        .collection('rooms')
        .doc(habit.roomId)
        .collection('habits')
        .doc(habit.id);

    await docRef.set(habit.toMap());
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final docRef = firestore
        .collection('rooms')
        .doc(habit.roomId)
        .collection('habits')
        .doc(habit.id);

    await docRef.update(habit.toMap());
  }

  @override
  Future<void> deleteHabit(String habitId, String roomId) async {
    final docRef = firestore
        .collection('rooms')
        .doc(roomId)
        .collection('habits')
        .doc(habitId);

    await docRef.delete();
  }

  @override
  Stream<List<HabitModel>> getHabitsByRoom(String roomId) {
    final query = firestore
        .collection('rooms')
        .doc(roomId)
        .collection('habits')
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return HabitModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
