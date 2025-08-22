class CatalogItemModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String
  category; // 'fondo' | 'decoracion' | 'alimento' | 'accesorio' | 'mascota'

  // ⬇️ NUEVO
  final bool wheelEnabled; // participa en la ruleta
  final int wheelWeight; // peso/probabilidad relativa (>=1)

  CatalogItemModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.category,
    this.wheelEnabled = false,
    this.wheelWeight = 1,
  });

  factory CatalogItemModel.fromMap(Map<String, dynamic> map) {
    return CatalogItemModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? '',
      category: map['category'] ?? 'unknown',
      wheelEnabled: map['wheelEnabled'] as bool? ?? false,
      wheelWeight: (map['wheelWeight'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'category': category,
      'wheelEnabled': wheelEnabled,
      'wheelWeight': wheelWeight,
    };
  }

  CatalogItemModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? category,
    bool? wheelEnabled,
    int? wheelWeight,
  }) {
    return CatalogItemModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      category: category ?? this.category,
      wheelEnabled: wheelEnabled ?? this.wheelEnabled,
      wheelWeight: wheelWeight ?? this.wheelWeight,
    );
  }
}
