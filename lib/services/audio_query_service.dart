import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../model/song_mode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AudioQueryService {
  static final AudioQueryService _instance = AudioQueryService._internal();

  factory AudioQueryService() {
    return _instance;
  }

  AudioQueryService._internal();

  // Request appropriate permission based on Android version
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();
        if (androidVersion >= 13) {
          print('📱 Android 13+: Requesting READ_MEDIA_AUDIO');
          var status = await Permission.audio.request();
          if (status.isGranted) return true;
        }
      }

      print('📱 Fallback: Requesting READ_EXTERNAL_STORAGE');
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Permission request error: $e');
      return false;
    }
  }

  // Check if permission is granted
  Future<bool> hasPermission() async {
    try {
      // Check audio permission first (Android 13+)
      var audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;

      // Fallback to storage permission
      var storageStatus = await Permission.storage.status;
      return storageStatus.isGranted;
    } catch (e) {
      print('❌ Permission check error: $e');
      return false;
    }
  }

  // Helper to get Android version
  Future<int> _getAndroidVersion() async {
    // For now, assume modern Android
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// Pick multiple audio files from device storage
  Future<List<Song>> pickAudioFiles() async {
    try {
      final hasPerms = await hasPermission();
      if (!hasPerms) {
        final requested = await requestPermission();
        if (!requested) {
          throw Exception('Storage permission denied');
        }
      }

      // Open file picker
      print('📁 Opening file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        print('⚠️ No files selected');
        return [];
      }

      print('✅ ${result.files.length} files selected');

      // Extract metadata from each file
      final songs = <Song>[];
      for (final file in result.files) {
        if (file.path == null) continue;

        try {
          final audioFile = File(file.path!);
          final metadata = readMetadata(audioFile);

          final song = Song(
            id: file.path.hashCode.toString(),
            title: metadata.title ?? file.name.split('.').first,
            artist: metadata.artist ?? 'Unknown Artist',
            album: metadata.album ?? 'Unknown Album',
            duration: metadata.duration ?? Duration.zero,
            filePath: file.path!,
            coverUrl: null,
            genre: metadata.genres.isNotEmpty ? metadata.genres.first : null,
            releaseDate: metadata.year,
          );
          songs.add(song);
          print('✅ Added: ${song.title} by ${song.artist}');
        } catch (e) {
          print('❌ Error extracting metadata for ${file.name}: $e');
          // Still add song with basic info if metadata extraction fails
          songs.add(
            Song(
              id: file.path.hashCode.toString(),
              title: file.name.split('.').first,
              artist: 'Unknown Artist',
              album: 'Unknown Album',
              duration: Duration.zero,
              filePath: file.path!,
              coverUrl: null,
              genre: null,
              releaseDate: null,
            ),
          );
        }
      }

      return songs;
    } catch (e) {
      print('❌ Error picking audio files: $e');
      return [];
    }
  }
}
