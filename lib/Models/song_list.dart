import 'dart:io';
import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sync_player/Models/models.dart';
import 'package:mime/mime.dart';

class SongList extends ChangeNotifier {
  List<String> folderPaths = [];
  List<Song> songs = [];

  Future<void> addPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (Platform.isAndroid) {
      selectedDirectory = fixDuplicatedEndingInPath(
        selectedDirectory.toString(),
      );
    }
    folderPaths.add(selectedDirectory.toString());
    refreshList();
  }

  void removePath(String path) {
    folderPaths.removeWhere((current) => path == current);
    refreshList();
  }

  void addSong(Song newSong) {
    songs.add(newSong);
  }

  void removeSong(Song song) {
    songs.removeWhere((current) => identical(song, current));
  }

  Song get(int idx) {
    return songs[idx];
  }

  int length() {
    return songs.length;
  }

  bool isEmpty() {
    return songs.isEmpty ? true : false;
  }

  Future<void> refreshList() async {
    songs = [];
    for (var path in folderPaths) {
      Directory dir = Directory(path);
      final List<FileSystemEntity> entities =
          await dir.list(recursive: true, followLinks: false).toList();
      for (var entity in entities) {
        if (entity is File) {
          if (lookupMimeType(entity.path)?.split('/')[0] == "audio") {
            Tag? tag = await AudioTags.read(entity.path);
            Song song = Song(
              path: entity.path,
              title: tag?.title ?? 'Unknown song',
              artist: tag?.albumArtist ?? 'Unknown artist',
              album: tag?.album ?? 'No album',
              duration: tag?.duration ?? 0,
              year: tag?.year ?? 2000,
              pictures: tag?.pictures ?? [],
              // Picture(
              //   pictureType: PictureType.artist,
              //   bytes: await File('assets/placeholder.png').readAsBytes(),
              // ),
            );
            addSong(song);
          }
        }
      }
    }
    notifyListeners();
  }

  String fixDuplicatedEndingInPath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();

    final n = parts.length;

    bool listEquals<T>(List<T> a, List<T> b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    for (int size = n ~/ 2; size >= 1; size--) {
      // Compare two blocks from the end
      final firstBlock = parts.sublist(n - 2 * size, n - size);
      final secondBlock = parts.sublist(n - size, n);

      if (listEquals(firstBlock, secondBlock)) {
        return '/${parts.sublist(0, n - size).join('/')}';
      }
    }

    return path;
  }
}
