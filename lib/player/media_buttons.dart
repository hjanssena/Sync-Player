import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player_state.dart';

class PlayPauseButton extends StatelessWidget {
  final double size;
  const PlayPauseButton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final PlayerState playerState = context.read<PlayerState>();
    return Builder(
      builder: (context) {
        return playerState.playing
            ? IconButton(
              iconSize: size,
              onPressed: () {
                audioHandler.pause();
              },
              icon: Icon(Icons.pause_circle),
            )
            : IconButton(
              iconSize: size,
              onPressed: () {
                audioHandler.play();
              },
              icon: Icon(Icons.play_circle),
            );
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  final double size;
  const NextSongButton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final PlayerState playerState = context.read<PlayerState>();
    return IconButton(
      iconSize: size,
      onPressed: () {
        audioHandler.skipToNext();
      },
      icon: Icon(Icons.arrow_circle_right_outlined),
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  final double size;
  const PreviousSongButton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final PlayerState playerState = context.read<PlayerState>();
    return Builder(
      builder: (context) {
        return playerState.isPreviousStackEmpty()
            ? IconButton(
              iconSize: size,
              onPressed: null,
              icon: Icon(Icons.arrow_circle_left_outlined),
            )
            : IconButton(
              iconSize: size,
              onPressed: () {
                audioHandler.skipToPrevious();
              },
              icon: Icon(Icons.arrow_circle_left_outlined),
            );
      },
    );
  }
}
