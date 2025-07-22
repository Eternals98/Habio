import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';

class AddItemUseCase {
  final InventarioRepository repository;

  AddItemUseCase(this.repository);

  Future<void> call(Item item, String userId) async {
    // Podrías agregar lógica extra antes o después si quieres
    await repository.createInventoryItem(item, userId);
  }
}
