import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/player/player_provider.dart';

class PlayPauseButton extends StatelessWidget {
  final double size;
  const PlayPauseButton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final PlayerProvider playerProvider = context.watch<PlayerProvider>();
    return Builder(
      builder: (context) {
        return playerProvider.getPlayerState() == PlayerSt.playing
            ? IconButton(
              iconSize: size,
              onPressed: () {
                playerProvider.pause();
              },
              icon: Icon(Icons.pause_circle),
            )
            : IconButton(
              iconSize: size,
              onPressed: () {
                playerProvider.resume();
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
    return IconButton(
      iconSize: size,
      onPressed: () {
        playerProvider.nextSong();
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
    final PlayerProvider playerProvider = context.watch<PlayerProvider>();
    return Builder(
      builder: (context) {
        return playerProvider.isSongHistoryEmpty()
            ? IconButton(
              iconSize: size,
              onPressed: null,
              icon: Icon(Icons.arrow_circle_left_outlined),
            )
            : IconButton(
              iconSize: size,
              onPressed: () {
                playerProvider.previousSong();
              },
              icon: Icon(Icons.arrow_circle_left_outlined),
            );
      },
    );
  }
}
