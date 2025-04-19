import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/song_list.dart';
import 'package:sync_player/list_screen/list_item.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Library', style: textTheme.headlineMedium),
      ),
      body: Consumer<SongList>(
        builder: (context, value, child) {
          if (value.isEmpty()) {
            return NoDirectoriesScreen(textTheme: textTheme, songList: value);
          } else {
            return SongListScreen(songList: value);
          }
        },
      ),
    );
  }
}

class SongListScreen extends StatelessWidget {
  final SongList songList;
  const SongListScreen({super.key, required this.songList});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: songList.length(),
        itemBuilder: (BuildContext context, int index) {
          return ListItem(song: songList.get(index));
        },
      ),
    );
  }
}

class NoDirectoriesScreen extends StatelessWidget {
  final SongList songList;
  final TextTheme textTheme;
  const NoDirectoriesScreen({
    super.key,
    required this.textTheme,
    required this.songList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            'Add your music folder to begin!',
            style: textTheme.bodyLarge,
          ),
        ),
        SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            songList.addPath();
          },
          child: Text('Add directory'),
        ),
      ],
    );
  }
}
