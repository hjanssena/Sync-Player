import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/list_screen/list_items.dart';
import 'package:sync_player/list_screen/main_screen.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ListScreenState screenState = context.read<ListScreenState>();
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
                tag: screenState.album.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: screenState.album.image,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  screenState.album.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: screenState.album.songs.length,
            itemBuilder: (context, index) {
              return SongItem(song: screenState.album.songs[index]);
            },
          ),
        ],
      ),
    );
  }
}
