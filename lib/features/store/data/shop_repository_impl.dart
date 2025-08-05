import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';
import 'package:per_habit/features/store/domain/entities/repositories.dart/store_repository.dart';
import 'package:per_habit/features/store/domain/entities/shop_item.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

class ShopRepositoryImpl implements ShopRepository {
  final FirebaseFirestore firestore;

  ShopRepositoryImpl(this.firestore);

  @override
  Stream<List<ShopItem>> watchShopItems() {
    return firestore
        .collection('shop')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final model = ShopItemModel.fromMap(doc.data());
                return ShopItem(
                  id: model.id,
                  name: model.name,
                  description: model.description,
                  icono: model.icono,
                  price: model.price,
                  isOffer: model.isOffer,
                  isBundle: model.isBundle,
                  content:
                      (doc.data()['content'] as List<dynamic>?)?.map((itemMap) {
                        final category = itemMap['category'] as String;
                        switch (category) {
                          case 'mascota':
                            return Mascota(
                              id: itemMap['id'] ?? '',
                              nombre: itemMap['nombre'] ?? '',
                              descripcion: itemMap['descripcion'] ?? '',
                              icono: itemMap['icono'] ?? '',
                              cantidad: itemMap['cantidad'] ?? 1,
                            );
                          case 'alimento':
                            return Alimento(
                              id: itemMap['id'] ?? '',
                              nombre: itemMap['nombre'] ?? '',
                              descripcion: itemMap['descripcion'] ?? '',
                              icono: itemMap['icono'] ?? '',
                              cantidad: itemMap['cantidad'] ?? 1,
                            );
                          case 'accesorio':
                            return Accesorio(
                              id: itemMap['id'] ?? '',
                              nombre: itemMap['nombre'] ?? '',
                              descripcion: itemMap['descripcion'] ?? '',
                              icono: itemMap['icono'] ?? '',
                              cantidad: itemMap['cantidad'] ?? 1,
                            );
                          case 'decoracion':
                            return Decoracion(
                              id: itemMap['id'] ?? '',
                              nombre: itemMap['nombre'] ?? '',
                              descripcion: itemMap['descripcion'] ?? '',
                              icono: itemMap['icono'] ?? '',
                              cantidad: itemMap['cantidad'] ?? 1,
                            );
                          case 'fondo':
                            return Fondo(
                              id: itemMap['id'] ?? '',
                              nombre: itemMap['nombre'] ?? '',
                              descripcion: itemMap['descripcion'] ?? '',
                              icono: itemMap['icono'] ?? '',
                              cantidad: itemMap['cantidad'] ?? 1,
                            );
                          default:
                            throw Exception('Unknown category: $category');
                        }
                      }).toList() ??
                      [],
                );
              }).toList(),
        );
  }

  @override
  Future<void> purchaseShopItem(String userId, ShopItem shopItem) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    final user = UserProfileModel.fromMap(userDoc.data()!, userId);
    if (user.habipoints < shopItem.price) {
      throw Exception('Insufficient HabiPoints');
    }

    await firestore.runTransaction((transaction) async {
      transaction.update(firestore.collection('users').doc(userId), {
        'habipoints': user.habipoints - shopItem.price,
      });

      for (final item in shopItem.content) {
        final inventoryRef = firestore
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .doc(item.id);
        final existingItem = await inventoryRef.get();
        if (existingItem.exists) {
          transaction.update(inventoryRef, {
            'cantidad': existingItem.data()!['cantidad'] + item.cantidad,
          });
        } else {
          final itemModel = ItemModel(
            id: item.id,
            nombre: item.nombre,
            descripcion: item.descripcion,
            icono: item.icono,
            cantidad: item.cantidad,
          );
          transaction.set(
            inventoryRef,
            itemModel.toMap()..['category'] = _getCategoryFromItem(item),
          );
        }
      }
    });
  }

  @override
  Future<void> purchaseHabiPoints(String userId, int amount) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    final user = UserProfileModel.fromMap(userDoc.data()!, userId);
    await firestore.collection('users').doc(userId).update({
      'habipoints': user.habipoints + amount,
    });
  }

  @override
  Future<UserProfile> getUser(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return UserProfileModel.fromMap(doc.data()!, userId);
  }

  String _getCategoryFromItem(Item item) {
    if (item is Mascota) return 'mascota';
    if (item is Alimento) return 'alimento';
    if (item is Accesorio) return 'accesorio';
    if (item is Decoracion) return 'decoracion';
    if (item is Fondo) return 'fondo';
    throw Exception('Unknown item type: ${item.runtimeType}');
  }
}
