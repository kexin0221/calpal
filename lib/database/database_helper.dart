import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calpal.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE brands(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE foods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brandId INTEGER,
        name TEXT NOT NULL,
        calories INTEGER NOT NULL,
        FOREIGN KEY (brandId) REFERENCES brands(id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE brands(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          name TEXT NOT NULL
        )
      ''');

      // 把旧 foods 迁移到新结构（如果有数据）
      final oldFoods = await db.query('foods');

      final Map<String, int> brandMap = {};

      for (var food in oldFoods) {
        final brand = food['brand'] as String;
        final category = food['category'] as String;

        if (!brandMap.containsKey(brand)) {
          final id = await db.insert('brands', {
            'name': brand,
            'category': category,
          });
          brandMap[brand] = id;
        }
      }

      await db.execute('ALTER TABLE foods RENAME TO foods_old');

      await db.execute('''
        CREATE TABLE foods(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          brandId INTEGER,
          name TEXT NOT NULL,
          calories INTEGER NOT NULL,
          FOREIGN KEY (brandId) REFERENCES brands(id)
        )
      ''');

      for (var food in oldFoods) {
        await db.insert('foods', {
          'brandId': brandMap[food['brand']],
          'name': food['name'],
          'calories': food['calories'],
        });
      }

      await db.execute('DROP TABLE foods_old');
    }
  }

  Future<List<Map<String, dynamic>>> getBrands(String category) async {
    final db = await database;
    return db.query(
      'brands',
      where: 'category=?',
      whereArgs: [category],
      orderBy: 'name',
    );
  }

  Future<int> addBrand({
    required String category,
    required String name,
  }) async {
    final db = await database;
    return db.insert('brands', {
      'category': category,
      'name': name,
    });
  }

  Future<List<Map<String, dynamic>>> getFoods(int brandId) async {
    final db = await database;
    return db.query(
      'foods',
      where: 'brandId=?',
      whereArgs: [brandId],
      orderBy: 'calories ASC',
    );
  }

  Future<int> addFood({
    required int brandId,
    required String name,
    required int calories,
  }) async {
    final db = await database;
    return db.insert('foods', {
      'brandId': brandId,
      'name': name,
      'calories': calories,
    });
  }

  Future<int> deleteFood(int id) async {
    final db = await database;

    return db.delete(
      'foods',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}