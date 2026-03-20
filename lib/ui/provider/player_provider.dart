import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import '../../model/song_mode.dart';
import './songs_proivider.dart';

part 'player_provider.g.dart';

// Current song index provider
@riverpod
class CurrentSongIndex extends _$CurrentSongIndex {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }

  void nextSong() {
    final playlist = ref.read(playlistProvider);
    if (state < playlist.length - 1) {
      state = state + 1;
    }
  }

  void previousSong() {
    if (state > 0) {
      state = state - 1;
    }
  }
}

// Current playing song provider
@riverpod
Song? currentSong(CurrentSongRef ref) {
  final index = ref.watch(currentSongIndexProvider);
  final playlist = ref.watch(playlistProvider);

  if (index >= 0 && index < playlist.length) {
    return playlist[index];
  }
  return null;
}

// Audio player instance
@riverpod
AudioPlayer audioPlayer(AudioPlayerRef ref) {
  final player = AudioPlayer();

  // Cleanup when provider is disposed
  ref.onDispose(() {
    player.dispose();
  });

  return player;
}

// Play/Pause state provider
@riverpod
class PlayingState extends _$PlayingState {
  @override
  bool build() {
    return false; // false = paused, true = playing
  }

  Future<void> toggle() async {
    final player = ref.read(audioPlayerProvider);
    final currentSong = ref.read(currentSongProvider);

    if (currentSong == null) return;

    if (state) {
      // Currently playing - pause
      await player.pause();
      state = false;
    } else {
      // Currently paused - play
      if (player.playing) {
        // Already has audio loaded
        await player.play();
      } else {
        // Load and play
        await player.setFilePath(currentSong.filePath);
        await player.play();
      }
      state = true;
    }
  }
}

// Current position stream
@riverpod
Stream<Duration> currentPosition(CurrentPositionRef ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.positionStream;
}

// Current duration stream
@riverpod
Stream<Duration?> totalDuration(TotalDurationRef ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.durationStream;
}
