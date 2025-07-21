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
      "image": "assets/images/dog.png",
      "price": 100,
      "maxLevel": 10,
      "rewardTable": [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
      "reducedRewardTable": [5, 10, 15, 20, 25, 30, 35, 40, 45, 50],
      "defaultPersonalityId": "calm",
      "mechanicIds": ["feedable", "dressable"],
    },
    {
      "id": "cat",
      "name": "Gato",
      "description": "Curioso y relajado",
      "available": true,
      "image": "assets/images/cat.png",
      "price": 100,
      "maxLevel": 10,
      "rewardTable": [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
      "reducedRewardTable": [5, 10, 15, 20, 25, 30, 35, 40, 45, 50],
      "defaultPersonalityId": "calm",
      "mechanicIds": ["feedable", "dressable"],
    },
  ];

  for (var item in petTypes) {
    await firestore.collection('petTypes').doc(item['id'] as String).set(item);
  }

  // 🟣 PERSONALITIES
  final personalities = [
    {
      "id": "calm",
      "name": "Tranquilo",
      "description": "Sereno y pacífico",
      "moodBoostRate": 1.0,
      "rewardMultiplier": 1.0,
    },
    {
      "id": "playful",
      "name": "Juguetón",
      "description": "Siempre listo para jugar",
      "moodBoostRate": 1.2,
      "rewardMultiplier": 1.1,
    },
    {
      "id": "affectionate",
      "name": "Cariñoso",
      "description": "Le encanta recibir cariño",
      "moodBoostRate": 1.5,
      "rewardMultiplier": 1.3,
    },
    {
      "id": "energetic",
      "name": "Energético",
      "description": "Siempre activo",
      "moodBoostRate": 1.8,
      "rewardMultiplier": 1.5,
    },
    {
      "id": "energetic",
      "name": "Energético",
      "description": "Siempre activo",
      "moodBoostRate": 1.8,
      "rewardMultiplier": 1.5,
    },
    {
      "id": "curious",
      "name": "Curioso",
      "description": "Le encanta explorar",
      "moodBoostRate": 1.3,
      "rewardMultiplier": 1.2,
    },
    {
      "id": "independent",
      "name": "Independiente",
      "description": "Le gusta hacer las cosas a su manera",
      "moodBoostRate": 1.0,
      "rewardMultiplier": 1.0,
    },
  ];

  for (var item in personalities) {
    await firestore
        .collection('personalities')
        .doc(item['id'] as String)
        .set(item);
  }

  // 🔴 STATUSES
  final statuses = [
    {
      "id": "happy",
      "name": "Feliz",
      "type": "base",
      "color": "#FFFF00",
      "description": "Se siente Feliz",
      "minLife": 80,
      "maxLife": 100,
    },
    {
      "id": "normal",
      "name": "Normal",
      "type": "base",
      "color": "#FFFF00",
      "description": "Se siente Normal",
      "minLife": 50,
      "maxLife": 79,
    },
    {
      "id": "sick",
      "name": "Enfermo",
      "type": "base",
      "color": "#FFFF00",
      "description": "Se siente Enfermo",
      "minLife": 0,
      "maxLife": 49,
    },
    {
      "id": "dead",
      "name": "Muerto",
      "type": "base",
      "color": "#FFFF00",
      "description": "Se siente Feliz",
      "minLife": 0,
      "maxLife": 0,
    },
    {
      "id": "excited",
      "name": "Emocionado",
      "type": "temporary",
      "color": "#FFFF00",
      "description": "Se siente Feliz",
      "minLife": 80,
      "maxLife": 100,
    },
    {
      "id": "grateful",
      "name": "Agradecido",
      "type": "temporary",
      "color": "#FFFF00",
      "description": "Se siente Feliz",
      "minLife": 80,
      "maxLife": 100,
    },
    {
      "id": "fancy",
      "name": "Con estilo",
      "type": "temporary",
      "color": "#FFFF00",
      "description": "Se siente Feliz",
      "minLife": 80,
      "maxLife": 100,
    },
  ];

  for (var item in statuses) {
    await firestore.collection('statuses').doc(item['id'] as String).set(item);
  }

  // 🟡 MECHANICS
  final mechanics = [
    {
      "id": "feedable",
      "name": "Se puede alimentar",
      "description": "Puede ser alimentado por el usuario",
    },
    {
      "id": "playable",
      "name": "Se puede jugar",
      "description": "Puede jugar con el usuario",
    },
    {
      "id": "trainable",
      "name": "Se puede entrenar",
      "description": "Puede ser entrenado por el usuario",
    },
    {
      "id": "groomable",
      "name": "Se puede acicalar",
      "description": "Puede ser acicalado por el usuario",
    },
    {
      "id": "walkable",
      "name": "Se puede pasear",
      "description": "Puede ser paseado por el usuario",
    },
    {
      "id": "dressable",
      "name": "Se puede vestir",
      "description": "Puede ser vestido por el usuario",
    },
    {
      "id": "pettable",
      "name": "Se puede acariciar",
      "description": "Puede ser acariciado por el usuario",
    },
    {
      "id": "trainable",
      "name": "Se puede entrenar",
      "description": "Puede ser entrenado por el usuario",
    },
    {
      "id": "playable",
      "name": "Se puede jugar",
      "description": "Puede jugar con el usuario",
    },
  ];

  for (var item in mechanics) {
    await firestore.collection('mechanics').doc(item['id']).set(item);
  }

  // ignore: avoid_print
  print('✅ Datos de configuración cargados');
}
