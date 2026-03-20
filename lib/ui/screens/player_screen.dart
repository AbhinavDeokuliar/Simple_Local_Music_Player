import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/player_provider.dart';
import '../widgets/music_card.dart';
import '../widgets/control_buttons.dart';
import '../widgets/progress_bar.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers
    final currentSong = ref.watch(currentSongProvider);
    final isPlaying = ref.watch(playingStateProvider);
    final currentPosition = ref.watch(currentPositionProvider);
    final totalDuration = ref.watch(totalDurationProvider);

    // Get notifiers for state management
    final playingStateNotifier = ref.read(playingStateProvider.notifier);
    final currentSongIndexNotifier = ref.read(
      currentSongIndexProvider.notifier,
    );

    if (currentSong == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Player'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('No songs available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Song Info
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SongName(
              songTitle: currentSong.title,
              artistName: currentSong.artist,
            ),
          ),

          // Music Card (Album Art) - Takes up available space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Mcards(
                songTitle: currentSong.title,
                artistName: currentSong.artist,
                imagePath: currentSong.coverUrl,
              ),
            ),
          ),

          // Progress Bar with Stream
          currentPosition.when(
            data: (position) {
              final duration = totalDuration.maybeWhen(
                data: (dur) => dur ?? currentSong.duration,
                orElse: () => currentSong.duration,
              );
              return ProgressBar(
                currentDuration: position,
                totalDuration: duration,
                onChanged: (seconds) async {
                  final player = ref.read(audioPlayerProvider);
                  await player.seek(Duration(seconds: seconds.toInt()));
                },
              );
            },
            loading: () => ProgressBar(
              currentDuration: Duration.zero,
              totalDuration: currentSong.duration,
            ),
            error: (error, _) => Text('Error: $error'),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ControlButtons(
              isPlaying: isPlaying,
              onPlayPause: () => playingStateNotifier.toggle(),
              onSkipNext: () => currentSongIndexNotifier.nextSong(),
              onSkipPrevious: () => currentSongIndexNotifier.previousSong(),
            ),
          ),
        ],
      ),
    );
  }
}

class SongName extends StatelessWidget {
  final String songTitle;
  final String artistName;

  const SongName({
    super.key,
    required this.songTitle,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          songTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          artistName,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
