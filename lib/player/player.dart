import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart' as s;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:sync_player/Library/models/models.dart';
//import 'package:just_audio_media_kit/just_audio_media_kit.dart';

/// Enum representing player state
enum PlayerSt { idle, playing, changingAudio, paused, completed }

/// Singleton player class that manages audio playback using just_audio.
class Player {
  // Singleton instance
  static final Player _instance = Player._internal();
  factory Player() => _instance;

  // Private constructor
  Player._internal() {
    audioPlayer = AudioPlayer();
    _init();
  }

  late final AudioPlayer audioPlayer;
  late final s.AudioSession session;
  PlayerSt state = PlayerSt.idle;
  int timeEllapsedMilliseconds = 0;

  // Stream controller for broadcasting player state changes
  final StreamController<PlayerSt> _stateStreamController =
      StreamController<PlayerSt>.broadcast();
  Stream<PlayerSt> get stateStream => _stateStreamController.stream;

  /// Initialization: setup audio session, platform-specific config and listeners
  Future<void> _init() async {
    if (Platform.isWindows || Platform.isLinux) {
      JustAudioMediaKit.ensureInitialized();
    }

    // Setup position tracking
    audioPlayer.positionStream.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
    });

    //Listen to when player completes the current song
    audioPlayer.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.completed) {
        _setState(PlayerSt.completed);
      }
    });

    // Set default volume on Windows
    if (Platform.isWindows) {
      await audioPlayer.setVolume(0.7);
    }
    await setAudioSession();
  }

  /// Helper to update player state and notify listeners
  void _setState(PlayerSt newState) {
    state = newState;
    _stateStreamController.add(state);
  }

  /// Resume playback if ready
  Future<void> resume() async {
    final buffer = StringBuffer();

    try {
      if ((Platform.isAndroid || Platform.isIOS)) {
        final activated = await session.setActive(true);
        buffer.writeln('Session activated: $activated');
      }

      await audioPlayer.setVolume(1.0);
      buffer.writeln('Volume set to: ${audioPlayer.volume}');

      _setState(PlayerSt.playing);
      audioPlayer.play();

      buffer.writeln('Playing: ${audioPlayer.playing}');
    } catch (e) {
      buffer.writeln('Error resuming playback: $e');
    }

    await _writeLogToDownload(buffer.toString());
  }

  Future<void> _writeLogToDownload(String content) async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        print("⚠️ Download folder not found.");
        return;
      }

      final file = File('${dir.path}/audio_debug_log.txt');
      await file.writeAsString(
        '${DateTime.now()}:\n$content\n\n',
        mode: FileMode.append,
      );
      print("✅ Log written to ${file.path}");
    } catch (e) {
      print('❌ Failed to write log: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await audioPlayer.pause();
      _setState(PlayerSt.paused);
    } catch (e) {
      print('Error pausing playback: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await audioPlayer.stop();
      _setState(PlayerSt.idle);
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
      final fileSource = AudioSource.uri(Uri.file(song.path));
      await audioPlayer.addAudioSource(fileSource);
      await audioPlayer.seekToNext();
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

  /// Set up audio session and platform-specific interruptions on Android and IOS
  Future<void> setAudioSession() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    session = await s.AudioSession.instance;
    await session.configure(
      s.AudioSessionConfiguration(
        avAudioSessionCategory: s.AVAudioSessionCategory.playback,
        avAudioSessionMode: s.AVAudioSessionMode.defaultMode,
        avAudioSessionCategoryOptions:
            s.AVAudioSessionCategoryOptions.duckOthers,
        androidAudioAttributes: const s.AndroidAudioAttributes(
          contentType: s.AndroidAudioContentType.music,
          usage: s.AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: s.AndroidAudioFocusGainType.gain,
      ),
    );

    // Handle interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case s.AudioInterruptionType.duck:
            setVolume(.3);
            break;
          case s.AudioInterruptionType.pause:
          case s.AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case s.AudioInterruptionType.duck:
            setVolume(1);
            break;
          case s.AudioInterruptionType.pause:
            resume();
            break;
          case s.AudioInterruptionType.unknown:
            // Don't resume
            break;
        }
      }
    });

    // On headphone unplug, pause
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });

    // On Bluetooth disconnect, pause
    session.devicesChangedEventStream.listen((event) {
      for (s.AudioDevice dev in event.devicesRemoved) {
        if (dev.isOutput && dev.type == s.AudioDeviceType.bluetoothA2dp) {
          pause();
        }
      }
    });
  }

  /// Clean up audio player and stream controller
  bool _isDisposed = false;
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    audioPlayer.dispose();
    _stateStreamController.close();
  }
}
