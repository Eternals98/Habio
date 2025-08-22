// lib/core/config/services/pet_type_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';

class PetTypeService {
  PetTypeService({
    FirebaseFirestore? db,
    this.collectionPath = 'petTypes', // ajusta si usas otra colección
  }) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(collectionPath);

  // Crea o actualiza (si ya existe el id)
  Future<String> create({
    String? id, // si no lo pasas, se genera desde name
    required String name,
    required String description,
    required String image, // ruta a tu spritesheet (assets o URL)
    bool available = true,
    int price = 0,
    int maxLevel = 50,
    List<int> rewardTable = const [2, 2, 3, 3, 4, 4, 5, 5],
    List<int> reducedRewardTable = const [1, 1, 2, 2, 3, 3],
    required String defaultPersonalityId,
    List<String> mechanicIds = const ['basic'],
  }) async {
    // --- Validaciones simples ---
    if (name.trim().isEmpty) {
      throw ArgumentError('name no puede estar vacío');
    }
    if (image.trim().isEmpty) {
      throw ArgumentError('image no puede estar vacío');
    }
    if (maxLevel <= 0) {
      throw ArgumentError('maxLevel debe ser > 0');
    }
    if (price < 0) {
      throw ArgumentError('price no puede ser negativo');
    }

    final newId = (id == null || id.trim().isEmpty) ? _slug(name) : id.trim();

    final model = PetTypeModel(
      id: newId,
      name: name.trim(),
      description: description.trim(),
      image: image.trim(),
      available: available,
      price: price,
      maxLevel: maxLevel,
      rewardTable: rewardTable,
      reducedRewardTable: reducedRewardTable,
      defaultPersonalityId: defaultPersonalityId,
      mechanicIds: mechanicIds,
    );

    await _col.doc(newId).set(model.toMap(), SetOptions(merge: false));
    return newId;
  }

  Future<void> update(String id, PetTypeModel model) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('id no puede estar vacío');
    }
    await _col.doc(id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('id no puede estar vacío');
    }
    await _col.doc(id).delete();
  }

  Future<PetTypeModel?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    return PetTypeModel.fromMap(snap.id, snap.data()!);
  }

  // Listado 1-shot
  Future<List<PetTypeModel>> list({bool? available}) async {
    Query<Map<String, dynamic>> q = _col;
    if (available != null) {
      q = q.where('available', isEqualTo: available);
    }
    final snap = await q.get();
    return snap.docs.map((d) => PetTypeModel.fromMap(d.id, d.data())).toList();
  }

  // Stream (útil para el selector)
  Stream<List<PetTypeModel>> watch({bool? available}) {
    Query<Map<String, dynamic>> q = _col;
    if (available != null) {
      q = q.where('available', isEqualTo: available);
    }
    return q.snapshots().map(
      (s) => s.docs.map((d) => PetTypeModel.fromMap(d.id, d.data())).toList(),
    );
  }

  // util
  String _slug(String text) {
    final s =
        text
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s_-]'), '')
            .replaceAll(RegExp(r'\s+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .trim();
    return s.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : s;
  }
}
