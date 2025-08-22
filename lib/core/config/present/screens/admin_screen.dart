// lib/features/admin/presentation/screens/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';

// Catálogo (sin cantidad)
import 'package:per_habit/features/store/data/models/catalogo_item_model.dart';

// INVENTARIO/ItemModel (con cantidad) -> para contenido de productos de tienda
import 'package:per_habit/features/inventary/data/models/items_model.dart';

// TIENDA (admin)
import 'package:per_habit/features/store/data/models/shop_item_model.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Mascotas + Catálogo + Tienda
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            IconButton(
              tooltip: 'Inicio',
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mascotas'),
              Tab(text: 'Catálogo'),
              Tab(text: 'Tienda'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_PetsTab(), _CatalogTab(), _ShopTab()],
        ),
      ),
    );
  }
}

// ---------- MASCOTAS ----------
class _PetsTab extends ConsumerWidget {
  const _PetsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petTypesStreamProvider);
    final svc = ref.watch(petTypeServiceProvider);

    return petsAsync.when(
      data:
          (list) => Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => showPetTypeDialog(context, ref),
              child: const Icon(Icons.add),
            ),
            body: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final p = list[i];
                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(p.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: p.available,
                          onChanged:
                              (v) => svc.update(p.id, p.copyWith(available: v)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed:
                              () => showPetTypeDialog(context, ref, pet: p),
                        ),
                        IconButton(
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
                            if (ok == true) await svc.delete(p.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: list.length,
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// ---------- CATÁLOGO (sin campo cantidad) ----------
class _CatalogTab extends ConsumerWidget {
  const _CatalogTab();

  // Quitamos 'mascota' de la creación; las mascotas se gestionan en su pestaña.
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

    final svc = ref.watch(catalogItemServiceProvider);
    final petSvc = ref.watch(petTypeServiceProvider);

    if (catalogAsync.isLoading || petsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalogAsync.hasError) {
      return Center(child: Text('Error catálogo: ${catalogAsync.error}'));
    }
    if (petsAsync.hasError) {
      return Center(child: Text('Error mascotas: ${petsAsync.error}'));
    }

    final catalog =
        (catalogAsync.value ?? const <CatalogItemModel>[])
            .where((it) => it.category != 'mascota')
            .toList();
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
          ...pets.map(
            (p) => Card(
              child: ListTile(
                leading: const Icon(Icons.pets),
                title: Text(p.name),
                subtitle: Text('Mascota · ${p.description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: p.available,
                      onChanged:
                          (v) => petSvc.update(p.id, p.copyWith(available: v)),
                    ),
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
                        if (ok == true) await petSvc.delete(p.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ítems del catálogo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...catalog.map(
            (it) => Card(
              child: ListTile(
                title: Text(it.nombre),
                subtitle: Text('${it.descripcion}\nCat: ${it.category}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        if (ok == true) await svc.delete(it.id);
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
                        if (isEdit) {
                          final updated = CatalogItemModel(
                            id: item.id,
                            nombre: nombreCtrl.text.trim(),
                            descripcion: descCtrl.text.trim(),
                            icono: iconoCtrl.text.trim(),
                            category: category,
                          );
                          await svc.update(item.id, updated);
                        } else {
                          await svc.create(
                            nombre: nombreCtrl.text.trim(),
                            descripcion: descCtrl.text.trim(),
                            icono: iconoCtrl.text.trim(),
                            category: category,
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

// ---------- TIENDA (admin de productos/paquetes) ----------
class _ShopTab extends ConsumerWidget {
  const _ShopTab();

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
            onPressed:
                () => _showShopItemDialog(context, ref, catalog: catalog),
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
                            () => _showShopItemDialog(
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

  Future<void> _showShopItemDialog(
    BuildContext context,
    WidgetRef ref, {
    required List<CatalogItemModel> catalog,
    ShopItemModel? item,
  }) async {
    final isEdit = item != null;

    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final iconoCtrl = TextEditingController(text: item?.icono ?? '🛒');
    final priceCtrl = TextEditingController(
      text: (item?.price ?? 0).toString(),
    );
    bool isOffer = item?.isOffer ?? false;
    bool isBundle = item?.isBundle ?? false;

    // filas de contenido (catálogo + cantidad)
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
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
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
                                    (v) =>
                                        setState(() => isOffer = v ?? isOffer),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Paquete'),
                                value: isBundle,
                                onChanged:
                                    (v) => setState(
                                      () => isBundle = v ?? isBundle,
                                    ),
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
                                        () =>
                                            rows[idx] = row.copyWith(item: sel),
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

                        // Validar contenido
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
                                  ? item.id
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

class _ContentRow {
  final CatalogItemModel? item;
  final int cantidad;
  const _ContentRow({required this.item, required this.cantidad});
  _ContentRow copyWith({CatalogItemModel? item, int? cantidad}) =>
      _ContentRow(item: item ?? this.item, cantidad: cantidad ?? this.cantidad);
}

/// --------- FUNCIÓN COMPARTIDA: diálogo para crear/editar PetType ---------
Future<void> showPetTypeDialog(
  BuildContext context,
  WidgetRef ref, {
  PetTypeModel? pet,
}) async {
  final isEdit = pet != null;

  final nameCtrl = TextEditingController(text: pet?.name ?? '');
  final descCtrl = TextEditingController(text: pet?.description ?? '');
  final imageCtrl = TextEditingController(text: pet?.image ?? '');
  final priceCtrl = TextEditingController(text: (pet?.price ?? 0).toString());
  final maxLevelCtrl = TextEditingController(
    text: (pet?.maxLevel ?? 50).toString(),
  );
  final rewardCtrl = TextEditingController(
    text: (pet?.rewardTable ?? const <int>[]).join(','),
  );
  final reducedCtrl = TextEditingController(
    text: (pet?.reducedRewardTable ?? const <int>[]).join(','),
  );
  bool available = pet?.available ?? true;

  final personalities = await ref.read(personalitiesProvider.future);
  final mechanics = await ref.read(mechanicsProvider.future);
  String selectedPersonalityId =
      pet?.defaultPersonalityId ??
      (personalities.isNotEmpty ? personalities.first.id : 'happy');
  final Set<String> selectedMechanics = {
    ...(pet?.mechanicIds ?? <String>[]),
  }; // <- ojo, Set declarado ANTES de usarse

  await showDialog(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(isEdit ? 'Editar mascota' : 'Nueva mascota'),
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
                          labelText: 'Imagen (ruta/URL)',
                        ),
                        controller: imageCtrl,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Precio',
                              ),
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Max Level',
                              ),
                              controller: maxLevelCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Reward Table (CSV)',
                        ),
                        controller: rewardCtrl,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Reduced Reward Table (CSV)',
                        ),
                        controller: reducedCtrl,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Disponible'),
                        value: available,
                        onChanged: (v) => setState(() => available = v),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedPersonalityId,
                        decoration: const InputDecoration(
                          labelText: 'Personalidad por defecto',
                        ),
                        items:
                            personalities
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (v) => setState(
                              () =>
                                  selectedPersonalityId =
                                      v ?? selectedPersonalityId,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              mechanics.map((m) {
                                final sel = selectedMechanics.contains(m.id);
                                return FilterChip(
                                  label: Text(m.name),
                                  selected: sel,
                                  onSelected: (v) {
                                    setState(() {
                                      if (v) {
                                        selectedMechanics.add(m.id);
                                      } else {
                                        selectedMechanics.remove(m.id);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
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
                      final svc = ref.read(petTypeServiceProvider);
                      final price = int.tryParse(priceCtrl.text) ?? 0;
                      final maxLevel = int.tryParse(maxLevelCtrl.text) ?? 50;
                      final reward =
                          rewardCtrl.text
                              .split(',')
                              .where((e) => e.trim().isNotEmpty)
                              .map((e) => int.tryParse(e.trim()) ?? 0)
                              .toList();
                      final reduced =
                          reducedCtrl.text
                              .split(',')
                              .where((e) => e.trim().isNotEmpty)
                              .map((e) => int.tryParse(e.trim()) ?? 0)
                              .toList();

                      if (isEdit) {
                        final updated = PetTypeModel(
                          id: pet.id,
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          image: imageCtrl.text.trim(),
                          available: available,
                          price: price,
                          maxLevel: maxLevel,
                          rewardTable: reward,
                          reducedRewardTable: reduced,
                          defaultPersonalityId: selectedPersonalityId,
                          mechanicIds: selectedMechanics.toList(),
                        );
                        await svc.update(pet.id, updated);
                      } else {
                        await svc.create(
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          image: imageCtrl.text.trim(),
                          available: available,
                          price: price,
                          maxLevel: maxLevel,
                          rewardTable: reward,
                          reducedRewardTable: reduced,
                          defaultPersonalityId: selectedPersonalityId,
                          mechanicIds: selectedMechanics.toList(),
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
