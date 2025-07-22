import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';

class GetInventoryStreamUseCase {
  final InventarioRepository repository;

  GetInventoryStreamUseCase(this.repository);

  Stream<Inventario> call(String userId) {
    return repository.getInventoryByUser(userId);
  }
}
