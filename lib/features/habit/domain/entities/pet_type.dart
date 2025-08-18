enum PetType {
  cat('cat', '/pets/rojo.png'),
  dog('dog', '/pets/verde.png');

  final String name;
  final String imagePath;

  const PetType(this.name, this.imagePath);

  static PetType fromString(String name) {
    return PetType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => PetType.cat, // Default to cat if not found
    );
  }
}
