import 'dart:io';

import 'package:file_picker/file_picker.dart';

class CsvService {
  static Future<List<Map<String, dynamic>>?> pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["csv"],
    );

    if (result == null) return null;

    final file = File(result.files.single.path!);

    final text = await file.readAsString();

    final lines = text.split("\n");

    final foods = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].trim();

      if (row.isEmpty) continue;

      final item = row.split(",");

      foods.add({
        "name": item[0],
        "calories": int.parse(item[1]),
      });
    }

    return foods;
  }
}