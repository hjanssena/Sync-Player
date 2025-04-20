import 'dart:io';
import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sync_player/Models/models.dart';
import 'package:mime/mime.dart';

class MusicLibrary extends ChangeNotifier {
  List<String> folderPaths = [];
  List<Artist> artists = [];
  List<PlayList> playlists = [];
  final Image placeholder = Image.asset('assets/placeholder.png');

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

  bool isEmpty() {
    return artists.isEmpty ? true : false;
  }

  Future<void> refreshList() async {
    for (var path in folderPaths) {
      Directory dir = Directory(path);
      final List<FileSystemEntity> entities =
          await dir.list(recursive: true, followLinks: false).toList();

      for (var entity in entities) {
        if (entity is File) {
          if (lookupMimeType(entity.path)?.split('/')[0] == "audio" &&
              !entity.path.contains("m3u")) {
            Tag? tag = await AudioTags.read(entity.path);
            Song song = createSong(entity, tag);
            addSongToLibrary(song);
          }
        }
      }
    }
    notifyListeners();
  }

  Song createSong(File entity, Tag? tag) {
    Song song = Song(
      path: entity.path,
      title: tag?.title ?? entity.path.split('/').last.split('.').first,
      artist: tag?.albumArtist ?? tag?.trackArtist ?? 'Unknown artist',
      album: tag?.album ?? 'No album',
      duration: tag?.duration ?? 0,
      year: tag?.year ?? 2000,
      pictures: tag?.pictures ?? [],
    );
    return song;
  }

  void addSongToLibrary(Song song) {
    Artist artist = getArtist(song);
    Album album = getAlbum(song, artist);
    album.songs.add(song);
  }

  ///Gets the artist from the song's metadata, creates a new one if it doesn't exist
  Artist getArtist(Song song) {
    Artist artist = artists.firstWhere(
      (element) => element.name.toLowerCase() == song.artist.toLowerCase(),
      orElse: () {
        Artist newArt = Artist(
          name: song.artist,
          image:
              song.pictures.isNotEmpty
                  ? Image.memory(song.pictures.first.bytes)
                  : placeholder,
          albums: [],
        );
        artists.add(newArt);
        return newArt;
      },
    );
    if (song.pictures.isNotEmpty &&
        artist.image == placeholder &&
        Image.memory(song.pictures.first.bytes) != placeholder) {
      artist.image = Image.memory(song.pictures.first.bytes);
    }
    return artist;
  }

  ///Gets the album from the song's metadata, creates a new one if it doesn't exist
  Album getAlbum(Song song, Artist artist) {
    Album album = artist.albums.firstWhere(
      (element) => element.name.toLowerCase() == song.album.toLowerCase(),
      orElse: () {
        Album newAlbum = Album(
          name: song.album,
          image:
              song.pictures.isNotEmpty
                  ? Image.memory(song.pictures.first.bytes)
                  : placeholder,
          songs: [],
        );
        artist.albums.add(newAlbum);
        return newAlbum;
      },
    );
    return album;
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
