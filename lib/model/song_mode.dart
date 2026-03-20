class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;
  final String? coverUrl;
  final String? genre;
  final DateTime? releaseDate;
  final bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.coverUrl,
    this.genre,
    this.releaseDate,
    this.isFavorite = false,
  });
}

  // Copy with method - useful for updating specific fields
  