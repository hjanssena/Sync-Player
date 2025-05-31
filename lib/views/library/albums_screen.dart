import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/views/library/list_items.dart';
import 'package:sync_player/views/player/player_widget.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryProvider library = context.watch<LibraryProvider>();
    final List<Song> allArtistSongs = library.getArtistSongs();
    allArtistSongs.shuffle();
    final PlayList randomizedPlayList = PlayList(
      uuid: '',
      name: "Random ${library.selectedArtist.name}",
      songs: allArtistSongs,
      created: DateTime.now(),
      lastModified: DateTime.now(),
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
                      library.selectedArtist.name,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(library.selectedArtist.image),
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
            itemCount: library.selectedArtist.albums.length,
            itemBuilder: (BuildContext context, int index) {
              return AlbumItem(album: library.selectedArtist.albums[index]);
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
