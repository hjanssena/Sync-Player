import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/player/media_buttons.dart';
import 'package:sync_player/player/player_state.dart';
import 'package:sync_player/player/progress_bar.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerViewState playerState = context.watch<PlayerViewState>();
    return Container(
      color: Color.fromARGB(255, 27, 25, 25),
      child:
      // Row(
      //   children: [
      //     Flexible(
      //       child:
      //           playerState.currentAlbum?.image ??
      //           Image.asset("assets/placeholder.png"),
      //     ),
      Material(
        child: InkWell(
          onHover: (value) {},
          onTap: () => {Navigator.pushNamed(context, '/player')},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LiteProgressBar(),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  "${playerState.currentArtist?.name ?? "No artist"} - ${playerState.currentSong?.title ?? "No song"}",
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PreviousSongButton(size: 40),
                  PlayPauseButton(size: 50),
                  NextSongButton(size: 40),
                ],
              ),
            ],
          ),
        ),
      ),
      //   ],
      // ),
    );
  }
}
