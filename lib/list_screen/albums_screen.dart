import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:sync_player/list_screen/list_items.dart';
import 'package:sync_player/list_screen/main_screen.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ListScreenState screenState = context.read<ListScreenState>();
    final List<Song> allArtistSongs = screenState.artist.allSongs();
    allArtistSongs.shuffle();
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
                  SizedBox(height: 15),
                  Text(
                    screenState.artist.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Hero(
                tag: screenState.artist.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: screenState.artist.image,
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
              return SongItem(song: allArtistSongs[index]);
            },
          ),
        ],
      ),
    );
  }
}
