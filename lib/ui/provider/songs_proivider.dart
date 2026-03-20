import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/song_mode.dart';
import '../../services/audio_query_service.dart';

part 'songs_proivider.g.dart';

@riverpod
AudioQueryService audioQueryService(AudioQueryServiceRef ref) {
  return AudioQueryService();
}

/// Provider to store the playlist (starts empty)
@riverpod
class PlaylistNotifier extends _$PlaylistNotifier {
  @override
  List<Song> build() {
    return []; // Start with empty list
  }

  /// Add songs to the playlist
  void addSongs(List<Song> songs) {
    state = [...state, ...songs];
  }

  /// Clear the playlist
  void clear() {
    state = [];
  }

  /// Replace all songs
  void setSongs(List<Song> songs) {
    state = songs;
  }
}

/// Shortcut for accessing the playlist
@riverpod
List<Song> playlist(PlaylistRef ref) {
  return ref.watch(playlistNotifierProvider);
}

/// Provider to check and request permissions
@riverpod
Future<bool> permission(PermissionRef ref) async {
  final service = ref.watch(audioQueryServiceProvider);
  return service.requestPermission();
}
