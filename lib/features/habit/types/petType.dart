// ignore_for_file: file_names

enum PetType {
  leon('Majestic and powerful lion'),
  dragon('Mythical and fiery dragon'),
  perro('Loyal and energetic dog'),
  gato('Graceful and independent cat'),
  cactus('Prickly and resilient plant'),
  pez('Serene and aquatic fish');

  final String description;

  const PetType(this.description);

  // Convertir PetType a un mapa para Firestore
  String toMap() => name;

  // Crear un PetType desde un mapa de Firestore
  static PetType fromMap(String value) => PetType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => PetType.leon, // Valor por defecto
  );
}
