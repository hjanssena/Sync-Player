import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/player/player_provider.dart';

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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage(
                    placeholder: MemoryImage(fileCache.emptyImage),
                    image: MemoryImage(artist.image),
                    fadeInDuration: Duration(milliseconds: 160),
                    fadeOutDuration: Duration(milliseconds: 50),
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
          context.read<LibraryProvider>().changeSelectedArtist(artist);
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
                  child: FadeInImage(
                    placeholder: MemoryImage(fileCache.emptyImage),
                    image: MemoryImage(album.image),
                    fadeInDuration: Duration(milliseconds: 160),
                    fadeOutDuration: Duration(milliseconds: 50),
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
          context.read<LibraryProvider>().changeSelectedAlbum(album);
          Navigator.pushNamed(context, '/songs');
        },
      ),
    );
  }
}

class SongItem extends StatelessWidget {
  final Song song;
  //List of songs that are currently being displayed on-screen.
  //Can be an album, a randomized playlist or an user-made playlist.
  final PlayList currentPlaylistOnScreen;
  const SongItem({
    super.key,
    required this.song,
    required this.currentPlaylistOnScreen,
  });

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerProvider = context.watch<PlayerProvider>();
    return Material(
      child: Card(
        elevation: 0,
        color:
            playerProvider.currentSong == song
                ? ThemeData.dark().focusColor
                : ThemeData.dark().cardColor,
        child: InkWell(
          onHover: (value) {},
          onTap: () {
            if (playerProvider.currentSong == song) {
              if (playerProvider.getPlayerState() == PlayerSt.playing) {
                playerProvider.pause();
              } else {
                playerProvider.resume();
              }
            } else {
              playerProvider.setSongAndPlaylist(song, currentPlaylistOnScreen);
            }
          },
          child: Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return playerProvider.currentSong == song &&
                            playerProvider.getPlayerState() == PlayerSt.playing
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
