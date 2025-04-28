import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/list_screen/list_items.dart';
import 'package:sync_player/player/player_widget.dart';
import 'package:sync_player/shared/exit_dialog.dart';
import 'package:sync_player/shared/loading.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, value, child) {
        if (value.state == LibraryState.loading ||
            value.state == LibraryState.scanning) {
          return Loader();
        } else if (value.state == LibraryState.empty) {
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
    final LibraryProvider library = context.watch<LibraryProvider>();
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
            itemCount: library.displayedArtists().length,
            itemBuilder: (BuildContext context, int index) {
              return ArtistItem(artist: library.displayedArtists()[index]);
            },
          ),
        ),
      ),
      bottomNavigationBar: PlayerWidget(),
    );
  }
}

class NoDirectoriesScreen extends StatelessWidget {
  const NoDirectoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    final LibraryProvider library = context.read<LibraryProvider>();
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
                library.addLibraryPath();
              },
              child: Text('Add directory'),
            ),
          ],
        ),
      ),
    );
  }
}
