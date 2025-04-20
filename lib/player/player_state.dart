import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_player/Models/models.dart';

class PlayerState extends StreamProvider {
  Song? currentSong;
  Album? currentAlbum;
  Artist? currentArtist;
  int timeEllapsedMilliseconds = 0;
  bool playing = false;

  PlayerState({required super.create, required super.initialData});
}
