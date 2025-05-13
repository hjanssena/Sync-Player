import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sync_player/Library/models/models.dart';
import 'package:sync_player/main.dart';

class Scraper {
  final String apiKey;

  Scraper(this.apiKey);

  Future<Uint8List?> _fetchImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<Uint8List?> _getLastFmImage(dynamic imageArray) async {
    // Try to get the largest image first (size: "extralarge" or "mega")
    final imageUrl =
        (imageArray as List?)?.lastWhere(
          (img) =>
              img['#text'] != null &&
              (img['size'] == 'extralarge' || img['size'] == 'mega'),
          orElse: () => null,
        )?['#text'];
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return await _fetchImageFromUrl(imageUrl);
    }
    return null;
  }

  Future<Uint8List?> getArtistImage(String artistName) async {
    final url = Uri.parse(
      'https://ws.audioscrobbler.com/2.0/?method=artist.getinfo'
      '&artist=${Uri.encodeComponent(artistName)}'
      '&api_key=$apiKey&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return await _getLastFmImage(json['artist']?['image']);
    }
    return null;
  }

  Future<Uint8List?> getAlbumImage(String albumName, String artistName) async {
    final url = Uri.parse(
      'https://ws.audioscrobbler.com/2.0/?method=album.getinfo'
      '&artist=${Uri.encodeComponent(artistName)}'
      '&album=${Uri.encodeComponent(albumName)}'
      '&api_key=$apiKey&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return await _getLastFmImage(json['album']?['image']);
    }
    return null;
  }

  Future<Song> scrapeSongArt(Song song) async {
    Uint8List? albumImg = await getAlbumImage(song.albumName, song.albumArtist);
    Uint8List? artistImg = await getArtistImage(song.albumArtist);

    song.album.image = albumImg ?? fileCache.placeholderImage;
    song.album.scraped = albumImg != null;

    song.artist.image = artistImg ?? fileCache.placeholderImage;
    song.artist.scraped = artistImg != null;

    return song;
  }
}
