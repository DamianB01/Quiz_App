import 'package:flutter/material.dart';
import '../models/quiz_result.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import '../services/firebase_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String categoryName;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.categoryName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final result = QuizResult(
      id: 0,
      category: widget.categoryName,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
      date: DateTime.now(),
    );
    await _dbService.saveResult(result);
    FirebaseService.logQuizCompleted(
      category: widget.categoryName,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
    );
  }

  String get _feedbackText {
    final pct = widget.score / widget.totalQuestions;
    if (pct >= 0.9) return 'Excellent result!';
    if (pct >= 0.7) return 'You did great!';
    if (pct >= 0.5) return 'Not bad, but you can do better';
    return 'You need to practice more';
  }

  Color get _scoreColor {
    final pct = widget.score / widget.totalQuestions;
    if (pct >= 0.7) return Colors.green;
    if (pct >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.score} / ${widget.totalQuestions}',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(_feedbackText,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                'Category: ${widget.categoryName}',
                style: const TextStyle(
                    fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomeScreen()),
                        (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Play again',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/profile'),
                child: const Text('Show statistics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
