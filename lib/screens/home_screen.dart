import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? _selectedCategoryId;
  String _selectedCategoryName = 'Any';
  String _selectedDifficulty = 'any';
  int _questionCount = 10;

  final List<String> _difficulties = ['any', 'easy', 'medium', 'hard'];
  final List<int> _counts = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cats = await _apiService.fetchCategories();
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download category. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoryId: _selectedCategoryId,
          categoryName: _selectedCategoryName,
          difficulty: _selectedDifficulty,
          questionCount: _questionCount,
        ),
      ),
    );
  }

  String _difficultyLabel(String d) {
    switch (d) {
      case 'easy': return 'Easy';
      case 'medium': return 'Medium';
      case 'hard': return 'Hard';
      default: return 'Any';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : _buildContent(theme),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select quiz settings',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSectionLabel('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              value: _selectedCategoryId,
              decoration: _inputDecoration('Select category'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('Any category')),
                ..._categories.map((c) => DropdownMenuItem(
                  value: c['id'] as int,
                  child: Text(c['name'],
                      overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: (val) => setState(() {
                _selectedCategoryId = val;
                _selectedCategoryName = val == null
                    ? 'Any'
                    : _categories
                    .firstWhere((c) => c['id'] == val)['name'];
              }),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Difficulty level'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _difficulties.map((d) {
                final selected = _selectedDifficulty == d;
                return ChoiceChip(
                  label: Text(_difficultyLabel(d)),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedDifficulty = d),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildSectionLabel('Number of questions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _counts.map((c) {
                final selected = _questionCount == c;
                return ChoiceChip(
                  label: Text('$c'),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _questionCount = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Start the quiz',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
