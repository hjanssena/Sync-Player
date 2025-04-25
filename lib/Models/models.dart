import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:sync_player/main.dart';
part 'models.g.dart';

// Convert images to base64
Uint8List _uint8ListFromBase64(String base64Str) => base64Decode(base64Str);
String _uint8ListToBase64(Uint8List bytes) => base64Encode(bytes);

@JsonSerializable()
class Directories {
  List<String> paths = [];

  Directories({this.paths = const []});
  factory Directories.fromJson(Map<String, dynamic> json) =>
      _$DirectoriesFromJson(json);
  Map<String, dynamic> toJson() => _$DirectoriesToJson(this);
}

@JsonSerializable()
class Song {
  int id;
  String path;
  String title;
  String albumArtist;
  String trackArtist;
  String albumName;
  String genre;
  int trackNumber;
  int duration;
  int year;
  bool scraped;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Artist artist = Artist.empty();
  @JsonKey(includeFromJson: false, includeToJson: false)
  Album album = Album.empty();

  Song({
    required this.id,
    required this.path,
    required this.title,
    required this.albumArtist,
    required this.trackArtist,
    required this.albumName,
    required this.genre,
    required this.trackNumber,
    required this.duration,
    required this.year,
    required this.scraped,
  });

  static Song empty() {
    return Song(
      id: -1 >>> 1,
      path: '',
      title: '',
      albumArtist: '',
      trackArtist: '',
      albumName: '',
      genre: '',
      trackNumber: 0,
      duration: 0,
      year: 0,
      scraped: false,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}

@JsonSerializable()
class Album extends PlayList {
  @JsonKey(fromJson: _uint8ListFromBase64, toJson: _uint8ListToBase64)
  Uint8List image;
  bool scraped;

  Album({
    required super.id,
    required super.name,
    required super.songs,
    required this.image,
    required this.scraped,
  });

  static Album empty() {
    return Album(
      id: -1 >>> 1,
      name: '',
      songs: const [],
      image: fileCache.placeholderImage,
      scraped: false,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()
class PlayList {
  int id;
  String name;
  List<Song> songs;

  PlayList({this.id = -1 >>> 1, this.name = '', this.songs = const []});

  factory PlayList.fromJson(Map<String, dynamic> json) =>
      _$PlayListFromJson(json);
  Map<String, dynamic> toJson() => _$PlayListToJson(this);
}

@JsonSerializable()
class Artist {
  int id;
  String name;
  @JsonKey(fromJson: _uint8ListFromBase64, toJson: _uint8ListToBase64)
  Uint8List image;
  List<Album> albums;
  bool scraped;

  Artist({
    required this.id,
    required this.name,
    required this.image,
    required this.albums,
    required this.scraped,
  });

  static Artist empty() {
    return Artist(
      id: -1 >>> 1,
      name: '',
      image: fileCache.placeholderImage,
      albums: [],
      scraped: false,
    );
  }

  ///Returns all the artist's song from all the albums (Consider moving to controller)
  List<Song> allSongs() {
    List<Song> allSongs = [];
    for (Album album in albums) {
      allSongs.addAll(album.songs);
    }
    return allSongs;
  }

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
