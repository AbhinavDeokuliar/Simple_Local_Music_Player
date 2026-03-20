import 'package:flutter/material.dart';

class Mcards extends StatelessWidget {
  final String? songTitle;
  final String? artistName;
  final String? imagePath;

  const Mcards({
    super.key,
    this.songTitle = 'Unknown Song',
    this.artistName = 'Unknown Artist',
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white12,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(imagePath!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.music_note,
                      size: 80,
                      color: Colors.white54,
                    ),
            ),
            const SizedBox(height: 24),
            // Song Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                songTitle ?? 'Unknown Song',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Artist Name
            Text(
              artistName ?? 'Unknown Artist',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
