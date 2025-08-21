// lib/features/habit/presentation/widgets/pet_type_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/config/models/pet_type_model.dart';
import 'package:per_habit/core/config/providers/config_provider.dart';

class PetTypeSelector extends ConsumerWidget {
  final PetTypeModel? selected;
  final Function(PetTypeModel) onSelected;
  final bool enabled;

  const PetTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petTypesAsync = ref.watch(petTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de mascota', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        petTypesAsync.when(
          data:
              (list) => Opacity(
                opacity: enabled ? 1 : 0.6,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      list
                          .where((p) => p.available)
                          .map(
                            (pet) => ChoiceChip(
                              label: Text(pet.name),
                              selected: selected?.id == pet.id,
                              onSelected:
                                  enabled ? (_) => onSelected(pet) : null,
                            ),
                          )
                          .toList(),
                ),
              ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error cargando mascotas: $e'),
        ),
      ],
    );
  }
}
