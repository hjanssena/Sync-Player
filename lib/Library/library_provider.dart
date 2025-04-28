import 'package:flutter/material.dart';
import 'package:sync_player/Library/library_model.dart';
import 'package:sync_player/Library/models/models.dart';

enum LibraryState { idle, loading, scanning, saving, empty }

class LibraryProvider extends ChangeNotifier {
  LibraryState state = LibraryState.idle;
  Library library = Library();
  Artist selectedArtist = Artist.empty();
  Album selectedAlbum = Album.empty();

  Future<void> init() async {
    state = LibraryState.loading;
    notifyListeners();
    await library.loadLibrary();
    if (library.noDirectoryPaths()) {
      state = LibraryState.empty;
    } else if (library.isEmpty()) {
      await library.refreshLibrary();
      if (library.isEmpty()) {
        state = LibraryState.empty;
      }
    } else {
      state = LibraryState.idle;
    }
    notifyListeners();
  }

  Future<void> addLibraryPath() async {
    state = LibraryState.loading;
    notifyListeners();
    await library.addDirectoryPath();
    state = LibraryState.idle;
    notifyListeners();
  }

  ///Add filtering later
  List<Artist> displayedArtists() {
    return library.getArtists();
  }

  ///Returns a list of albums depending on the selected artist. Add filtering later
  List<Album> displayedAlbums() {
    List<Album> albums;
    if (selectedArtist.id != -1 >>> 1) {
      albums = selectedArtist.albums;
    } else {
      albums = library.getAllAlbums();
    }

    return albums;
  }

  List<Song> getArtistSongs() {
    return selectedArtist.allSongs();
  }

  List<Song> getAlbumSongs() {
    return selectedAlbum.songs;
  }

  List<Song> getAllSongs() {
    return library.getAllSongs();
  }

  Song getRandomSong() {
    return library.getRandomSong();
  }

  void changeSelectedArtist(Artist newArtist) {
    selectedArtist = newArtist;
    notifyListeners();
  }

  void changeSelectedAlbum(Album newAlbum) {
    selectedAlbum = newAlbum;
    notifyListeners();
  }
}
