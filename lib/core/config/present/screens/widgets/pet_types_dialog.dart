// lib/features/admin/presentation/widgets/pet_type_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/providers/config_provider.dart';

Future<void> showPetTypeDialogImpl(
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
  final Set<String> selectedMechanics = {...(pet?.mechanicIds ?? <String>[])};

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
                          id: pet!.id,
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
