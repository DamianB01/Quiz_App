import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'quiz_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            difficulty TEXT,
            question_text TEXT UNIQUE,
            correct_answer TEXT,
            incorrect_answers TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            score INTEGER,
            total_questions INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> addFavorite(Question question) async {
    final db = await database;
    await db.insert(
      'favorites',
      question.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String questionText) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'question_text = ?',
      whereArgs: [questionText],
    );
  }

  Future<List<Question>> getFavorites() async {
    final db = await database;
    final maps = await db.query('favorites');
    return maps.map((m) => Question.fromMap(m)).toList();
  }

  Future<bool> isFavorite(String questionText) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'question_text = ?',
      whereArgs: [questionText],
    );
    return result.isNotEmpty;
  }


  Future<void> saveResult(QuizResult result) async {
    final db = await database;
    await db.insert('quiz_results', result.toMap());
  }

  Future<List<QuizResult>> getResults() async {
    final db = await database;
    final maps = await db.query(
      'quiz_results',
      orderBy: 'date DESC',
      limit: 10,
    );
    return maps.map((m) => QuizResult.fromMap(m)).toList();
  }
}
