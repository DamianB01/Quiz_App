import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> initCrashlytics() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<T> traceApiCall<T>(
      String traceName,
      Future<T> Function() apiCall,
      ) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
    try {
      final result = await apiCall();
      return result;
    } finally {
      await trace.stop();
    }
  }

  static Future<void> logQuizStarted({
    required String category,
    required String difficulty,
    required int questionCount,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_started',
      parameters: {
        'category': category,
        'difficulty': difficulty,
        'question_count': questionCount,
      },
    );
  }

  static Future<void> logQuizCompleted({
    required String category,
    required int score,
    required int totalQuestions,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'category': category,
        'score': score,
        'total_questions': totalQuestions,
        'percentage': (score / totalQuestions * 100).round(),
      },
    );
  }

  static Future<void> logQuestionFavorited({
    required String category,
    required String difficulty,
  }) async {
    await _analytics.logEvent(
      name: 'question_favorited',
      parameters: {
        'category': category,
        'difficulty': difficulty,
      },
    );
  }
}