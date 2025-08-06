class ItemModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int cantidad;
  final String category;

  ItemModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    this.cantidad = 1,
    required this.category,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      category: map['category'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'cantidad': cantidad,
      'category': category,
    };
  }

  ItemModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? icono,
    int? cantidad,
    String? category,
  }) {
    return ItemModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      cantidad: cantidad ?? this.cantidad,
      category: category ?? this.category,
    );
  }
}
