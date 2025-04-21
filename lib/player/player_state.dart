import 'dart:async';
import 'dart:collection';
import 'package:audio_session/audio_session.dart';
import 'package:sync_player/Models/models.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sync_player/Models/music_library.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

class PlayerState {
  final AudioPlayer audioPlayer = AudioPlayer();

  PlayerState._internal() {
    _init();
  }

  Future<void> _init() async {
    // Set audio session (for Android/iOS media controls)
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && playing) {
        playing = false;
        nextSong();
      }
    });

    audioPlayer.positionStream.listen((position) {
      timeEllapsedMilliseconds = position.inMilliseconds;
      _controller.add(viewState);
    });

    JustAudioMediaKit.ensureInitialized();
  }

  static final PlayerState _instance = PlayerState._internal();
  factory PlayerState() => _instance;

  final Queue<Song> _previousSongs = Queue<Song>();
  final Queue<Song> _songQueue = Queue<Song>();
  Song currentSong = Song();
  Album currentAlbum = Album.placeholder();
  Artist currentArtist = Artist.placeholder();
  int timeEllapsedMilliseconds = 0;
  bool playing = false;

  final _controller = StreamController<PlayerViewState>.broadcast();
  Stream<PlayerViewState> get stateStream => _controller.stream;

  PlayerViewState get viewState => PlayerViewState(
    currentSong: currentSong,
    currentAlbum: currentAlbum,
    currentArtist: currentArtist,
    timeEllapsedMilliseconds: timeEllapsedMilliseconds,
    playing: playing,
  );

  MusicLibrary _musicLibrary = MusicLibrary();

  void setLibrary(MusicLibrary library) {
    _musicLibrary = library;
  }

  void updateProgress(Duration currentPosition) {
    timeEllapsedMilliseconds = currentPosition.inMilliseconds;
    _controller.add(viewState);
  }

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

  Future<void> stop() async {
    playing = false;
    await audioPlayer.stop();
    _controller.add(viewState);
  }

  Future<void> pause() async {
    playing = false;
    await audioPlayer.pause();
    _controller.add(viewState);
  }

  Future<void> setSong(Artist artist, Album album, Song song) async {
    await audioPlayer.stop();
    if (currentSong.title != '') {
      _addSongToPrevious(currentSong);
    }
    currentArtist = artist;
    currentAlbum = album;
    currentSong = song;
    await audioPlayer.setAudioSource(AudioSource.file(song.path));

    resume();
    _songQueue.clear();
    _fillAlbumQueue();
    _fillQueue();
  }

  void _fillAlbumQueue() {
    //Fill next songs queue with next album songs
    Song? song = currentSong;
    int i = 0;
    while (currentAlbum.songs.length >= i) {
      song = song?.nextInAlbum();
      if (song != null) {
        _songQueue.add(song);
      }
      i++;
    }
  }

  Future<void> _changeSong(Artist artist, Album album, Song song) async {
    await audioPlayer.stop();
    currentArtist = artist;
    currentAlbum = album;
    currentSong = song;

    await audioPlayer.setAudioSource(AudioSource.file(song.path));
    resume();
    _fillQueue();
  }

  Future<void> nextSong() async {
    if (currentSong.title != '') {
      _addSongToPrevious(currentSong);
      currentSong = _songQueue.removeFirst();
      _changeSong(currentSong.artist, currentSong.album, currentSong);
    } else {
      currentSong = _musicLibrary.getRandomSong();
      _changeSong(currentSong.artist, currentSong.album, currentSong);
    }
  }

  Future<void> previousSong() async {
    _songQueue.addFirst(currentSong);
    currentSong = _previousSongs.removeLast();
    _changeSong(currentSong.artist, currentSong.album, currentSong);
  }

  void _fillQueue() {
    while (_songQueue.length <= 30) {
      addSongToQueue(_musicLibrary.getRandomSong());
    }
  }

  void addSongToQueue(Song song) {
    _songQueue.add(song);
  }

  void _addSongToPrevious(Song song) {
    _previousSongs.add(song);
    if (_previousSongs.length > 30) {
      _previousSongs.removeFirst();
    }
  }

  bool isPreviousStackEmpty() {
    return _previousSongs.isEmpty ? true : false;
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
    _controller.add(viewState);
  }

  void dispose() {
    audioPlayer.dispose();
    _controller.close();
  }

  PlayerState copy() {
    return PlayerState()
      ..currentSong = currentSong
      ..currentAlbum = currentAlbum
      ..currentArtist = currentArtist
      ..timeEllapsedMilliseconds = timeEllapsedMilliseconds
      ..playing = playing;
  }
}

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
