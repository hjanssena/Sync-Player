import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:sync_player/main.dart';
import 'package:crypto/crypto.dart';
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
  final String uuid;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String contentHash;
  String path;
  String title;
  String albumArtist;
  String trackArtist;
  String albumName;
  String genre;
  int trackNumber;
  int duration;
  int year;
  int playCount;
  bool liked;
  bool scraped;
  DateTime lastPlayed;
  DateTime lastModified;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Artist artist = Artist.empty();

  @JsonKey(includeFromJson: false, includeToJson: false)
  Album album = Album.empty();

  Song({
    required this.uuid,
    required this.path,
    required this.title,
    required this.albumArtist,
    required this.trackArtist,
    required this.albumName,
    required this.genre,
    required this.trackNumber,
    required this.duration,
    required this.year,
    this.playCount = 0,
    this.liked = false,
    required this.scraped,
    required this.lastModified,
    required this.lastPlayed,
  }) : contentHash = _generateContentHash(
         albumArtist,
         trackArtist,
         title,
         duration,
       );

  static String _generateContentHash(
    String albumArtist,
    String trackArtist,
    String title,
    int duration,
  ) {
    final content =
        '$albumArtist|$trackArtist|$title|$duration'.toLowerCase().trim();
    return sha1.convert(utf8.encode(content)).toString();
  }

  static Song empty() {
    return Song(
      uuid: '',
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
      lastPlayed: DateTime.now(),
      lastModified: DateTime.now(),
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
    required super.uuid,
    required super.name,
    required super.songs,
    required super.created,
    required super.lastModified,
    required this.image,
    required this.scraped,
    super.genres = const [],
  });

  static Album empty() {
    return Album(
      uuid: '',
      name: '',
      songs: const [],
      image: fileCache.placeholderImage,
      scraped: false,
      created: DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()
class PlayList {
  String uuid;
  String name;
  DateTime created;
  DateTime lastModified;
  List<String> genres;
  List<Song> songs;

  PlayList({
    required this.uuid,
    required this.name,
    required this.created,
    required this.lastModified,
    required this.songs,
    this.genres = const [],
  });

  factory PlayList.fromJson(Map<String, dynamic> json) =>
      _$PlayListFromJson(json);
  Map<String, dynamic> toJson() => _$PlayListToJson(this);
}

@JsonSerializable()
class Artist {
  String uuid;
  String name;
  @JsonKey(fromJson: _uint8ListFromBase64, toJson: _uint8ListToBase64)
  Uint8List image;
  List<Album> albums;
  List<String> genres;
  bool scraped;
  DateTime lastModified;

  Artist({
    required this.uuid,
    required this.name,
    required this.image,
    required this.albums,
    required this.scraped,
    required this.lastModified,
    this.genres = const [],
  });

  static Artist empty() {
    return Artist(
      uuid: '',
      name: '',
      image: fileCache.placeholderImage,
      albums: [],
      scraped: false,
      lastModified: DateTime.now(),
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
