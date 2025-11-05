// lib/features/store/data/services/shop_admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';

class ShopAdminService {
  final FirebaseFirestore db;
  final String collectionPath;

  ShopAdminService({required this.db, this.collectionPath = 'shop'});

  Stream<List<ShopItemModel>> watchAll() {
    return db.collection(collectionPath).snapshots().map((snap) {
      return snap.docs
          .map((d) => ShopItemModel.fromMap(d.data(), id: d.id))
          .toList();
    });
  }

  Future<void> create(ShopItemModel model) async {
    await db.collection(collectionPath).doc(model.id).set(model.toMap());
  }

  Future<void> update(String id, ShopItemModel model) async {
    await db.collection(collectionPath).doc(id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    await db.collection(collectionPath).doc(id).delete();
  }
}
