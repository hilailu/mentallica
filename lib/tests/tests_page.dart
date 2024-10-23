import 'package:flutter/material.dart';

import 'autism/aqtest.dart';
import 'autism/catqtest.dart';
import 'autism/rbq2atest.dart';
import 'depression/phq9.dart';

// Category widget for expand/collapse functionality
class TestCategory extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> tests;

  const TestCategory({super.key, required this.category, required this.tests});

  @override
  _TestCategoryState createState() => _TestCategoryState();
}

class _TestCategoryState extends State<TestCategory> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.category, style: const TextStyle(fontSize: 18)),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      children: widget.tests.map((test) {
        return ListTile(
          title: Text(test['name']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => test['page']),
            );
          },
        );
      }).toList(),
    );
  }
}

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mental Health Tests')),
      body: ListView(
        children: const [
          TestCategory(
            category: 'Autism',
            tests: [
              {'name': 'CAT-Q Test', 'page': CATQTestPage()},
              {'name': 'RBQ-2A Test', 'page': RBQ2ATestPage()},
              {'name': 'AQ Test', 'page': AQTestPage()},
            ],
          ),
          TestCategory(
            category: 'Depression',
            tests: [
              {'name': 'PHQ-9 Test', 'page': PHQ9TestPage()},
            ],
          ),
          TestCategory(
            category: 'Anxiety',
            tests: [
              {'name': 'GAD-7 Test', 'page': CATQTestPage()},
            ],
          ),
        ],
      ),
    );
  }
}