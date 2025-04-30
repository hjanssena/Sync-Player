import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class PlayerUtils {
  static Future<void> saveImageAndGetUri(Uint8List imageBytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/songImg.jpg');
    await file.writeAsBytes(imageBytes, flush: true);
  }
}
