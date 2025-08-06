import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';
import 'package:per_habit/features/user/data/models/user_profile_model.dart';

abstract class ShopDatasource {
  Stream<List<ShopItemModel>> watchShopItems();
  Future<void> purchaseShopItem(String userId, ShopItemModel shopItem);
  Future<void> purchaseHabiPoints(String userId, int amount);
  Future<UserProfileModel> getUser(String userId);
}

class ShopDatasourceImpl implements ShopDatasource {
  final FirebaseFirestore firestore;

  ShopDatasourceImpl(this.firestore);

  @override
  Stream<List<ShopItemModel>> watchShopItems() {
    return firestore
        .collection('shop')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ShopItemModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  @override
  Future<void> purchaseShopItem(String userId, ShopItemModel shopItem) async {
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
          transaction.set(
            inventoryRef,
            item.toMap()..['category'] = _getCategoryFromItem(item),
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
  Future<UserProfileModel> getUser(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return UserProfileModel.fromMap(doc.data()!, userId);
  }

  String _getCategoryFromItem(ItemModel item) {
    // Since ItemModel has no category, we rely on Firestore data or item type
    // This method assumes the category is handled elsewhere (e.g., in ShopItemModel)
    return 'unknown'; // Placeholder, as ItemModel lacks category
  }
}
