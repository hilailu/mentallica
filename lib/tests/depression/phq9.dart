import 'package:flutter/material.dart';
import '../test_page.dart';

class PHQ9TestPage extends StatelessWidget {
  const PHQ9TestPage({super.key});

  Map<String, int> _calculatePHQ9Results(Map<int, int> answers) {
    int totalScore = 0;

    answers.forEach((questionIndex, score) {
      totalScore += score - 1;
    });

    return {
      'Total score': totalScore
    };
  }

  @override
  Widget build(BuildContext context) {
    return TestPage(
      testName: 'PHQ9',
      calculateResults: _calculatePHQ9Results,
    );
  }
}
