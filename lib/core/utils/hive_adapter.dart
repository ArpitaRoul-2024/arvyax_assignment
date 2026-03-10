import 'package:hive/hive.dart';
import '../../data/model/journal_entry.dart';
import '../../data/model/mood.dart';


// Manual adapter for Mood
class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 0;

  @override
  Mood read(BinaryReader reader) {
    final index = reader.readInt();
    return Mood.values[index];
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    writer.writeInt(obj.index);
  }
}

// Manual adapter for JournalEntry
class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 1;

  @override
  JournalEntry read(BinaryReader reader) {
    return JournalEntry(
      id: reader.readString(),
      ambienceId: reader.readString(),
      ambienceTitle: reader.readString(),
      text: reader.readString(),
      mood: reader.read() as Mood,
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.ambienceId);
    writer.writeString(obj.ambienceTitle);
    writer.writeString(obj.text);
    writer.write(obj.mood);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}