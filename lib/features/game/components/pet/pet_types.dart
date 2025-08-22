enum PetType {
  penguin("Penguin", 'pets/penguin_full.png'),
  ducky("Ducky", 'pets/ducky_full.png'),
  teddy("Teddy", 'pets/teddy_full.png');

  final String
  label; // 👈 renombré name → label (porque 'name' choca con getter implícito del enum)
  final String imagePath;
  const PetType(this.label, this.imagePath);

  // 🔥 convierte String → PetType de forma dinámica
  static PetType fromString(String s) {
    final normalized = s.trim().toLowerCase();
    return PetType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          normalized, // e.name = "penguin", "ducky", ...
      orElse: () => PetType.teddy, // fallback seguro
    );
  }
}
