import 'package:equatable/equatable.dart';

enum AmbienceTag { focus, calm, sleep, reset }

class Ambience extends Equatable {
  final String id;
  final String title;
  final AmbienceTag tag;
  final int durationMinutes;
  final String description;
  final String imageUrl;
  final List<String> sensoryChips;
  final String audioAssetPath;

  const Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.durationMinutes,
    required this.description,
    required this.imageUrl,
    required this.sensoryChips,
    required this.audioAssetPath,
  });

  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] ?? DateTime.now().toString(),
      title: json['title'] ?? '',
      tag: _parseTag(json['tag']),
      durationMinutes: json['durationMinutes'] ?? 2,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sensoryChips: List<String>.from(json['sensoryChips'] ?? []),
      audioAssetPath: json['audioAssetPath'] ?? '',
    );
  }

  static AmbienceTag _parseTag(String tag) {
    switch (tag.toLowerCase()) {
      case 'focus':
        return AmbienceTag.focus;
      case 'calm':
        return AmbienceTag.calm;
      case 'sleep':
        return AmbienceTag.sleep;
      case 'reset':
        return AmbienceTag.reset;
      default:
        return AmbienceTag.calm;
    }
  }

  int get durationSeconds => durationMinutes * 60;

  @override
  List<Object?> get props => [id, title, tag, durationMinutes];
}