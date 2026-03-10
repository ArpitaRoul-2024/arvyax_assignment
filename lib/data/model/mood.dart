import 'package:hive/hive.dart';
part 'mood.g.dart';

@HiveType(typeId: 0)
enum Mood {
  @HiveField(0)
  calm,

  @HiveField(1)
  grounded,

  @HiveField(2)
  energized,

  @HiveField(3)
  sleepy,
}

// Extension for display names
extension MoodExtension on Mood {
  String get displayName {
    switch (this) {
      case Mood.calm:
        return 'Calm';
      case Mood.grounded:
        return 'Grounded';
      case Mood.energized:
        return 'Energized';
      case Mood.sleepy:
        return 'Sleepy';
    }
  }

  String get emoji {
    switch (this) {
      case Mood.calm:
        return '😌';
      case Mood.grounded:
        return '🌱';
      case Mood.energized:
        return '⚡';
      case Mood.sleepy:
        return '😴';
    }
  }
}