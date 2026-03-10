import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../model/ambience_model.dart';

class AmbienceRepository {
  // Cache for ambiences to avoid repeated JSON parsing
  List<Ambience>? _cachedAmbiences;
  DateTime? _lastFetchTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  /// Get all ambiences from local JSON asset
  Future<List<Ambience>> getAmbiences() async {
    try {
      // Return cached data if available and not expired
      if (_cachedAmbiences != null && _isCacheValid()) {
        debugPrint('📦 Returning cached ambiences: ${_cachedAmbiences!.length} items');
        return _cachedAmbiences!;
      }

      debugPrint('📂 Loading ambiences from JSON asset...');

      // Load JSON from assets
      final String response = await rootBundle.loadString('ambiences.json');
      final List<dynamic> data = json.decode(response);

      // Parse JSON to Ambience objects
      final ambiences = data.map((json) {
        try {
          return Ambience.fromJson(json);
        } catch (e) {
          debugPrint('❌ Error parsing ambience: $e');
          return null;
        }
      }).whereType<Ambience>().toList();

      debugPrint('✅ Loaded ${ambiences.length} ambiences successfully');

      // Update cache
      _cachedAmbiences = ambiences;
      _lastFetchTime = DateTime.now();

      return ambiences;
    } catch (e) {
      debugPrint('❌ Error loading ambiences: $e');

      // Return cached data even if expired, rather than empty list
      if (_cachedAmbiences != null) {
        debugPrint('⚠️ Returning expired cache as fallback');
        return _cachedAmbiences!;
      }

      return [];
    }
  }

  /// Get ambience by ID
  Future<Ambience?> getAmbienceById(String id) async {
    try {
      final ambiences = await getAmbiences();

      // Safely find ambience by ID (case-sensitive comparison)
      final ambience = ambiences.firstWhere(
            (a) => a.id == id,
        orElse: () => throw Exception('Ambience not found'),
      );

      debugPrint('🔍 Found ambience: ${ambience.title} for ID: $id');
      return ambience;
    } catch (e) {
      debugPrint('❌ Error getting ambience by ID $id: $e');

      // Try to find in cache without fetching again
      if (_cachedAmbiences != null) {
        try {
          return _cachedAmbiences!.firstWhere((a) => a.id == id);
        } catch (_) {
          return null;
        }
      }

      return null;
    }
  }

  /// Get ambiences by tag
  Future<List<Ambience>> getAmbiencesByTag(AmbienceTag tag) async {
    try {
      final ambiences = await getAmbiences();
      final filtered = ambiences.where((a) => a.tag == tag).toList();

      debugPrint('🏷️ Found ${filtered.length} ambiences with tag: $tag');
      return filtered;
    } catch (e) {
      debugPrint('❌ Error getting ambiences by tag: $e');
      return [];
    }
  }

  /// Search ambiences by query
  Future<List<Ambience>> searchAmbiences(String query) async {
    if (query.isEmpty) return getAmbiences();

    try {
      final ambiences = await getAmbiences();
      final searchTerm = query.toLowerCase().trim();

      final results = ambiences.where((ambience) {
        return ambience.title.toLowerCase().contains(searchTerm) ||
            ambience.description.toLowerCase().contains(searchTerm) ||
            ambience.sensoryChips.any(
                    (chip) => chip.toLowerCase().contains(searchTerm)
            );
      }).toList();

      debugPrint('🔎 Found ${results.length} ambiences matching: "$query"');
      return results;
    } catch (e) {
      debugPrint('❌ Error searching ambiences: $e');
      return [];
    }
  }

  /// Get featured ambiences (random selection or based on some logic)
  Future<List<Ambience>> getFeaturedAmbiences({int count = 3}) async {
    try {
      final ambiences = await getAmbiences();

      // Shuffle and take first 'count' items
      final shuffled = List<Ambience>.from(ambiences)..shuffle();
      final featured = shuffled.take(count).toList();

      debugPrint('⭐ Selected ${featured.length} featured ambiences');
      return featured;
    } catch (e) {
      debugPrint('❌ Error getting featured ambiences: $e');
      return [];
    }
  }

  /// Get recommended ambiences based on a reference ambience
  Future<List<Ambience>> getRecommendedAmbiences(String ambienceId, {int count = 3}) async {
    try {
      final ambiences = await getAmbiences();
      final currentAmbience = ambiences.firstWhere((a) => a.id == ambienceId);

      // Find ambiences with same tag first
      final sameTag = ambiences
          .where((a) => a.id != ambienceId && a.tag == currentAmbience.tag)
          .toList();

      // If we have enough same-tag ambiences, return them
      if (sameTag.length >= count) {
        sameTag.shuffle();
        return sameTag.take(count).toList();
      }

      // Otherwise, mix with other ambiences
      final otherAmbiences = ambiences
          .where((a) => a.id != ambienceId && a.tag != currentAmbience.tag)
          .toList()
        ..shuffle();

      final recommendations = [...sameTag, ...otherAmbiences].take(count).toList();

      debugPrint('🎯 Found ${recommendations.length} recommendations for: ${currentAmbience.title}');
      return recommendations;
    } catch (e) {
      debugPrint('❌ Error getting recommendations: $e');
      return [];
    }
  }

  /// Get all unique sensory chips from all ambiences
  Future<List<String>> getAllSensoryChips() async {
    try {
      final ambiences = await getAmbiences();

      // Collect all chips and remove duplicates
      final allChips = ambiences
          .expand((a) => a.sensoryChips)
          .toSet()
          .toList();

      debugPrint('🧩 Found ${allChips.length} unique sensory chips');
      return allChips;
    } catch (e) {
      debugPrint('❌ Error getting sensory chips: $e');
      return [];
    }
  }

  /// Get ambiences by sensory chip
  Future<List<Ambience>> getAmbiencesBySensoryChip(String chip) async {
    try {
      final ambiences = await getAmbiences();

      final filtered = ambiences
          .where((a) => a.sensoryChips.any(
              (c) => c.toLowerCase() == chip.toLowerCase()
      ))
          .toList();

      debugPrint('🧪 Found ${filtered.length} ambiences with chip: $chip');
      return filtered;
    } catch (e) {
      debugPrint('❌ Error filtering by sensory chip: $e');
      return [];
    }
  }

  /// Get ambience duration in formatted string
  String getFormattedDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '$hours hr $remainingMinutes min'
          : '$hours hr';
    }
  }

  /// Refresh cache by forcing reload from asset
  Future<List<Ambience>> refreshAmbiences() async {
    _cachedAmbiences = null;
    _lastFetchTime = null;
    return getAmbiences();
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    final age = DateTime.now().difference(_lastFetchTime!);
    return age <= cacheDuration;
  }

  /// Clear cache
  void clearCache() {
    _cachedAmbiences = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Ambience cache cleared');
  }

  /// Get total count of ambiences
  Future<int> getAmbienceCount() async {
    final ambiences = await getAmbiences();
    return ambiences.length;
  }

  /// Validate if ambience exists
  Future<bool> ambienceExists(String id) async {
    final ambience = await getAmbienceById(id);
    return ambience != null;
  }

  /// Get random ambience
  Future<Ambience?> getRandomAmbience() async {
    final ambiences = await getAmbiences();
    if (ambiences.isEmpty) return null;

    final randomIndex = DateTime.now().microsecondsSinceEpoch % ambiences.length;
    return ambiences[randomIndex];
  }

  /// Get ambience statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final ambiences = await getAmbiences();

    // Count by tag
    final tagCount = <AmbienceTag, int>{};
    for (var tag in AmbienceTag.values) {
      tagCount[tag] = 0;
    }

    for (var ambience in ambiences) {
      tagCount[ambience.tag] = (tagCount[ambience.tag] ?? 0) + 1;
    }

    // Find min and max duration
    int minDuration = ambiences.isNotEmpty
        ? ambiences.map((a) => a.durationMinutes).reduce((a, b) => a < b ? a : b)
        : 0;

    int maxDuration = ambiences.isNotEmpty
        ? ambiences.map((a) => a.durationMinutes).reduce((a, b) => a > b ? a : b)
        : 0;

    // Average duration
    double avgDuration = ambiences.isNotEmpty
        ? ambiences.map((a) => a.durationMinutes).reduce((a, b) => a + b) / ambiences.length
        : 0;

    return {
      'totalCount': ambiences.length,
      'byTag': tagCount,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'avgDuration': avgDuration.round(),
      'totalSensoryChips': await getAllSensoryChips().then((chips) => chips.length),
    };
  }
}