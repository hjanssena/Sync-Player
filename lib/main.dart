import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/music_library.dart';
import 'package:sync_player/list_screen/main_screen.dart';
import 'package:sync_player/player/player_state.dart';
import 'package:sync_player/routes.dart';
import 'package:sync_player/services/background_audio_handler.dart';

late final AudioHandler audioHandler;
late final PlayerState playerState;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  playerState = PlayerState();
  audioHandler = await AudioService.init(
    builder: () => BackgroundAudioHandler(player: playerState),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.sync_player.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
    ),
  );
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
        Provider<PlayerState>(
          create: (_) => playerState,
          dispose: (_, playerState) => playerState.dispose(),
        ),
        StreamProvider<PlayerViewState>(
          create: (context) {
            final playerState = context.read<PlayerState>();
            final library = context.read<MusicLibrary>();
            playerState.setLibrary(library);
            return playerState.stateStream;
          },
          initialData: const PlayerViewState(
            currentSong: null,
            currentAlbum: null,
            currentArtist: null,
            timeEllapsedMilliseconds: 0,
            playing: false,
          ),
        ),
      ],
      child: MaterialApp(routes: appRoutes, theme: ThemeData.dark()),
    );
  }

  Future<void> getPermission() async {
    var audioStatus = await Permission.audio.status;

    if (!audioStatus.isGranted) {
      await Permission.audio.request();
    }

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      try {
        await Permission.storage.request();
      } catch (e) {}
    }
  }
}
