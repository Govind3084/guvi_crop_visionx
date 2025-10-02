import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/community_models.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  static Database? _database;

  factory CommunityService() => _instance;

  CommunityService._internal();

  bool isDatabaseConnected = false;

  Future<Database> get database async {
    try {
      if (_database != null) {
        // Check if database is actually connected
        await _database!.rawQuery('SELECT 1');
        isDatabaseConnected = true;
        return _database!;
      }
      _database = await _initDatabase();
      isDatabaseConnected = true;
      print('✅ Database connected successfully');
      return _database!;
    } catch (e) {
      isDatabaseConnected = false;
      print('❌ Database connection failed: $e');
      throw Exception('Failed to connect to database: $e');
    }
  }

  Future<Database> _initDatabase() async {
    try {
      // Use fixed path for Windows testing
      String path = 'd:\\crop\\community.db';
      print('📁 Database path: $path');

      // Delete existing database for testing
      // await deleteDatabase(path);

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print('🔧 Creating database tables...');
          await _onCreate(db, version);
        },
        onOpen: (Database db) async {
          print('📂 Database opened successfully');
          // Verify tables exist
          final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
          print('📊 Available tables: ${tables.map((t) => t['name']).toList()}');
        },
      );

      return db;
    } catch (e) {
      print('❌ Database initialization failed: $e');
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS posts (
          id TEXT PRIMARY KEY,
          authorName TEXT NOT NULL,
          content TEXT NOT NULL,
          imagePath TEXT,
          timestamp INTEGER NOT NULL,
          category TEXT NOT NULL,
          likes INTEGER DEFAULT 0,
          comments INTEGER DEFAULT 0,
          commentList TEXT DEFAULT '[]'
        )
      ''');
      print('✅ Tables created successfully');
    } catch (e) {
      print('❌ Error creating tables: $e');
      throw Exception('Failed to create tables: $e');
    }
  }

  Future<String?> saveImage(File image) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String imageName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String imagePath = join(appDir.path, 'post_images', imageName);

      // Create images directory if it doesn't exist
      await Directory(join(appDir.path, 'post_images')).create(recursive: true);
      
      // Copy image to app directory
      await image.copy(imagePath);
      return imagePath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<void> addPost(CommunityPost post) async {
    try {
      final db = await database;
      await db.insert(
        'posts',
        post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Post added successfully: ${post.id}');
      print('🟢 Post data: ${post.toMap()}'); // Add this line
    } catch (e) {
      print('❌ Error adding post: $e');
      throw Exception('Failed to add post: $e');
    }
  }

  Future<List<CommunityPost>> getPosts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'posts',
        orderBy: 'timestamp DESC',
      );
      print('📝 Retrieved ${maps.length} posts');
      return List.generate(maps.length, (i) => CommunityPost.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error fetching posts: $e');
      return [];
    }
  }

  Future<void> updateLikes(String postId, int likes) async {
    final db = await database;
    await db.update(
      'posts',
      {'likes': likes},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  Future<void> addComment(String postId, Comment comment) async {
    final db = await database;
    final post = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
    
    if (post.isNotEmpty) {
      final currentPost = CommunityPost.fromMap(post.first);
      // Decode commentList from JSON string to List
      List<dynamic> commentListDecoded = [];
      try {
        commentListDecoded = jsonDecode(currentPost.commentList);
      } catch (e) {
        commentListDecoded = [];
      }
      // Add new comment
      commentListDecoded.add(comment.toMap());
      // Encode back to JSON string
      final updatedCommentList = jsonEncode(commentListDecoded);

      await db.update(
        'posts',
        {
          'comments': commentListDecoded.length,
          'commentList': updatedCommentList,
        },
        where: 'id = ?',
        whereArgs: [postId],
      );
    }
  }
}
