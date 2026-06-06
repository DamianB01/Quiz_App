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

        await db.execute('''
          CREATE TABLE cached_categories (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cached_questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER,
            difficulty TEXT,
            category TEXT,
            type TEXT,
            difficulty_level TEXT,
            question_text TEXT,
            correct_answer TEXT,
            incorrect_answers TEXT
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

  Future<void> clearResults() async {
    final db = await database;
    await db.delete('quiz_results');
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

  Future<void> cacheCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    await db.delete('cached_categories');
    for (final c in categories) {
      await db.insert('cached_categories', {
        'id': c['id'],
        'name': c['name'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCachedCategories() async {
    final db = await database;
    final maps = await db.query('cached_categories');
    return maps.map((m) => {'id': m['id'], 'name': m['name']}).toList();
  }

  Future<void> cacheQuestions(
      List<Question> questions,
      int? categoryId,
      String difficulty,
      ) async {
    final db = await database;
    await db.delete(
      'cached_questions',
      where: 'category_id = ? AND difficulty = ?',
      whereArgs: [categoryId ?? -1, difficulty],
    );
    for (final q in questions) {
      await db.insert('cached_questions', {
        'category_id': categoryId ?? -1,
        'difficulty': difficulty,
        'category': q.category,
        'type': q.type,
        'difficulty_level': q.difficulty,
        'question_text': q.questionText,
        'correct_answer': q.correctAnswer,
        'incorrect_answers': q.incorrectAnswers.join('|||'),
      });
    }
  }

  Future<List<Question>> getCachedQuestions(
      int? categoryId,
      String difficulty,
      int amount,
      ) async {
    final db = await database;
    final maps = await db.query(
      'cached_questions',
      where: 'category_id = ? AND difficulty = ?',
      whereArgs: [categoryId ?? -1, difficulty],
      limit: amount,
    );
    return maps.map((m) => Question(
      category: m['category'] as String,
      type: m['type'] as String,
      difficulty: m['difficulty_level'] as String,
      questionText: m['question_text'] as String,
      correctAnswer: m['correct_answer'] as String,
      incorrectAnswers: (m['incorrect_answers'] as String).split('|||'),
    )).toList();
  }

  Future<bool> hasCachedQuestions(
      int? categoryId,
      String difficulty,
      ) async {
    final db = await database;
    final result = await db.query(
      'cached_questions',
      where: 'category_id = ? AND difficulty = ?',
      whereArgs: [categoryId ?? -1, difficulty],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
