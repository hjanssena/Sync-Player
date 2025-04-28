import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sync_player/Library/utils/directory_scanner.dart';
import 'package:sync_player/Library/utils/library_utils.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/Library/models/model_serializator.dart';
import 'package:sync_player/main.dart';

class Library {
  Directories _directories = Directories(paths: []);
  List<Artist> _artists = [];
  final List<Album> _allAlbums = [];
  final List<Song> _allSongs = [];
  List<PlayList> playlists = [];
  LibraryUtils utils = LibraryUtils();

  ///Loads the library, playlist and directories json to memory.
  Future<void> loadLibrary() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    //Load source dirs
    _directories = await ModelSerializator.readModel<Directories>(
      "${appDocumentsDir.path}/directories.json",
      Directories.fromJson,
      () => Directories(paths: []),
    );

    //Load library
    _artists = await ModelSerializator.readModels<Artist>(
      "${appDocumentsDir.path}/library.json",
      Artist.fromJson,
    );

    //Load playlists
    playlists = await ModelSerializator.readModels<PlayList>(
      "${appDocumentsDir.path}/playlists.json",
      PlayList.fromJson,
    );

    //Build library references
    for (final artist in _artists) {
      for (final album in artist.albums) {
        _allAlbums.add(album);
        for (final song in album.songs) {
          _allSongs.add(song);
          song.artist = artist;
          song.album = album;
        }
      }
    }
    refreshLibrary();
  }

  ///Saves the library and dir sources to json
  Future<void> saveLibrary() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    await ModelSerializator.saveModel<Directories>(
      _directories,
      '${appDocumentsDir.path}/directories.json',
      (a) => a.toJson(),
    );

    await ModelSerializator.saveModels(
      _artists,
      '${appDocumentsDir.path}/library.json',
      (a) => a.toJson(),
    );

    //Load playlists
    await ModelSerializator.saveModels<PlayList>(
      playlists,
      "${appDocumentsDir.path}/playlists.json",
      (a) => a.toJson(),
    );
  }

  Future<void> refreshLibrary() async {
    //check for deleted songs
    await _checkLibraryForDeletedFiles();
    //look for new songs in all source directories
    await _addAudioFilesFromAllDirPaths();
    saveLibrary();
  }

  ///Opens a dialog box to select and add a source directory.
  Future<void> addDirectoryPath() async {
    DirectoryScanner scanner = DirectoryScanner();
    String newPath = await scanner.addDirectoryPath();
    _directories.paths.add(newPath);
    await _addAudioFilesFromNewDirPath(newPath);
  }

  ///Removes directory from the library sources
  void removeDirectoryPath(String path) {
    _directories.paths.removeWhere((current) => path == current);
    refreshLibrary();
  }

  ///Scans a new directory path and adds all songs found to the library
  Future<void> _addAudioFilesFromNewDirPath(String path) async {
    DirectoryScanner scanner = DirectoryScanner();
    for (String filePath in await scanner.getAudioFilePathsFromDirectories(
      path,
    )) {
      try {
        await _addSongToLibrary(filePath);
      } catch (e) {
        debugPrint("Failed to process $filePath: $e");
      }
    }
    await saveLibrary();
  }

  ///Scans all the saved sources for new songs that are not already in the database
  Future<void> _addAudioFilesFromAllDirPaths() async {
    DirectoryScanner scanner = DirectoryScanner();
    final existingPaths = _allSongs.map((song) => song.path).toSet();
    for (var path in _directories.paths) {
      for (String filePath in await scanner.getAudioFilePathsFromDirectories(
        path,
      )) {
        try {
          if (!existingPaths.contains(filePath)) {
            await _addSongToLibrary(filePath);
          }
        } catch (e) {
          debugPrint("Failed to process $filePath: $e");
        }
      }
    }
    await saveLibrary();
  }

  ///Checks a source directory for deleted audio files. If a file is not found it is removed from the library.
  ///Also checks for empty albums and artists and deletes them if empty.
  Future<void> _checkLibraryForDeletedFiles() async {
    int i = 0;
    while (i < _allSongs.length) {
      File file = File(_allSongs[i].path);
      if (!await file.exists()) {
        _allSongs[i].album.songs.remove(_allSongs[i]);
        if (_allSongs[i].album.songs.isEmpty) {
          _allSongs[i].artist.albums.remove(_allSongs[i].album);
          _allAlbums.remove(_allSongs[i].album);
          if (_allSongs[i].artist.albums.isEmpty) {
            _artists.remove(_allSongs[i].artist);
          }
        }
        _allSongs.removeAt(i);
      } else {
        i++;
      }
    }
  }

  ///Empties all the models and re-scans all the paths.
  Future<void> rebuildLibrary() async {
    _allAlbums.clear();
    _allSongs.clear();
    _artists.clear();
    for (String path in _directories.paths) {
      _addAudioFilesFromNewDirPath(path);
    }
  }

  ///Registers the song with it's corresponding album and artist, and adds it to the allsongs list
  Future<void> _addSongToLibrary(String filePath) async {
    //Get metadata and create song object
    Tag? tag = await AudioTags.read(filePath);
    Song song = utils.createSong(filePath, tag, _allSongs.length);
    //Get image from song metadata if it exist to add to artist or album if needed
    Uint8List? image = utils.getImage(tag);
    _allSongs.add(song);
    //Get album and artist to establish relations. The artist has albums and albums has songs. Each song also has reference to it's album and artist to make things simpler.
    Artist artist = _getArtistFromSong(song, image);
    song.artist = artist;
    Album album = _getAlbumFromSong(song, artist, image);
    song.album = album;
    album.songs.add(song);
  }

  ///Gets the artist from the song's metadata, creates a new one if it doesn't exist
  Artist _getArtistFromSong(Song song, Uint8List image) {
    Artist artist = _artists.firstWhere(
      (element) => element.name.toLowerCase() == song.albumArtist.toLowerCase(),
      orElse: () {
        Artist newArtist = Artist(
          id: _artists.length,
          name: song.albumArtist,
          image: image,
          albums: [],
          scraped: false,
        );
        _artists.add(newArtist);
        return newArtist;
      },
    );
    if (artist.image == fileCache.placeholderImage) artist.image = image;
    return artist;
  }

  ///Gets the album from the song's metadata, creates a new one if it doesn't exist
  Album _getAlbumFromSong(Song song, Artist artist, Uint8List image) {
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

  List<Artist> getArtists() {
    return _artists;
  }

  List<Album> getAllAlbums() {
    return _allAlbums;
  }

  List<Song> getAllSongs() {
    return _allSongs;
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

  bool isEmpty() {
    return _allSongs.isEmpty ? true : false;
  }

  bool noDirectoryPaths() {
    return _directories.paths.isEmpty ? true : false;
  }
}
