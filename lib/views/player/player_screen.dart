import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/views/Player/components/media_buttons.dart';
import 'package:sync_player/player/player_provider.dart';
import 'package:sync_player/views/Player/components/progress_bar.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late double startSwipePositionY;
  late double startSwipePositionX;
  late final PageController pageController;
  late final SnapshotController snapshotController;
  late bool changingSong;

  @override
  void initState() {
    super.initState();
    startSwipePositionY = 0;
    startSwipePositionX = 0;
    pageController = PageController(initialPage: 1);
    snapshotController = SnapshotController();
    changingSong = false;
  }

  void _handleVerticalSwipes(double endSwipePositionY) {
    if (endSwipePositionY > startSwipePositionY + 30) {
      Navigator.pop(context);
    } else if (endSwipePositionY < startSwipePositionY - 30) {
      //Navigate to queue screen
    }
  }

  Future<void> _handlePageChange(double value) async {
    setState(() => changingSong = true);
    if (value == 0) {
      await pageController.previousPage(
        duration: Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
      snapshotController.allowSnapshotting = true;
      await Future.delayed(Duration(milliseconds: 50));
      await audioHandler.skipToPrevious();
    } else if (value == 2) {
      await pageController.nextPage(
        duration: Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
      snapshotController.allowSnapshotting = true;
      await Future.delayed(Duration(milliseconds: 50));
      await audioHandler.skipToNext();
    }
    pageController.jumpToPage(1);
    snapshotController.clear();
    snapshotController.allowSnapshotting = false;
    setState(() => changingSong = false);
  }

  @override
  Widget build(BuildContext context) {
    final PlayerProvider playerProvider = context.watch<PlayerProvider>();
    return GestureDetector(
      onVerticalDragStart: (details) {
        startSwipePositionY = details.globalPosition.dy;
      },
      onVerticalDragEnd: (details) {
        _handleVerticalSwipes(details.globalPosition.dy);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Now playing",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onHorizontalDragStart: (details) {
                  startSwipePositionX = details.globalPosition.dx;
                },
                onHorizontalDragEnd: (details) {
                  if (!changingSong) {
                    if (details.globalPosition.dx > startSwipePositionX + 10) {
                      if (!playerProvider.isSongHistoryEmpty()) {
                        _handlePageChange(0);
                      }
                    } else if (details.globalPosition.dx <
                        startSwipePositionX - 10) {
                      if (!playerProvider.isSongQueueEmpty()) {
                        _handlePageChange(2);
                      }
                    }
                  }
                },
                child: SnapshotWidget(
                  controller: snapshotController,
                  mode: SnapshotMode.normal,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    pageSnapping: true,
                    children: [
                      _CarouselSongPage(
                        song:
                            playerProvider.getLastSongInHistory() ??
                            Song.empty(),
                      ),
                      _CurrentSongPage(),
                      _CarouselSongPage(
                        song:
                            playerProvider.getNextSongInQueue() ?? Song.empty(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(tag: "BackBtn", child: PreviousSongButton(size: 65)),
                Hero(tag: "PlayBtn", child: PlayPauseButton(size: 80)),
                Hero(tag: "FwdBtn", child: NextSongButton(size: 65)),
              ],
            ),
            SongProgressBar(),
            SizedBox(width: 100),
          ],
        ),
      ),
    );
  }
}

class _CurrentSongPage extends StatelessWidget {
  const _CurrentSongPage({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerProvider = context.watch<PlayerProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 300,
          child: Hero(
            tag: "PlayerImg",
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(playerProvider.currentSong.album.image),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0, right: 5.0, left: 5.0),
          child: Center(
            child: Hero(
              tag: "ArtistInfo",
              child: Text(
                playerProvider.currentSong.artist.name,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Hero(
              tag: "SongInfo",
              child: Text(
                playerProvider.currentSong.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselSongPage extends StatelessWidget {
  final Song song;
  const _CarouselSongPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 300,
          child: Hero(
            tag: "PlayerImg",
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(song.album.image),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0, right: 5.0, left: 5.0),
          child: Center(
            child: Hero(
              tag: "ArtistInfo",
              child: Text(
                song.artist.name,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Hero(
              tag: "SongInfo",
              child: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
