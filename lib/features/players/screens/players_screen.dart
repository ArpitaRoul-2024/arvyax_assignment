import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../data/model/ambience_model.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../../ambience/provider/ambience_provider.dart';
import '../provider/player_state_provider.dart';


class PlayerScreen extends ConsumerStatefulWidget {
  final String ambienceId;

  const PlayerScreen({super.key, required this.ambienceId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation (breathing effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize subtle rotation animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.linear,
      ),
    );

    // Start audio and timer after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSession();
    });
  }

  Future<void> _initializeSession() async {
    try {
      final ambience = await ref.read(ambienceByIdProvider(widget.ambienceId).future);
      if (ambience == null) {
        debugPrint('❌ Ambience not found');
        return;
      }

      debugPrint('🎵 Initializing session for: ${ambience.title}');
      debugPrint('📁 Audio path: ${ambience.audioAssetPath}');

      // Set audio configuration
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Play audio
      final result = await _audioPlayer.play(AssetSource(ambience.audioAssetPath));

      // Start player provider
      ref.read(playerStateProvider.notifier).startSession(
        widget.ambienceId,
        ambience.durationSeconds,
      );

      // Start timer
      _startTimer();

      // Listen to audio completion
      _audioPlayer.onPlayerComplete.listen((event) {
        debugPrint('🔄 Audio loop completed - restarting');
      });

    } catch (e) {
      debugPrint('❌ Error initializing session: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final state = ref.read(playerStateProvider);
      if (!state.isPlaying) return;

      final newElapsed = state.elapsedSeconds + 1;
      ref.read(playerStateProvider.notifier).updateProgress(newElapsed);

      // Check if session completed
      if (newElapsed >= state.totalSeconds) {
        debugPrint('✅ Session completed!');
        _timer?.cancel();
        _audioPlayer.stop();
        _navigateToReflection();
      }
    });
  }

  void _navigateToReflection() {
    final ambience = ref.read(ambienceByIdProvider(widget.ambienceId)).value;
    context.go('/reflection', extra: {
      'ambienceId': widget.ambienceId,
      'ambienceTitle': ambience?.title ?? '',
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambienceAsync = ref.watch(ambienceByIdProvider(widget.ambienceId));
    final playerState = ref.watch(playerStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Session',
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showEndSessionDialog(context),
          ),
        ],
      ),
      body: ambienceAsync.when(
        data: (ambience) {
          if (ambience == null) {
            return const Center(child: Text('Ambience not found'));
          }

          return Stack(
            children: [
              // ✅ FULL SCREEN BACKGROUND IMAGE
              Positioned.fill(
                child: _buildFullScreenImage(ambience),
              ),

              // ✅ Dark overlay for better visibility of controls
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Top spacer
                    const Spacer(flex: 1),

                    // Title and Tag
                    Column(
                      children: [
                        Text(
                          ambience.title,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.2,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            ambience.tag.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Player Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Progress Bar
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                    pressedElevation: 4,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: playerState.progress.clamp(0.0, 1.0),
                                  onChanged: (value) {
                                    final newSeconds = (value * playerState.totalSeconds).round();
                                    ref.read(playerStateProvider.notifier).seekTo(newSeconds);
                                    _audioPlayer.seek(Duration(seconds: newSeconds));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatTime(playerState.elapsedSeconds),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(playerState.totalSeconds),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Reset button
                              _buildControlButton(
                                icon: Icons.restart_alt,
                                onPressed: () {
                                  ref.read(playerStateProvider.notifier).resetSession();
                                  _audioPlayer.seek(Duration.zero);
                                },
                              ),

                              // Main Play/Pause button
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                  onPressed: () async {
                                    ref.read(playerStateProvider.notifier).togglePlayPause();
                                    if (playerState.isPlaying) {
                                      await _audioPlayer.pause();
                                      _timer?.cancel();
                                    } else {
                                      await _audioPlayer.resume();
                                      _startTimer();
                                    }
                                  },
                                ),
                              ),

                              // Extend button
                              _buildControlButton(
                                icon: Icons.add_circle_outline,
                                onPressed: () {
                                  ref.read(playerStateProvider.notifier).extendSession(60);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Preparing your session...'),
        error: (error, _) => ErrorView(
          message: 'Failed to load session: $error',
          onRetry: () {
            ref.invalidate(ambienceByIdProvider(widget.ambienceId));
          },
        ),
      ),
    );
  }

  // ✅ Build FULL SCREEN image based on ambience ID
  Widget _buildFullScreenImage(Ambience ambience) {
    // Map ambience titles to image files
    String imagePath = _getImagePathForAmbience(ambience.title);

    debugPrint('🖼️ Loading background image: $imagePath for ${ambience.title}');

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading image: $error');
        // Fallback color based on tag
        return Container(
          color: _getTagColor(ambience.tag).withOpacity(0.5),
        );
      },
    );
  }

  // ✅ Get image path based on ambience title
  String _getImagePathForAmbience(String title) {
    // Map titles to image files based on your images list
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

  // ✅ Build control button
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  // ✅ Get color for tag (fallback)
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              _audioPlayer.stop();
              ref.read(playerStateProvider.notifier).endSession();
              Navigator.pop(ctx);
              _navigateToReflection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('End'),
          ),
        ],
      ),
    );
  }
}