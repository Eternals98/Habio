// lib/features/admin/presentation/widgets/shop_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';
import 'package:per_habit/features/inventary/data/models/items_model.dart';
import 'package:per_habit/features/store/data/models/shop_item_model.dart';

Future<void> showShopItemDialog(
  BuildContext context,
  WidgetRef ref, {
  required List<CatalogItemModel> catalog,
  ShopItemModel? item,
}) async {
  final isEdit = item != null;

  final nameCtrl = TextEditingController(text: item?.name ?? '');
  final descCtrl = TextEditingController(text: item?.description ?? '');
  final iconoCtrl = TextEditingController(text: item?.icono ?? '🛒');
  final priceCtrl = TextEditingController(text: (item?.price ?? 0).toString());
  bool isOffer = item?.isOffer ?? false;
  bool isBundle = item?.isBundle ?? false;

  final List<_ContentRow> rows =
      (item?.content ?? const <ItemModel>[]).map((im) {
        final found = catalog.firstWhere(
          (c) => c.id == im.id,
          orElse:
              () => CatalogItemModel(
                id: im.id,
                nombre: im.nombre,
                descripcion: im.descripcion,
                icono: im.icono,
                category: im.category,
              ),
        );
        return _ContentRow(item: found, cantidad: im.cantidad);
      }).toList();

  await showDialog(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(isEdit ? 'Editar producto' : 'Nuevo producto'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        controller: nameCtrl,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        controller: descCtrl,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Icono (emoji/URL)',
                        ),
                        controller: iconoCtrl,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Precio (HabiPoints)',
                        ),
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Oferta'),
                              value: isOffer,
                              onChanged:
                                  (v) => setState(() => isOffer = v ?? isOffer),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Paquete'),
                              value: isBundle,
                              onChanged:
                                  (v) =>
                                      setState(() => isBundle = v ?? isBundle),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contenido',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...rows.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final row = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: row.item?.id,
                                  hint: const Text('Selecciona ítem'),
                                  items:
                                      catalog
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c.id,
                                              child: Text(
                                                '${c.nombre} (${c.category})',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    final sel = catalog.firstWhere(
                                      (c) => c.id == v,
                                    );
                                    setState(
                                      () => rows[idx] = row.copyWith(item: sel),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: row.cantidad.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Cant',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v) ?? 1;
                                    setState(
                                      () =>
                                          rows[idx] = row.copyWith(
                                            cantidad: n < 1 ? 1 : n,
                                          ),
                                    );
                                  },
                                ),
                              ),
                              IconButton(
                                tooltip: 'Quitar',
                                onPressed:
                                    () => setState(() => rows.removeAt(idx)),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed:
                              () => setState(
                                () => rows.add(
                                  _ContentRow(item: null, cantidad: 1),
                                ),
                              ),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar ítem'),
                        ),
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
                      final svc = ref.read(shopAdminServiceProvider);
                      final price = int.tryParse(priceCtrl.text) ?? 0;

                      final selected =
                          rows
                              .where((r) => r.item != null && r.cantidad > 0)
                              .toList();
                      final content =
                          selected
                              .map<ItemModel>(
                                (r) => ItemModel(
                                  id: r.item!.id,
                                  nombre: r.item!.nombre,
                                  descripcion: r.item!.descripcion,
                                  icono: r.item!.icono,
                                  cantidad: r.cantidad,
                                  category: r.item!.category,
                                ),
                              )
                              .toList();

                      final model = ShopItemModel(
                        id:
                            isEdit
                                ? item!.id
                                : (nameCtrl.text
                                    .trim()
                                    .toLowerCase()
                                    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')),
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        icono: iconoCtrl.text.trim(),
                        price: price,
                        isOffer: isOffer,
                        isBundle: isBundle,
                        content: content,
                      );

                      if (isEdit) {
                        await svc.update(model.id, model);
                      } else {
                        await svc.create(model);
                      }

                      // refrescar lista
                      ref.invalidate(shopAdminStreamProvider);

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

class _ContentRow {
  final CatalogItemModel? item;
  final int cantidad;
  const _ContentRow({required this.item, required this.cantidad});
  _ContentRow copyWith({CatalogItemModel? item, int? cantidad}) =>
      _ContentRow(item: item ?? this.item, cantidad: cantidad ?? this.cantidad);
}
