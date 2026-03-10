import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/players/provider/player_state_provider.dart';


class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(playerStateProvider);
    final theme = Theme.of(context);

    if (!sessionState.hasActiveSession) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        if (sessionState.activeAmbienceId != null) {
          context.push('/player/${sessionState.activeAmbienceId}');
        }
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.spa,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Title and progress
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Session',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: sessionState.progress,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),

              // Play/Pause button
              IconButton(
                icon: Icon(
                  sessionState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  ref.read(playerStateProvider.notifier).togglePlayPause();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}