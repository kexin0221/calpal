import 'dart:io';
import 'package:file_picker/file_picker.dart';

class CsvService {
  static Future<List<Map<String, dynamic>>?> pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);

    String text = await file.readAsString();

    // 去掉 UTF-8 BOM
    text = text.replaceFirst('\uFEFF', '');

    // 兼容 Windows / Mac / Linux
    final lines = text.split(RegExp(r'\r?\n'));

    final foods = <Map<String, dynamic>>[];

    // 跳过第一行表头
    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].trim();

      if (row.isEmpty) continue;

      final parts = row.split(',');

      if (parts.length < 2) continue;

      final name = parts.first.trim();
      final calories = int.tryParse(parts.last.trim());

      if (name.isEmpty || calories == null) continue;

      foods.add({
        "name": name,
        "calories": calories,
      });
    }

    return foods;
  }
}