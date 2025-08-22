// lib/features/admin/presentation/tabs/shop_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

import '../widgets/shop_item_dialog.dart';

class ShopTab extends ConsumerWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopAdminStreamProvider);
    final catalogAsync = ref.watch(catalogItemsStreamProvider);
    final svc = ref.watch(shopAdminServiceProvider);

    return shopAsync.when(
      data: (products) {
        final catalog = catalogAsync.value ?? const <CatalogItemModel>[];
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => showShopItemDialog(context, ref, catalog: catalog),
            child: const Icon(Icons.add),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final p = products[i];
              final contentSummary =
                  p.content.isEmpty
                      ? 'Contenido: —'
                      : 'Contenido: ${p.content.map((c) => '${c.nombre} (x${c.cantidad})').join(', ')}';
              return Card(
                child: ListTile(
                  title: Text('${p.name}  •  ${p.price} HP'),
                  subtitle: Text(
                    '${p.description}\n${p.isOffer ? 'Oferta · ' : ''}${p.isBundle ? 'Paquete · ' : ''}$contentSummary',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit),
                        onPressed:
                            () => showShopItemDialog(
                              context,
                              ref,
                              catalog: catalog,
                              item: p,
                            ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Eliminar producto'),
                                  content: Text(
                                    '¿Eliminar "${p.name}" de la tienda?',
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
                          if (ok == true) await svc.delete(p.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: products.length,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
