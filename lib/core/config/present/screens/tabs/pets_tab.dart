// lib/features/admin/presentation/tabs/pets_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/config/present/screens/tabs/catalogo_tab.dart';
import 'package:per_habit/core/config/providers/config_provider.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';

class PetsTab extends ConsumerWidget {
  const PetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petTypesStreamProvider);
    final svc = ref.watch(petTypeServiceProvider);

    return petsAsync.when(
      data:
          (List<PetTypeModel> list) => Scaffold(
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
