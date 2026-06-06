import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseService.initCrashlytics();
  final prefs = await SharedPreferences.getInstance();
  final savedDarkMode = prefs.getBool('dark_mode') ?? false;
  runApp(QuizApp(initialDarkMode: savedDarkMode));
}

class QuizApp extends StatefulWidget {
  final bool initialDarkMode;
  const QuizApp({super.key, required this.initialDarkMode});

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _toggleTheme(bool val) async {
    setState(() => _isDarkMode = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/profile': (ctx) => ProfileScreen(
          isDarkMode: _isDarkMode,
          onThemeChanged: _toggleTheme,
        ),
      },
    );
  }
}