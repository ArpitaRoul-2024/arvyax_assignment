// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 0;

  @override
  Mood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Mood.calm;
      case 1:
        return Mood.grounded;
      case 2:
        return Mood.energized;
      case 3:
        return Mood.sleepy;
      default:
        return Mood.calm;
    }
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    switch (obj) {
      case Mood.calm:
        writer.writeByte(0);
        break;
      case Mood.grounded:
        writer.writeByte(1);
        break;
      case Mood.energized:
        writer.writeByte(2);
        break;
      case Mood.sleepy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
