import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/player/player_provider.dart';
import 'package:sync_player/routes.dart';
import 'package:sync_player/services/background_audio_handler.dart';
import 'package:sync_player/services/file_cache.dart';

late final FileCache fileCache;
late final AudioHandler audioHandler;
late final PlayerProvider playerProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Creating references to assets that are used multiple times on the application
  fileCache = await FileCache.create();
  //Initialize the player service
  playerProvider = PlayerProvider();
  //Initialize the handler for background playback and notification media control
  audioHandler = await AudioService.init(
    builder:
        () =>
            BackgroundAudioHandler(playerProvider: playerProvider)
                as AudioHandler,
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
        ChangeNotifierProvider<PlayerProvider>(create: (_) => playerProvider),
      ],
      child: Builder(
        builder: (context) {
          //Load library
          LibraryProvider library = context.read<LibraryProvider>();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            library.init();
          });
          //Set library reference to player
          context.read<PlayerProvider>().setLibrary(library);
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
