import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';

class LibraryUtils {
  Song createSong(String path, Tag? tag, int id) {
    Song song = Song(
      id: id,
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
    );
    return song;
  }

  ///Returns and image from the song's metadata. If the metadata doesn't contain images it returns a placeholder image.
  Uint8List getImage(Tag? tag) {
    Uint8List image;
    if (tag != null && tag.pictures.isNotEmpty) {
      image = tag.pictures.first.bytes;
    } else {
      image = fileCache.placeholderImage;
    }
    return image;
  }
}
