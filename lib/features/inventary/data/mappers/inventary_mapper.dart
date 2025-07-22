import 'package:per_habit/features/inventary/data/models/inventory_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

class InventarioMapper {
  static Inventario toEntity(InventarioModel model) {
    return Inventario(
      mascotas: model.mascotas.map((m) => m).toList(),
      alimentos: model.alimentos.map((a) => a).toList(),
      accesorios: model.accesorios.map((a) => a).toList(),
      decoraciones: model.decoraciones.map((d) => d).toList(),
      fondos: model.fondos.map((f) => f).toList(),
    );
  }

  static InventarioModel toModel(Inventario entity) {
    return InventarioModel(
      mascotas:
          entity.mascotas
              .map(
                (m) => MascotaModel(
                  id: m.id,
                  nombre: m.nombre,
                  cantidad: m.cantidad,
                ),
              )
              .toList(),
      alimentos:
          entity.alimentos
              .map(
                (a) => AlimentoModel(
                  id: a.id,
                  nombre: a.nombre,
                  cantidad: a.cantidad,
                ),
              )
              .toList(),
      accesorios:
          entity.accesorios
              .map(
                (a) => AccesorioModel(
                  id: a.id,
                  nombre: a.nombre,
                  cantidad: a.cantidad,
                ),
              )
              .toList(),
      decoraciones:
          entity.decoraciones
              .map(
                (d) => DecoracionModel(
                  id: d.id,
                  nombre: d.nombre,
                  cantidad: d.cantidad,
                ),
              )
              .toList(),
      fondos:
          entity.fondos
              .map(
                (f) => FondoModel(
                  id: f.id,
                  nombre: f.nombre,
                  cantidad: f.cantidad,
                ),
              )
              .toList(),
    );
  }
}

class ItemMapper {
  static Item toEntity(Map<String, dynamic> map, String type) {
    switch (type) {
      case 'mascota':
        return Mascota(
          id: map['id'] ?? '',
          nombre: map['nombre'] ?? '',
          cantidad: map['cantidad'] ?? 1,
        );
      case 'alimento':
        return Alimento(
          id: map['id'] ?? '',
          nombre: map['nombre'] ?? '',
          cantidad: map['cantidad'] ?? 1,
        );
      case 'accesorio':
        return Accesorio(
          id: map['id'] ?? '',
          nombre: map['nombre'] ?? '',
          cantidad: map['cantidad'] ?? 1,
        );
      case 'decoracion':
        return Decoracion(
          id: map['id'] ?? '',
          nombre: map['nombre'] ?? '',
          cantidad: map['cantidad'] ?? 1,
        );
      case 'fondo':
        return Fondo(
          id: map['id'] ?? '',
          nombre: map['nombre'] ?? '',
          cantidad: map['cantidad'] ?? 1,
        );
      default:
        throw Exception('Unknown item type: $type');
    }
  }

  static Map<String, dynamic> toModel(Item entity) {
    return {
      'id': entity.id,
      'nombre': entity.nombre,
      'cantidad': entity.cantidad,
      'type': _getType(entity),
    };
  }

  static String _getType(Item entity) {
    if (entity is Mascota) return 'mascota';
    if (entity is Alimento) return 'alimento';
    if (entity is Accesorio) return 'accesorio';
    if (entity is Decoracion) return 'decoracion';
    if (entity is Fondo) return 'fondo';
    throw Exception('Unknown item entity type');
  }
}
