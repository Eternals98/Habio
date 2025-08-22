import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
// ⬅️ corrige el import del catálogo (era catalogo_item_model.dart)
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

class InventoryItemService {
  InventoryItemService({FirebaseFirestore? db, this.collectionPath = 'items'})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String collectionPath;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(collectionPath);

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

  Future<String> create({
    String? id,
    required String nombre,
    required String descripcion,
    required String icono,
    int cantidad = 1,
    required String category,
  }) async {
    if (nombre.trim().isEmpty) throw ArgumentError('nombre vacío');
    if (icono.trim().isEmpty) throw ArgumentError('icono vacío');
    if (category.trim().isEmpty) throw ArgumentError('category vacía');

    final newId = (id == null || id.trim().isEmpty) ? _slug(nombre) : id.trim();

    final model = ItemModel(
      id: newId,
      nombre: nombre.trim(),
      descripcion: descripcion.trim(),
      icono: icono.trim(),
      cantidad: cantidad,
      category: category.trim(),
    );

    await _col.doc(newId).set(model.toMap());
    return newId;
  }

  Future<void> update(String id, ItemModel model) async {
    if (id.trim().isEmpty) throw ArgumentError('id vacío');
    await _col.doc(id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) throw ArgumentError('id vacío');
    await _col.doc(id).delete();
  }

  Future<ItemModel?> getById(String id) async {
    final d =
        await _col.doc(id).get(); // DocumentSnapshot<Map<String, dynamic>>
    if (!d.exists || d.data() == null) return null;
    final data = d.data()!..['id'] = d.id;
    return ItemModel.fromMap(data);
  }

  Future<List<ItemModel>> list({String? category}) async {
    Query<Map<String, dynamic>> q = _col;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    final s = await q.get();
    return s.docs
        .map((e) => ItemModel.fromMap(e.data()..['id'] = e.id))
        .toList();
  }

  Stream<List<ItemModel>> watch({String? category}) {
    Query<Map<String, dynamic>> q = _col;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map(
      (s) =>
          s.docs
              .map((e) => ItemModel.fromMap(e.data()..['id'] = e.id))
              .toList(),
    );
  }
}

class CatalogItemService {
  final FirebaseFirestore db;
  final String collectionPath;

  CatalogItemService({required this.db, this.collectionPath = 'catalogItems'});

  String _slug(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s_-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      db.collection(collectionPath);

  Future<String> create({
    String? id,
    required String nombre,
    required String descripcion,
    required String icono,
    required String category,
  }) async {
    final docId = id?.trim().isNotEmpty == true ? id!.trim() : _slug(nombre);
    final ref = _col.doc(docId);
    final model = CatalogItemModel(
      id: docId,
      nombre: nombre,
      descripcion: descripcion,
      icono: icono,
      category: category,
    );
    await ref.set(model.toMap());
    return docId;
  }

  Future<void> update(String id, CatalogItemModel model) async {
    await _col.doc(id).update(model.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Future<CatalogItemModel?> getById(String id) async {
    final snap =
        await _col.doc(id).get(); // DocumentSnapshot<Map<String, dynamic>>
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!..['id'] = snap.id;
    return CatalogItemModel.fromMap(data);
  }

  Future<List<CatalogItemModel>> list({String? category}) async {
    Query<Map<String, dynamic>> q = _col;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    final res = await q.get(); // QuerySnapshot<Map<String, dynamic>>
    return res.docs
        .map((d) => CatalogItemModel.fromMap(d.data()..['id'] = d.id))
        .toList();
  }

  Stream<List<CatalogItemModel>> watch({String? category}) {
    Query<Map<String, dynamic>> q = _col;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map(
      (s) =>
          s.docs
              .map((d) => CatalogItemModel.fromMap(d.data()..['id'] = d.id))
              .toList(),
    );
  }
}
