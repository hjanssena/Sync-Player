import 'package:sync_player/list_screen/albums_screen.dart';
import 'package:sync_player/list_screen/main_screen.dart';
import 'package:sync_player/list_screen/songs_screen.dart';
import 'package:sync_player/player/player_screen.dart';

var appRoutes = {
  '/': (context) => const MainScreen(),
  '/albums': (context) => const AlbumListScreen(),
  '/songs': (context) => const SongListScreen(),
  '/player': (context) => const PlayerScreen(),
};
