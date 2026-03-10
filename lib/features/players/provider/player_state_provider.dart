import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/model/session_state.dart';
import '../../../data/repositaries/session_repositary.dart';


final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final playerStateProvider = StateNotifierProvider<PlayerNotifier, SessionState>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return PlayerNotifier(sessionRepo: sessionRepo);
});

class PlayerNotifier extends StateNotifier<SessionState> {
  final SessionRepository sessionRepo;

  PlayerNotifier({required this.sessionRepo}) : super(sessionRepo.getLastSession());

  /// Start a new session
  void startSession(String ambienceId, int totalSeconds) {
    final newState = SessionState(
      activeAmbienceId: ambienceId,
      isPlaying: true,
      elapsedSeconds: 0,
      totalSeconds: totalSeconds,
      lastUpdated: DateTime.now(),
    );

    state = newState;
    sessionRepo.saveSession(newState);
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (state.isPlaying) {
      sessionRepo.pauseSession();
    } else {
      sessionRepo.resumeSession();
    }

    state = state.copyWith(
      isPlaying: !state.isPlaying,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update progress
  void updateProgress(int elapsedSeconds) {
    // Check if session completed
    if (elapsedSeconds >= state.totalSeconds) {
      endSession();
      return;
    }

    state = state.copyWith(
      elapsedSeconds: elapsedSeconds,
      lastUpdated: DateTime.now(),
    );

    sessionRepo.updateProgress(elapsedSeconds, state.totalSeconds);
  }

  /// Seek to position
  void seekTo(int seconds) {
    if (seconds > state.totalSeconds) {
      seconds = state.totalSeconds;
    }
    if (seconds < 0) {
      seconds = 0;
    }

    state = state.copyWith(
      elapsedSeconds: seconds,
      lastUpdated: DateTime.now(),
    );

    sessionRepo.saveSession(state);
  }

  /// End session
  void endSession() {
    sessionRepo.clearSession();
    state = SessionState.initial();
  }

  /// Extend session
  void extendSession(int additionalSeconds) {
    sessionRepo.extendSession(additionalSeconds);
    state = state.copyWith(
      totalSeconds: state.totalSeconds + additionalSeconds,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reset session
  void resetSession() {
    sessionRepo.resetSession();
    state = state.copyWith(
      elapsedSeconds: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Check if session is completed
  bool isSessionCompleted() {
    return state.elapsedSeconds >= state.totalSeconds;
  }

  /// Get remaining time in seconds
  int getRemainingSeconds() {
    return state.totalSeconds - state.elapsedSeconds;
  }

  /// Get progress percentage
  double getProgress() {
    return state.elapsedSeconds / state.totalSeconds;
  }
}