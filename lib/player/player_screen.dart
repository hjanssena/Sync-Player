import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/player/media_buttons.dart';
import 'package:sync_player/player/player_state.dart';
import 'package:sync_player/player/progress_bar.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerViewState playerState = context.watch<PlayerViewState>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            flexibleSpace: Center(
              child: Text(
                "Now playing",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Hero(
                tag: "${playerState.currentSong?.title}player",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: playerState.currentAlbum?.image,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 5.0,
                right: 5.0,
                left: 5.0,
              ),
              child: Center(
                child: Text(
                  playerState.currentArtist?.name ?? "No artist",
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  playerState.currentSong?.title ?? "No song",
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SongProgressBar()),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(tag: "BackBtn", child: PreviousSongButton(size: 70)),
                Hero(tag: "PlayBtn", child: PlayPauseButton(size: 90)),
                Hero(tag: "FwdBtn", child: NextSongButton(size: 70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
