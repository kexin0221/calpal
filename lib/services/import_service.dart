import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';

class ImportService {
  static Future<void> importDatabase(File file) async {
    final json = jsonDecode(await file.readAsString());

    final db = DatabaseHelper.instance;

    await db.clearDatabase();

    for (final brand in json["brands"]) {
      await db.insertBrandRaw(
        Map<String, dynamic>.from(brand),
      );
    }

    for (final food in json["foods"]) {
      await db.insertFoodRaw(
        Map<String, dynamic>.from(food),
      );
    }
  }
}