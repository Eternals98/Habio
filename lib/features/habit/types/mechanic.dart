enum Mechanic {
  dance('Dance', 'Rhythmic movements and energetic steps to music'),
  sing('Sing', 'Melodic vocal expressions, from soft tunes to powerful songs'),
  workout('WorkOut', 'Physical exercises to build strength and stamina'),
  charm('Charm', 'Captivating gestures and charismatic interactions'),
  posing('Posing', 'Striking confident or dramatic poses for attention');

  final String description;
  final String name;

  const Mechanic(this.name, this.description);

  // Convertir Mechanic a un mapa para Firestore
  String toMap() => name;

  // Crear un Mechanic desde un mapa de Firestore
  static Mechanic fromMap(String value) => Mechanic.values.firstWhere(
    (e) => e.name == value,
    orElse: () => Mechanic.dance, // Valor por defecto
  );
}
