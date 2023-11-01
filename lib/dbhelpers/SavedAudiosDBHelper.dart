import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tiksnap/models/SavedAudios.dart';

import '../models/SavedVideos.dart';


class SavedAudiosDatabaseHelper {
  static final _databaseName = 'saved_audios.db';
  static final _databaseVersion = 1;

  static final table = 'saved_audios';

  static final columnId = 'id';
  static final columntitle = 'title';
  static final columnplay = 'play';
  static final columncover = 'cover';
  static final columnauthor = 'author';
  static final columnduration = 'duration';
  static final columnalbum = 'album';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columntitle TEXT NOT NULL,
        $columnplay TEXT NOT NULL,
        $columncover TEXT NOT NULL,
        $columnauthor TEXT NOT NULL,
        $columnduration INTEGER NOT NULL,
        $columnalbum TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertAudio(SavedAudios savedAudios) async {
    final db = await database;
    await db.insert(
      table,
      savedAudios.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> deleteAudio(String newmusiccover) async {
    final db = await database;
    print("Reached here");
    await db.delete(
      table,
      where: '$columncover = ?',
      whereArgs: [newmusiccover],
    );
  }
  Future<int> getRecordCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'))!;
  }
  Future<List<SavedAudios>> getAllAudios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table,
      orderBy: '$columnId DESC', // Sort by id in descending order
    );
    return List.generate(maps.length, (i) {
      return
        SavedAudios(
            title: maps[i][columntitle],
            play: maps[i][columnplay],
            cover: maps[i][columncover],
            author: maps[i][columnauthor],
            duration: maps[i][columnduration],
            album: maps[i][columnalbum]);
    });
  }
}