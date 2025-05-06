import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:sync_player/Library/models/models.dart';

/// Enum representing player state
enum PlayerSt { idle, playing, changingAudio, paused, completed }

/// Singleton player class that manages audio playback using just_audio.
class Player {
  // Singleton instance
  static final Player _instance = Player._internal();
  factory Player() => _instance;

  // Private constructor
  Player._internal() {
    _init();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _setState(PlayerSt.playing);
      } else if (state == PlayerState.paused) {
        _setState(PlayerSt.paused);
      } else if (state == PlayerState.completed) {
        _setState(PlayerSt.completed);
      } else if (state == PlayerState.stopped) {
        _setState(PlayerSt.idle);
      } else if (state == PlayerState.disposed) {
        //To do
      }
    });

    AudioContextAndroid android = AudioContextAndroid();
    android.audioFocus;

    // audioPlayer.eventStream.listen((event) {
    //   if (event.eventType == AudioEventType.) {
    //     player.pause();
    //   }
    // });
  }

  // Audio player instance
  final AudioPlayer audioPlayer = AudioPlayer();

  // Player state
  PlayerSt state = PlayerSt.idle;

  // Time elapsed in milliseconds
  int timeEllapsedMilliseconds = 0;

  // Stream controller for broadcasting player state changes
  final StreamController<PlayerSt> _stateStreamController =
      StreamController<PlayerSt>.broadcast();

  // Public state stream
  Stream<PlayerSt> get stateStream => _stateStreamController.stream;

  /// Initialization: setup media session, platform-specific config, and listeners
  Future<void> _init() async {
    audioPlayer.onPlayerComplete.listen((justAudioState) {
      //_setState(PlayerSt.completed); // Broadcast completion
    });

    // Track playback position
    audioPlayer.onPositionChanged.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
    });

    // Default volume on Windows
    if (Platform.isWindows) {
      audioPlayer.setVolume(0.7);
    }
  }

  /// Helper to update player state and notify listeners
  void _setState(PlayerSt newState) {
    state = newState;
    _stateStreamController.add(state);
  }

  /// Resume playback if an audio source is loaded
  Future<void> resume() async {
    try {
      if (audioPlayer.source != null) {
        //_setState(PlayerSt.playing);
        await audioPlayer.resume();
      }
    } catch (e) {
      //_setState(PlayerSt.idle);
      print('Error resuming playback: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      if (audioPlayer.source != null) {
        //_setState(PlayerSt.paused);
        await audioPlayer.pause();
      }
    } catch (e) {
      print('Error pausing playback: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      if (audioPlayer.source != null) {
        //_setState(PlayerSt.idle);
        await audioPlayer.stop();
      }
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  /// Seek to a specific position in the current track
  Future<void> seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Load a new song and start playback
  Future<void> changeSongAndPlay(Song song) async {
    try {
      await audioPlayer.setSource(DeviceFileSource(song.path));
      await resume();
    } catch (e) {
      //_setState(PlayerSt.idle);
      print('Error changing song: $e');
    }
  }

  /// Set the playback volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Clean up audio player and stream controller
  void dispose() {
    audioPlayer.release();
    audioPlayer.dispose();
    _stateStreamController.close();
  }
}
