import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:sync_player/Library/library_provider.dart';
import 'package:sync_player/Library/models/models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

class PlayerState {
  // Singleton instance
  static final PlayerState _instance = PlayerState._internal();
  factory PlayerState() => _instance;

  // Audio player from just_audio
  final AudioPlayer audioPlayer = AudioPlayer();

  // Constructor (private for singleton)
  PlayerState._internal() {
    _init();
  }

  /// Initialization: configure audio session and listen to events
  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // Handle end of song playback
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && playing) {
        playing = false;
        nextSong();
      }
      if (Platform.isWindows) {
        audioPlayer.setVolume(.7);
      }
    });

    // Update playback progress
    audioPlayer.positionStream.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
      _controller.add(viewState);
    });

    // Initialize MediaKit (used on Windows/Linux)
    JustAudioMediaKit.title = 'Sync Player';
    JustAudioMediaKit.ensureInitialized();
  }

  // Queues for history and upcoming songs
  final Queue<Song> _previousSongs = Queue<Song>();
  final Queue<Song> _songQueue = Queue<Song>();

  // Current playback metadata
  Song currentSong = Song.empty();
  Album currentAlbum = Album.empty();
  Artist currentArtist = Artist.empty();
  int timeEllapsedMilliseconds = 0;
  bool playing = false;

  // View state stream controller
  final _controller = StreamController<PlayerViewState>.broadcast();
  Stream<PlayerViewState> get stateStream => _controller.stream;

  PlayerViewState get viewState => PlayerViewState(
    currentSong: currentSong,
    currentAlbum: currentAlbum,
    currentArtist: currentArtist,
    timeEllapsedMilliseconds: timeEllapsedMilliseconds,
    playing: playing,
  );

  // Music data source
  LibraryProvider _musicLibrary = LibraryProvider();
  void setLibrary(LibraryProvider library) => _musicLibrary = library;

  /// Start/resume playback
  Future<void> resume() async {
    if (currentSong.title != '') {
      playing = true;
      await audioPlayer.play();
      _controller.add(viewState);
    } else {
      currentSong = _musicLibrary.getRandomSong();
      await _changeSong(currentSong.artist, currentSong.album, currentSong);
      _controller.add(viewState);
    }
  }

  /// Stop playback and frees all player resources
  Future<void> stop() async {
    playing = false;
    await audioPlayer.stop();
    _controller.add(viewState);
  }

  /// Pause playback
  Future<void> pause() async {
    playing = false;
    await audioPlayer.pause();
    _controller.add(viewState);
  }

  /// Set current song and playlist
  Future<void> setSongAndPlaylist(
    Artist artist,
    Album album,
    Song song,
    PlayList playlist,
  ) async {
    await audioPlayer.stop();
    if (currentSong.title != '') {
      _addSongToHistory(currentSong);
    }
    currentArtist = artist;
    currentAlbum = album;
    currentSong = song;
    await audioPlayer.setAudioSource(AudioSource.file(song.path));
    resume();
    _songQueue.clear();
    _fillQueueWithPlaylist(playlist);
    _fillQueue();
  }

  /// Change to new song (internal)
  Future<void> _changeSong(Artist artist, Album album, Song song) async {
    await audioPlayer.stop();
    currentArtist = artist;
    currentAlbum = album;
    currentSong = song;
    await audioPlayer.setAudioSource(AudioSource.file(song.path));
    resume();
    _fillQueue();
  }

  /// Play the next song in the queue
  Future<void> nextSong() async {
    if (currentSong.title != '') {
      _addSongToHistory(currentSong);
      currentSong = _songQueue.removeFirst();
      await _changeSong(currentSong.artist, currentSong.album, currentSong);
    } else {
      currentSong = _musicLibrary.getRandomSong();
      await _changeSong(currentSong.artist, currentSong.album, currentSong);
    }
  }

  /// Play the previous song from history
  Future<void> previousSong() async {
    if (_previousSongs.isNotEmpty) {
      _songQueue.addFirst(currentSong);
      currentSong = _previousSongs.removeLast();
      await _changeSong(currentSong.artist, currentSong.album, currentSong);
    }
  }

  /// Fill the next-song queue from the playlist starting from the selected song.
  void _fillQueueWithPlaylist(PlayList playlist) {
    int i = 1;
    bool songFound = false;
    for (Song song in playlist.songs) {
      if (song == currentSong) {
        songFound = true;
        break;
      }
      i++;
    }
    //If the song is not on the playlist we skip adding the playlist to the queue
    if (songFound) {
      while (i < playlist.songs.length) {
        _songQueue.add(playlist.songs[i]);
        i++;
      }
    }
  }

  /// Fill queue with random songs from the library
  void _fillQueue() {
    while (_songQueue.length <= 30) {
      addSongToQueue(_musicLibrary.getRandomSong());
    }
  }

  void addSongToQueue(Song song) => _songQueue.add(song);

  bool isSongQueueEmpty() => _songQueue.isEmpty;

  void _addSongToHistory(Song song) {
    _previousSongs.add(song);
    if (_previousSongs.length > 30) {
      _previousSongs.removeFirst();
    }
  }

  Song? getNextSongInQueue() {
    if (_songQueue.isNotEmpty) {
      return _songQueue.first;
    } else {
      return null;
    }
  }

  Song? getLastSongInHistory() {
    if (_previousSongs.isNotEmpty) {
      return _previousSongs.last;
    } else {
      return null;
    }
  }

  bool isSongHistoryEmpty() => _previousSongs.isEmpty;

  /// Seek to a specific position in the current song
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
    _controller.add(viewState);
  }

  /// Dispose resources
  void dispose() {
    audioPlayer.dispose();
    _controller.close();
  }
}

///This class is watched by the UI, it gets broadcasted when it changes and triggers the widget rebuild
class PlayerViewState {
  final Song? currentSong;
  final Album? currentAlbum;
  final Artist? currentArtist;
  final int timeEllapsedMilliseconds;
  final bool playing;

  const PlayerViewState({
    required this.currentSong,
    required this.currentAlbum,
    required this.currentArtist,
    required this.timeEllapsedMilliseconds,
    required this.playing,
  });
}
