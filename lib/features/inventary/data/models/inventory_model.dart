import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';

class InventarioModel extends Inventario {
  InventarioModel({
    super.mascotas = const [],
    super.alimentos = const [],
    super.accesorios = const [],
    super.decoraciones = const [],
    super.fondos = const [],
  });

  factory InventarioModel.fromMap(Map<String, dynamic> map) {
    return InventarioModel(
      mascotas:
          (map['mascotas'] as List<dynamic>?)
              ?.map((m) => MascotaModel.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      alimentos:
          (map['alimentos'] as List<dynamic>?)
              ?.map((a) => AlimentoModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      accesorios:
          (map['accesorios'] as List<dynamic>?)
              ?.map((a) => AccesorioModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      decoraciones:
          (map['decoraciones'] as List<dynamic>?)
              ?.map((d) => DecoracionModel.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      fondos:
          (map['fondos'] as List<dynamic>?)
              ?.map((f) => FondoModel.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mascotas': mascotas.map((m) => (m as MascotaModel).toMap()).toList(),
      'alimentos': alimentos.map((a) => (a as AlimentoModel).toMap()).toList(),
      'accesorios':
          accesorios.map((a) => (a as AccesorioModel).toMap()).toList(),
      'decoraciones':
          decoraciones.map((d) => (d as DecoracionModel).toMap()).toList(),
      'fondos': fondos.map((f) => (f as FondoModel).toMap()).toList(),
    };
  }
}
