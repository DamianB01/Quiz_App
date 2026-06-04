import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/quiz_result.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<QuizResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await _dbService.getResults();
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  int get _totalQuizzes => _results.length;
  double get _avgScore {
    if (_results.isEmpty) return 0;
    final sum = _results.fold<double>(
        0, (acc, r) => acc + r.percentage);
    return sum / _results.length;
  }
  int get _bestScore =>
      _results.isEmpty ? 0 : _results.map((r) => r.score).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          if (_results.isNotEmpty) ...[
            _buildChartSection(),
            const SizedBox(height: 24),
          ],
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor:
              Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 36,
                  color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Player',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('$_totalQuizzes quizzes played',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('Played', '$_totalQuizzes', Icons.quiz),
        const SizedBox(width: 12),
        _statCard(
            'Average %', '${_avgScore.toStringAsFixed(0)}%', Icons.percent),
        const SizedBox(width: 12),
        _statCard('The best', '$_bestScore pts', Icons.star),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _results.take(7).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Results history (%)',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, _) => Text(
                        '${val.toInt()}%',
                        style: const TextStyle(fontSize: 10),
                      )),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      final i = val.toInt();
                      if (i >= data.length) return const SizedBox();
                      return Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(data.length, (i) {
                final pct = data[i].percentage;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: pct,
                      color:
                      Theme.of(context).colorScheme.primary,
                      width: 22,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark theme'),
            subtitle: Text(widget.isDarkMode ? 'On' : 'Off'),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    if (_results.isEmpty) {
      return const Center(
        child: Text('No quiz history',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Latest quizzes',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ..._results.map((r) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
              r.percentage >= 70
                  ? Colors.green
                  : r.percentage >= 50
                  ? Colors.orange
                  : Colors.red,
              child: Text(
                '${r.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(r.category,
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${r.score}/${r.totalQuestions} pts  •  '
                  '${r.date.day}.${r.date.month}.${r.date.year}',
            ),
          ),
        )),
      ],
    );
  }
}
