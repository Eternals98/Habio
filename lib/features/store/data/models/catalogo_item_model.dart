// lib/features/inventary/data/models/catalog_item_model.dart
class CatalogItemModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String
  category; // 'fondo' | 'decoracion' | 'alimento' | 'accesorio' | 'mascota'

  CatalogItemModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.category,
  });

  factory CatalogItemModel.fromMap(Map<String, dynamic> map) {
    return CatalogItemModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? '',
      category: map['category'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'category': category,
    };
  }

  CatalogItemModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? category,
  }) {
    return CatalogItemModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      category: category ?? this.category,
    );
  }
}
