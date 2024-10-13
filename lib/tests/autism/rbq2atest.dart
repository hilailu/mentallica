import 'package:flutter/material.dart';
import '../test_page.dart';

class RBQ2ATestPage extends StatelessWidget {
  const RBQ2ATestPage({super.key});

  Map<String, int> _calculateRBQ2AResults(Map<int, int> answers) {
    int totalScore = 0;

    answers.forEach((questionIndex, score) {
      totalScore += score;
    });

    return {
      'Total score': totalScore
    };
  }

  @override
  Widget build(BuildContext context) {
    return TestPage(
      testName: 'rbq2a',
      calculateResults: _calculateRBQ2AResults,
    );
  }
}
