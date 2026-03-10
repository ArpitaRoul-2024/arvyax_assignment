import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/model/ambience_model.dart';
import '../provider/ambience_provider.dart';


class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final theme = Theme.of(context);

    final filters = [
      {'label': 'All', 'tag': null},
      {'label': 'Focus', 'tag': AmbienceTag.focus},
      {'label': 'Calm', 'tag': AmbienceTag.calm},
      {'label': 'Sleep', 'tag': AmbienceTag.sleep},
      {'label': 'Reset', 'tag': AmbienceTag.reset},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedTag == filter['tag'];

          return FilterChip(
            label: Text(filter['label'] as String),
            selected: isSelected,
            onSelected: (_) {
              ref.read(selectedTagProvider.notifier).state =
              filter['tag'] as AmbienceTag?;
            },
            backgroundColor: theme.cardColor,
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}