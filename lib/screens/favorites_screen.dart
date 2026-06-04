import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/database_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Question> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favs = await _dbService.getFavorites();
    setState(() {
      _favorites = favs;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Question q) async {
    await _dbService.removeFavorite(q.questionText);
    setState(() => _favorites.remove(q));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite questions')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favorite questions',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final q = _favorites[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          q.difficulty.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () =>
                            _removeFavorite(q),
                        tooltip: 'Remove from favorites',
                      ),
                    ],
                  ),
                  Text(q.questionText,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    '✅ ${q.correctAnswer}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}