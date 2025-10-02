import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/community_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('community.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print('📱 Local database path: $path');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      // Create posts table only
      await db.execute('''
        CREATE TABLE posts(
          id TEXT PRIMARY KEY,
          authorName TEXT NOT NULL,
          content TEXT NOT NULL,
          imagePath TEXT,
          timestamp INTEGER NOT NULL,
          category TEXT NOT NULL,
          likes INTEGER NOT NULL DEFAULT 0,
          comments INTEGER NOT NULL DEFAULT 0,
          commentList TEXT DEFAULT '[]'
        )
      ''');
      print('✅ Posts table created successfully');
    } catch (e) {
      print('❌ Error creating database: $e');
      rethrow;
    }
  }

  Future<int> insertPost(CommunityPost post) async {
    final db = await database;
    return await db.insert('posts', post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CommunityPost>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('posts',
        orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => CommunityPost.fromMap(maps[i]));
  }

  Future<bool> updateLikes(String postId, int likes) async {
    final db = await database;
    final count = await db.update(
      'posts',
      {'likes': likes},
      where: 'id = ?',
      whereArgs: [postId],
    );
    return count > 0;
  }
}