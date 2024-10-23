import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../auth/auth.dart';
import '../journal/journal_entry.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimePeriod = 'week';
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchJournalEntries(_selectedTimePeriod);

    _tabController.addListener(() {
      switch (_tabController.index) {
        case 0:
          setState(() => _selectedTimePeriod = 'week');
          break;
        case 1:
          setState(() => _selectedTimePeriod = 'month');
          break;
        case 2:
          setState(() => _selectedTimePeriod = 'year');
          break;
      }
      _fetchJournalEntries(_selectedTimePeriod);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchJournalEntries(String timePeriod) async {
    setState(() {
      _isLoading = true;
    });

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
    final List<Color> barColors = [
      const Color(0xFF8BACA5), const Color(0xFF78C0D6),
      const Color(0xFFE29E85), const Color(0xFFEEC27F),
      const Color(0xFF746A6A)
    ];

    List<BarChartGroupData> barGroups = moodFrequency.entries.map((entry) {
      int index = moodFrequency.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: barColors[index % barColors.length],
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
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: 1,
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      SizedBox(height: 5,),
                      Image.asset(
                        'assets/images/$mood.png',
                        height: 20,
                        width: 20,
                      ),
                      Text(
                        mood,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
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
    List<BarChartGroupData> barGroups = correlationData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value['positives']!.toDouble(),
            color: const Color(0xFF8BACA5),
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
          BarChartRodData(
            toY: entry.value['symptoms']!.toDouble(),
            color: const Color(0xFFE29E85),
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
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      SizedBox(height: 5,),
                      Image.asset(
                        'assets/images/$mood.png',
                        height: 20,
                        width: 20,
                      ),
                      Text(
                        mood,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
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

  @override
  Widget build(BuildContext context) {
    Map<String, int> moodFrequency = _getMoodFrequency(_entries);
    Map<String, Map<String, int>> correlationData = _getMoodCorrelation(
        _entries);

    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              // Add padding here
              child: _isLoading // Check the loading state
                  ? Center(
                  child: CircularProgressIndicator()) // Show loading indicator
                  : ListView(
                children: [
                  SizedBox(height: 20),
                  Center(child: Text('Mood Frequency', style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge)),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: _buildMoodChart(moodFrequency),
                  ),
                  SizedBox(height: 20),
                  Center(child: Text(
                      'Mood Correlation (Positives & Symptoms)', style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge)),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: _buildCorrelationChart(correlationData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
