import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';

class Song {
  String path;
  String title;
  String artist;
  String album;
  int duration;
  int year;
  List<Picture> pictures;
  bool scraped;

  Song({
    this.path = '',
    this.title = '',
    this.artist = '',
    this.album = '',
    this.duration = 0,
    this.year = 0,
    this.pictures = const [],
    this.scraped = false,
  });
}

class Album {
  final String name;
  final Image image;
  final List<Song> songs;

  Album({required this.name, required this.image, required this.songs});

  static Album placeholder() {
    return Album(
      name: '',
      image: Image.asset('assets/placeholder.png'),
      songs: [],
    );
  }
}

class Artist {
  final String name;
  Image image;
  final List<Album> albums;

  Artist({required this.name, required this.image, required this.albums});

  static Artist placeholder() {
    return Artist(
      name: '',
      image: Image.asset('assets/placeholder.png'),
      albums: [],
    );
  }

  List<Song> allSongs() {
    List<Song> allSongs = [];
    for (Album album in albums) {
      allSongs.addAll(album.songs);
    }
    return allSongs;
  }
}

class PlayList {
  String name = '';
  List<Song> songList = [];
}
