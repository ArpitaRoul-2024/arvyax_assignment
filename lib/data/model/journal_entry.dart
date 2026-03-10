import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'mood.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 1)
class JournalEntry extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ambienceId;

  @HiveField(2)
  final String ambienceTitle;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final Mood mood;

  @HiveField(5)
  final DateTime timestamp;

  const JournalEntry({
    required this.id,
    required this.ambienceId,
    required this.ambienceTitle,
    required this.text,
    required this.mood,
    required this.timestamp,
  });

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (entryDate == today) return 'Today';
    if (entryDate == yesterday) return 'Yesterday';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get previewText => text.length > 50
      ? '${text.substring(0, 50)}...'
      : text;

  @override
  List<Object?> get props => [id, ambienceId, timestamp];
}