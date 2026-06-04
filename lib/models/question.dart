class Question {
  final String category;
  final String type;
  final String difficulty;
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  bool isFavorite;

  Question({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
    this.isFavorite = false,
  });

  List<String> get allAnswers {
    final answers = [...incorrectAnswers, correctAnswer];
    answers.shuffle();
    return answers;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'],
      type: json['type'],
      difficulty: json['difficulty'],
      questionText: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'difficulty': difficulty,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers.join('|||'),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      category: map['category'],
      type: 'multiple',
      difficulty: map['difficulty'],
      questionText: map['question_text'],
      correctAnswer: map['correct_answer'],
      incorrectAnswers: (map['incorrect_answers'] as String).split('|||'),
      isFavorite: true,
    );
  }
}
