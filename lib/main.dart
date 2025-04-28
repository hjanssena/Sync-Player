import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
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

    //Adding all providers we need
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryProvider>(
          create: (context) => LibraryProvider(),
        ),
        Provider<PlayerState>(
          create: (_) => playerState,
          dispose: (_, playerState) => playerState.dispose(),
        ),
        StreamProvider<PlayerViewState>(
          create: (context) {
            final playerState = context.read<PlayerState>();
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
            context.read<LibraryProvider>().init();
          });
          //Set library reference to player
          context.read<PlayerState>().setLibrary(
            context.read<LibraryProvider>(),
          );
          return MaterialApp(routes: appRoutes, theme: ThemeData.dark());
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
