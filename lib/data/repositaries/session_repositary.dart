import '../model/session_state.dart';
 import '../../core/utils/hive_utils.dart';

class SessionRepository {
  static const String _sessionKey = 'activeSession';

  /// Save session state to local storage
  Future<void> saveSession(SessionState session) async {
    try {
      final box = HiveUtils.sessionBox;
      await box.put(_sessionKey, session.toJson());
      print('✅ Session saved: ${session.activeAmbienceId}');
    } catch (e) {
      print('❌ Error saving session: $e');
    }
  }

  /// Get last active session
  SessionState getLastSession() {
    try {
      final box = HiveUtils.sessionBox;
      final data = box.get(_sessionKey);

      if (data == null) {
        print('ℹ️ No active session found');
        return SessionState.initial();
      }

      final session = SessionState.fromJson(Map<String, dynamic>.from(data));

      // Calculate elapsed time if session was playing
      if (session.isPlaying && session.lastUpdated != null) {
        final now = DateTime.now();
        final elapsed = now.difference(session.lastUpdated!).inSeconds;
        final newElapsed = session.elapsedSeconds + elapsed;

        // Check if session completed
        if (newElapsed >= session.totalSeconds) {
          print('✅ Session completed while away');
          clearSession();
          return SessionState.initial();
        }

        // Update elapsed time
        final updatedSession = session.copyWith(
          elapsedSeconds: newElapsed,
          lastUpdated: now,
        );

        // Save updated session
        saveSession(updatedSession);

        print('🔄 Session resumed: ${updatedSession.elapsedSeconds}/${updatedSession.totalSeconds} seconds');
        return updatedSession;
      }

      print('📂 Session loaded: ${session.activeAmbienceId}');
      return session;
    } catch (e) {
      print('❌ Error loading session: $e');
      return SessionState.initial();
    }
  }

  /// Clear active session
  Future<void> clearSession() async {
    try {
      final box = HiveUtils.sessionBox;
      await box.delete(_sessionKey);
      print('🗑️ Session cleared');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  /// Update session progress
  Future<void> updateProgress(int elapsedSeconds, int totalSeconds) async {
    try {
      final currentSession = getLastSession();
      if (!currentSession.hasActiveSession) return;

      final updatedSession = currentSession.copyWith(
        elapsedSeconds: elapsedSeconds,
        lastUpdated: DateTime.now(),
      );

      // Check if session completed
      if (elapsedSeconds >= totalSeconds) {
        print('✅ Session completed');
        await clearSession();
      } else {
        await saveSession(updatedSession);
        print('⏱️ Progress updated: $elapsedSeconds/$totalSeconds seconds');
      }
    } catch (e) {
      print('❌ Error updating progress: $e');
    }
  }

  /// Check if session is active
  bool hasActiveSession() {
    try {
      final box = HiveUtils.sessionBox;
      return box.containsKey(_sessionKey);
    } catch (e) {
      print('❌ Error checking active session: $e');
      return false;
    }
  }

  /// Get session duration remaining
  Duration? getRemainingTime() {
    try {
      final session = getLastSession();
      if (!session.hasActiveSession) return null;

      final remaining = session.totalSeconds - session.elapsedSeconds;
      return Duration(seconds: remaining > 0 ? remaining : 0);
    } catch (e) {
      print('❌ Error getting remaining time: $e');
      return null;
    }
  }

  /// Pause session
  Future<void> pauseSession() async {
    try {
      final currentSession = getLastSession();
      if (!currentSession.hasActiveSession || !currentSession.isPlaying) return;

      final updatedSession = currentSession.copyWith(
        isPlaying: false,
        lastUpdated: DateTime.now(),
      );

      await saveSession(updatedSession);
      print('⏸️ Session paused');
    } catch (e) {
      print('❌ Error pausing session: $e');
    }
  }

  /// Resume session
  Future<void> resumeSession() async {
    try {
      final currentSession = getLastSession();
      if (!currentSession.hasActiveSession || currentSession.isPlaying) return;

      final updatedSession = currentSession.copyWith(
        isPlaying: true,
        lastUpdated: DateTime.now(),
      );

      await saveSession(updatedSession);
      print('▶️ Session resumed');
    } catch (e) {
      print('❌ Error resuming session: $e');
    }
  }

  /// Get session statistics
  Map<String, dynamic> getSessionStats() {
    try {
      final session = getLastSession();

      if (!session.hasActiveSession) {
        return {
          'hasActiveSession': false,
          'message': 'No active session',
        };
      }

      final remaining = session.totalSeconds - session.elapsedSeconds;
      final progress = (session.elapsedSeconds / session.totalSeconds * 100).round();

      return {
        'hasActiveSession': true,
        'ambienceId': session.activeAmbienceId,
        'isPlaying': session.isPlaying,
        'elapsedSeconds': session.elapsedSeconds,
        'totalSeconds': session.totalSeconds,
        'remainingSeconds': remaining,
        'progress': progress,
        'lastUpdated': session.lastUpdated,
      };
    } catch (e) {
      print('❌ Error getting session stats: $e');
      return {'hasActiveSession': false, 'error': e.toString()};
    }
  }

  /// Extend session duration
  Future<void> extendSession(int additionalSeconds) async {
    try {
      final currentSession = getLastSession();
      if (!currentSession.hasActiveSession) return;

      final updatedSession = currentSession.copyWith(
        totalSeconds: currentSession.totalSeconds + additionalSeconds,
        lastUpdated: DateTime.now(),
      );

      await saveSession(updatedSession);
      print('➕ Session extended by $additionalSeconds seconds');
    } catch (e) {
      print('❌ Error extending session: $e');
    }
  }

  /// Reset session to beginning
  Future<void> resetSession() async {
    try {
      final currentSession = getLastSession();
      if (!currentSession.hasActiveSession) return;

      final updatedSession = currentSession.copyWith(
        elapsedSeconds: 0,
        lastUpdated: DateTime.now(),
      );

      await saveSession(updatedSession);
      print('🔄 Session reset to beginning');
    } catch (e) {
      print('❌ Error resetting session: $e');
    }
  }
}