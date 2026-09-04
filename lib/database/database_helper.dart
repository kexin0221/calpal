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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// 第一次安装
  Future<void> _createDB(Database db, int version) async {
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

  /// 老版本自动升级
  Future<void> _upgradeDB(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("""
        CREATE TABLE IF NOT EXISTS brands(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          name TEXT NOT NULL
        )
      """);

      // 如果旧 foods 表是 brand/category 结构，则迁移
      try {
        final oldFoods = await db.query("foods");

        final Set<String> columns = oldFoods.isNotEmpty
            ? oldFoods.first.keys.toSet()
            : <String>{};

        if (columns.contains("brand")) {
          final Map<String, int> brandMap = {};

          for (final item in oldFoods) {
            final brand = item["brand"] as String;
            final category = item["category"] as String;

            if (!brandMap.containsKey(brand)) {
              final id = await db.insert("brands", {
                "category": category,
                "name": brand,
              });
              brandMap[brand] = id;
            }
          }

          await db.execute("ALTER TABLE foods RENAME TO foods_old");

          await db.execute("""
            CREATE TABLE foods(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              brandId INTEGER NOT NULL,
              name TEXT NOT NULL,
              calories INTEGER NOT NULL
            )
          """);

          for (final item in oldFoods) {
            await db.insert("foods", {
              "brandId": brandMap[item["brand"]],
              "name": item["name"],
              "calories": item["calories"],
            });
          }

          await db.execute("DROP TABLE foods_old");
        }
      } catch (_) {
        // 已是新结构，无需迁移
      }
    }
  }

  //==================== 品牌 ====================//

  Future<List<Map<String, dynamic>>> getBrands(String category) async {
    final db = await database;

    return await db.query(
      "brands",
      where: "category=?",
      whereArgs: [category],
      orderBy: "name COLLATE NOCASE",
    );
  }

  Future<int> addBrand({
    required String category,
    required String name,
  }) async {
    final db = await database;

    return await db.insert("brands", {
      "category": category,
      "name": name,
    });
  }

  Future<int> updateBrand({
    required int id,
    required String name,
  }) async {
    final db = await database;

    return await db.update(
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

    return await db.delete(
      "brands",
      where: "id=?",
      whereArgs: [id],
    );
  }

  //==================== 产品 ====================//

  Future<List<Map<String, dynamic>>> getFoods(int brandId) async {
    final db = await database;

    return await db.query(
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

    return await db.insert("foods", {
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

    return await db.update(
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

    return await db.delete(
      "foods",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBrands() async {
    final db = await database;
    return db.query("brands");
  }

  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return db.query("foods");
  }

  Future<void> clearDatabase() async {
    final db = await database;

    await db.delete("foods");
    await db.delete("brands");
  }

  Future<void> insertBrandRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("brands", data);
  }

  Future<void> insertFoodRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("foods", data);
  }
}