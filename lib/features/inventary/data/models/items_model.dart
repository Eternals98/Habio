import 'package:per_habit/features/inventary/domain/entities/items.dart';

abstract class ItemModel extends Item {
  ItemModel({required super.id, required super.nombre, super.cantidad});

  factory ItemModel.fromMap(Map<String, dynamic> map, String type) {
    switch (type) {
      case 'mascota':
        return MascotaModel.fromMap(map);
      case 'alimento':
        return AlimentoModel.fromMap(map);
      case 'accesorio':
        return AccesorioModel.fromMap(map);
      case 'decoracion':
        return DecoracionModel.fromMap(map);
      case 'fondo':
        return FondoModel.fromMap(map);
      default:
        throw Exception('Unknown item type: $type');
    }
  }

  Map<String, dynamic> toMap();
}

class MascotaModel extends Mascota implements ItemModel {
  MascotaModel({required super.id, required super.nombre, super.cantidad});

  factory MascotaModel.fromMap(Map<String, dynamic> map) {
    return MascotaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'type': 'mascota',
  };
}

class AlimentoModel extends Alimento implements ItemModel {
  AlimentoModel({required super.id, required super.nombre, super.cantidad});

  factory AlimentoModel.fromMap(Map<String, dynamic> map) {
    return AlimentoModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'type': 'alimento',
  };
}

class AccesorioModel extends Accesorio implements ItemModel {
  AccesorioModel({required super.id, required super.nombre, super.cantidad});

  factory AccesorioModel.fromMap(Map<String, dynamic> map) {
    return AccesorioModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'type': 'accesorio',
  };
}

class DecoracionModel extends Decoracion implements ItemModel {
  DecoracionModel({required super.id, required super.nombre, super.cantidad});

  factory DecoracionModel.fromMap(Map<String, dynamic> map) {
    return DecoracionModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'type': 'decoracion',
  };
}

class FondoModel extends Fondo implements ItemModel {
  FondoModel({required super.id, required super.nombre, super.cantidad});

  factory FondoModel.fromMap(Map<String, dynamic> map) {
    return FondoModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 1,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'cantidad': cantidad,
    'type': 'fondo',
  };
}
