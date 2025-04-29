import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/player/player.dart';

class PlayerEvent {
  final Song currentSong;
  final PlayerSt state;

  PlayerEvent({required this.currentSong, required this.state});
}

class PlayerProvider extends ChangeNotifier {
  //Get player instance
  Player player = Player();

  // Queues for history and upcoming songs
  final Queue<Song> _previousSongs = Queue<Song>();
  final Queue<Song> _songQueue = Queue<Song>();

  // Current playback metadata
  Song currentSong = Song.empty();

  //Data stream for audio service
  late final stateStream = StreamController<PlayerEvent>.broadcast();

  //State broadcast function
  _broadcast() {
    notifyListeners();
    stateStream.add(PlayerEvent(currentSong: currentSong, state: player.state));
  }

  Timer? _positionUpdateTimer;

  PlayerProvider() {
    _positionUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (player.state == PlayerSt.playing) {
        _broadcast();
      }
    });
  }

  // Music data source
  late final LibraryProvider _musicLibrary;
  void setLibrary(LibraryProvider library) => _musicLibrary = library;

  /// Start/resume playback
  Future<void> resume() async {
    if (currentSong.id == -1 >>> 1) {
      currentSong = _musicLibrary.getRandomSong();
      await player.changeSong(currentSong);
    }
    await player.resume();
    _broadcast();
  }

  /// Stop playback and frees all player resources
  Future<void> stop() async {
    await player.stop();
    _broadcast();
  }

  /// Pause playback
  Future<void> pause() async {
    await player.pause();
    _broadcast();
  }

  /// Seek to a specific position in the current song
  Future<void> seek(Duration position) async {
    await player.seek(position);
    _broadcast();
  }

  /// Set current song and playlist
  Future<void> setSongAndPlaylist(Song song, PlayList playlist) async {
    await player.stop();
    if (currentSong.id != -1 >>> 1) _addSongToHistory(currentSong);
    currentSong = song;
    await player.changeSong(currentSong);
    _songQueue.clear();
    _fillQueueWithPlaylist(playlist);
    _fillQueue();
    resume();
  }

  /// Play the next song in the queue
  Future<void> nextSong() async {
    if (currentSong.id != -1 >>> 1) {
      _addSongToHistory(currentSong);
    }

    if (_songQueue.isNotEmpty) {
      currentSong = _songQueue.removeFirst();
    } else {
      currentSong = _musicLibrary.getRandomSong();
    }

    await player.changeSong(currentSong);
    await resume();
  }

  /// Play the previous song from history
  Future<void> previousSong() async {
    if (_previousSongs.isNotEmpty) {
      _songQueue.addFirst(currentSong);
      currentSong = _previousSongs.removeLast();
      await player.changeSong(currentSong);
      await resume();
    }
  }

  /// Fill the next-song queue from the playlist starting from the selected song.
  void _fillQueueWithPlaylist(PlayList playlist) {
    int i = 1;
    bool songFound = false;
    for (Song song in playlist.songs) {
      if (song == currentSong) {
        songFound = true;
        break;
      }
      i++;
    }
    //If the song is not on the playlist we skip adding the playlist to the queue
    if (songFound) {
      while (i < playlist.songs.length) {
        _songQueue.add(playlist.songs[i]);
        i++;
      }
    }
  }

  /// Fill queue with random songs from the library
  void _fillQueue() {
    while (_songQueue.length <= 30) {
      addSongToQueue(_musicLibrary.getRandomSong());
    }
  }

  void addSongToQueue(Song song) => _songQueue.add(song);

  bool isSongQueueEmpty() => _songQueue.isEmpty;

  Song? getNextSongInQueue() {
    if (_songQueue.isNotEmpty) {
      return _songQueue.first;
    } else {
      return null;
    }
  }

  void _addSongToHistory(Song song) {
    _previousSongs.add(song);
    if (_previousSongs.length > 30) {
      _previousSongs.removeFirst();
    }
  }

  Song? getLastSongInHistory() {
    if (_previousSongs.isNotEmpty) {
      return _previousSongs.last;
    } else {
      return null;
    }
  }

  bool isSongHistoryEmpty() => _previousSongs.isEmpty;

  @override
  void dispose() {
    stateStream.close();
    _positionUpdateTimer?.cancel();
    super.dispose();
  }
}
