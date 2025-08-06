import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

class MascotaModel extends ItemModel implements Mascota {
  MascotaModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
    required super.category,
  });

  factory MascotaModel.fromMap(Map<String, dynamic> map) {
    return MascotaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      category: map['category'] ?? 'unknown',
    );
  }

  @override
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
}
