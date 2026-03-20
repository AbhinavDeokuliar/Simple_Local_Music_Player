import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/songs_proivider.dart';
import '../provider/player_provider.dart';

class SongListScreen extends ConsumerStatefulWidget {
  const SongListScreen({super.key});

  @override
  ConsumerState<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends ConsumerState<SongListScreen> {
  @override
  void initState() {
    super.initState();
    // Request permission on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('🔐 Requesting storage permission...');
      await ref.read(permissionProvider.future);
      print('✅ Permission status checked');
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlist = ref.watch(playlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Music Library'), elevation: 0),
      body: () {
        if (playlist.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No songs selected'),
                SizedBox(height: 8),
                Text('Tap the + button to add songs'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final song = playlist[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[800],
                ),
                child: song.coverUrl != null
                    ? Image.asset(song.coverUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.music_note),
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              onTap: () {
                ref.read(currentSongIndexProvider.notifier).setIndex(index);
                context.push('/player');
              },
            );
          },
        );
      }(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            print('❤️ Add button pressed - opening file picker');

            // Check permission first
            final permissionGranted = await ref.read(permissionProvider.future);
            print('🔐 Permission granted: $permissionGranted');

            if (!permissionGranted) {
              print('❌ Permission denied');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Storage permission required')),
                );
              }
              return;
            }

            // Open file picker
            print('📁 Opening file picker...');
            final service = ref.read(audioQueryServiceProvider);
            final songs = await service.pickAudioFiles();
            print('📝 Picked ${songs.length} songs');

            if (songs.isNotEmpty) {
              print('✅ Adding ${songs.length} songs to playlist');
              for (var song in songs) {
                print('  - ${song.title} by ${song.artist}');
              }
              ref.read(playlistNotifierProvider.notifier).addSongs(songs);
              print('✅ Songs added successfully');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${songs.length} songs')),
                );
              }
            } else {
              print('⚠️ No songs selected by user');
            }
          } catch (e, stackTrace) {
            print('❌ Error picking songs: $e');
            print('Stack trace: $stackTrace');
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
