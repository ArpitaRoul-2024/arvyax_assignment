import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/ambience_provider.dart';

class ClearFiltersButton extends ConsumerWidget {
  const ClearFiltersButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    // Only show if any filter is active
    if (searchQuery.isEmpty && selectedTag == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            ref.read(searchQueryProvider.notifier).state = '';
            ref.read(selectedTagProvider.notifier).state = null;
          },
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear All Filters'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}