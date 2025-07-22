import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/datasources/inventary_datasource.dart';

import 'package:per_habit/features/inventary/domain/entities/inventory.dart';

import 'package:per_habit/features/inventary/data/inventory_repository_impl.dart';
import 'package:per_habit/features/inventary/domain/repositories/inventary_repository.dart';
import 'package:per_habit/features/inventary/presentation/controllers/inventary_controller.dart';

final inventoryDatasourceProvider = Provider<InventarioDatasourceImpl>((ref) {
  return InventarioDatasourceImpl(FirebaseFirestore.instance);
});

final inventoryRepositoryProvider = Provider<InventarioRepository>((ref) {
  final datasource = ref.read(inventoryDatasourceProvider);
  return InventoryRepositoryImpl(datasource);
});

final inventoryControllerProvider =
    AutoDisposeAsyncNotifierProvider<InventoryController, Inventario>(
      InventoryController.new,
    );
