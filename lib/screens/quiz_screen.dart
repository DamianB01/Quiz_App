import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'result_screen.dart';
import '../services/firebase_service.dart';

class QuizScreen extends StatefulWidget {
  final int? categoryId;
  final String categoryName;
  final String difficulty;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<List<String>> _shuffledAnswers = [];
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    FirebaseService.logQuizStarted(
      category: widget.categoryName,
      difficulty: widget.difficulty,
      questionCount: widget.questionCount,
    );
    try {
      final questions = await _apiService.fetchQuestions(
        amount: widget.questionCount,
        categoryId: widget.categoryId,
        difficulty: widget.difficulty,
        dbService: _dbService,
      );
      for (final q in questions) {
        q.isFavorite = await _dbService.isFavorite(q.questionText);
      }
      setState(() {
        _questions = questions;
        _shuffledAnswers = questions.map((q) {
          final answers = [...q.incorrectAnswers, q.correctAnswer];
          answers.shuffle();
          return answers;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final q = _questions[_currentIndex];
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == q.correctAnswer) _score++;
    });
    FirebaseService.logQuestionAnswered(
      category: q.category,
      difficulty: q.difficulty,
      isCorrect: answer == q.correctAnswer,
    );
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            totalQuestions: _questions.length,
            categoryName: widget.categoryName,
          ),
        ),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final q = _questions[_currentIndex];
    if (q.isFavorite) {
      await _dbService.removeFavorite(q.questionText);
    } else {
      await _dbService.addFavorite(q);
      FirebaseService.logQuestionFavorited(
        category: q.category,
        difficulty: q.difficulty,
      );
    }
    setState(() => q.isFavorite = !q.isFavorite);
  }

  Color _answerColor(String answer) {
    if (!_answered) return Colors.transparent;
    final correct = _questions[_currentIndex].correctAnswer;
    if (answer == correct) return Colors.green.withOpacity(0.2);
    if (answer == _selectedAnswer) return Colors.red.withOpacity(0.2);
    return Colors.transparent;
  }

  Icon? _answerIcon(String answer) {
    if (!_answered) return null;
    final correct = _questions[_currentIndex].correctAnswer;
    if (answer == correct) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (answer == _selectedAnswer) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName,
            overflow: TextOverflow.ellipsis),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(
                _questions[_currentIndex].isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _questions[_currentIndex].isFavorite
                    ? Colors.red
                    : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : _buildQuiz(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadQuestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentIndex];
    final answers = _shuffledAnswers[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 6),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1} / ${_questions.length}'),
              Text('Score: $_score',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Chip(
                          label: Text(question.difficulty.toUpperCase(),
                              style: const TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...answers.map((answer) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _selectAnswer(answer),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _answerColor(answer),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(answer,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          if (_answerIcon(answer) != null)
                            _answerIcon(answer)!,
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next question'
                      : 'Show results',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
