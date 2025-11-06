import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/firebase/firebase_providers.dart';
import 'package:per_habit/features/inventary/data/datasources/inventary_datasource.dart';

import 'package:per_habit/features/inventary/domain/entities/inventory.dart';

import 'package:per_habit/features/inventary/data/inventory_repository_impl.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';
import 'package:per_habit/features/inventary/presentation/controllers/inventary_controller.dart';

final inventoryDatasourceProvider = Provider<InventarioDatasourceImpl>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return InventarioDatasourceImpl(firestore);
});

final inventoryRepositoryProvider = Provider<InventarioRepository>((ref) {
  final datasource = ref.read(inventoryDatasourceProvider);
  return InventoryRepositoryImpl(datasource);
});

final inventoryControllerProvider =
    AutoDisposeAsyncNotifierProvider<InventoryController, Inventario>(
      InventoryController.new,
    );
