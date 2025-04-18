import 'package:audiotags/audiotags.dart';

class Song {
  String path;
  String title;
  String artist;
  String album;
  int duration;
  int year;
  List<Picture> pictures;

  Song({
    this.path = '',
    this.title = '',
    this.artist = '',
    this.album = '',
    this.duration = 0,
    this.year = 0,
    this.pictures = const [],
  });
}

class Album {}

class Artist {}

class PlayList {
  String name = '';
  List<Song> songList = [];
}
