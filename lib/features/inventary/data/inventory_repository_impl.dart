import 'package:per_habit/features/inventary/data/datasources/inventary_datasource.dart';
import 'package:per_habit/features/inventary/data/mappers/inventary_mapper.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';
import 'package:per_habit/features/inventary/data/mappers/item_mapper.dart';

class InventoryRepositoryImpl implements InventarioRepository {
  final InventarioDatasource remoteDatasource;

  InventoryRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> saveInventory(Inventario inventario) async {
    final model = InventarioMapper.toModel(inventario);
    await remoteDatasource.saveInventory(model);
  }

  @override
  Future<void> replaceInventory(Inventario inventario) async {
    final model = InventarioMapper.toModel(inventario);
    await remoteDatasource.replaceInventory(model);
  }

  @override
  Future<void> deleteInventory(String itemId, String userId) async {
    await remoteDatasource.deleteItem(itemId, userId);
  }

  @override
  Future<void> createInventoryItem(Item item, String userId) async {
    final itemModel = ItemMapper.toModel(item);
    await remoteDatasource.createItem(itemModel, userId);
  }

  @override
  Future<void> updateInventoryItem(Item item, String userId) async {
    final itemModel = ItemMapper.toModel(item);
    await remoteDatasource.updateItem(itemModel, userId);
  }

  @override
  Future<void> deleteInventoryItem(String itemId, String userId) async {
    await remoteDatasource.deleteItem(itemId, userId);
  }

  @override
  Stream<Inventario> getInventoryByUser(String userId) {
    return remoteDatasource
        .getInventoryByUser(userId)
        .map(InventarioMapper.toEntity);
  }
}
