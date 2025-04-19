import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/song_list.dart';
import 'package:sync_player/list_screen/list_screen.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    ///We want to get storage or audio permissions in android depending on the sdk version
    if (Platform.isAndroid) getPermission();

    ///Later we want to read the cached paths and compute the lists from here
    return ChangeNotifierProvider<SongList>(
      create: (context) => SongList(),
      child: MaterialApp(home: MainScreen(), theme: ThemeData.dark()),
    );
  }

  Future<void> getPermission() async {
    var audioStatus = await Permission.audio.status;

    if (!audioStatus.isGranted) {
      await Permission.audio.request();
    }

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }
}
