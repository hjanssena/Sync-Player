import 'package:flutter/services.dart';

class FileCache {
  final Uint8List placeholderImage;
  final Uint8List emptyImage;
  static FileCache? _instance;

  FileCache._internal(this.placeholderImage, this.emptyImage);

  static Future<FileCache> create({
    Uint8List? placeholderImage,
    Uint8List? emptyImage,
  }) async {
    if (_instance != null) return _instance!;
    final ByteData placeholderData = await rootBundle.load(
      'assets/placeholder.png',
    );
    final Uint8List placeholder = placeholderData.buffer.asUint8List();
    final ByteData emptyData = await rootBundle.load('assets/empty.png');
    final Uint8List empty = emptyData.buffer.asUint8List();
    _instance = FileCache._internal(placeholder, empty);
    return _instance!;
  }
}
