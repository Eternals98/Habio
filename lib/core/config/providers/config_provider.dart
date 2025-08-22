// lib/core/config/providers/config_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:per_habit/core/config/models/mechanic_model.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/models/status_model.dart';
import 'package:per_habit/core/config/repositories/config_repository.dart';
import 'package:per_habit/core/config/repositories/config_repository_impl.dart';

import 'package:per_habit/core/config/services/pet_type_service.dart';
import 'package:per_habit/core/config/services/item_service.dart'; // inventario (con cantidad)
import 'package:per_habit/core/config/services/shop_service.dart';

import 'package:per_habit/features/inventary/data/models/items_model.dart'; // inventario
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart'; // catálogo

// ⬇️ NUEVO: admin de tienda
import 'package:per_habit/features/store/data/models/shop_item_model.dart';

/// Repo de config (si lo usa otra parte del código)
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(FirebaseFirestore.instance);
});

/// -------------------- PET TYPES --------------------
final petTypeServiceProvider = Provider<PetTypeService>((ref) {
  return PetTypeService(
    db: FirebaseFirestore.instance,
    collectionPath: 'petTypes',
  );
});

final petTypesProvider = FutureProvider<List<PetTypeModel>>((ref) async {
  final svc = ref.read(petTypeServiceProvider);
  return svc.list(available: true);
});

final petTypesStreamProvider = StreamProvider<List<PetTypeModel>>((ref) {
  final svc = ref.watch(petTypeServiceProvider);
  return svc.watch(available: true);
});

/// -------------------- INVENTARIO (por usuario/tienda) --------------------
/// Mantén este si ya lo usas para packs/compra (tiene cantidad).
final itemServiceProvider = Provider<InventoryItemService>((ref) {
  return InventoryItemService(
    db: FirebaseFirestore.instance,
    collectionPath: 'items',
  );
});

final itemsStreamProvider = StreamProvider.autoDispose<List<ItemModel>>((ref) {
  final svc = ref.watch(itemServiceProvider);
  return svc.watch();
});

final itemsByCategoryProvider = StreamProvider.family
    .autoDispose<List<ItemModel>, String>((ref, category) {
      final svc = ref.watch(itemServiceProvider);
      return svc.watch(category: category);
    });

/// -------------------- CATÁLOGO (sin cantidad) --------------------
final catalogItemServiceProvider = Provider<CatalogItemService>((ref) {
  return CatalogItemService(
    db: FirebaseFirestore.instance,
    collectionPath: 'catalogItems',
  );
});

final catalogItemsStreamProvider =
    StreamProvider.autoDispose<List<CatalogItemModel>>((ref) {
      final svc = ref.watch(catalogItemServiceProvider);
      return svc.watch();
    });

final catalogItemsByCategoryProvider = StreamProvider.family
    .autoDispose<List<CatalogItemModel>, String>((ref, category) {
      final svc = ref.watch(catalogItemServiceProvider);
      return svc.watch(category: category);
    });

/// -------------------- ADMIN TIENDA (Shop items) --------------------
/// Estos providers los usa la pestaña "Tienda" del AdminPanel.
final shopAdminServiceProvider = Provider<ShopAdminService>((ref) {
  return ShopAdminService(db: FirebaseFirestore.instance);
});

final shopAdminStreamProvider = StreamProvider<List<ShopItemModel>>((ref) {
  final svc = ref.watch(shopAdminServiceProvider);
  return svc.watchAll(); // asegúrate de que tu servicio tenga este método
});

/// -------------------- OTROS CATÁLOGOS --------------------
final personalitiesProvider = FutureProvider<List<PersonalityModel>>((
  ref,
) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getPersonalities();
});

final mechanicsProvider = FutureProvider<List<MechanicModel>>((ref) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getMechanics();
});

final statusesProvider = FutureProvider<List<StatusModel>>((ref) async {
  final repo = ref.read(configRepositoryProvider);
  return repo.getStatuses();
});
