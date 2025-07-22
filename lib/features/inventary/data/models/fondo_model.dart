import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

class FondoModel extends ItemModel implements Fondo {
  FondoModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.icono,
    super.cantidad,
  });

  factory FondoModel.fromMap(Map<String, dynamic> map) {
    return FondoModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      icono: map['icono'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'cantidad': cantidad,
    };
  }
}
