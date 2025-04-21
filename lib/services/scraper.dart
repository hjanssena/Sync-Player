import 'package:musicbrainz_api_client/musicbrainz_api_client.dart';
import 'package:sync_player/Models/models.dart';

class Scraper {
  Future<Song> scrapeMissingData(Song song) async {
    final client = MusicBrainzApiClient();
    try {
      final response = await client.recordings.search(
        "Track artist:${song.artistTag} AND Title:${song.title}",
      );
      if (song.albumTag == '') {}
      print(response["recordings"][0]["title"]);
      return song;
    } catch (e) {
      //Song and artist not found
      return song;
    }
  }
}
