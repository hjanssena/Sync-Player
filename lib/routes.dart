import 'package:sync_player/views/library/albums_screen.dart';
import 'package:sync_player/views/library/main_screen.dart';
import 'package:sync_player/views/library/songs_screen.dart';
import 'package:sync_player/views/player/player_screen.dart';

var appRoutes = {
  '/': (context) => const EntryScreen(),
  '/albums': (context) => const AlbumListScreen(),
  '/songs': (context) => const SongListScreen(),
  '/player': (context) => const PlayerScreen(),
};
