import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:sync_player/Models/song_list.dart';
import 'package:sync_player/list_screen/list_item.dart';
import 'package:sync_player/main.dart';

class SongListScreen extends StatelessWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('No music found', style: textTheme.headlineMedium),
      ),
      body: Selector<SongListProvider, SongList>(
        selector: (_, changeNotifier) => changeNotifier.songList,
        builder: (context, value, child) {
          if (value.isEmpty()) {
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
                    value.addPath();
                  },
                  child: Text('Add directory'),
                ),
              ],
            );
          } else {
            return Center(
              child: ListView.builder(
                itemCount: value.length(),
                itemBuilder: (BuildContext context, int index) {
                  return ListItem(song: value.get(index));
                },
              ),
            );
          }
        },
      ),
    );
  }
}
