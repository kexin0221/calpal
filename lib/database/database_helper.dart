import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // 单例：整个 App 只使用一个 DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // 获取数据库
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('calpal.db');
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 第一次创建数据库
  Future<void> _createDB(
  Database db,
  int version,
  ) async {
  await db.execute('''
        CREATE TABLE foods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          brand TEXT NOT NULL,
          category TEXT NOT NULL,
          calories INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
  }

  // 数据库版本升级
  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE foods ADD COLUMN brand TEXT NOT NULL DEFAULT "自定义"',
      );

      await db.execute(
        'ALTER TABLE foods ADD COLUMN category TEXT NOT NULL DEFAULT "其他"',
      );
    }
  }

  // 添加食物
  Future<int> addFood({
    required String name,
    required String brand,
    required String category,
    required int calories,
  }) async {
    final db = await database;

    return await db.insert(
      'foods',
      {
        'name': name,
        'brand': brand,
        'category': category,
        'calories': calories,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // 获取所有食物
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await database;

    return await db.query(
      'foods',
      orderBy: 'id DESC',
    );
  }

  // 删除食物
  Future<int> deleteFood(int id) async {
    final db = await database;

    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

