import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

class ItemMapper {
  // Modelo -> Entidad
  static Item toEntity(ItemModel model) {
    if (model is MascotaModel) {
      return Mascota(
        id: model.id,
        nombre: model.nombre,
        descripcion: model.descripcion,
        icono: model.icono,
        cantidad: model.cantidad,
      );
    } else if (model is AlimentoModel) {
      return Alimento(
        id: model.id,
        nombre: model.nombre,
        descripcion: model.descripcion,
        icono: model.icono,
        cantidad: model.cantidad,
      );
    } else if (model is AccesorioModel) {
      return Accesorio(
        id: model.id,
        nombre: model.nombre,
        descripcion: model.descripcion,
        icono: model.icono,
        cantidad: model.cantidad,
      );
    } else if (model is DecoracionModel) {
      return Decoracion(
        id: model.id,
        nombre: model.nombre,
        descripcion: model.descripcion,
        icono: model.icono,
        cantidad: model.cantidad,
      );
    } else if (model is FondoModel) {
      return Fondo(
        id: model.id,
        nombre: model.nombre,
        descripcion: model.descripcion,
        icono: model.icono,
        cantidad: model.cantidad,
      );
    } else {
      throw Exception('Unknown ItemModel type');
    }
  }

  // Entidad -> Modelo
  static ItemModel toModel(Item entity) {
    if (entity is Mascota) {
      return MascotaModel(
        id: entity.id,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        icono: entity.icono,
        cantidad: entity.cantidad,
      );
    } else if (entity is Alimento) {
      return AlimentoModel(
        id: entity.id,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        icono: entity.icono,
        cantidad: entity.cantidad,
      );
    } else if (entity is Accesorio) {
      return AccesorioModel(
        id: entity.id,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        icono: entity.icono,
        cantidad: entity.cantidad,
      );
    } else if (entity is Decoracion) {
      return DecoracionModel(
        id: entity.id,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        icono: entity.icono,
        cantidad: entity.cantidad,
      );
    } else if (entity is Fondo) {
      return FondoModel(
        id: entity.id,
        nombre: entity.nombre,
        descripcion: entity.descripcion,
        icono: entity.icono,
        cantidad: entity.cantidad,
      );
    } else {
      throw Exception('Unknown Item entity type');
    }
  }
}
