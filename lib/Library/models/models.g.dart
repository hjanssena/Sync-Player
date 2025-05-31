// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Directories _$DirectoriesFromJson(Map<String, dynamic> json) => Directories(
  paths:
      (json['paths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$DirectoriesToJson(Directories instance) =>
    <String, dynamic>{'paths': instance.paths};

Song _$SongFromJson(Map<String, dynamic> json) => Song(
  uuid: json['uuid'] as String,
  path: json['path'] as String,
  title: json['title'] as String,
  albumArtist: json['albumArtist'] as String,
  trackArtist: json['trackArtist'] as String,
  albumName: json['albumName'] as String,
  genre: json['genre'] as String,
  trackNumber: (json['trackNumber'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  playCount: (json['playCount'] as num?)?.toInt() ?? 0,
  liked: json['liked'] as bool? ?? false,
  scraped: json['scraped'] as bool,
  lastModified: DateTime.parse(json['lastModified'] as String),
  lastPlayed: DateTime.parse(json['lastPlayed'] as String),
);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'path': instance.path,
  'title': instance.title,
  'albumArtist': instance.albumArtist,
  'trackArtist': instance.trackArtist,
  'albumName': instance.albumName,
  'genre': instance.genre,
  'trackNumber': instance.trackNumber,
  'duration': instance.duration,
  'year': instance.year,
  'playCount': instance.playCount,
  'liked': instance.liked,
  'scraped': instance.scraped,
  'lastPlayed': instance.lastPlayed.toIso8601String(),
  'lastModified': instance.lastModified.toIso8601String(),
};

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  songs:
      (json['songs'] as List<dynamic>)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
  created: DateTime.parse(json['created'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
  image: _uint8ListFromBase64(json['image'] as String),
  scraped: json['scraped'] as bool,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'created': instance.created.toIso8601String(),
  'lastModified': instance.lastModified.toIso8601String(),
  'genres': instance.genres,
  'songs': instance.songs,
  'image': _uint8ListToBase64(instance.image),
  'scraped': instance.scraped,
};

PlayList _$PlayListFromJson(Map<String, dynamic> json) => PlayList(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  created: DateTime.parse(json['created'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
  songs:
      (json['songs'] as List<dynamic>)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PlayListToJson(PlayList instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'created': instance.created.toIso8601String(),
  'lastModified': instance.lastModified.toIso8601String(),
  'genres': instance.genres,
  'songs': instance.songs,
};

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  image: _uint8ListFromBase64(json['image'] as String),
  albums:
      (json['albums'] as List<dynamic>)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList(),
  scraped: json['scraped'] as bool,
  lastModified: DateTime.parse(json['lastModified'] as String),
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'image': _uint8ListToBase64(instance.image),
  'albums': instance.albums,
  'genres': instance.genres,
  'scraped': instance.scraped,
  'lastModified': instance.lastModified.toIso8601String(),
};
