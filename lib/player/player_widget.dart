import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/media_buttons.dart';
import 'package:sync_player/player/player_state.dart';
import 'package:sync_player/player/progress_bar.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool changingSong = false;
  late final PageController pageController;
  late final SnapshotController snapshotController;
  late double startSwipePositionY;
  late double startSwipePositionX;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
    snapshotController = SnapshotController(allowSnapshotting: false);
    startSwipePositionY = 0;
    startSwipePositionX = 0;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _handlePageChange(int value) async {
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
    final playerState = context.watch<PlayerViewState>();
    final player = context.read<PlayerState>();
    //double endSwipePosition;

    return Container(
      height: 80,
      color: const Color.fromARGB(255, 26, 25, 25),
      child: GestureDetector(
        onVerticalDragStart: (details) {
          startSwipePositionY = details.globalPosition.dy;
        },
        onVerticalDragEnd: (details) {
          if (details.globalPosition.dy < startSwipePositionY - 25) {
            Navigator.pushNamed(context, '/player');
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress bar
            Hero(tag: "ProgressBar", child: const LiteProgressBar()),
            // Song content and buttons
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragStart: (details) {
                        startSwipePositionX = details.globalPosition.dx;
                      },
                      onHorizontalDragEnd: (details) {
                        if (!changingSong) {
                          if (details.globalPosition.dx >
                              startSwipePositionX + 10) {
                            if (!player.isSongHistoryEmpty()) {
                              _handlePageChange(0);
                            }
                          } else if (details.globalPosition.dx <
                              startSwipePositionX - 10) {
                            if (!player.isSongQueueEmpty()) {
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
                            _CarouselSongInformation(
                              song:
                                  player.getLastSongInHistory() ?? Song.empty(),
                            ),
                            _LiveSongInformation(playerState: playerState),
                            _CarouselSongInformation(
                              song: player.getNextSongInQueue() ?? Song.empty(),
                            ),
                          ],
                          onPageChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _MediaButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveSongInformation extends StatelessWidget {
  const _LiveSongInformation({super.key, required this.playerState});

  final PlayerViewState playerState;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/player'),
      child: Row(
        children: [
          SizedBox(
            width: 77,
            height: 77,
            child: Hero(
              tag: "PlayerImg",
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    playerState.currentAlbum?.image ??
                        fileCache.placeholderImage,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: "ArtistInfo",
                  child: Text(
                    playerState.currentArtist?.name ?? "No artist",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Hero(
                  tag: "SongInfo",
                  child: Text(
                    playerState.currentSong?.title ?? "No song",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselSongInformation extends StatelessWidget {
  final Song song;
  const _CarouselSongInformation({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/player'),
      child: Row(
        children: [
          SizedBox(
            width: 77,
            height: 77,
            child: Hero(
              tag: "PlayerImg",
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(song.album.image),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: "ArtistInfo",
                  child: Text(
                    song.artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Hero(
                  tag: "SongInfo",
                  child: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButtons extends StatelessWidget {
  const _MediaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PlayerViewState>();
    return Container(
      color: const Color.fromARGB(255, 26, 25, 25),
      child: Builder(
        builder: (context) {
          if (Platform.isAndroid || Platform.isIOS) {
            return Row(
              children: [
                Hero(tag: "PlayBtn", child: PlayPauseButton(size: 50)),
              ],
            );
          } else {
            return Row(
              children: [
                Hero(tag: "BackBtn", child: PreviousSongButton(size: 45)),
                Hero(tag: "PlayBtn", child: PlayPauseButton(size: 60)),
                Hero(tag: "FwdBtn", child: NextSongButton(size: 45)),
              ],
            );
          }
        },
      ),
    );
  }
}
