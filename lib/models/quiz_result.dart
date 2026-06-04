class QuizResult {
  final int id;
  final String category;
  final int score;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.id,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  double get percentage => (score / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'score': score,
      'total_questions': totalQuestions,
      'date': date.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      category: map['category'],
      score: map['score'],
      totalQuestions: map['total_questions'],
      date: DateTime.parse(map['date']),
    );
  }
}
