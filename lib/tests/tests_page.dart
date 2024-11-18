import 'package:flutter/material.dart';
import 'package:mentallica/tests/test_configs.dart';
import 'package:mentallica/tests/test_page.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tests',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF8BACA5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: _groupTestsByCategory().entries.map((entry) {
            final category = entry.key;
            final tests = entry.value;

            return Container(
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
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                children: tests.map((testKey) {
                  return ListTile(
                    title: Text(testKey.toUpperCase()),
                    onTap: () {
                      final config = testConfigurations[testKey]!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestPage(
                            testName: config.testName,
                            calculateResults: config.calculateResults,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<String, List<String>> _groupTestsByCategory() {
    final Map<String, List<String>> groupedTests = {};
    testConfigurations.forEach((testKey, config) {
      final category = config.category;
      if (!groupedTests.containsKey(category)) {
        groupedTests[category] = [];
      }
      groupedTests[category]!.add(testKey);
    });
    return groupedTests;
  }
}