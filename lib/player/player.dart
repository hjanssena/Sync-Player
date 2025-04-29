import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:sync_player/Library/models/models.dart';

enum PlayerSt { idle, playing, changingAudio, paused, completed }

class Player {
  // Singleton instance
  static final Player _instance = Player._internal();
  factory Player() => _instance;

  // Constructor (private for singleton)
  Player._internal() {
    _init();
  }

  // Audio player from just_audio
  final AudioPlayer audioPlayer = AudioPlayer();

  // Player state
  PlayerSt state = PlayerSt.idle;
  Song currentSong = Song.empty();
  int timeEllapsedMilliseconds = 0;

  /// Initialization: configure audio session and listen to events
  Future<void> _init() async {
    // Handle end of song playback
    audioPlayer.playerStateStream.listen((justAudioState) {
      if (justAudioState.processingState == ProcessingState.completed) {
        state = PlayerSt.completed;
      }
    });

    // Update playback progress
    audioPlayer.positionStream.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
    });

    // Initialize MediaKit (used on Windows/Linux)
    JustAudioMediaKit.title = 'Sync Player';
    JustAudioMediaKit.ensureInitialized();

    if (Platform.isWindows) {
      audioPlayer.setVolume(.7);
    }
  }

  Future<void> resume() async {
    if (audioPlayer.audioSource != null) {
      await audioPlayer.play();
      state = PlayerSt.playing;
    }
  }

  Future<void> pause() async {
    if (audioPlayer.audioSource != null) {
      await audioPlayer.pause();
      state = PlayerSt.paused;
    }
  }

  Future<void> stop() async {
    if (audioPlayer.audioSource != null) {
      await audioPlayer.stop();
      state = PlayerSt.idle;
    }
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> changeSong(Song song) async {
    state = PlayerSt.changingAudio;
    await stop();
    await audioPlayer.setAudioSource(AudioSource.file(song.path));
    state = PlayerSt.paused;
  }

  /// Dispose resources
  void dispose() {
    audioPlayer.dispose();
  }
}
