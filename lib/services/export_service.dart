import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

class ExportService {
  static Future<File> exportDatabase() async {
    final db = DatabaseHelper.instance;
    final data = {
      "version": 6,
      "categories": await db.getCategories(),
      "brands": await db.getAllBrands(),
      "foods": await db.getAllFoods(),
      "presets": await db.getPresets(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/calpal_backup_${DateTime.now().millisecondsSinceEpoch}.json",
    );

    await file.writeAsString(
      const JsonEncoder.withIndent("  ").convert(data),
    );

    return file;
  }
}