
import 'dart:convert';
import 'dart:io';

import '../database/database_helper.dart';

class ImportService {
  static Future<void> importDatabase(File file) async {
    final json = jsonDecode(await file.readAsString());

    await DatabaseHelper.instance.clearDatabase();

    for (final item in json["brands"]) {
      await DatabaseHelper.instance.insertBrandRaw(
        Map<String, dynamic>.from(item),
      );
    }

    for (final item in json["foods"]) {
      await DatabaseHelper.instance.insertFoodRaw(
        Map<String, dynamic>.from(item),
      );
    }
  }
}