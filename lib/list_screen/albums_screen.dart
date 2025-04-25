import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:sync_player/list_screen/list_items.dart';
import 'package:sync_player/list_screen/main_screen.dart';
import 'package:sync_player/player/player_widget.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryScreenState screenState = context.read<LibraryScreenState>();
    final List<Song> allArtistSongs = screenState.artist.allSongs();
    allArtistSongs.shuffle();
    final PlayList randomizedPlayList = PlayList(
      id: -1 >>> 1,
      name: "Random ${screenState.artist.name}",
      songs: allArtistSongs,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 50,
            flexibleSpace: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Text(
                      screenState.artist.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Hero(
                tag: "${screenState.artist.name}artist",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(screenState.artist.image),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  "Albums",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
          SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: screenState.artist.albums.length,
            itemBuilder: (BuildContext context, int index) {
              return AlbumItem(album: screenState.artist.albums[index]);
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  "Random Songs",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: allArtistSongs.length,
            itemBuilder: (context, index) {
              return SongItem(
                song: allArtistSongs[index],
                currentPlaylistOnScreen: randomizedPlayList,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: PlayerWidget(),
    );
  }
}
