import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/player/player_provider.dart';

class BackgroundAudioHandler extends BaseAudioHandler with QueueHandler {
  final PlayerProvider playerProvider;

  BackgroundAudioHandler({required this.playerProvider}) {
    // Set current media item when song changes
    playerProvider.stateStream.stream.listen((playerEvent) {
      final song = playerEvent.currentSong;
      mediaItem.add(
        MediaItem(
          id: song.path,
          album: song.album.name,
          title: song.title,
          artist: song.artist.name,
          duration: Duration(seconds: song.duration),
          artUri: playerEvent.art,
        ),
      );
      _broadcastState();
    });

    playerProvider.positionStream.listen((position) {
      _broadcastState();
    });
  }

  Future<void> _broadcastState() async {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playerProvider.getPlayerState() == PlayerSt.playing
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
              PlayerSt.idle: AudioProcessingState.idle,
              PlayerSt.playing: AudioProcessingState.ready,
              PlayerSt.paused: AudioProcessingState.ready,
              PlayerSt.completed: AudioProcessingState.completed,
            }[playerProvider.getPlayerState()]!,
        playing: playerProvider.getPlayerState() == PlayerSt.playing,
        updatePosition: Duration(
          milliseconds: playerProvider.timeEllapsedMilliseconds,
        ),
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
}
