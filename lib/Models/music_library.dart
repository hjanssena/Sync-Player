import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_player/Models/models.dart';
import 'package:mime/mime.dart';
import 'package:sync_player/Models/model_serializator.dart';
import 'package:sync_player/main.dart';

enum LibraryState { idle, loading, scanning, saving }

class MusicLibrary extends ChangeNotifier {
  Directories _directories = Directories(paths: []);
  List<Artist> artists = [];
  final List<Album> _allAlbums = [];
  final List<Song> _allSongs = [];
  List<PlayList> playlists = [];
  LibraryState libraryState = LibraryState.idle;

  Future<void> loadLibrary() async {
    libraryState = LibraryState.loading;
    notifyListeners();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    _directories = await ModelSerializator.readModel<Directories>(
      "${appDocumentsDir.path}/directories.json",
      Directories.fromJson,
      () => Directories(paths: []),
    );

    artists = await ModelSerializator.readModels<Artist>(
      "${appDocumentsDir.path}/library.json",
      Artist.fromJson,
    );

    for (final artist in artists) {
      for (final album in artist.albums) {
        _allAlbums.add(album);
        for (final song in album.songs) {
          _allSongs.add(song);
          song.artist = artist;
          song.album = album;
        }
      }
    }
    libraryState = LibraryState.idle;
    notifyListeners();
    refreshLibrary();
  }

  Future<void> saveLibrary() async {
    libraryState = LibraryState.saving;
    notifyListeners();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    await ModelSerializator.saveModel<Directories>(
      _directories,
      '${appDocumentsDir.path}/directories.json',
      (a) => a.toJson(),
    );

    await ModelSerializator.saveModels(
      artists,
      '${appDocumentsDir.path}/library.json',
      (a) => a.toJson(),
    );
    libraryState = LibraryState.idle;
  }

  Future<void> refreshLibrary() async {
    //check for deleted songs
    int i = 0;
    while (i < _allSongs.length) {
      File file = File(_allSongs[i].path);
      if (!await file.exists()) {
        _allSongs[i].album.songs.remove(_allSongs[i]);
        if (_allSongs[i].album.songs.isEmpty) {
          _allSongs[i].artist.albums.remove(_allSongs[i].album);
          if (_allSongs[i].artist.albums.isEmpty) {
            artists.remove(_allSongs[i].artist);
          }
        }
        _allSongs.removeAt(i);
      } else {
        i++;
      }
    }
    //look for new songs
    final existingPaths = _allSongs.map((song) => song.path).toSet();
    for (var path in _directories.paths) {
      Directory dir = Directory(path);
      final List<FileSystemEntity> entities =
          await dir.list(recursive: true, followLinks: false).toList();

      for (var entity in entities) {
        if (entity is File) {
          if (lookupMimeType(entity.path)?.split('/')[0] == "audio" &&
              !entity.path.contains("m3u")) {
            try {
              if (!existingPaths.contains(entity.path)) {
                Tag? tag = await AudioTags.read(entity.path);
                Song song = createSong(entity, tag);
                Uint8List? image = getImage(tag);
                addSongToLibrary(song, image);
              }
            } catch (e) {
              // Optionally log or skip
              debugPrint("Failed to process ${entity.path}: $e");
            }
          }
        }
      }
    }
    notifyListeners();
    saveLibrary();
  }

  ///Opens a dialog box to select and add a source directory.
  Future<void> addSourceDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if (Platform.isAndroid) {
        selectedDirectory = fixDuplicatedEndingInPath(
          selectedDirectory.toString(),
        );
      }
      _directories.paths.add(selectedDirectory.toString());
      scanLibraryPaths();
    }
  }

  ///Removes directory from the library sources
  void removeSourceDirectory(String path) {
    _directories.paths.removeWhere((current) => path == current);
    scanLibraryPaths();
  }

  bool isEmpty() {
    return _allSongs.isEmpty ? true : false;
  }

  ///Scans all registered directories and re-generates all the library
  Future<void> scanLibraryPaths() async {
    libraryState = LibraryState.scanning;
    notifyListeners();
    for (var path in _directories.paths) {
      Directory dir = Directory(path);
      final List<FileSystemEntity> entities =
          await dir.list(recursive: true, followLinks: false).toList();

      for (var entity in entities) {
        if (entity is File) {
          if (lookupMimeType(entity.path)?.split('/')[0] == "audio" &&
              !entity.path.contains("m3u")) {
            Tag? tag = await AudioTags.read(entity.path);
            Song song = createSong(entity, tag);
            Uint8List? image = getImage(tag);
            addSongToLibrary(song, image);
          }
        }
      }
    }
    saveLibrary();
    libraryState = LibraryState.idle;
    notifyListeners();
  }

  Song createSong(File entity, Tag? tag) {
    Song song = Song(
      id: _allSongs.length,
      path: entity.path,
      title: tag?.title ?? entity.path.split('/').last.split('.').first,
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

  Uint8List getImage(Tag? tag) {
    Uint8List image;
    if (tag != null && tag.pictures.isNotEmpty) {
      image = tag.pictures.first.bytes;
    } else {
      image = fileCache.placeholderImage;
    }
    return image;
  }

  ///Registers the song with it's corresponding album and artist, and adds it to the allsongs list
  void addSongToLibrary(Song song, Uint8List image) {
    _allSongs.add(song);
    Artist artist = getArtist(song, image);
    song.artist = artist;
    Album album = getAlbum(song, artist, image);
    song.album = album;
    album.songs.add(song);
  }

  ///Gets the artist from the song's metadata, creates a new one if it doesn't exist
  Artist getArtist(Song song, Uint8List image) {
    Artist artist = artists.firstWhere(
      (element) => element.name.toLowerCase() == song.albumArtist.toLowerCase(),
      orElse: () {
        Artist newArtist = Artist(
          id: artists.length,
          name: song.albumArtist,
          image: image,
          albums: [],
          scraped: false,
        );
        artists.add(newArtist);
        return newArtist;
      },
    );
    if (artist.image == fileCache.placeholderImage) artist.image = image;
    return artist;
  }

  ///Gets the album from the song's metadata, creates a new one if it doesn't exist
  Album getAlbum(Song song, Artist artist, Uint8List image) {
    Album album = artist.albums.firstWhere(
      (element) => element.name.toLowerCase() == song.albumName.toLowerCase(),
      orElse: () {
        Album newAlbum = Album(
          id: _allAlbums.length,
          name: song.albumName,
          image: image,
          songs: [],
          scraped: false,
        );
        artist.albums.add(newAlbum);
        return newAlbum;
      },
    );
    if (album.image == fileCache.placeholderImage) album.image = image;
    return album;
  }

  ///Returns a random song from all the songs in the library
  Song getRandomSong() {
    final random = Random();
    return _allSongs[random.nextInt(_allSongs.length)];
  }

  ///Returns the total number of songs in the library
  int allSongsCount() {
    return _allSongs.length;
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
