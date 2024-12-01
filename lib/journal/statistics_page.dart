import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/auth.dart';
import 'journal_entry.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimePeriod = 'week';
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  Map<String, Color> moodColors = {
    'Энтузиазм': const Color(0xFFEEC27F),
    'Радость': const Color(0xFFECA670),
    'Спокойствие': const Color(0xFF8BACA5),
    'Смущение': const Color(0xFFE497AD),
    'Усталость': const Color(0xFF9785CC),
    'Грусть': const Color(0xFF78C0D6),
    'Злость': const Color(0xFFDC6C6C),
    'Тревожность': const Color(0xFF746A6A),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchJournalEntries(_selectedTimePeriod);

    _tabController.addListener(() {
      final newTimePeriod = ['week', 'month', 'year'][_tabController.index];
      if (_selectedTimePeriod != newTimePeriod) {
        setState(() {
          _selectedTimePeriod = newTimePeriod;
          _isLoading = true;
        });
        _fetchJournalEntries(newTimePeriod);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchJournalEntries(String timePeriod) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('journal_entries')
        .where('patientId', isEqualTo: Auth().userId)
        .get();

    List<JournalEntry> entries = querySnapshot.docs.map((doc) {
      return JournalEntry(
        date: (doc['date'] as Timestamp).toDate(),
        mood: doc['mood'],
        symptoms: List<String>.from(doc['symptoms']),
        positives: List<String>.from(doc['positives']),
        description: doc['description'],
        patientId: doc['patientId'],
      );
    }).toList();

    DateTime now = DateTime.now();
    if (timePeriod == 'week') {
      entries = entries.where((entry) =>
          entry.date.isAfter(now.subtract(Duration(days: 7)))).toList();
    } else if (timePeriod == 'month') {
      entries = entries.where((entry) =>
          entry.date.isAfter(DateTime(now.year, now.month - 1, now.day)))
          .toList();
    } else if (timePeriod == 'year') {
      entries = entries.where((entry) =>
          entry.date.isAfter(DateTime(now.year - 1, now.month, now.day)))
          .toList();
    }

    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Map<String, int> _getMoodFrequency(List<JournalEntry> entries) {
    Map<String, int> moodFrequency = {};
    for (var entry in entries) {
      moodFrequency[entry.mood] = (moodFrequency[entry.mood] ?? 0) + 1;
    }
    return moodFrequency;
  }

  Widget _buildMoodChart(Map<String, int> moodFrequency) {
    List<MapEntry<String, int>> sortedMoodFrequency = moodFrequency.entries.toList()
      ..sort((a, b) {
        int indexA = moodColors.keys.toList().indexOf(a.key);
        int indexB = moodColors.keys.toList().indexOf(b.key);
        return indexA.compareTo(indexB);
      });

    List<BarChartGroupData> barGroups = sortedMoodFrequency.map((entry) {
      String mood = entry.key;
      int frequency = entry.value;

      Color barColor = moodColors[mood] ?? Colors.grey;

      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: frequency.toDouble(),
            color: barColor,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();

    return Center(
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String mood = moodFrequency.keys
                      .firstWhere((key) => key.hashCode == value.toInt(),
                      orElse: () => '');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5,),
                      Image.asset(
                        'assets/images/$mood.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(height: 15,),
                      Transform.rotate(
                          angle: 55 * 3.14159 / 180, // Rotate text 90 degrees counter-clockwise
                          child: Text(
                        mood,
                        style: const TextStyle(fontSize: 8, color: Colors
                            .black),
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          minY: 0,
          maxY: moodFrequency.values.reduce((a, b) => a > b ? a : b)
              .toDouble() + 1,
        ),
      ),
    );
  }

  Map<String, Map<String, int>> _getMoodCorrelation(
      List<JournalEntry> entries) {
    Map<String, Map<String, int>> correlation = {};

    for (var entry in entries) {
      if (!correlation.containsKey(entry.mood)) {
        correlation[entry.mood] = {'positives': 0, 'symptoms': 0};
      }
      correlation[entry.mood]!['positives'] =
          (correlation[entry.mood]!['positives'] ?? 0) + entry.positives.length;
      correlation[entry.mood]!['symptoms'] =
          (correlation[entry.mood]!['symptoms'] ?? 0) + entry.symptoms.length;
    }

    return correlation;
  }

  Widget _buildCorrelationChart(Map<String, Map<String, int>> correlationData) {
    List<MapEntry<String, Map<String, int>>> sortedCorrelationData = correlationData.entries.toList()
      ..sort((a, b) {
        int indexA = moodColors.keys.toList().indexOf(a.key);
        int indexB = moodColors.keys.toList().indexOf(b.key);
        return indexA.compareTo(indexB);
      });

    List<BarChartGroupData> barGroups = sortedCorrelationData.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value['positives']!.toDouble(),
            color: const Color(0xFF8BACA5),
            width: 10,
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            toY: entry.value['symptoms']!.toDouble(),
            color: const Color(0xFFDC6C6C),
            width: 10,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();

    return Center(
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String mood = correlationData.keys
                      .firstWhere((key) => key.hashCode == value.toInt(),
                      orElse: () => '');

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5,),
                      Image.asset(
                        'assets/images/$mood.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(height: 15,),
                      Transform.rotate(
                          angle: 55 * 3.14159 / 180, // Rotate text 90 degrees counter-clockwise
                          child: Text(
                        mood,
                        style: const TextStyle(fontSize: 8, color: Colors
                            .black),
                      )),
                    ],
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          minY: 0,
          maxY: correlationData.values
              .expand((entry) => [entry['positives']!, entry['symptoms']!])
              .reduce((a, b) => a > b ? a : b)
              .toDouble() + 1,
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 270, child: chart),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> moodFrequency = _getMoodFrequency(_entries);
    Map<String, Map<String, int>> correlationData = _getMoodCorrelation(
        _entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Статистика', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Column(
        children: [
          Material(
              elevation: 4,
              child: ColoredTabBar(const Color(0xFF8BACA5), TabBar(
                labelStyle: const TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
                indicatorColor: Colors.white,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Неделя'),
                  Tab(text: 'Месяц'),
                  Tab(text: 'Год'),
                ],
              ))
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 10),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _entries.isEmpty
                  ? const Center(
                child: Text(
                  'Не хватает данных для генерации статистики.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView(
                children: [
                  _buildChartCard(
                      'Частота настроений', _buildMoodChart(moodFrequency)),
                  _buildChartCard('Корреляция настроений\n(Позитивные моменты и симптомы)',
                      _buildCorrelationChart(correlationData)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar, {super.key});

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}

