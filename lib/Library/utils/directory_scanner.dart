import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class DirectoryScanner {
  Future<String> addDirectoryPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if (Platform.isAndroid) {
        selectedDirectory = fixDuplicatedEndingInAndroidPath(
          selectedDirectory.toString(),
        );
      }
    }
    return selectedDirectory ?? '';
  }

  Future<List<String>> getAudioFilePathsFromDirectories(String path) async {
    List<String> filePaths = [];
    Directory dir = Directory(path);
    final List<FileSystemEntity> entities =
        await dir.list(recursive: true, followLinks: false).toList();

    for (var entity in entities) {
      if (entity is File) {
        if (lookupMimeType(entity.path)?.split('/')[0] == "audio" &&
            !entity.path.contains("m3u")) {
          filePaths.add(entity.path);
        }
      }
    }
    return filePaths;
  }

  String fixDuplicatedEndingInAndroidPath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();

    final n = parts.length;

    bool listEquals<T>(List<T> a, List<T> b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    for (int size = n ~/ 2; size >= 1; size--) {
      // Compare two blocks from the end
      final firstBlock = parts.sublist(n - 2 * size, n - size);
      final secondBlock = parts.sublist(n - size, n);

      if (listEquals(firstBlock, secondBlock)) {
        return '/${parts.sublist(0, n - size).join('/')}';
      }
    }

    return path;
  }
}
