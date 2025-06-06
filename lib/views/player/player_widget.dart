import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';
import 'package:sync_player/player/player.dart';
import 'package:sync_player/views/player/components/media_buttons.dart';
import 'package:sync_player/player/player_provider.dart';
import 'package:sync_player/views/player/components/progress_bar.dart';
import 'package:sync_player/views/player/player_screen.dart';

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

  Future<void> _handlePageChange(
    int value,
    PlayerProvider playerProvider,
  ) async {
    setState(() => changingSong = true);
    if (value == 0) {
      await pageController.previousPage(
        duration: Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
      snapshotController.allowSnapshotting = true;
      await Future.delayed(Duration(milliseconds: 50));
      await playerProvider.previousSong();
    } else if (value == 2) {
      await pageController.nextPage(
        duration: Duration(milliseconds: 250),
        curve: Curves.linearToEaseOut,
      );
      snapshotController.allowSnapshotting = true;
      await Future.delayed(Duration(milliseconds: 50));
      await playerProvider.nextSong();
    }
    pageController.jumpToPage(1);
    snapshotController.clear();
    snapshotController.allowSnapshotting = false;
    setState(() => changingSong = false);
  }

  PageRouteBuilder _transitionToPlayer(BuildContext context) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => PlayerScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.linear;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    //double endSwipePosition;
    return Builder(
      builder: (context) {
        if (playerProvider.getPlayerState() != PlayerSt.playing &&
            playerProvider.getPlayerState() != PlayerSt.paused) {
          return SizedBox(height: 0, width: 0);
        }
        return Container(
          height: 80,
          color: const Color.fromARGB(255, 26, 25, 25),
          child: GestureDetector(
            onVerticalDragStart: (details) {
              startSwipePositionY = details.globalPosition.dy;
            },
            onVerticalDragEnd: (details) {
              if (details.globalPosition.dy < startSwipePositionY - 25) {
                Navigator.of(context).push(_transitionToPlayer(context));
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Progress bar
                const LiteProgressBar(),
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
                                if (!playerProvider.isSongHistoryEmpty()) {
                                  _handlePageChange(0, playerProvider);
                                }
                              } else if (details.globalPosition.dx <
                                  startSwipePositionX - 10) {
                                if (!playerProvider.isSongQueueEmpty()) {
                                  _handlePageChange(2, playerProvider);
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
                                      playerProvider.getLastSongInHistory() ??
                                      Song.empty(),
                                ),
                                InkWell(
                                  onTap:
                                      () => Navigator.of(
                                        context,
                                      ).push(_transitionToPlayer(context)),
                                  child: _LiveSongInformation(
                                    playerProvider: playerProvider,
                                  ),
                                ),
                                _CarouselSongInformation(
                                  song:
                                      playerProvider.getNextSongInQueue() ??
                                      Song.empty(),
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
      },
    );
  }
}

class _LiveSongInformation extends StatelessWidget {
  const _LiveSongInformation({required this.playerProvider});

  final PlayerProvider playerProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 77,
          height: 77,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Hero(
              tag: "PlayerImg",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FadeInImage(
                  placeholder: MemoryImage(fileCache.emptyImage),
                  image: MemoryImage(playerProvider.currentSong.album.image),
                  fadeInDuration: Duration(milliseconds: 200),
                  fadeOutDuration: Duration(milliseconds: 50),
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
                  playerProvider.currentSong.artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Hero(
                tag: "SongInfo",
                child: Text(
                  playerProvider.currentSong.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CarouselSongInformation extends StatelessWidget {
  final Song song;
  const _CarouselSongInformation({required this.song});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 77,
          height: 77,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.memory(song.album.image),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.artist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaButtons extends StatelessWidget {
  const _MediaButtons();

  @override
  Widget build(BuildContext context) {
    context.watch<PlayerProvider>();
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
