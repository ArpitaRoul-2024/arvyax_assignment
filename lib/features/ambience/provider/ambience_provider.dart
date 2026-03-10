import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/model/ambience_model.dart';
import '../../../data/repositaries/ambience_repositary.dart';


// Repository provider (singleton)
final ambienceRepositoryProvider = Provider<AmbienceRepository>((ref) {
  return AmbienceRepository();
});

 final ambienceListProvider = FutureProvider<List<Ambience>>((ref) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getAmbiences();
});

// Provider for refreshing ambience list
final ambienceRefreshProvider = Provider((ref) {
  return () async {
    final repository = ref.read(ambienceRepositoryProvider);
    final result = await repository.refreshAmbiences();
    // Invalidate the FutureProvider to trigger rebuild
    ref.invalidate(ambienceListProvider);
    return result;
  };
});

// Selected ambience provider
final selectedAmbienceIdProvider = StateProvider<String?>((ref) => null);

// Selected ambience details provider
final selectedAmbienceProvider = FutureProvider<Ambience?>((ref) {
  final id = ref.watch(selectedAmbienceIdProvider);
  if (id == null) return Future.value(null);

  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getAmbienceById(id);
});

// Filter providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTagProvider = StateProvider<AmbienceTag?>((ref) => null);
final selectedSensoryChipProvider = StateProvider<String?>((ref) => null);

// Filtered ambiences provider with advanced filtering
final filteredAmbiencesProvider = Provider<List<Ambience>>((ref) {
  final ambiencesAsync = ref.watch(ambienceListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final selectedTag = ref.watch(selectedTagProvider);
  final selectedChip = ref.watch(selectedSensoryChipProvider);

  List<Ambience> ambiences;
  if (ambiencesAsync.hasValue) {
    ambiences = ambiencesAsync.value!;
  } else {
    ambiences = [];
  }
  if (ambiences.isEmpty) return [];

  return ambiences.where((ambience) {
    // Apply tag filter
    if (selectedTag != null && ambience.tag != selectedTag) {
      return false;
    }

    // Apply sensory chip filter
    if (selectedChip != null && !ambience.sensoryChips.contains(selectedChip)) {
      return false;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final titleMatch = ambience.title.toLowerCase().contains(searchQuery);
      final descMatch = ambience.description.toLowerCase().contains(searchQuery);
      final chipMatch = ambience.sensoryChips.any(
              (chip) => chip.toLowerCase().contains(searchQuery)
      );

      return titleMatch || descMatch || chipMatch;
    }

    return true;
  }).toList();
});

// Featured ambiences provider
final featuredAmbiencesProvider = FutureProvider<List<Ambience>>((ref) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getFeaturedAmbiences();
});

// Recommended ambiences provider
final recommendedAmbiencesProvider = FutureProvider.family<List<Ambience>, String>((ref, ambienceId) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getRecommendedAmbiences(ambienceId);
});

// All sensory chips provider
final allSensoryChipsProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getAllSensoryChips();
});

// Ambience statistics provider
final ambienceStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getStatistics();
});

// Ambience by ID provider
final ambienceByIdProvider = FutureProvider.family<Ambience?, String>((ref, id) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.getAmbienceById(id);
});

// Check if ambience exists provider
final ambienceExistsProvider = FutureProvider.family<bool, String>((ref, id) {
  final repository = ref.watch(ambienceRepositoryProvider);
  return repository.ambienceExists(id);
});