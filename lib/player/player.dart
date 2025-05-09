import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:audio_session/audio_session.dart';

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
        dispose();
      }
    });
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  PlayerSt state = PlayerSt.idle;
  int timeEllapsedMilliseconds = 0;
  late final AudioSession session;

  // Stream controller for broadcasting player state changes
  final StreamController<PlayerSt> _stateStreamController =
      StreamController<PlayerSt>.broadcast();
  Stream<PlayerSt> get stateStream => _stateStreamController.stream;

  /// Initialization: setup media session, platform-specific config, and listeners
  Future<void> _init() async {
    //On song finish broadcast completion
    audioPlayer.onPlayerComplete.listen((justAudioState) {
      _setState(PlayerSt.completed);
    });

    //Set audiosession instance for communication with android and ios
    session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    await session.setActive(true);
    await setAudioSessionListener();

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
        await audioPlayer.resume();
      }
    } catch (e) {
      print('Error resuming playback: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      if (audioPlayer.source != null) {
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

  Future<void> setAudioSessionListener() async {
    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            await setVolume(30);
            break;
          case AudioInterruptionType.pause:
            break;
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            setVolume(100);
            break;
          case AudioInterruptionType.pause:
            resume();
            break;
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume.
            break;
        }
      }
    });
    //On headphone disconnect, pause
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });
    //On bluetooth output device disconnect, pause
    session.devicesChangedEventStream.listen((event) {
      for (AudioDevice dev in event.devicesRemoved) {
        if (dev.isOutput && dev.type == AudioDeviceType.bluetoothA2dp) {
          pause();
        }
      }
    });
  }

  /// Clean up audio player and stream controller
  void dispose() {
    audioPlayer.release();
    audioPlayer.dispose();
    _stateStreamController.close();
  }
}
