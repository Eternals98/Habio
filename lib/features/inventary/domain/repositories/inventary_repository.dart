import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

abstract class InventarioRepository {
  Future<void> createInventory(Inventario inventario, String userId);
  Future<void> updateInventory(Inventario inventario);
  Future<void> deleteInventory(String itemId, String userId);

  // Métodos nuevos para manipular items individuales
  Future<void> createInventoryItem(Item item, String userId);
  Future<void> updateInventoryItem(Item item, String userId);
  Future<void> deleteInventoryItem(String itemId, String userId);

  Stream<Inventario> getInventoryByUser(String userId);
}
