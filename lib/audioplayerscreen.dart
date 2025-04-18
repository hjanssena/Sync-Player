import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'dart:io';
import 'package:audiotags/audiotags.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioFilePath;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playAudio(String filePath) async {
    DeviceFileSource deviceFileSource = DeviceFileSource(filePath);
    _audioPlayer.play(deviceFileSource);
  }

  Future<void> stopAudio() async {
    _audioPlayer.stop();
  }

  Future<void> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    print(result!.paths);

    if (result != null) {
      String filPath = result.files.single.path!;
      setState(() {
        _audioFilePath = filPath;
      });
      playAudio(filPath);
    } else {
      //User cancelled the picker
    }
  }

  Future<void> pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (Platform.isAndroid) {
      selectedDirectory = fixDuplicatedEndingInPath(
        selectedDirectory.toString(),
      );
    }
    if (selectedDirectory != null) {
      var directory = Directory(selectedDirectory);

      final List<FileSystemEntity> entities =
          await directory.list(recursive: true, followLinks: false).toList();
      for (var entity in entities) {
        if (entity is File) {
          Tag? tag = await AudioTags.read(entity.path);
          print(tag?.title);
          print(tag?.album);
          print(tag?.trackArtist);
          print(tag?.duration);
        }
      }
    } else {
      //User cancelled the picker
    }
  }

  static String fixDuplicatedEndingInPath(String path) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: pickAudioFile,
          child: Text('Pick an audio File'),
        ),
        ElevatedButton(onPressed: pickDirectory, child: Text("Pick directory")),
        const SizedBox(height: 20),
        _audioFilePath != null
            ? Column(
              children: [
                Text('Playing : ${_audioFilePath!.split('/').last}'),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: stopAudio, child: const Text('Stop')),
              ],
            )
            : const Text('No audio files selected'),
      ],
    );
  }
}
