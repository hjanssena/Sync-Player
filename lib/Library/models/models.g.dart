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
  id: (json['id'] as num).toInt(),
  path: json['path'] as String,
  title: json['title'] as String,
  albumArtist: json['albumArtist'] as String,
  trackArtist: json['trackArtist'] as String,
  albumName: json['albumName'] as String,
  genre: json['genre'] as String,
  trackNumber: (json['trackNumber'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  scraped: json['scraped'] as bool,
);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
  'id': instance.id,
  'path': instance.path,
  'title': instance.title,
  'albumArtist': instance.albumArtist,
  'trackArtist': instance.trackArtist,
  'albumName': instance.albumName,
  'genre': instance.genre,
  'trackNumber': instance.trackNumber,
  'duration': instance.duration,
  'year': instance.year,
  'scraped': instance.scraped,
};

Album _$AlbumFromJson(Map<String, dynamic> json) => Album(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  songs:
      (json['songs'] as List<dynamic>)
          .map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList(),
  image: _uint8ListFromBase64(json['image'] as String),
  scraped: json['scraped'] as bool,
);

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'songs': instance.songs,
  'image': _uint8ListToBase64(instance.image),
  'scraped': instance.scraped,
};

PlayList _$PlayListFromJson(Map<String, dynamic> json) => PlayList(
  id: (json['id'] as num?)?.toInt() ?? -1 >>> 1,
  name: json['name'] as String? ?? '',
  songs:
      (json['songs'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PlayListToJson(PlayList instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'songs': instance.songs,
};

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  image: _uint8ListFromBase64(json['image'] as String),
  albums:
      (json['albums'] as List<dynamic>)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList(),
  scraped: json['scraped'] as bool,
);

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': _uint8ListToBase64(instance.image),
  'albums': instance.albums,
  'scraped': instance.scraped,
};
