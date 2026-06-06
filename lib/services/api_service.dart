import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import '../models/question.dart';
import 'firebase_service.dart';
import '../services/database_service.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';
  final HtmlUnescape _unescape = HtmlUnescape();

  Future<List<Map<String, dynamic>>> fetchCategories({
    DatabaseService? dbService,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api_category.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = List<Map<String, dynamic>>.from(
            data['trivia_categories']);
        if (dbService != null) {
          await dbService.cacheCategories(categories);
        }
        return categories;
      } else {
        throw Exception('Error downloading categories');
      }
    } catch (e) {
      if (dbService != null) {
        final cached = await dbService.getCachedCategories();
        if (cached.isNotEmpty) return cached;
      }
      throw Exception('No internet connection');
    }
  }

  Future<List<Question>> fetchQuestions({
    required int amount,
    int? categoryId,
    String? difficulty,
    DatabaseService? dbService,
  }) async {
    String url = '$_baseUrl/api.php?amount=$amount';
    if (categoryId != null) url += '&category=$categoryId';
    if (difficulty != null && difficulty != 'all') {
      url += '&difficulty=$difficulty';
    }

    try {
      final response = await FirebaseService.traceApiCall(
        'fetch_questions',
            () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 10)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_code'] != 0) {
          throw Exception('No questions for selected parameters');
        }

        final questions = (data['results'] as List).map((item) {
          item['question'] = _unescape.convert(item['question']);
          item['correct_answer'] = _unescape.convert(item['correct_answer']);
          item['incorrect_answers'] = (item['incorrect_answers'] as List)
              .map((a) => _unescape.convert(a.toString()))
              .toList();
          return Question.fromJson(item);
        }).toList();

        if (dbService != null) {
          await dbService.cacheQuestions(
              questions, categoryId, difficulty ?? 'all');
        }

        return questions;
      } else {
        throw Exception('Connection error');
      }
    } catch (e) {
      if (dbService != null) {
        final hasCached = await dbService.hasCachedQuestions(
            categoryId, difficulty ?? 'all');
        if (hasCached) {
          final cached = await dbService.getCachedQuestions(
              categoryId, difficulty ?? 'all', amount);
          if (cached.isNotEmpty) return cached;
        }
      }
      throw Exception(
          'No internet connection. Play a quiz online first to enable offline mode.');
    }
  }
}