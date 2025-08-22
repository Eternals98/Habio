// lib/features/store/presentation/controllers/shop_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Datasource (con ShopDatasourceImpl)
import 'package:per_habit/features/store/data/datasources/shop_datasource.dart';

// ⚠️ Asegúrate que la ruta de implementación es la REAL en tu proyecto.
// Si tu clase está en data/shop_repository_impl.dart usa este import:
import 'package:per_habit/features/store/data/shop_repository_impl.dart'
    as repo_impl;
import 'package:per_habit/features/store/domain/entities/repositories.dart/store_repository.dart';

// Si la tienes en data/repositories/shop_repository_impl.dart usa este otro:
// import 'package:per_habit/features/store/data/repositories/shop_repository_impl.dart' as repo_impl;

// Interfaz del repositorio de dominio (path correcto)

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
  // Usamos alias para evitar ambigüedad y forzar que encuentre la clase
  return repo_impl.ShopRepositoryImpl(datasource);
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
