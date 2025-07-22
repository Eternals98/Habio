import 'package:per_habit/features/inventary/data/datasources/inventary_datasource.dart';
import 'package:per_habit/features/inventary/data/mappers/inventary_mapper.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';

class InventoryRepositoryImpl implements InventarioRepository {
  final InventarioDatasource remoteDatasource;

  InventoryRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> createInventory(Inventario inventario, String userId) async {
    final model = InventarioMapper.toModel(inventario);
    await remoteDatasource.createItem(model as ItemModel, inventario.userId);
  }

  @override
  Future<void> updateInventory(Inventario inventario) async {
    final model = InventarioMapper.toModel(inventario);
    await remoteDatasource.updateItem(model as ItemModel, inventario.userId);
  }

  @override
  Future<void> deleteInventory(String itemId, String userId) async {
    await remoteDatasource.deleteItem(itemId, userId);
  }

  @override
  Future<void> createInventoryItem(Item item, String userId) async {
    await remoteDatasource.createItem(item as ItemModel, userId);
  }

  @override
  Future<void> updateInventoryItem(Item item, String userId) async {
    await remoteDatasource.updateItem(item as ItemModel, userId);
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
