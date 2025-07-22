import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/inventary/application/agregar_objeto_use_case.dart';
import 'package:per_habit/features/inventary/application/botar_objeto_use_case.dart';
import 'package:per_habit/features/inventary/application/obtener_inventario_use_case.dart';
import 'package:per_habit/features/inventary/domain/entities/inventory.dart';
import 'package:per_habit/features/inventary/domain/entities/items.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';
import 'package:per_habit/features/inventary/presentation/controllers/inventary_provider.dart';

class InventoryController extends AutoDisposeAsyncNotifier<Inventario> {
  late final InventarioRepository _repository;

  late final AddItemUseCase _addItem;
  late final RemoveItemUseCase _removeItem;
  late final GetInventoryStreamUseCase _getStream;

  StreamSubscription<Inventario>? _subscription;
  String? _userId;

  @override
  Future<Inventario> build() async {
    _repository = ref.read(inventoryRepositoryProvider);

    _addItem = AddItemUseCase(_repository);
    _removeItem = RemoveItemUseCase(_repository);
    _getStream = GetInventoryStreamUseCase(_repository);

    ref.onDispose(() => _subscription?.cancel());

    // Estado inicial vacío (userId nulo)
    return Inventario(userId: '');
  }

  void listenToInventory(String userId) {
    if (_userId == userId) return; // Ya está escuchando ese userId

    _userId = userId;

    _subscription?.cancel();

    _subscription = _getStream(userId).listen((inventario) {
      state = AsyncData(inventario);
    });
  }

  Future<void> addItem(Item item) async {
    if (_userId == null) {
      state = AsyncError('UserId no definido', StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    try {
      await _addItem(item, _userId!);
      // El estado será actualizado vía stream
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeItem(String itemId) async {
    if (_userId == null) {
      state = AsyncError('UserId no definido', StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    try {
      await _removeItem(itemId, _userId!);
      // El estado será actualizado vía stream
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
