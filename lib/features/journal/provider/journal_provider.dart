import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/model/journal_entry.dart';
import '../../../data/model/mood.dart';
import '../../../data/repositaries/journal_repositary.dart';


// Repository provider
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

// All journal entries provider
final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getAllEntries();
});

// Single journal entry by ID provider
final journalEntryByIdProvider = FutureProvider.family<JournalEntry?, String>((ref, id) {
  final repository = ref.watch(journalRepositoryProvider);
  return Future.value(repository.getEntryById(id));
});

// Recent entries provider (last 7 days)
final recentJournalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return Future.value(repository.getRecentEntries());
});

// Entries by mood provider
final journalEntriesByMoodProvider = FutureProvider.family<List<JournalEntry>, Mood>((ref, mood) {
  final repository = ref.watch(journalRepositoryProvider);
  return Future.value(repository.getEntriesByMood(mood));
});

// Journal statistics provider
final journalStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return Future.value(repository.getStatistics());
});

// Save journal entry provider (for actions)
final saveJournalEntryProvider = FutureProvider.family<void, JournalEntry>((ref, entry) async {
  final repository = ref.watch(journalRepositoryProvider);
  await repository.saveEntry(entry);
  ref.invalidate(journalEntriesProvider); // Refresh the list
});

// Delete journal entry provider
final deleteJournalEntryProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(journalRepositoryProvider);
  await repository.deleteEntry(id);
  ref.invalidate(journalEntriesProvider); // Refresh the list
});