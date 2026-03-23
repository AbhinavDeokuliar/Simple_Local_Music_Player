import 'dart:io';
import 'package:flutter/foundation.dart';
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
          debugPrint('📱 Android 13+: Requesting READ_MEDIA_AUDIO');
          var status = await Permission.audio.request();
          if (status.isGranted) return true;
        }
      }

      debugPrint('📱 Fallback: Requesting READ_EXTERNAL_STORAGE');
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
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
      debugPrint('❌ Permission check error: $e');
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
      debugPrint('📁 Opening file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('⚠️ No files selected');
        return [];
      }

      debugPrint('✅ ${result.files.length} files selected');

      // Extract metadata from each file
      final songs = <Song>[];
      for (final file in result.files) {
        if (file.path == null) continue;

        final audioFile = File(file.path!);
        final metadata = _readMetadataSafely(audioFile, file.name);

        final song = Song(
          id: file.path.hashCode.toString(),
          title: metadata?.title ?? file.name.split('.').first,
          artist: metadata?.artist ?? 'Unknown Artist',
          album: metadata?.album ?? 'Unknown Album',
          duration: metadata?.duration ?? Duration.zero,
          filePath: file.path!,
          coverUrl: null,
          genre: metadata != null && metadata.genres.isNotEmpty
              ? metadata.genres.first
              : null,
          releaseDate: metadata?.year,
        );
        songs.add(song);
        debugPrint('✅ Added: ${song.title} by ${song.artist}');
      }

      return songs;
    } catch (e) {
      debugPrint('❌ Error picking audio files: $e');
      return [];
    }
  }

  AudioMetadata? _readMetadataSafely(File audioFile, String fileName) {
    try {
      return _readMetadataWithManagedReader(audioFile);
    } catch (e) {
      debugPrint(
        '⚠️ Metadata unavailable for $fileName ($e). Using fallback song details.',
      );
      return null;
    }
  }

  AudioMetadata _readMetadataWithManagedReader(File audioFile) {
    final reader = audioFile.openSync();

    try {
      if (ID3v2Parser.canUserParser(reader)) {
        final mp3Metadata =
            ID3v2Parser(fetchImage: false).parse(reader) as Mp3Metadata;

        final metadata = AudioMetadata(
          file: audioFile,
          album: mp3Metadata.album,
          artist:
              mp3Metadata.bandOrOrchestra ??
              mp3Metadata.leadPerformer ??
              mp3Metadata.originalArtist,
          bitrate: mp3Metadata.bitrate,
          duration: mp3Metadata.duration,
          language: mp3Metadata.languages,
          lyrics: mp3Metadata.lyric,
          sampleRate: mp3Metadata.samplerate,
          title: mp3Metadata.songName,
          totalDisc: mp3Metadata.totalDics,
          trackNumber: mp3Metadata.trackNumber,
          trackTotal: mp3Metadata.trackTotal,
          year: _safeYear(mp3Metadata.originalReleaseYear ?? mp3Metadata.year),
          discNumber: mp3Metadata.discNumber,
        );

        metadata.pictures = mp3Metadata.pictures;
        metadata.genres = mp3Metadata.genres;

        final guestArtistFrame = mp3Metadata.customMetadata['GUEST ARTIST'];
        if (guestArtistFrame != null) {
          metadata.performers.addAll(guestArtistFrame.split('/'));
        }

        return metadata;
      }

      if (FlacParser.canUserParser(reader)) {
        final vorbisMetadata =
            FlacParser(fetchImage: false).parse(reader) as VorbisMetadata;

        final metadata = AudioMetadata(
          file: audioFile,
          album: vorbisMetadata.album.firstOrNull,
          artist: vorbisMetadata.artist.firstOrNull,
          bitrate: vorbisMetadata.bitrate,
          discNumber: vorbisMetadata.discNumber,
          duration: vorbisMetadata.duration,
          language: vorbisMetadata.artist.firstOrNull,
          lyrics: vorbisMetadata.lyric,
          sampleRate: vorbisMetadata.sampleRate,
          title: vorbisMetadata.title.firstOrNull,
          totalDisc: vorbisMetadata.discTotal,
          trackNumber: vorbisMetadata.trackNumber.firstOrNull,
          trackTotal: vorbisMetadata.trackTotal,
          year: vorbisMetadata.date.firstOrNull,
        );

        metadata.genres = vorbisMetadata.genres;
        metadata.pictures = vorbisMetadata.pictures;
        metadata.performers.addAll(vorbisMetadata.performer);

        return metadata;
      }

      if (MP4Parser.canUserParser(reader)) {
        final mp4Metadata =
            MP4Parser(fetchImage: false).parse(reader) as Mp4Metadata;

        final metadata = AudioMetadata(
          file: audioFile,
          album: mp4Metadata.album,
          artist: mp4Metadata.artist,
          bitrate: mp4Metadata.bitrate,
          discNumber: mp4Metadata.discNumber,
          duration: mp4Metadata.duration,
          language: null,
          lyrics: mp4Metadata.lyrics,
          sampleRate: mp4Metadata.sampleRate,
          title: mp4Metadata.title,
          totalDisc: mp4Metadata.totalDiscs,
          trackNumber: mp4Metadata.trackNumber,
          trackTotal: mp4Metadata.totalTracks,
          year: mp4Metadata.year,
        );

        if (mp4Metadata.picture != null) {
          metadata.pictures.add(mp4Metadata.picture!);
        }
        if (mp4Metadata.genre != null) {
          metadata.genres.add(mp4Metadata.genre!);
        }

        return metadata;
      }

      if (OGGParser.canUserParser(reader)) {
        final oggMetadata =
            OGGParser(fetchImage: false).parse(reader) as VorbisMetadata;

        final metadata = AudioMetadata(
          file: audioFile,
          album: oggMetadata.album.firstOrNull,
          artist: oggMetadata.artist.firstOrNull,
          bitrate: oggMetadata.bitrate,
          discNumber: oggMetadata.discNumber,
          duration: oggMetadata.duration,
          language: oggMetadata.artist.firstOrNull,
          lyrics: oggMetadata.lyric,
          sampleRate: oggMetadata.sampleRate,
          title: oggMetadata.title.firstOrNull,
          totalDisc: oggMetadata.discTotal,
          trackNumber: oggMetadata.trackNumber.firstOrNull,
          trackTotal: oggMetadata.trackTotal,
          year: oggMetadata.date.firstOrNull,
        );

        metadata.genres = oggMetadata.genres;
        metadata.pictures.addAll(oggMetadata.pictures);
        metadata.performers.addAll(oggMetadata.performer);

        return metadata;
      }

      if (ID3v1Parser.canUserParser(reader)) {
        final mp3Metadata = ID3v1Parser().parse(reader) as Mp3Metadata;

        final metadata = AudioMetadata(
          file: audioFile,
          album: mp3Metadata.album,
          artist:
              mp3Metadata.bandOrOrchestra ??
              mp3Metadata.originalArtist ??
              mp3Metadata.leadPerformer,
          bitrate: mp3Metadata.bitrate,
          duration: mp3Metadata.duration,
          language: mp3Metadata.languages,
          lyrics: mp3Metadata.lyric,
          sampleRate: mp3Metadata.samplerate,
          title: mp3Metadata.songName,
          totalDisc: mp3Metadata.totalDics,
          trackNumber: mp3Metadata.trackNumber,
          trackTotal: mp3Metadata.trackTotal,
          year: _safeYear(mp3Metadata.originalReleaseYear ?? mp3Metadata.year),
          discNumber: mp3Metadata.discNumber,
        );

        metadata.pictures = mp3Metadata.pictures;
        metadata.genres = mp3Metadata.genres;

        return metadata;
      }

      throw NoMetadataParserException(track: audioFile);
    } finally {
      reader.closeSync();
    }
  }

  DateTime? _safeYear(int? year) {
    if (year == null || year <= 0) {
      return null;
    }

    try {
      return DateTime(year);
    } catch (_) {
      return null;
    }
  }
}
