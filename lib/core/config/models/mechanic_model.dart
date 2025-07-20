// lib/core/config/models/mechanic_model.dart

class MechanicModel {
  final String id;
  final String name;
  final String description;

  MechanicModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory MechanicModel.fromMap(String id, Map<String, dynamic> map) {
    return MechanicModel(
      id: id,
      name: map['name'],
      description: map['description'],
    );
  }
}
