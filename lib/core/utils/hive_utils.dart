import 'package:hive_flutter/hive_flutter.dart';

import '../../data/model/journal_entry.dart';
import '../../data/model/mood.dart';


class HiveUtils {
  static const String journalBoxName = 'journalBox';
  static const String sessionBoxName = 'sessionBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }

    // Open boxes
    await Hive.openBox<JournalEntry>(journalBoxName);
    await Hive.openBox<Map>(sessionBoxName);
  }

  static Box<JournalEntry> get journalBox =>
      Hive.box<JournalEntry>(journalBoxName);

  static Box<Map> get sessionBox =>
      Hive.box<Map>(sessionBoxName);

  // Helper methods for journal
  static Future<void> addJournalEntry(JournalEntry entry) async {
    await journalBox.put(entry.id, entry);
  }

  static List<JournalEntry> getAllJournalEntries() {
    return journalBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static JournalEntry? getJournalEntry(String id) {
    return journalBox.get(id);
  }

  static Future<void> deleteJournalEntry(String id) async {
    await journalBox.delete(id);
  }

  // Helper methods for session
  static Future<void> saveSession(Map<String, dynamic> sessionData) async {
    await sessionBox.put('activeSession', sessionData);
  }

  static Map? getSession() {
    return sessionBox.get('activeSession');
  }

  static Future<void> clearSession() async {
    await sessionBox.delete('activeSession');
  }
}