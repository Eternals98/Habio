import 'package:per_habit/features/inventary/data/models/inventory_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'item_mapper.dart';

class InventarioMapper {
  // Modelo -> Entidad
  static Inventario toEntity(InventarioModel model) {
    return Inventario(
      userId: model.userId,
      mascotas:
          model.mascotas
              .map((m) => ItemMapper.toEntity(m as ItemModel) as Mascota)
              .toList(),
      alimentos:
          model.alimentos
              .map((a) => ItemMapper.toEntity(a as ItemModel) as Alimento)
              .toList(),
      accesorios:
          model.accesorios
              .map((a) => ItemMapper.toEntity(a as ItemModel) as Accesorio)
              .toList(),
      decoraciones:
          model.decoraciones
              .map((d) => ItemMapper.toEntity(d as ItemModel) as Decoracion)
              .toList(),
      fondos:
          model.fondos
              .map((f) => ItemMapper.toEntity(f as ItemModel) as Fondo)
              .toList(),
    );
  }

  // Entidad -> Modelo
  static InventarioModel toModel(Inventario entity) {
    return InventarioModel(
      userId: entity.userId,
      mascotas:
          entity.mascotas
              .map((m) => ItemMapper.toModel(m) as MascotaModel)
              .toList(),
      alimentos:
          entity.alimentos
              .map((a) => ItemMapper.toModel(a) as AlimentoModel)
              .toList(),
      accesorios:
          entity.accesorios
              .map((a) => ItemMapper.toModel(a) as AccesorioModel)
              .toList(),
      decoraciones:
          entity.decoraciones
              .map((d) => ItemMapper.toModel(d) as DecoracionModel)
              .toList(),
      fondos:
          entity.fondos
              .map((f) => ItemMapper.toModel(f) as FondoModel)
              .toList(),
    );
  }
}
