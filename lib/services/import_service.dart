import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';

class ImportService {
  static Future<void> importDatabase(File file) async {
    final db = DatabaseHelper.instance;
    final json = jsonDecode(await file.readAsString());

    await db.clearAllData();

    if (json["categories"] != null) {
      for (final item in json["categories"]) {
        await db.insertCategoryRaw(
          Map<String, dynamic>.from(item),
        );
      }
    }

    if (json["brands"] != null) {
      for (final item in json["brands"]) {
        await db.insertBrandRaw(
          Map<String, dynamic>.from(item),
        );
      }
    }

    if (json["foods"] != null) {
      for (final item in json["foods"]) {
        await db.insertFoodRaw(
          Map<String, dynamic>.from(item),
        );
      }
    }

    if (json["presets"] != null) {
      for (final item in json["presets"]) {
        await db.insertPresetRaw(
          Map<String, dynamic>.from(item),
        );
      }
    }
  }
}