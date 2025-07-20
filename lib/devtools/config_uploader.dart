import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadConfigData() async {
  final firestore = FirebaseFirestore.instance;

  // 🔵 PET TYPES
  final petTypes = [
    {
      "id": "dog",
      "name": "Perro",
      "description": "Fiel y activo",
      "available": true,
    },
    {
      "id": "cat",
      "name": "Gato",
      "description": "Curioso y relajado",
      "available": true,
    },
  ];

  for (var item in petTypes) {
    await firestore.collection('petTypes').doc(item['id'] as String).set(item);
  }

  // 🟣 PERSONALITIES
  final personalities = [
    {"id": "calm", "name": "Tranquilo", "description": "Sereno y pacífico"},
    {"id": "energetic", "name": "Energético", "description": "Siempre activo"},
  ];

  for (var item in personalities) {
    await firestore.collection('personalities').doc(item['id']).set(item);
  }

  // 🔴 STATUSES
  final statuses = [
    {"id": "happy", "name": "Feliz", "type": "base"},
    {"id": "normal", "name": "Normal", "type": "base"},
    {"id": "sick", "name": "Enfermo", "type": "base"},
    {"id": "dead", "name": "Muerto", "type": "base"},
    {"id": "excited", "name": "Emocionado", "type": "temporary"},
    {"id": "grateful", "name": "Agradecido", "type": "temporary"},
    {"id": "fancy", "name": "Con estilo", "type": "temporary"},
  ];

  for (var item in statuses) {
    await firestore.collection('statuses').doc(item['id']).set(item);
  }

  // 🟡 MECHANICS
  final mechanics = [
    {"id": "feedable", "name": "Se puede alimentar"},
    {"id": "dressable", "name": "Se puede vestir"},
  ];

  for (var item in mechanics) {
    await firestore.collection('mechanics').doc(item['id']).set(item);
  }

  print('✅ Datos de configuración cargados');
}
