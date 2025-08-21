// lib/features/habit/presentation/widgets/personality_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/core/config/models/personality_model.dart';
import 'package:per_habit/core/config/providers/config_provider.dart';

class PersonalitySelector extends ConsumerWidget {
  final PersonalityModel? selected;
  final Function(PersonalityModel) onSelected;
  final bool enabled;

  const PersonalitySelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalitiesAsync = ref.watch(personalitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personalidad', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        personalitiesAsync.when(
          data:
              (list) => Opacity(
                opacity: enabled ? 1 : 0.6,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      list
                          .map(
                            (personality) => ChoiceChip(
                              label: Text(personality.name),
                              selected: selected?.id == personality.id,
                              onSelected:
                                  enabled
                                      ? (_) => onSelected(personality)
                                      : null,
                            ),
                          )
                          .toList(),
                ),
              ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error cargando personalidades: $e'),
        ),
      ],
    );
  }
}
