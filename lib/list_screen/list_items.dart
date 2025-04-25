import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/list_screen/main_screen.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player_state.dart';
import '../Models/models.dart';

class ArtistItem extends StatelessWidget {
  final Artist artist;
  const ArtistItem({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Hero(
                  tag: "${artist.name}artist",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(artist.image),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  artist.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          context.read<LibraryScreenState>().changeArtist(artist);
          Navigator.pushNamed(context, '/albums');
        },
      ),
    );
  }
}

class AlbumItem extends StatelessWidget {
  final Album album;
  const AlbumItem({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Hero(
                    tag: "${album.name}album",
                    child: Image.memory(album.image),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Text(
                    album.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          context.read<LibraryScreenState>().changeAlbum(album);
          Navigator.pushNamed(context, '/songs');
        },
      ),
    );
  }
}

class SongItem extends StatelessWidget {
  final Song song;

  ///List of songs that are currently being displayed on-screen.
  ///Can be an album, a randomized playlist or an user-made playlist.
  final PlayList currentPlaylistOnScreen;
  const SongItem({
    super.key,
    required this.song,
    required this.currentPlaylistOnScreen,
  });

  @override
  Widget build(BuildContext context) {
    PlayerState player = context.read<PlayerState>();
    PlayerViewState playerState = context.watch<PlayerViewState>();
    return Material(
      child: Card(
        elevation: 0,
        color:
            playerState.currentSong == song
                ? ThemeData.dark().focusColor
                : ThemeData.dark().cardColor,
        child: InkWell(
          onHover: (value) {},
          onTap: () {
            if (playerState.currentSong == song) {
              if (playerState.playing) {
                audioHandler.stop();
              } else {
                audioHandler.play();
              }
            } else {
              player.setSongAndPlaylist(
                song.artist,
                song.album,
                song,
                currentPlaylistOnScreen,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return playerState.currentSong == song &&
                            playerState.playing
                        ? Icon(Icons.pause)
                        : Icon(Icons.play_arrow);
                  },
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.artist.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1,
                      ),
                      Text(
                        song.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Text(formatSeconds(song.duration)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
