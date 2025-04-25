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
import 'package:sync_player/services/file_cache.dart';

late final AudioHandler audioHandler;
late final PlayerState playerState;
late final FileCache fileCache;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Creating references to assets that are used multiple times on the application
  fileCache = await FileCache.create();
  //Initialize the player service
  playerState = PlayerState();
  //Initialize the handler for background playback and notification media control
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
    ///Get storage or audio permissions in android depending on the sdk version
    if (Platform.isAndroid) getPermission();

    ///Load library if it exists

    //Adding all providers we need
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MusicLibrary>(
          create: (context) => MusicLibrary(),
        ),
        ChangeNotifierProvider<LibraryScreenState>(
          create: (context) => LibraryScreenState(),
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
      child: Builder(
        builder: (context) {
          //Load library
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MusicLibrary>().loadLibrary();
          });
          ThemeData theme = ThemeData.dark();
          return MaterialApp(
            routes: appRoutes,
            theme: ThemeData.dark().copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getPermission() async {
    var audioStatus = await Permission.audio.status;

    if (!audioStatus.isGranted) {
      try {
        await Permission.audio.request();
      } catch (e) {
        //not supported by the phone
      }
    }

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      try {
        await Permission.storage.request();
      } catch (e) {
        //Not supported by the phone
      }
    }
  }
}
