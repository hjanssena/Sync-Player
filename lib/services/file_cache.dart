import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FileCache {
  final Uint8List placeholderImage;

  static FileCache? _instance;

  FileCache._internal(this.placeholderImage);

  static Future<FileCache> create({Uint8List? placeholderImage}) async {
    if (_instance != null) return _instance!;
    final ByteData data = await rootBundle.load('assets/placeholder.png');
    final Uint8List placeholder = data.buffer.asUint8List();
    _instance = FileCache._internal(placeholder);
    return _instance!;
  }
}
