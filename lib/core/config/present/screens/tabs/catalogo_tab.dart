// lib/features/admin/presentation/tabs/catalog_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/config/present/screens/widgets/pet_types_dialog.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

class CatalogTab extends ConsumerWidget {
  const CatalogTab({super.key});

  static const List<String> _categorias = [
    'fondo',
    'decoracion',
    'alimento',
    'accesorio',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            Future<void> _upsertPetCatalogItem({
              bool? wheelEnabled,
              int? wheelWeight,
            }) async {
              final doc = FirebaseFirestore.instance
                  .collection('catalogItems')
                  .doc(p.id);

              final int w = (wheelWeight ?? existing.wheelWeight);
              final int safeW = w < 1 ? 1 : w;

              await doc.set({
                'id': p.id,
                'nombre': p.name,
                'descripcion': p.description,
                'icono': p.image,
                'category': 'mascota',
                'wheelEnabled': wheelEnabled ?? existing.wheelEnabled,
                'wheelWeight': safeW,
              }, SetOptions(merge: true));

              // refresca catálogo
              ref.invalidate(catalogItemsStreamProvider);
            }

            return Card(
              child: ListTile(
                leading: const Icon(Icons.pets),
                title: Text(p.name),
                subtitle: Text('Mascota · ${p.description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle ruleta
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Ruleta', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Switch(
                          value: existing.wheelEnabled,
                          onChanged: (v) async {
                            await _upsertPetCatalogItem(wheelEnabled: v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Peso
                    SizedBox(
                      width: 64,
                      child: TextFormField(
                        initialValue: existing.wheelWeight.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Peso',
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (v) async {
                          final n = int.tryParse(v);
                          final safe = (n == null || n < 1) ? 1 : n;
                          await _upsertPetCatalogItem(wheelWeight: safe);
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
                          // (opcional) limpiar su CatalogItem:
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

          // Ítems normales
          ...catalog.map(
            (it) => Card(
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
                          value: it.wheelEnabled,
                          onChanged: (v) {
                            final svc = ref.read(catalogItemServiceProvider);
                            svc.update(it.id, it.copyWith(wheelEnabled: v));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 64,
                      child: TextFormField(
                        initialValue: it.wheelWeight.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Peso',
                          isDense: true,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onFieldSubmitted: (v) {
                          final n = int.tryParse(v) ?? it.wheelWeight;
                          final svc = ref.read(catalogItemServiceProvider);
                          svc.update(
                            it.id,
                            it.copyWith(wheelWeight: n < 1 ? 1 : n),
                          );
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
            ),
          ),
          if (catalog.isEmpty && pets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('Sin elementos')),
            ),
        ],
      ),
    );
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

Future<void> showPetTypeDialog(
  BuildContext context,
  WidgetRef ref, {
  PetTypeModel? pet,
}) async {
  // reusa tu implementación existente (la moví a widgets/pet_type_dialog.dart)
  return showPetTypeDialogImpl(context, ref, pet: pet);
}
