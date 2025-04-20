import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/music_library.dart';
import 'package:sync_player/list_screen/main_screen.dart';
import 'package:sync_player/player/player_widget.dart';
import 'package:sync_player/routes.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    ///We want to get storage or audio permissions in android depending on the sdk version
    if (Platform.isAndroid) getPermission();

    ///Later we want to read the cached info to populate the library from here

    //Adding all providers we need
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MusicLibrary>(
          create: (context) => MusicLibrary(),
        ),
        ChangeNotifierProvider<ListScreenState>(
          create: (context) => ListScreenState(),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: MaterialApp(routes: appRoutes, theme: ThemeData.dark()),
          ),
          SizedBox(height: 75, child: PlayerWidget()),
        ],
      ),
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
