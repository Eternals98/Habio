import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitService {
  final CollectionReference habitsCollection = FirebaseFirestore.instance
      .collection('habits');

  Future<void> createHabit(
    String title,
    String description,
    String frequency,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await habitsCollection.add({
      'userId': user.uid,
      'title': title,
      'description': description,
      'frequency': frequency,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot =
        await habitsCollection
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Puedes agregar el ID si lo necesitas
      return data;
    }).toList();
  }
}
