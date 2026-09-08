import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

class ExportService {
  static Future<File> exportDatabase() async {
    final categories = await DatabaseHelper.instance.getCategories();
    final brands = await DatabaseHelper.instance.getAllBrands();
    final foods = await DatabaseHelper.instance.getAllFoods();

    final data = {
      "version": 6,
      "categories": await DatabaseHelper.instance.getCategories(),
      "brands": await DatabaseHelper.instance.getAllBrands(),
      "foods": await DatabaseHelper.instance.getAllFoods(),
      "presets": await DatabaseHelper.instance.getPresets(),
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