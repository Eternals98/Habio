enum PetType {
  penguin('Penguin', '/pets/penguin_full.png');

  final String name;
  final String imagePath;

  const PetType(this.name, this.imagePath);

  static PetType fromString(String name) {
    return PetType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => PetType.penguin, // Default to cat if not found
    );
  }
}
