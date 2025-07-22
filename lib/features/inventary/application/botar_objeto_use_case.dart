import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';

class RemoveItemUseCase {
  final InventarioRepository repository;

  RemoveItemUseCase(this.repository);

  Future<void> call(String itemId, String userId) async {
    await repository.deleteInventoryItem(itemId, userId);
  }
}
