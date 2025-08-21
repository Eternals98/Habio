enum PetStatus {
  normal('normal'),
  hurt('hurt'),
  dizzy('dizzy'),
  dead('dead');

  final String name;

  const PetStatus(this.name);

  static PetStatus fromString(String name) {
    return PetStatus.values.firstWhere(
      (type) => type.name == name,
      orElse: () => PetStatus.normal, // Default to cat if not found
    );
  }
}
