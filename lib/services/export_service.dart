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
      "version": 2,
      "exportTime": DateTime.now().toIso8601String(),
      "categories": categories,
      "brands": brands,
      "foods": foods,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/calpal_backup.json");

    await file.writeAsString(
      const JsonEncoder.withIndent("  ").convert(data),
    );

    return file;
  }
}