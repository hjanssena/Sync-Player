import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sync_player/player/player.dart';

import '../Models/models.dart';

class ListItem extends StatelessWidget {
  final Song song;
  ListItem({super.key, required this.song});
  Player player = Player(song: Song());

  @override
  Widget build(BuildContext context) {
    Uint8List? img;
    if (song.pictures.isNotEmpty) img = song.pictures.first.bytes;
    return Material(
      child: InkWell(
        child: Row(
          children: [
            if (img != null)
              SizedBox(
                width: 50,
                height: 50,
                child: Image(image: Image.memory(img).image),
              ),
            Column(children: [Text("${song.artist} - ${song.title}")]),
          ],
        ),
        onTap: () {
          player.changeSong(song);
        },
      ),
    );
  }

  Future<Uint8List> getImageFromAsset(String path) async {
    return await File('assets/placeholder.png').readAsBytes();
  }
}
