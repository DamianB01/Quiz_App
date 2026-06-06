import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import '../models/question.dart';
import 'firebase_service.dart';

class ApiService {
  static const String _baseUrl = 'https://opentdb.com';
  final HtmlUnescape _unescape = HtmlUnescape();

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await FirebaseService.traceApiCall(
      'fetch_categories',
          () => http.get(Uri.parse('$_baseUrl/api_category.php')),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['trivia_categories']);
    } else {
      throw Exception('Błąd pobierania kategorii');
    }
  }

  Future<List<Question>> fetchQuestions({
    required int amount,
    int? categoryId,
    String? difficulty,
  }) async {
    String url = '$_baseUrl/api.php?amount=$amount';
    if (categoryId != null) url += '&category=$categoryId';
    if (difficulty != null && difficulty != 'all') {
      url += '&difficulty=$difficulty';
    }

    final response = await FirebaseService.traceApiCall(
      'fetch_questions',
          () => http.get(Uri.parse(url)),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['response_code'] != 0) {
        throw Exception('Brak pytań dla wybranych parametrów');
      }

      return (data['results'] as List).map((item) {
        item['question'] = _unescape.convert(item['question']);
        item['correct_answer'] = _unescape.convert(item['correct_answer']);
        item['incorrect_answers'] = (item['incorrect_answers'] as List)
            .map((a) => _unescape.convert(a.toString()))
            .toList();
        return Question.fromJson(item);
      }).toList();
    } else {
      throw Exception('Błąd połączenia z API');
    }
  }
}
