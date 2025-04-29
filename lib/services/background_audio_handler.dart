import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/player/player_provider.dart';
import 'package:just_audio/just_audio.dart';

class BackgroundAudioHandler extends BaseAudioHandler with QueueHandler {
  final PlayerProvider playerProvider;
  late final StreamSubscription _playerSubscription;
  Timer? _positionUpdateTimer;

  BackgroundAudioHandler({required this.playerProvider}) {
    // Listen to player updates
    _playerSubscription = playerProvider.player.audioPlayer.playbackEventStream
        .listen(_broadcastState);

    // Set current media item when song changes
    playerProvider.stateStream.stream.listen((viewState) {
      final song = viewState.currentSong;
      mediaItem.add(
        MediaItem(
          id: song.path,
          album: song.album.name,
          title: song.title,
          artist: song.artist.name,
          duration: Duration(milliseconds: song.duration),
        ),
      );

      // Start a periodic timer to update progress
      _positionUpdateTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
        if (playerProvider.player.state == PlayerSt.playing) {
          _broadcastState(playerProvider.player.audioPlayer.playbackEvent);
        }
      });
    });
  }

  Future<void> _broadcastState(PlaybackEvent event) async {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playerProvider.player.state == PlayerSt.playing
              ? MediaControl.pause
              : MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState:
            {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[playerProvider.player.audioPlayer.processingState]!,
        playing: playerProvider.player.state == PlayerSt.playing,
        updatePosition: playerProvider.player.audioPlayer.position,
        bufferedPosition: playerProvider.player.audioPlayer.bufferedPosition,
        speed: playerProvider.player.audioPlayer.speed,
        queueIndex: null,
      ),
    );
  }

  @override
  Future<void> play() => playerProvider.resume();

  @override
  Future<void> pause() => playerProvider.pause();

  @override
  Future<void> stop() => playerProvider.stop();

  @override
  Future<void> seek(Duration position) => playerProvider.seek(position);

  @override
  Future<void> skipToNext() => playerProvider.nextSong();

  @override
  Future<void> skipToPrevious() => playerProvider.previousSong();

  void dispose() {
    _playerSubscription.cancel();
    _positionUpdateTimer?.cancel();
  }
}
