import 'dart:collection';
import 'package:sync_player/Library/models/models.dart';

/// Manages playback queue and history for the music player.
class PlaybackQueue {
  // Queue of upcoming songs
  final Queue<Song> _songQueue = Queue<Song>();

  // History of previously played songs
  final Queue<Song> _previousSongs = Queue<Song>();

  /// Adds a song to the end of the playback queue.
  void addToQueue(Song song) => _songQueue.add(song);

  /// Adds a song to the front of the queue (used for restoring current when going back).
  void addFirstToQueue(Song song) => _songQueue.addFirst(song);

  /// Returns and removes the next song from the queue, if available.
  Song? next() {
    return _songQueue.isNotEmpty ? _songQueue.removeFirst() : null;
  }

  /// Peeks at the next song in the queue without removing it.
  Song? peekNext() {
    return _songQueue.isNotEmpty ? _songQueue.first : null;
  }

  /// Returns and removes the last song from history (previously played).
  Song? previous() {
    return _previousSongs.isNotEmpty ? _previousSongs.removeLast() : null;
  }

  /// Peeks at the last song in history without removing it.
  Song? peekPrevious() {
    return _previousSongs.isNotEmpty ? _previousSongs.last : null;
  }

  /// Adds a song to the history of played songs.
  void addToHistory(Song song) {
    _previousSongs.add(song);

    // Keep history bounded to a reasonable length (e.g., 30)
    if (_previousSongs.length > 30) {
      _previousSongs.removeFirst();
    }
  }

  /// Clears the upcoming song queue.
  void clearQueue() => _songQueue.clear();

  /// Fills the queue with the songs that come after [currentSong] in the given playlist.
  void fillFromPlaylist(PlayList playlist, Song currentSong) {
    int index = playlist.songs.indexWhere((s) => s.id == currentSong.id);
    if (index != -1) {
      // Add remaining songs after the current one
      for (int i = index + 1; i < playlist.songs.length; i++) {
        _songQueue.add(playlist.songs[i]);
      }
    }
  }

  /// Returns whether the song queue is currently empty.
  bool isQueueEmpty() => _songQueue.isEmpty;

  /// Returns whether the playback history is currently empty.
  bool isHistoryEmpty() => _previousSongs.isEmpty;

  int songQueueLength() => _songQueue.length;

  int songHistoryLength() => _previousSongs.length;
}
