import 'dart:convert';
import 'dart:io';

class ModelSerializator {
  /// Generic function to save a list of models to a JSON file
  static Future<void> saveModels<T>(
    List<T> models,
    String path,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final file = File(path);
    final jsonList = models.map(toJson).toList();
    final jsonString = jsonEncode(jsonList);
    await file.writeAsString(jsonString);
  }

  /// Generic function to read a list of models from a JSON file
  static Future<List<T>> readModels<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final file = File(path);
    if (!await file.exists()) return [];

    final jsonString = await file.readAsString();
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveModel<T>(
    T model,
    String filePath,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final file = File(filePath);
    final jsonString = jsonEncode(toJson(model));
    await file.writeAsString(jsonString);
  }

  static Future<T> readModel<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJson,
    T Function()? fallback,
  ) async {
    final file = File(filePath);

    if (!await file.exists()) {
      if (fallback != null) {
        return fallback();
      } else {
        throw Exception("File not found and no fallback provided: $filePath");
      }
    }

    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(jsonMap);
  }
}
