import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/player/playback_queue.dart';
import 'package:sync_player/services/background_audio_handler.dart';

/// Represents a playback update event containing the current song and state.
class PlayerEvent {
  final Song currentSong;
  final PlayerSt state;
  final Uri? art;

  PlayerEvent({
    required this.currentSong,
    required this.state,
    required this.art,
  });
}

/// Provider for controlling music playback and maintaining UI synchronization.
class PlayerProvider extends ChangeNotifier {
  // Main audio player instance
  final Player _player = Player();

  // Handles upcoming songs and playback history
  final PlaybackQueue _playbackQueue = PlaybackQueue();

  // Stream to broadcast state updates (e.g., current song, playback status)
  final StreamController<PlayerEvent> stateStream =
      StreamController<PlayerEvent>.broadcast();

  // Stream to broadcast position updates for the UI progress bar
  final StreamController<Duration> _positionStream =
      StreamController.broadcast();
  Stream<Duration> get positionStream => _positionStream.stream;

  // Reference to the music library
  late final LibraryProvider _musicLibrary;
  //Background Audio Handler
  late final AudioHandler audioHandler;

  // Currently playing song
  Song currentSong = Song.empty();
  int timeEllapsedMilliseconds = 0;

  /// Constructor: sets up periodic position updates and listens to player state changes.
  PlayerProvider() {
    // Track playback position
    _player.audioPlayer.positionStream.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
      _positionStream.add(position);
    });
    //Handle end of song behaviour
    _player.stateStream.listen((state) {
      if (state == PlayerSt.completed) {
        nextSong();
      }
    });
    initAudioHandler();
  }

  //Initialize the handler for background playback and notification media control
  Future<void> initAudioHandler() async {
    audioHandler = await AudioService.init(
      builder:
          () => BackgroundAudioHandler(playerProvider: this) as AudioHandler,
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.sync_player.channel.audio',
        androidNotificationChannelName: 'Sync Player',
        androidNotificationOngoing: true,
      ),
    );
  }

  /// Injects the music library into the player provider.
  void setLibrary(LibraryProvider library) => _musicLibrary = library;

  /// Starts playback or resumes the current song if already set.
  Future<void> resume() async {
    if (currentSong.id == -1 >>> 1) {
      currentSong = _musicLibrary.getRandomSong();
      await _player.changeSongAndPlay(currentSong);
    } else {
      await _player.resume();
    }
    _broadcast();
  }

  /// Stops playback and releases resources.
  Future<void> stop() async {
    await _player.stop();
    _broadcast();
  }

  /// Pauses the currently playing song.
  Future<void> pause() async {
    await _player.pause();
    _broadcast();
  }

  /// Seeks to a specific position within the current song.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _broadcast();
  }

  /// Sets a specific song and playlist as the current playback context.
  Future<void> setSongAndPlaylist(Song song, PlayList playlist) async {
    if (currentSong.id != -1 >>> 1) _playbackQueue.addToHistory(currentSong);
    currentSong = song;
    await _saveNowPlayingImage(currentSong);
    await _player.changeSongAndPlay(currentSong);
    _playbackQueue.clearQueue();
    _playbackQueue.fillFromPlaylist(playlist, currentSong);
    _fillQueueWithRandomSongs();
    _broadcast();
  }

  /// Plays the next song in the queue or selects a random one if the queue is empty.
  Future<void> nextSong() async {
    if (currentSong.id != -1 >>> 1) _playbackQueue.addToHistory(currentSong);

    currentSong = _playbackQueue.next() ?? _musicLibrary.getRandomSong();
    await _saveNowPlayingImage(currentSong);
    await _player.changeSongAndPlay(currentSong);
    _fillQueueWithRandomSongs();
    _broadcast();
  }

  /// Plays the last song from history, if available.
  Future<void> previousSong() async {
    final prev = _playbackQueue.previous();
    if (prev != null) {
      _playbackQueue.addFirstToQueue(currentSong); // Push current to front
      currentSong = prev;
      await _saveNowPlayingImage(currentSong);
      await _player.changeSongAndPlay(currentSong);
      _broadcast();
    }
  }

  ///Changes volume
  Future<void> changeVolume(double volume) async {
    await _player.setVolume(volume);
  }

  /// Ensures queue is filled with additional random songs.
  void _fillQueueWithRandomSongs() {
    while (_playbackQueue.songQueueLength() <= 30) {
      _playbackQueue.addToQueue(_musicLibrary.getRandomSong());
    }
  }

  ///Saves the art to a temp directory and gets the uri
  Uri? _currentArtUri;
  Future<void> _saveNowPlayingImage(Song song) async {
    if (Platform.isIOS || Platform.isAndroid) {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        "${tempDir.path}/${sanitizePath('${currentSong.id}-${currentSong.title}-${currentSong.album.name}-${currentSong.artist.name}')}",
      );
      await file.writeAsBytes(
        song.album.image,
        flush: true,
      ); // Overwrites each time
      _currentArtUri = file.uri;
    }
  }

  String sanitizePath(String input) {
    // Replace slashes with an underscore or another safe character
    return input.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');
  }

  // === Utility accessors ===

  bool isSongQueueEmpty() => _playbackQueue.isQueueEmpty();
  bool isSongHistoryEmpty() => _playbackQueue.isHistoryEmpty();
  Song? getNextSongInQueue() => _playbackQueue.peekNext();
  Song? getLastSongInHistory() => _playbackQueue.peekPrevious();

  /// Broadcasts player state to the UI and listeners.
  void _broadcast() {
    stateStream.add(
      PlayerEvent(
        currentSong: currentSong,
        state: _player.state,
        art: _currentArtUri,
      ),
    );
    notifyListeners();
  }

  /// Gets the player's state
  PlayerSt getPlayerState() => _player.state;

  /// Cleans up all resources.
  @override
  void dispose() {
    stateStream.close();
    super.dispose();
  }
}
