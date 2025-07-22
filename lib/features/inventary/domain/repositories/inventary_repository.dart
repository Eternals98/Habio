import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';

abstract class InventarioRepository {
  Future<void> createItem(Item item, String userId);
  Future<void> updateItem(Item item, String userId);
  Future<void> deleteItem(Item item, String userId);
  Stream<List<Inventario>> getInventoriesByUser(String userId);
}
