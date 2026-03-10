import 'package:uuid/uuid.dart';

import '../../core/utils/hive_utils.dart';
import '../model/journal_entry.dart';
import '../model/mood.dart';

class JournalRepository {
  final _uuid = const Uuid();

  // Save a journal entry
  Future<void> saveEntry(JournalEntry entry) async {
    try {
      print('💾 Saving journal entry: ${entry.id}');
      await HiveUtils.addJournalEntry(entry);
      print('✅ Journal entry saved successfully');
    } catch (e) {
      print('❌ Error saving journal entry: $e');
    }
  }

  // Get all journal entries
  List<JournalEntry> getAllEntries() {
    try {
      final entries = HiveUtils.getAllJournalEntries();
      print('📖 Loading ${entries.length} journal entries from Hive');
      return entries;
    } catch (e) {
      print('❌ Error loading journal entries: $e');
      return [];
    }
  }

  // Get entry by ID
  JournalEntry? getEntryById(String id) {
    try {
      return HiveUtils.getJournalEntry(id);
    } catch (e) {
      print('❌ Error getting entry by ID: $e');
      return null;
    }
  }

  // Delete entry by ID
  Future<void> deleteEntry(String id) async {
    try {
      await HiveUtils.deleteJournalEntry(id);
      print('🗑️ Deleted journal entry: $id');
    } catch (e) {
      print('❌ Error deleting entry: $e');
    }
  }

  // Create a new journal entry
  JournalEntry createEntry({
    required String ambienceId,
    required String ambienceTitle,
    required String text,
    required Mood mood,
  }) {
    return JournalEntry(
      id: _uuid.v4(),
      ambienceId: ambienceId,
      ambienceTitle: ambienceTitle,
      text: text,
      mood: mood,
      timestamp: DateTime.now(),
    );
  }

  // ✅ NEW: Get entries by ambience ID
  List<JournalEntry> getEntriesByAmbienceId(String ambienceId) {
    try {
      final allEntries = getAllEntries();
      return allEntries.where((entry) => entry.ambienceId == ambienceId).toList();
    } catch (e) {
      print('❌ Error getting entries by ambience ID: $e');
      return [];
    }
  }

  // ✅ NEW: Get entries by mood
  List<JournalEntry> getEntriesByMood(Mood mood) {
    try {
      final allEntries = getAllEntries();
      return allEntries.where((entry) => entry.mood == mood).toList();
    } catch (e) {
      print('❌ Error getting entries by mood: $e');
      return [];
    }
  }

  // ✅ NEW: Get entries by date range
  List<JournalEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    try {
      final allEntries = getAllEntries();
      return allEntries.where((entry) {
        return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
      }).toList();
    } catch (e) {
      print('❌ Error getting entries by date range: $e');
      return [];
    }
  }

  // ✅ NEW: Get recent entries (last 7 days)
  List<JournalEntry> getRecentEntries() {
    try {
      final allEntries = getAllEntries();
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      return allEntries.where((entry) => entry.timestamp.isAfter(sevenDaysAgo)).toList();
    } catch (e) {
      print('❌ Error getting recent entries: $e');
      return [];
    }
  }

  // ✅ NEW: Get entry count
  int getEntryCount() {
    try {
      return getAllEntries().length;
    } catch (e) {
      print('❌ Error getting entry count: $e');
      return 0;
    }
  }

  // ✅ NEW: Update an existing entry
  Future<void> updateEntry(JournalEntry updatedEntry) async {
    try {
      await saveEntry(updatedEntry); // Hive will overwrite if ID exists
      print('🔄 Updated journal entry: ${updatedEntry.id}');
    } catch (e) {
      print('❌ Error updating entry: $e');
    }
  }

  // ✅ NEW: Delete all entries
  Future<void> deleteAllEntries() async {
    try {
      final box = HiveUtils.journalBox;
      await box.clear();
      print('🗑️ Deleted all journal entries');
    } catch (e) {
      print('❌ Error deleting all entries: $e');
    }
  }

  // ✅ NEW: Search entries by text
  List<JournalEntry> searchEntries(String query) {
    try {
      if (query.isEmpty) return getAllEntries();

      final allEntries = getAllEntries();
      final searchTerm = query.toLowerCase();

      return allEntries.where((entry) {
        return entry.text.toLowerCase().contains(searchTerm) ||
            entry.ambienceTitle.toLowerCase().contains(searchTerm);
      }).toList();
    } catch (e) {
      print('❌ Error searching entries: $e');
      return [];
    }
  }

  // ✅ NEW: Get entries statistics
  Map<String, dynamic> getStatistics() {
    try {
      final allEntries = getAllEntries();

      // Count by mood
      final moodCount = <Mood, int>{};
      for (var mood in Mood.values) {
        moodCount[mood] = 0;
      }

      for (var entry in allEntries) {
        moodCount[entry.mood] = (moodCount[entry.mood] ?? 0) + 1;
      }

      // Most used ambience
      final ambienceCount = <String, int>{};
      for (var entry in allEntries) {
        ambienceCount[entry.ambienceTitle] = (ambienceCount[entry.ambienceTitle] ?? 0) + 1;
      }

      String mostUsedAmbience = '';
      int maxCount = 0;
      ambienceCount.forEach((ambience, count) {
        if (count > maxCount) {
          maxCount = count;
          mostUsedAmbience = ambience;
        }
      });

      // Average entries per day
      final oldestEntry = allEntries.isNotEmpty
          ? allEntries.last.timestamp
          : DateTime.now();
      final daysDiff = DateTime.now().difference(oldestEntry).inDays + 1;
      final avgPerDay = allEntries.length / (daysDiff > 0 ? daysDiff : 1);

      return {
        'totalEntries': allEntries.length,
        'byMood': moodCount,
        'mostUsedAmbience': mostUsedAmbience,
        'mostUsedAmbienceCount': maxCount,
        'uniqueAmbiences': ambienceCount.length,
        'lastEntryDate': allEntries.isNotEmpty ? allEntries.first.timestamp : null,
        'firstEntryDate': allEntries.isNotEmpty ? allEntries.last.timestamp : null,
        'averagePerDay': double.parse(avgPerDay.toStringAsFixed(2)),
      };
    } catch (e) {
      print('❌ Error getting statistics: $e');
      return {
        'totalEntries': 0,
        'byMood': {},
        'mostUsedAmbience': '',
        'mostUsedAmbienceCount': 0,
        'uniqueAmbiences': 0,
        'lastEntryDate': null,
        'firstEntryDate': null,
        'averagePerDay': 0.0,
      };
    }
  }

  // ✅ NEW: Get entries grouped by month
  Map<String, List<JournalEntry>> getEntriesByMonth() {
    try {
      final allEntries = getAllEntries();
      final Map<String, List<JournalEntry>> grouped = {};

      for (var entry in allEntries) {
        final monthKey = '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}';
        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }
        grouped[monthKey]!.add(entry);
      }

      return grouped;
    } catch (e) {
      print('❌ Error grouping entries by month: $e');
      return {};
    }
  }

  // ✅ NEW: Get latest entry
  JournalEntry? getLatestEntry() {
    try {
      final allEntries = getAllEntries();
      return allEntries.isNotEmpty ? allEntries.first : null;
    } catch (e) {
      print('❌ Error getting latest entry: $e');
      return null;
    }
  }

  // ✅ NEW: Get entries count by mood
  Map<Mood, int> getMoodCounts() {
    try {
      final stats = getStatistics();
      return stats['byMood'] as Map<Mood, int>;
    } catch (e) {
      print('❌ Error getting mood counts: $e');
      return {};
    }
  }
}