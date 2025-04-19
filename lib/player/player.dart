import 'package:sync_player/Models/models.dart';
import 'package:audioplayers/audioplayers.dart';

class Player {
  Player({required this.song});
  Song song;
  // ignore: prefer_final_fields
  AudioPlayer _audioPlayer = AudioPlayer();

  void resume() {
    _audioPlayer.resume();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(int nextPosition) {
    Duration position = Duration(milliseconds: nextPosition);
    _audioPlayer.seek(position);
  }

  void changeSong(Song newSong) {
    song = newSong;
    DeviceFileSource deviceFileSource = DeviceFileSource(song.path);
    _audioPlayer.play(deviceFileSource);
  }
}
