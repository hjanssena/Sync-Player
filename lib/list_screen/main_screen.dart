import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:sync_player/Models/music_library.dart';
import 'package:sync_player/list_screen/list_items.dart';
import 'package:sync_player/player/player_widget.dart';
import 'package:sync_player/shared/exit_dialog.dart';
import 'package:sync_player/shared/loading.dart';

class ListScreenState extends ChangeNotifier {
  Artist artist = Artist.placeholder();
  Album album = Album.placeholder();

  void changeArtist(Artist newArtist) {
    artist = newArtist;
    notifyListeners();
  }

  void changeAlbum(Album newAlbum) {
    album = newAlbum;
    notifyListeners();
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var library = context.read<MusicLibrary>();
    return Consumer<MusicLibrary>(
      builder: (context, value, child) {
        if (library.refreshingList) {
          return Loader();
        } else if (value.isEmpty()) {
          return NoDirectoriesScreen();
        } else {
          return ArtistListScreen();
        }
      },
    );
  }
}

class ArtistListScreen extends StatelessWidget {
  const ArtistListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MusicLibrary library = context.read<MusicLibrary>();
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Music library"))),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          ExitDialog exitDialog = ExitDialog();
          bool result = !await exitDialog.showExitDialog(context);
          if (!result) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SystemNavigator.pop();
            });
          }
        },
        child: Center(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: library.artists.length,
            itemBuilder: (BuildContext context, int index) {
              return ArtistItem(artist: library.artists[index]);
            },
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Hero(tag: "playerwidget", child: PlayerWidget()),
      ),
    );
  }
}

class NoDirectoriesScreen extends StatelessWidget {
  const NoDirectoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final MusicLibrary library = context.read<MusicLibrary>();
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("No music found"))),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          ExitDialog exitDialog = ExitDialog();
          bool result = !await exitDialog.showExitDialog(context);
          if (!result) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SystemNavigator.pop();
            });
          }
        },
        child: Column(
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
                library.addPath();
              },
              child: Text('Add directory'),
            ),
          ],
        ),
      ),
    );
  }
}
