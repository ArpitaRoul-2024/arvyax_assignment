import 'package:equatable/equatable.dart';

class SessionState extends Equatable {
  final String? activeAmbienceId;
  final bool isPlaying;
  final int elapsedSeconds;
  final int totalSeconds;
  final DateTime? lastUpdated;

  const SessionState({
    this.activeAmbienceId,
    required this.isPlaying,
    required this.elapsedSeconds,
    required this.totalSeconds,
    this.lastUpdated,
  });

  factory SessionState.initial() {
    return const SessionState(
      activeAmbienceId: null,
      isPlaying: false,
      elapsedSeconds: 0,
      totalSeconds: 0,
      lastUpdated: null,
    );
  }

  SessionState copyWith({
    String? activeAmbienceId,
    bool? isPlaying,
    int? elapsedSeconds,
    int? totalSeconds,
    DateTime? lastUpdated,
  }) {
    return SessionState(
      activeAmbienceId: activeAmbienceId ?? this.activeAmbienceId,
      isPlaying: isPlaying ?? this.isPlaying,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  double get progress => totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0;

  bool get hasActiveSession => activeAmbienceId != null;

  Map<String, dynamic> toJson() {
    return {
      'activeAmbienceId': activeAmbienceId,
      'isPlaying': isPlaying,
      'elapsedSeconds': elapsedSeconds,
      'totalSeconds': totalSeconds,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory SessionState.fromJson(Map<String, dynamic> json) {
    return SessionState(
      activeAmbienceId: json['activeAmbienceId'],
      isPlaying: json['isPlaying'] ?? false,
      elapsedSeconds: json['elapsedSeconds'] ?? 0,
      totalSeconds: json['totalSeconds'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    activeAmbienceId,
    isPlaying,
    elapsedSeconds,
    totalSeconds,
    lastUpdated
  ];
}