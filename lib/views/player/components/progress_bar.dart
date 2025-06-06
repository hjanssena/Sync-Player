import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/player/player_provider.dart';

class SongProgressBar extends StatefulWidget {
  const SongProgressBar({super.key});

  @override
  State<SongProgressBar> createState() => _SongProgressBarState();
}

class _SongProgressBarState extends State<SongProgressBar> {
  double? _dragValue;
  bool _isDragging = false;

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();

    return StreamBuilder<Duration>(
      stream: playerProvider.positionStream,
      builder: (context, snapshot) {
        var totalDuration = playerProvider.currentSong.duration;
        final currentPosition =
            snapshot.data?.inMilliseconds ?? Duration.zero.inMilliseconds;
        totalDuration = totalDuration * 1000;

        final progress = currentPosition / totalDuration;
        final displayedProgress =
            _isDragging ? (_dragValue ?? progress) : progress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: displayedProgress.clamp(0.0, 1.0),
                onChangeStart: (value) {
                  setState(() {
                    _isDragging = true;
                    _dragValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    _dragValue = value;
                  });
                },
                onChangeEnd: (value) {
                  final newPosition = (value * totalDuration).toInt();
                  playerProvider.seek(Duration(milliseconds: newPosition));

                  setState(() {
                    _isDragging = false;
                    _dragValue = null;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(
                      (_isDragging
                          ? (_dragValue! * totalDuration).toInt()
                          : currentPosition),
                    ),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LiteProgressBar extends StatelessWidget {
  const LiteProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    return StreamBuilder<Duration>(
      stream: playerProvider.positionStream,
      builder: (context, snapshot) {
        final currentPosition = snapshot.data ?? Duration.zero;
        final totalDuration = playerProvider.currentSong.duration * 1000;
        final progress = currentPosition.inMilliseconds / totalDuration;
        return LinearProgressIndicator(
          value: progress.clamp(0, 1),
          minHeight: 3,
        );
      },
    );
  }
}
