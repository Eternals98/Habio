class StatusModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final String type; // "core" o "temporary"
  final int? minLife;
  final int? maxLife;

  StatusModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.type,
    this.minLife,
    this.maxLife,
  });

  factory StatusModel.fromMap(String id, Map<String, dynamic> map) {
    return StatusModel(
      id: id.toString(),
      name: map['name'],
      description: map['description'].toString(),
      color: map['color'],
      type: map['type'] ?? 'core',
      minLife: map['minLife'],
      maxLife: map['maxLife'],
    );
  }
}
