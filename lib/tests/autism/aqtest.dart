import 'package:flutter/material.dart';
import '../test_page.dart';

class AQTestPage extends StatelessWidget {
  const AQTestPage({super.key});

  Map<String, int> _calculateAQResults(Map<int, int> answers) {
    final List<int> reverseScoringQuestions = [1, 3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28, 29, 30, 31, 32, 34, 36, 37, 38, 40, 44, 47, 48, 49, 50];
    int totalScore = 0;

    answers.forEach((questionIndex, score) {
      score = score - 1;
      int adjustedScore = reverseScoringQuestions.contains(questionIndex) ? (score == 0 ? 1 : 0) : score;
      totalScore += adjustedScore;
    });

    return {
      'Total score': totalScore
    };
  }

  @override
  Widget build(BuildContext context) {
    return TestPage(
      testName: 'aq',
      calculateResults: _calculateAQResults,
    );
  }
}
