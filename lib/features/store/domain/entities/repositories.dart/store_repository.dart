import 'package:per_habit/features/store/domain/entities/shop_item.dart';
import 'package:per_habit/features/user/domain/entities/user_profile.dart';

abstract class ShopRepository {
  Stream<List<ShopItem>> watchShopItems();
  Future<void> purchaseShopItem(String userId, ShopItem shopItem);
  Future<void> purchaseHabiPoints(String userId, int amount);
  Future<UserProfile> getUser(String userId);

  // 👇 NUEVO
  Stream<UserProfile> watchUser(String userId);
}
