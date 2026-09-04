import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("calpal.db");
    return _database!;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sortOrder INTEGER NOT NULL
      )
    """);

    final defaults = [
      "奶茶",
      "果茶",
      "咖啡",
      "甜品",
      "糖水",
      "轻食",
      "烘焙",
      "三明治",
      "西式快餐",
      "中式快餐"
    ];

    for (int i = 0; i < defaults.length; i++) {
      await db.insert("categories", {
        "name": defaults[i],
        "sortOrder": i,
      });
    }

    await db.execute("""
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brandId INTEGER NOT NULL,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL
      )
    """);
  }

  Future<void> _upgradeDB(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute("""
        CREATE TABLE IF NOT EXISTS categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          sortOrder INTEGER NOT NULL
        )
      """);

      final count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM categories"),
      );

      if (count == 0) {
        final defaults = [
          "奶茶",
          "果茶",
          "咖啡",
          "甜品",
          "糖水",
          "轻食",
          "烘焙",
          "三明治",
          "西式快餐",
          "中式快餐"
        ];

        for (int i = 0; i < defaults.length; i++) {
          await db.insert("categories", {
            "name": defaults[i],
            "sortOrder": i,
          });
        }
      }
    }
  }

  //================ 分类 =================//

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;

    return db.query(
      "categories",
      orderBy: "sortOrder ASC",
    );
  }

  Future<void> addCategory(String name) async {
    final db = await database;

    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM categories"),
    ) ??
        0;

    await db.insert("categories", {
      "name": name,
      "sortOrder": count,
    });
  }

  Future<void> updateCategory(int id, String name) async {
    final db = await database;

    await db.update(
      "categories",
      {"name": name},
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;

    await db.delete(
      "categories",
      where: "id=?",
      whereArgs: [id],
    );
  }

  //================ 品牌 =================//

  Future<List<Map<String, dynamic>>> getBrands(String category) async {
    final db = await database;

    return db.query(
      "brands",
      where: "category=?",
      whereArgs: [category],
      orderBy: "name",
    );
  }

  Future<int> addBrand({
    required String category,
    required String name,
  }) async {
    final db = await database;

    return db.insert("brands", {
      "category": category,
      "name": name,
    });
  }

  Future<int> updateBrand({
    required int id,
    required String name,
  }) async {
    final db = await database;

    return db.update(
      "brands",
      {"name": name},
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteBrand(int id) async {
    final db = await database;

    await db.delete(
      "foods",
      where: "brandId=?",
      whereArgs: [id],
    );

    return db.delete(
      "brands",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBrands() async {
    final db = await database;
    return db.query("brands");
  }

  Future<void> insertBrandRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("brands", data);
  }

  //================ 产品 =================//

  Future<List<Map<String, dynamic>>> getFoods(int brandId) async {
    final db = await database;

    return db.query(
      "foods",
      where: "brandId=?",
      whereArgs: [brandId],
      orderBy: "calories ASC",
    );
  }

  Future<int> addFood({
    required int brandId,
    required String name,
    required int calories,
  }) async {
    final db = await database;

    return db.insert("foods", {
      "brandId": brandId,
      "name": name,
      "calories": calories,
    });
  }

  Future<int> updateFood({
    required int id,
    required String name,
    required int calories,
  }) async {
    final db = await database;

    return db.update(
      "foods",
      {
        "name": name,
        "calories": calories,
      },
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;

    return db.delete(
      "foods",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return db.query("foods");
  }

  Future<void> insertFoodRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("foods", data);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete("foods");
    await db.delete("brands");
  }

  Future<void> updateCategoryOrder(
      List<Map<String, dynamic>> list) async {
    final db = await database;

    final batch = db.batch();

    for (int i = 0; i < list.length; i++) {
      batch.update(
        "categories",
        {"sortOrder": i},
        where: "id=?",
        whereArgs: [list[i]["id"]],
      );
    }

    await batch.commit(noResult: true);
  }
}