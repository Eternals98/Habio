import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/store/data/datasources/shop_datasource.dart';
import 'package:per_habit/features/store/data/shop_repository_impl.dart';
import 'package:per_habit/features/store/domain/entities/repositories.dart/store_repository.dart';
import 'package:per_habit/features/store/domain/entities/shop_item.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

class PurchaseShopItemParams {
  final String userId;
  final ShopItem shopItem;

  PurchaseShopItemParams(this.userId, this.shopItem);
}

class PurchaseHabiPointsParams {
  final String userId;
  final int amount;

  PurchaseHabiPointsParams(this.userId, this.amount);
}

final shopDatasourceProvider = Provider<ShopDatasource>((ref) {
  return ShopDatasourceImpl(FirebaseFirestore.instance);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final datasource = ref.read(shopDatasourceProvider);
  return ShopRepositoryImpl(datasource);
});

final shopItemsStreamProvider = StreamProvider<List<ShopItem>>((ref) {
  final repository = ref.read(shopRepositoryProvider);
  return repository.watchShopItems();
});

final userProvider = FutureProvider.family<UserProfile, String>((
  ref,
  userId,
) async {
  final repository = ref.read(shopRepositoryProvider);
  return repository.getUser(userId);
});

final purchaseShopItemProvider =
    FutureProvider.family<void, PurchaseShopItemParams>((ref, params) async {
      final repository = ref.read(shopRepositoryProvider);
      await repository.purchaseShopItem(params.userId, params.shopItem);
    });

final purchaseHabiPointsProvider =
    FutureProvider.family<void, PurchaseHabiPointsParams>((ref, params) async {
      final repository = ref.read(shopRepositoryProvider);
      await repository.purchaseHabiPoints(params.userId, params.amount);
    });
