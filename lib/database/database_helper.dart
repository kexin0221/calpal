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
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        remark TEXT DEFAULT '',
        isTop INTEGER DEFAULT 0
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
      "中式快餐",
    ];

    for (int i = 0; i < defaults.length; i++) {
      await db.insert("categories", {"name": defaults[i], "sortOrder": i});
    }

    await db.execute("""
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        remark TEXT DEFAULT ''
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

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute("""
        CREATE TABLE IF NOT EXISTS categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          sortOrder INTEGER NOT NULL
        )
      """);

      final count =
          Sqflite.firstIntValue(
            await db.rawQuery("SELECT COUNT(*) FROM categories"),
          ) ??
          0;

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
          "中式快餐",
        ];

        for (int i = 0; i < defaults.length; i++) {
          await db.insert("categories", {"name": defaults[i], "sortOrder": i});
        }
      }
    }

    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE brands ADD COLUMN remark TEXT DEFAULT ''",
      );
    }

    if (oldVersion < 5) {
      await db.execute(
        "ALTER TABLE brands ADD COLUMN isTop INTEGER DEFAULT 0",
      );
    }
  }

  //================ 分类 =================//

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;

    return db.query("categories", orderBy: "sortOrder ASC");
  }

  Future<void> addCategory(String name) async {
    final db = await database;

    final count =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM categories"),
        ) ??
        0;

    await db.insert("categories", {"name": name, "sortOrder": count});
  }

  Future<void> updateCategory(int id, String newName) async {
    final db = await database;

    await db.transaction((txn) async {
      // 先获取旧分类名
      final result = await txn.query(
        "categories",
        columns: ["name"],
        where: "id=?",
        whereArgs: [id],
      );

      if (result.isEmpty) return;

      final oldName = result.first["name"] as String;

      // 更新分类表
      await txn.update(
        "categories",
        {"name": newName},
        where: "id=?",
        whereArgs: [id],
      );

      // 同步更新该分类下所有品牌
      await txn.update(
        "brands",
        {"category": newName},
        where: "category=?",
        whereArgs: [oldName],
      );
    });
  }

  /// 删除分类（同时删除该分类下所有品牌和产品）
  Future<void> deleteCategory(int id) async {
    final db = await database;

    final category = await db.query(
      "categories",
      where: "id=?",
      whereArgs: [id],
    );

    if (category.isEmpty) return;

    final categoryName = category.first["name"] as String;

    final brands = await db.query(
      "brands",
      where: "category=?",
      whereArgs: [categoryName],
    );

    final batch = db.batch();

    for (final brand in brands) {
      batch.delete("foods", where: "brandId=?", whereArgs: [brand["id"]]);
    }

    batch.delete("brands", where: "category=?", whereArgs: [categoryName]);

    batch.delete("categories", where: "id=?", whereArgs: [id]);

    await batch.commit(noResult: true);
  }

  Future<void> updateCategoryOrder(List<Map<String, dynamic>> list) async {
    final db = await database;

    await db.transaction((txn) async {
      for (int i = 0; i < list.length; i++) {
        await txn.update(
          "categories",
          {"sortOrder": i},
          where: "id = ?",
          whereArgs: [list[i]["id"] as int],
        );
      }
    });
  }

  //================ 品牌 =================//

  Future<List<Map<String, dynamic>>> getBrands(String category) async {
    final db = await database;

    return db.query(
      "brands",
      where: "category=?",
      whereArgs: [category],
      orderBy: "isTop DESC,name COLLATE NOCASE ASC",
    );
  }

  Future<List<Map<String, dynamic>>> getAllBrands() async {
    final db = await database;
    return db.query("brands");
  }

  Future<bool> brandExists({
    required String category,
    required String name,
  }) async {
    final db = await database;

    final result = await db.query(
      "brands",
      where: "category=? AND name=?",
      whereArgs: [category, name],
    );

    return result.isNotEmpty;
  }

  Future<int> addBrand({required String category, required String name}) async {
    final db = await database;

    final exists = await brandExists(category: category, name: name);

    if (exists) {
      throw Exception("品牌已存在");
    }

    return db.insert("brands", {"category": category, "name": name});
  }

  Future<int> updateBrand({required int id, required String name}) async {
    final db = await database;

    return db.update("brands", {"name": name}, where: "id=?", whereArgs: [id]);
  }

  Future<String> getBrandRemark(int id) async {
    final db = await database;

    final result = await db.query(
      "brands",
      columns: ["remark"],
      where: "id=?",
      whereArgs: [id],
    );

    if (result.isEmpty) return "";
    return (result.first["remark"] ?? "") as String;
  }

  Future<void> updateBrandRemark({
    required int id,
    required String remark,
  }) async {
    final db = await database;

    await db.update(
      "brands",
      {"remark": remark},
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteBrand(int id) async {
    final db = await database;

    await db.delete("foods", where: "brandId=?", whereArgs: [id]);

    return db.delete("brands", where: "id=?", whereArgs: [id]);
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
      {"name": name, "calories": calories},
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteFood(int id) async {
    final db = await database;

    return db.delete("foods", where: "id=?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return db.query("foods");
  }

  Future<void> insertFoodRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("foods", data);
  }

  Future<void> addFoodsBatch({
    required int brandId,
    required List<Map<String, dynamic>> foods,
  }) async {
    final db = await database;
    final batch = db.batch();

    for (final food in foods) {
      batch.insert("foods", {
        "brandId": brandId,
        "name": food["name"],
        "calories": food["calories"],
      });
    }

    await batch.commit(noResult: true);
  }

  //================ 数据同步 =================//

  Future<void> clearAllData() async {
    final db = await database;

    await db.delete("foods");
    await db.delete("brands");
    await db.delete("categories");

    await db.execute("DELETE FROM sqlite_sequence");

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
      "中式快餐",
    ];

    for (int i = 0; i < defaults.length; i++) {
      await db.insert("categories", {"name": defaults[i], "sortOrder": i});
    }

    // 删除默认，再导入用户分类（避免旧分类残留）
    await db.delete("categories");
  }

  Future<void> insertCategoryRaw(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert("categories", data);
  }

  Future<void> setBrandTop({
    required int id,
    required bool isTop,
  }) async {
    final db = await database;

    await db.update(
      "brands",
      {
        "isTop": isTop ? 1 : 0,
      },
      where: "id=?",
      whereArgs: [id],
    );
  }

}
