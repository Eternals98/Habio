// lib/core/config/providers/config_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
      return svc.watch().map(
        (items) => items.where((it) => it.category == category).toList(),
      );
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

// -------------------- RULETA (spins + pool desde catálogo) --------------------

final userInventoryStreamProvider =
    StreamProvider.family<List<ItemModel>, String>((ref, uid) {
      final db = FirebaseFirestore.instance;
      return db
          .collection('users')
          .doc(uid)
          .collection('inventory')
          .snapshots()
          .map(
            (qs) =>
                qs.docs.map((d) {
                  final data = d.data();
                  return ItemModel(
                    id: data['id'] as String,
                    nombre: data['nombre'] as String? ?? '',
                    descripcion: data['descripcion'] as String? ?? '',
                    icono: data['icono'] as String? ?? '',
                    cantidad: (data['cantidad'] as num?)?.toInt() ?? 0,
                    category: data['category'] as String? ?? '',
                  );
                }).toList(),
          );
    });

final _dbProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

String _todayYmd() => DateFormat('yyyy-MM-dd').format(DateTime.now());

/// Meta de ruleta del usuario (lastSpinYmd, extraSpins)
final userWheelMetaProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, uid) async {
      final db = ref.read(_dbProvider);
      final snap =
          await db
              .collection('users')
              .doc(uid)
              .collection('wheel')
              .doc('meta')
              .get();
      return snap.data() ?? {};
    });

/// ✅ availableSpinsFromMetaProvider(String uid) -> Future<int>
final availableSpinsFromMetaProvider = FutureProvider.family<int, String>((
  ref,
  uid,
) async {
  final meta = await ref.watch(userWheelMetaProvider(uid).future);
  final lastSpinYmd = (meta['lastSpinYmd'] as String?) ?? '';
  final extraSpins = (meta['extraSpins'] as num?)?.toInt() ?? 0;
  final daily = (lastSpinYmd == _todayYmd()) ? 0 : 1; // 1 diario no acumulable
  return daily + extraSpins;
});

/// ✅ consumeOneSpinProvider(String uid) -> Future<void>
/// Consume primero un extraSpin si hay; si no, usa el diario (si aún no usado hoy).
final consumeOneSpinProvider = FutureProvider.family<void, String>((
  ref,
  uid,
) async {
  final db = ref.read(_dbProvider);
  final doc = db.collection('users').doc(uid).collection('wheel').doc('meta');

  await db.runTransaction((tx) async {
    final snap = await tx.get(doc);
    final data = snap.data() ?? {};
    final today = _todayYmd();
    final last = (data['lastSpinYmd'] as String?) ?? '';
    int extra = (data['extraSpins'] as num?)?.toInt() ?? 0;

    if (extra > 0) {
      extra -= 1;
      tx.set(doc, {'extraSpins': extra}, SetOptions(merge: true));
    } else {
      if (last == today) {
        throw StateError('NO_SPINS_AVAILABLE');
      }
      tx.set(doc, {'lastSpinYmd': today}, SetOptions(merge: true));
    }
  });
});

/// ✅ wheelPrizePoolProvider -> Stream<List<CatalogItemModel>>
/// Filtra catálago por wheelEnabled && wheelWeight > 0
final wheelPrizePoolProvider = StreamProvider<List<CatalogItemModel>>((ref) {
  // Usamos el .stream del StreamProvider existente para encadenar el mapa
  return ref.watch(catalogItemsStreamProvider.stream).map((items) {
    return items
        .where((c) => c.wheelEnabled == true && (c.wheelWeight) > 0)
        .toList();
  });
});

/// ✅ grantCatalogPrizeProvider(({String uid, String itemId})) -> Future<void>
/// Incrementa en +1 el ítem en el inventario del usuario. Trae los datos del
/// ítem de catálogo para guardarlos (nombre, icono, etc.) si es la primera vez.
final grantCatalogPrizeProvider = FutureProvider.family<
  void,
  ({String uid, String itemId})
>((ref, args) async {
  final db = ref.read(_dbProvider);

  // Leemos el item del catálogo (para tener nombre, icono, category…)
  final catSnap = await db.collection('catalogItems').doc(args.itemId).get();
  if (!catSnap.exists) {
    throw StateError('CATALOG_ITEM_NOT_FOUND');
  }
  final item = catSnap.data()!;

  final invDoc = db
      .collection('users')
      .doc(args.uid)
      .collection('inventory')
      .doc(args.itemId);

  await db.runTransaction((tx) async {
    final snap = await tx.get(invDoc);
    final curr = (snap.data()?['cantidad'] as num?)?.toInt() ?? 0;

    tx.set(invDoc, {
      'id': args.itemId,
      'nombre': item['nombre'] ?? '',
      'descripcion': item['descripcion'] ?? '',
      'icono': item['icono'] ?? '',
      'category': item['category'] ?? '',
      'cantidad': curr + 1,
    }, SetOptions(merge: true));
  });
});
