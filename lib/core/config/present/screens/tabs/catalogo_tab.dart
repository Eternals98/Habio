// lib/features/admin/presentation/tabs/catalog_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:per_habit/core/config/present/screens/widgets/pet_types_dialog.dart';
import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

class CatalogTab extends ConsumerStatefulWidget {
  const CatalogTab({super.key});

  @override
  ConsumerState<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends ConsumerState<CatalogTab> {
  // Categorías (los “ítems normales” excluyen mascota)
  static const List<String> _categorias = [
    'fondo',
    'decoracion',
    'alimento',
    'accesorio',
  ];

  /// Drafts en memoria (no se guardan hasta pulsar “Guardar”)
  final Map<String, int> _weightDrafts = {}; // id -> peso
  final Map<String, bool> _enabledDrafts = {}; // id -> wheelEnabled

  // Últimos datos que pintó el build (para _saveAllEdits)
  List<CatalogItemModel> _lastAllCatalog = const [];
  List<CatalogItemModel> _lastCatalog = const [];
  List<PetTypeModel> _lastPets = const [];

  // ⬇️ guardamos el “unsubscribe” del listenManual
  late final void Function() _removeSaveAllListener;
  late final ProviderSubscription<int> _saveAllSub;

  @override
  void initState() {
    super.initState();

    _saveAllSub = ref.listenManual<int>(saveAllProvider, (prev, next) async {
      if (prev == next) return;
      await _saveAllEdits();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
    });
  }

  @override
  void dispose() {
    _saveAllSub.close(); // <- cerrar la suscripción
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogItemsStreamProvider);
    final petsAsync = ref.watch(petTypesStreamProvider);

    if (catalogAsync.isLoading || petsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalogAsync.hasError) {
      return Center(child: Text('Error catálogo: ${catalogAsync.error}'));
    }
    if (petsAsync.hasError) {
      return Center(child: Text('Error mascotas: ${petsAsync.error}'));
    }

    final allCatalog = catalogAsync.value ?? const <CatalogItemModel>[];
    final catalog = allCatalog.where((it) => it.category != 'mascota').toList();
    final pets = petsAsync.value ?? const <PetTypeModel>[];

    // Guarda referencia para _saveAllEdits()
    _lastAllCatalog = allCatalog;
    _lastCatalog = catalog;
    _lastPets = pets;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCatalogDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Mascotas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // ======= MASCOTAS (control de ruleta/ peso) =======
          ...pets.map((p) {
            final existing = allCatalog.firstWhere(
              (c) => c.id == p.id && c.category == 'mascota',
              orElse:
                  () => CatalogItemModel(
                    id: p.id,
                    nombre: p.name,
                    descripcion: p.description,
                    icono: p.image,
                    category: 'mascota',
                    wheelEnabled: false,
                    wheelWeight: 1,
                  ),
            );

            // Valores visibles consideran “drafts” si existen
            final bool enabled = _enabledDrafts[p.id] ?? existing.wheelEnabled;
            final int weight = _weightDrafts[p.id] ?? existing.wheelWeight;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.pets),
                title: Text(p.name),
                subtitle: Text('Mascota · ${p.description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle ruleta (solo draft)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ruleta', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Switch(
                          value: enabled,
                          onChanged: (v) {
                            setState(() => _enabledDrafts[p.id] = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Peso (solo draft)
                    SizedBox(
                      width: 64,
                      child: TextFormField(
                        initialValue: '$weight',
                        decoration: const InputDecoration(
                          labelText: 'Peso',
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          setState(() {
                            _weightDrafts[p.id] = (n == null || n < 1) ? 1 : n;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed: () => showPetTypeDialog(context, ref, pet: p),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Eliminar mascota'),
                                content: Text('¿Eliminar "${p.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                        );
                        if (ok == true) {
                          await ref.read(petTypeServiceProvider).delete(p.id);
                          // (opcional) borrar su CatalogItem:
                          // await FirebaseFirestore.instance.collection('catalogItems').doc(p.id).delete();
                          ref.invalidate(catalogItemsStreamProvider);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),
          Text(
            'Ítems del catálogo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // ======= ÍTEMS NORMALES =======
          ..._lastCatalog.map((it) {
            final bool enabled = _enabledDrafts[it.id] ?? it.wheelEnabled;
            final int weight = _weightDrafts[it.id] ?? it.wheelWeight;

            return Card(
              child: ListTile(
                title: Text(it.nombre),
                subtitle: Text('${it.descripcion}\nCat: ${it.category}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ruleta', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Switch(
                          value: enabled,
                          onChanged: (v) {
                            setState(() => _enabledDrafts[it.id] = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: TextFormField(
                        initialValue: '$weight',
                        decoration: const InputDecoration(
                          labelText: 'Peso',
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          setState(() {
                            _weightDrafts[it.id] = (n == null || n < 1) ? 1 : n;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit),
                      onPressed:
                          () => _showCatalogDialog(context, ref, item: it),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Eliminar ítem'),
                                content: Text(
                                  '¿Eliminar "${it.nombre}" del catálogo?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                        );
                        if (ok == true) {
                          final svc = ref.read(catalogItemServiceProvider);
                          await svc.delete(it.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          if (_lastCatalog.isEmpty && _lastPets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Sin elementos')),
            ),
        ],
      ),
    );
  }

  /// Guarda TODOS los drafts (mascotas + ítems normales) usando un batch.
  Future<void> _saveAllEdits() async {
    final batch = FirebaseFirestore.instance.batch();

    Future<void> _upsertPetCatalogItem({
      required PetTypeModel p,
      required bool wheelEnabled,
      required int wheelWeight,
    }) async {
      final doc = FirebaseFirestore.instance
          .collection('catalogItems')
          .doc(p.id);
      batch.set(doc, {
        'id': p.id,
        'nombre': p.name,
        'descripcion': p.description,
        'icono': p.image,
        'category': 'mascota',
        'wheelEnabled': wheelEnabled,
        'wheelWeight': wheelWeight < 1 ? 1 : wheelWeight,
      }, SetOptions(merge: true));
    }

    // 1) Mascotas
    for (final p in _lastPets) {
      final existing = _lastAllCatalog.firstWhere(
        (c) => c.id == p.id && c.category == 'mascota',
        orElse:
            () => CatalogItemModel(
              id: p.id,
              nombre: p.name,
              descripcion: p.description,
              icono: p.image,
              category: 'mascota',
              wheelEnabled: false,
              wheelWeight: 1,
            ),
      );
      final enabled = _enabledDrafts[p.id] ?? existing.wheelEnabled;
      final weight = _weightDrafts[p.id] ?? existing.wheelWeight;
      await _upsertPetCatalogItem(
        p: p,
        wheelEnabled: enabled,
        wheelWeight: weight,
      );
    }

    // 2) Ítems normales (solo si cambió algo)
    for (final it in _lastCatalog) {
      final enabled = _enabledDrafts[it.id] ?? it.wheelEnabled;
      final weight = _weightDrafts[it.id] ?? it.wheelWeight;

      if (enabled != it.wheelEnabled || weight != it.wheelWeight) {
        final doc = FirebaseFirestore.instance
            .collection('catalogItems')
            .doc(it.id);
        batch.set(doc, {
          'wheelEnabled': enabled,
          'wheelWeight': weight < 1 ? 1 : weight,
        }, SetOptions(merge: true));
      }
    }

    await batch.commit();

    // Limpiar drafts y refrescar
    setState(() {
      _enabledDrafts.clear();
      _weightDrafts.clear();
    });
    ref.invalidate(catalogItemsStreamProvider);
  }

  Future<void> _showCatalogDialog(
    BuildContext context,
    WidgetRef ref, {
    CatalogItemModel? item,
  }) async {
    final isEdit = item != null;

    final nombreCtrl = TextEditingController(text: item?.nombre ?? '');
    final descCtrl = TextEditingController(text: item?.descripcion ?? '');
    final iconoCtrl = TextEditingController(text: item?.icono ?? '');
    String category = item?.category ?? _categorias.first;

    bool wheelEnabled = item?.wheelEnabled ?? false;
    final wheelWeightCtrl = TextEditingController(
      text: (item?.wheelWeight ?? 1).toString(),
    );

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    isEdit
                        ? 'Editar ítem de catálogo'
                        : 'Nuevo ítem de catálogo',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          controller: nombreCtrl,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                          controller: descCtrl,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Icono (ruta/URL)',
                          ),
                          controller: iconoCtrl,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                          ),
                          items:
                              _categorias
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => category = v ?? category),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Disponible en ruleta'),
                          value: wheelEnabled,
                          onChanged: (v) => setState(() => wheelEnabled = v),
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Peso de ruleta (>=1)',
                          ),
                          controller: wheelWeightCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final svc = ref.read(catalogItemServiceProvider);
                        final weight = int.tryParse(wheelWeightCtrl.text) ?? 1;

                        if (isEdit) {
                          final updated = CatalogItemModel(
                            id: item!.id,
                            nombre: nombreCtrl.text.trim(),
                            descripcion: descCtrl.text.trim(),
                            icono: iconoCtrl.text.trim(),
                            category: category,
                            wheelEnabled: wheelEnabled,
                            wheelWeight: weight < 1 ? 1 : weight,
                          );
                          await svc.update(item.id, updated);
                        } else {
                          await svc.create(
                            nombre: nombreCtrl.text.trim(),
                            descripcion: descCtrl.text.trim(),
                            icono: iconoCtrl.text.trim(),
                            category: category,
                            wheelEnabled: wheelEnabled,
                            wheelWeight: weight < 1 ? 1 : weight,
                          );
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                      child: Text(isEdit ? 'Guardar' : 'Crear'),
                    ),
                  ],
                ),
          ),
    );
  }
}

/// Simple wrapper: reusa tu implementación existente (movida a widgets/pet_types_dialog.dart)
Future<void> showPetTypeDialog(
  BuildContext context,
  WidgetRef ref, {
  PetTypeModel? pet,
}) async {
  return showPetTypeDialogImpl(context, ref, pet: pet);
}
