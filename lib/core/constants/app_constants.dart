import 'package:flutter/material.dart';

class AppConstants {
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Padding values
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 30.0;

  // Grid settings
  static const int gridCrossCount = 2;
  static const double gridSpacing = 16.0;

  // Tag filters
  static const List<Map<String, dynamic>> tagFilters = [
    {'label': 'All', 'value': null},
    {'label': 'Focus', 'value': 'focus'},
    {'label': 'Calm', 'value': 'calm'},
    {'label': 'Sleep', 'value': 'sleep'},
    {'label': 'Reset', 'value': 'reset'},
  ];

  // Mood options
  static const List<Map<String, dynamic>> moodOptions = [
    {'label': 'Calm', 'value': 'calm', 'icon': Icons.spa},
    {'label': 'Grounded', 'value': 'grounded', 'icon': Icons.landscape},
    {'label': 'Energized', 'value': 'energized', 'icon': Icons.wb_sunny},
    {'label': 'Sleepy', 'value': 'sleepy', 'icon': Icons.nightlight},
  ];
}