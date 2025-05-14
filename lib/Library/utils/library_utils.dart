import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';
import 'package:uuid/uuid.dart';

class LibraryUtils {
  static Song createSong(String path, Tag? tag) {
    var uuid = Uuid();
    Song song = Song(
      uuid: uuid.v4(),
      path: path,
      title: tag?.title ?? path.split('/').last.split('.').first,
      albumArtist: tag?.albumArtist ?? tag?.trackArtist ?? 'Unknown artist',
      trackArtist: tag?.trackArtist ?? tag?.albumArtist ?? 'Unknown artist',
      albumName: tag?.album ?? 'No album',
      genre: tag?.genre ?? 'No genre',
      trackNumber: tag?.trackNumber ?? -1 >>> 1,
      duration: tag?.duration ?? 0,
      year: tag?.year ?? 2000,
      scraped: false,
      lastModified: DateTime.now(),
    );
    return song;
  }

  static Album createAlbum(Song song, Artist artist, Uint8List image) {
    final uuid = Uuid();
    return Album(
      uuid: uuid.v4(),
      name: song.albumName,
      image: image,
      songs: [],
      scraped: false,
      lastModified: DateTime.now(),
    );
  }

  static Artist createArtist(Song song, Uint8List image) {
    final uuid = Uuid();
    return Artist(
      uuid: uuid.v4(),
      name: song.albumArtist,
      lastModified: DateTime.now(),
      image: image,
      albums: [],
      scraped: false,
    );
  }

  ///Returns and image from the song's metadata. If the metadata doesn't contain images it returns a placeholder image.
  static Uint8List getImage(Tag? tag) {
    Uint8List image;
    if (tag != null && tag.pictures.isNotEmpty) {
      image = tag.pictures.first.bytes;
    } else {
      image = fileCache.placeholderImage;
    }
    return image;
  }
}
