import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

  Future<void> setIndex(int index) async {
    state = index;
    final player = ref.read(audioPlayerProvider);
    final sequence = player.sequence;
    if (sequence != null &&
        sequence.isNotEmpty &&
        index >= 0 &&
        index < sequence.length) {
      await player.seek(Duration.zero, index: index);
    }
  }

  Future<void> nextSong() async {
    final playlist = ref.read(playlistProvider);
    if (state < playlist.length - 1) {
      state = state + 1;
      final player = ref.read(audioPlayerProvider);
      if (player.hasNext) {
        await player.seekToNext();
      }
    }
  }

  Future<void> previousSong() async {
    if (state > 0) {
      state = state - 1;
      final player = ref.read(audioPlayerProvider);
      if (player.hasPrevious) {
        await player.seekToPrevious();
      }
    }
  }

  void syncFromPlayer(int index) {
    if (state != index) {
      state = index;
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
    final player = ref.watch(audioPlayerProvider);

    final playingSubscription = player.playingStream.listen((isPlaying) {
      if (state != isPlaying) {
        state = isPlaying;
      }
    });

    final indexSubscription = player.currentIndexStream.listen((index) {
      if (index != null) {
        ref.read(currentSongIndexProvider.notifier).syncFromPlayer(index);
      }
    });

    ref.onDispose(() {
      playingSubscription.cancel();
      indexSubscription.cancel();
    });

    return player.playing;
  }

  Future<void> toggle() async {
    final player = ref.read(audioPlayerProvider);
    final currentSong = ref.read(currentSongProvider);
    final playlist = ref.read(playlistProvider);
    final currentIndex = ref.read(currentSongIndexProvider);

    if (currentSong == null) return;

    if (state) {
      // Currently playing - pause
      await player.pause();
      state = false;
    } else {
      // Currently paused - play
      final sequenceLength = player.sequence?.length ?? 0;
      final shouldReload =
          player.audioSource == null || sequenceLength != playlist.length;
      if (shouldReload) {
        await player.setAudioSource(
          ConcatenatingAudioSource(
            children: playlist.map(_songToAudioSource).toList(),
          ),
          initialIndex: currentIndex,
          initialPosition: Duration.zero,
        );
      } else if (player.currentIndex != currentIndex) {
        await player.seek(Duration.zero, index: currentIndex);
      }

      await player.play();
      state = true;
    }
  }

  AudioSource _songToAudioSource(Song song) {
    return AudioSource.uri(
      Uri.file(song.filePath),
      tag: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        artUri: _toArtUri(song.coverUrl),
      ),
    );
  }

  Uri? _toArtUri(String? coverUrl) {
    if (coverUrl == null || coverUrl.trim().isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(coverUrl);
    if (parsed == null) {
      return null;
    }

    if (parsed.hasScheme) {
      return parsed;
    }

    if (coverUrl.startsWith('/')) {
      return Uri.file(coverUrl);
    }

    return null;
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
