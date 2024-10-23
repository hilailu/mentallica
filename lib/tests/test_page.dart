import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  final String testName;
  final Function(Map<int, int>) calculateResults;

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
  final Map<int, int> _answers = {};
  int _currentQuestionIndex = 0;
  String _warningMessage = '';
  String _testName = 'Test';

  @override
  void initState() {
    super.initState();
    _testName = widget.testName;
    _loadTestData(_testName);
  }

  Future<void> _loadTestData(String testName) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('tests').doc(testName).get();
      if (doc.exists) {
        setState(() {
          _questions = List<String>.from(doc['questions']);
          _options = List<String>.from(doc['options']);
        });
      } else {
        setState(() {
          _warningMessage = 'Test data not found';
        });
      }
    } catch (e) {
      setState(() {
        _warningMessage = 'Error loading test data: $e';
      });
    }
  }

  void _nextQuestion() {
    if (_answers[_currentQuestionIndex] == null) {
      setState(() {
        _warningMessage = 'Please, pick an option';
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
        builder: (context) => TestResultPage(results: results),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty || _options.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_testName),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_testName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _questions[_currentQuestionIndex],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ..._options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              return RadioListTile<int>(
                title: Text(option),
                value: index + 1,
                groupValue: _answers[_currentQuestionIndex],
                onChanged: (int? value) {
                  _answerQuestion(value!);
                },
              );
            }),
            const SizedBox(height: 20),
            if (_warningMessage.isNotEmpty)
              Text(
                _warningMessage,
                style: const TextStyle(color: Colors.red),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous'),
                  )
                else
                  const Spacer(),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                      _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Results'
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TestResultPage extends StatelessWidget {
  final Map<String, int> results;

  const TestResultPage({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: results.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
