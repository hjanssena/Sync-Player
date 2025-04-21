import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';

class Song {
  String path;
  String title;
  String artistTag;
  String albumTag;
  int duration;
  int year;
  List<Picture> pictures;
  bool scraped;
  Artist artist = Artist.placeholder();
  Album album = Album.placeholder();

  Song({
    this.path = '',
    this.title = '',
    this.artistTag = '',
    this.albumTag = '',
    this.duration = 0,
    this.year = 0,
    this.pictures = const [],
    this.scraped = false,
  });

  Song? nextInAlbum() {
    int i = 0;

    while (this != album.songs[i]) {
      i++;
    }
    if (i >= album.songs.length - 1) {
      return null;
    } else {
      return album.songs[i + 1];
    }
  }

  Song? previousInAlbum() {
    int i = 0;

    while (this != album.songs[i]) {
      i++;
    }
    if (i >= 1) {
      return album.songs[i - 1];
    } else {
      return null;
    }
  }
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
