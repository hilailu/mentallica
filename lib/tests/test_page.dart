import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentallica/tests/test_configs.dart';

class TestPage extends StatefulWidget {
  final String testName;
  final Map<String, dynamic> Function(Map<int, int>) calculateResults;

  const TestPage({
    super.key,
    required this.testName,
    required this.calculateResults,
  });

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<String> _questions = [];
  List<String> _options = [];
  String _testName = 'Тест';
  final Map<int, int> _answers = {};
  int _currentQuestionIndex = 0;
  String _warningMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTestData(widget.testName);
  }

  Future<void> _loadTestData(String testName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tests')
          .doc(testName)
          .get();
      if (doc.exists) {
        setState(() {
          _questions = List<String>.from(doc['questions']);
          _options = List<String>.from(doc['options']);
          _testName = doc['name'];
        });
      } else {
        setState(() {
          _warningMessage = 'Данные теста не найдены';
        });
      }
    } catch (e) {
      setState(() {
        _warningMessage = 'Ошибка загрузки теста: $e';
      });
    }
  }

  void _nextQuestion() {
    if (_answers[_currentQuestionIndex] == null) {
      setState(() {
        _warningMessage = 'Пожалуйста, выберите вариант ответа';
      });
    } else {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _warningMessage = '';
        });
      } else {
        _showResults();
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _answerQuestion(int score) {
    setState(() {
      _answers[_currentQuestionIndex] = score;
    });
  }

  void _showResults() {
    final results = widget.calculateResults(_answers);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultPage(results: results, config: testConfigurations[widget.testName],),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty || _options.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            '',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF8BACA5),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _testName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _questions[_currentQuestionIndex],
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 20),
              ..._options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;

                return Card(
                  color: Colors.grey.shade50,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: RadioListTile<int>(
                    title: Text(option),
                    value: index + 1,
                    groupValue: _answers[_currentQuestionIndex],
                    onChanged: (int? value) {
                      _answerQuestion(value!);
                    },
                  ),
                );
              }),
              const SizedBox(height: 10),
              if (_warningMessage.isNotEmpty)
                Text(
                  _warningMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fixedSize: const Size(120, 50),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.navigate_before, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Пред.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 140),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      fixedSize: const Size(120, 50),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                         'След.',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.navigate_next, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestResultPage extends StatelessWidget {
  final Map<String, dynamic> results;
  final TestConfig? config;

  const TestResultPage({
    super.key,
    required this.results,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          config!.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  config!.description,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.left,
                  softWrap: true,
                ),
              ),
              ...results.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F6),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: entry.value.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
