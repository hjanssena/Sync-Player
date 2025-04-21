import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player_state.dart' as a;
import 'package:just_audio/just_audio.dart';

class BackgroundAudioHandler extends BaseAudioHandler with QueueHandler {
  final a.PlayerState player;
  late final StreamSubscription _playerSubscription;
  Timer? _positionUpdateTimer;

  BackgroundAudioHandler({required this.player}) {
    // Listen to player updates
    _playerSubscription = player.audioPlayer.playbackEventStream.listen(
      _broadcastState,
    );

    // Set current media item when song changes
    player.stateStream.listen((viewState) {
      final song = viewState.currentSong;
      if (song != null) {
        mediaItem.add(
          MediaItem(
            id: song.path,
            album: song.album.name,
            title: song.title,
            artist: song.artist.name,
            duration: Duration(milliseconds: song.duration),
          ),
        );
      }
      // Start a periodic timer to update progress
      _positionUpdateTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
        if (playerState.playing) {
          _broadcastState(player.audioPlayer.playbackEvent);
        }
      });
    });
  }

  Future<void> _broadcastState(PlaybackEvent event) async {
    final playing = playerState.playing;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
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
            }[player.audioPlayer.processingState]!,
        playing: playing,
        updatePosition: player.audioPlayer.position,
        bufferedPosition: player.audioPlayer.bufferedPosition,
        speed: player.audioPlayer.speed,
        queueIndex: null,
      ),
    );
  }

  @override
  Future<void> play() => player.resume();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.nextSong();

  @override
  Future<void> skipToPrevious() => player.previousSong();

  void dispose() {
    _playerSubscription.cancel();
    _positionUpdateTimer?.cancel();
  }
}
