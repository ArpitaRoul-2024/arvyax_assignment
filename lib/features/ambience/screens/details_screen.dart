import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/model/ambience_model.dart';
  import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../provider/ambience_provider.dart';

class DetailsScreen extends ConsumerWidget {
  final String ambienceId;

  const DetailsScreen({super.key, required this.ambienceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(ambienceId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ambience Details',
        showBackButton: true,
      ),
      body: ambienceAsync.when(
        data: (ambience) {
          if (ambience == null) {
            return const Center(child: Text('Ambience not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image - Now shows GIF based on ambience title
                Container(
                  height: 250,
                  width: double.infinity,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Stack(
                    children: [
                      // GIF Image instead of icon
                      _buildHeroImage(ambience, theme),

                      // Duration badge
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${ambience.durationMinutes} min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Tag
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ambience.title,
                              style: theme.textTheme.displayMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagColor(ambience.tag),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ambience.tag.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ambience.description,
                        style: theme.textTheme.bodyLarge,
                      ),

                      const SizedBox(height: 24),

                      // Sensory Chips
                      Text(
                        'Sensory Experience',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ambience.sensoryChips.map((chip) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),

                      // Start Session Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/player/$ambienceId');
                          },
                          child: const Text(
                            'Start Session',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading details...'),
        error: (error, _) => ErrorView(
          message: 'Error loading details: $error',
          onRetry: () {
            ref.invalidate(ambienceByIdProvider(ambienceId));
          },
        ),
      ),
    );
  }

  // ✅ Build hero image based on ambience title
  Widget _buildHeroImage(Ambience ambience, ThemeData theme) {
    String imagePath = _getImagePathForAmbience(ambience.title);

    debugPrint('🖼️ Loading hero image: $imagePath for ${ambience.title}');

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 250,
      gaplessPlayback: true, // Smooth for GIFs
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading image: $error');
        // Fallback to colored container with icon
        return Container(
          color: _getTagColor(ambience.tag).withOpacity(0.2),
          child: Center(
            child: Icon(
              _getIconForTag(ambience.tag),
              size: 80,
              color: _getTagColor(ambience.tag).withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }

  // ✅ Get image path based on ambience title
  String _getImagePathForAmbience(String title) {
    // Map titles to image files
    final Map<String, String> imageMap = {
      'Forest Focus': 'assets/images/forest.jpg',
      'Ocean Calm': 'assets/images/ocean.jpg',
      'Deep Sleep': 'assets/images/sleep.jpg',
      'Morning Reset': 'assets/images/morning.jpg',
      'Rainy Focus': 'assets/images/rain.jpg',
      'Zen Garden': 'assets/images/garden.jpg',
      'Mountain Peak': 'assets/images/mountain.jpg',
      'Desert Night': 'assets/images/desert.jpg',
    };

    return imageMap[title] ?? 'assets/images/forest.jpg'; // Default fallback
  }

  // ✅ Get icon for tag (fallback)
  IconData _getIconForTag(AmbienceTag tag) {
    switch (tag) {
      case AmbienceTag.focus:
        return Icons.psychology;
      case AmbienceTag.calm:
        return Icons.spa;
      case AmbienceTag.sleep:
        return Icons.nightlight;
      case AmbienceTag.reset:
        return Icons.wb_sunny;
    }
  }

  // ✅ Get color for tag
  Color _getTagColor(AmbienceTag tag) {
    switch (tag) {
      case AmbienceTag.focus:
        return Colors.blue;
      case AmbienceTag.calm:
        return Colors.green;
      case AmbienceTag.sleep:
        return Colors.purple;
      case AmbienceTag.reset:
        return Colors.orange;
    }
  }
}