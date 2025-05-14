import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/player/player_provider.dart';
import 'package:sync_player/routes.dart';
import 'package:sync_player/services/file_cache.dart';

late final FileCache fileCache;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Creating references to assets that are used multiple times on the application
  fileCache = await FileCache.create();
  //Initialize the player service
  final PlayerProvider playerProvider = PlayerProvider();
  runApp(Home(playerProvider: playerProvider));
}

class Home extends StatelessWidget {
  final PlayerProvider playerProvider;
  const Home({super.key, required this.playerProvider});
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
    if (Platform.isAndroid) {
      var audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        var status = await Permission.audio.request();
        if (status.isDenied) {
          // Pending implementation
          print("Audio permission denied");
        }
      }

      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        var status = await Permission.storage.request();
        if (status.isDenied) {
          // Pending implementation
          print("Storage permission denied");
        }
      }
    } else if (Platform.isIOS) {
      // Pending implementation
    }
  }
}
