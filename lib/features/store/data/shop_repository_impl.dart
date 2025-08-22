import 'package:per_habit/features/inventary/data/models/accesorio_model.dart';
import 'package:per_habit/features/inventary/data/models/alimento_model.dart';
import 'package:per_habit/features/inventary/data/models/decoracion_model.dart';
import 'package:per_habit/features/inventary/data/models/fondo_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/data/models/mascota_model.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/store/data/datasources/shop_datasource.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';
import 'package:per_habit/features/store/domain/entities/repositories.dart/store_repository.dart';
import 'package:per_habit/features/store/domain/entities/shop_item.dart';
import 'package:per_habit/features/user/data/mappers/user_profile_mapper.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopDatasource datasource;

  ShopRepositoryImpl(this.datasource);

  @override
  Stream<UserProfile> watchUser(String userId) {
    return datasource.watchUser(userId).map(UserProfileMapper.fromModel);
  }

  @override
  Stream<List<ShopItem>> watchShopItems() {
    return datasource.watchShopItems().map(
      (models) =>
          models.map((model) {
            return ShopItem(
              id: model.id,
              name: model.name,
              description: model.description,
              icono: model.icono,
              price: model.price,
              isOffer: model.isOffer,
              isBundle: model.isBundle,
              content:
                  model.content.map((itemModel) {
                    if (itemModel is MascotaModel) {
                      return Mascota(
                        id: itemModel.id,
                        nombre: itemModel.nombre,
                        descripcion: itemModel.descripcion,
                        icono: itemModel.icono,
                        cantidad: itemModel.cantidad,
                      );
                    } else if (itemModel is AlimentoModel) {
                      return Alimento(
                        id: itemModel.id,
                        nombre: itemModel.nombre,
                        descripcion: itemModel.descripcion,
                        icono: itemModel.icono,
                        cantidad: itemModel.cantidad,
                      );
                    } else if (itemModel is AccesorioModel) {
                      return Accesorio(
                        id: itemModel.id,
                        nombre: itemModel.nombre,
                        descripcion: itemModel.descripcion,
                        icono: itemModel.icono,
                        cantidad: itemModel.cantidad,
                      );
                    } else if (itemModel is DecoracionModel) {
                      return Decoracion(
                        id: itemModel.id,
                        nombre: itemModel.nombre,
                        descripcion: itemModel.descripcion,
                        icono: itemModel.icono,
                        cantidad: itemModel.cantidad,
                      );
                    } else if (itemModel is FondoModel) {
                      return Fondo(
                        id: itemModel.id,
                        nombre: itemModel.nombre,
                        descripcion: itemModel.descripcion,
                        icono: itemModel.icono,
                        cantidad: itemModel.cantidad,
                      );
                    } else {
                      throw Exception(
                        'Unknown ItemModel type: ${itemModel.runtimeType}',
                      );
                    }
                  }).toList(),
            );
          }).toList(),
    );
  }

  @override
  Future<void> purchaseShopItem(String userId, ShopItem shopItem) async {
    final user = await datasource.getUser(userId);
    if (user.habipoints < shopItem.price) {
      throw Exception('Insufficient HabiPoints');
    }

    final shopItemModel = ShopItemModel(
      id: shopItem.id,
      name: shopItem.name,
      description: shopItem.description,
      icono: shopItem.icono,
      price: shopItem.price,
      isOffer: shopItem.isOffer,
      isBundle: shopItem.isBundle,
      content:
          shopItem.content.map((item) {
            return ItemModel(
              id: item.id,
              nombre: item.nombre,
              descripcion: item.descripcion,
              icono: item.icono,
              cantidad: item.cantidad,
              category:
                  item is Mascota
                      ? 'mascota'
                      : item is Alimento
                      ? 'alimento'
                      : item is Accesorio
                      ? 'accesorio'
                      : item is Decoracion
                      ? 'decoracion'
                      : item is Fondo
                      ? 'fondo'
                      : 'unknown',
            );
          }).toList(),
    );

    await datasource.purchaseShopItem(userId, shopItemModel);
  }

  @override
  Future<void> purchaseHabiPoints(String userId, int amount) async {
    await datasource.purchaseHabiPoints(userId, amount);
  }

  @override
  Future<UserProfile> getUser(String userId) async {
    final userModel = await datasource.getUser(userId);
    return UserProfileMapper.fromModel(userModel);
  }
}
