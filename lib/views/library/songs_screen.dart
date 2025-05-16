import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/views/player/player_widget.dart';
import 'package:sync_player/views/library/list_items.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LibraryProvider library = context.read<LibraryProvider>();
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
                    library.selectedArtist.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    softWrap: false,
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
                child: Image.memory(library.selectedAlbum.image),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  library.selectedAlbum.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: library.selectedAlbum.songs.length,
            itemBuilder: (context, index) {
              return SongItem(
                song: library.selectedAlbum.songs[index],
                currentPlaylistOnScreen: library.selectedAlbum,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: PlayerWidget(),
    );
  }
}
