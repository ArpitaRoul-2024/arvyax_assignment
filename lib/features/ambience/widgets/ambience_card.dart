import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // ✅ Add this import

import '../../../core/constants/app_constants.dart';
import '../../../data/model/ambience_model.dart';

class AmbienceCard extends StatelessWidget {
  final Ambience ambience;
  final VoidCallback onTap;

  const AmbienceCard({
    super.key,
    required this.ambience,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusL),
              ),
              child: Stack(
                children: [
                  // Image/Animation
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: _buildMedia(theme), // ✅ Unified media builder
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tag chip
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildTagChip(theme),
                  ),
                  // Duration
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _buildDurationChip(theme),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ambience.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Sensory chips preview
                  SizedBox(
                    height: 24,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ambience.sensoryChips.length > 2
                          ? 2
                          : ambience.sensoryChips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ambience.sensoryChips[index],
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Unified media builder - handles all types
  Widget _buildMedia(ThemeData theme) {
    final imageUrl = ambience.imageUrl.toLowerCase();

    // Check for Lottie animations (.json files)
    if (imageUrl.endsWith('.json')) {
      return _buildLottieAnimation(theme);
    }
    // Check for GIFs
    else if (imageUrl.endsWith('.gif')) {
      return _buildGifImage(theme);
    }
    // Check for asset images
    else if (ambience.imageUrl.startsWith('assets/')) {
      return _buildAssetImage(theme);
    }
    // Default to network image
    else {
      return _buildNetworkImage(theme);
    }
  }

  // ✅ Build asset image
  Widget _buildAssetImage(ThemeData theme) {
    return Image.asset(
      ambience.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading asset image: $error');
        return _buildIconPlaceholder(theme);
      },
    );
  }

  // ✅ Build GIF image with smooth looping
  Widget _buildGifImage(ThemeData theme) {
    return Image.asset(
      ambience.imageUrl,
      fit: BoxFit.cover,
      gaplessPlayback: true, // Smooth looping for GIFs
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading GIF: $error');
        return _buildIconPlaceholder(theme);
      },
    );
  }

  // ✅ Build network image
  Widget _buildNetworkImage(ThemeData theme) {
    return Image.network(
      ambience.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading network image: $error');
        return _buildIconPlaceholder(theme);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: theme.colorScheme.primary.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  // ✅ Build Lottie animation
  Widget _buildLottieAnimation(ThemeData theme) {
    return Lottie.asset(
      ambience.imageUrl, // Use the imageUrl from ambience
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading Lottie: $error');
        return _buildIconPlaceholder(theme);
      },
    );
  }

  // ✅ Build tag chip
  Widget _buildTagChip(ThemeData theme) {
    Color tagColor;
    switch (ambience.tag) {
      case AmbienceTag.focus:
        tagColor = Colors.blue;
        break;
      case AmbienceTag.calm:
        tagColor = Colors.green;
        break;
      case AmbienceTag.sleep:
        tagColor = Colors.purple;
        break;
      case AmbienceTag.reset:
        tagColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ambience.tag.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ✅ Build duration chip
  Widget _buildDurationChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            '${ambience.durationMinutes} min',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fallback icon placeholder
  Widget _buildIconPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.2),
      child: Center(
        child: Icon(
          _getIconForTag(),
          size: 40,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  // ✅ Get icon based on tag
  IconData _getIconForTag() {
    switch (ambience.tag) {
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
}