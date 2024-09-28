import 'package:flutter/material.dart';
import 'test_page.dart';

class CATQTestPage extends StatelessWidget {
  const CATQTestPage({super.key});

  Map<String, int> _calculateCATQResults(Map<int, int> answers) {
    final List<int> reverseScoringQuestions = [2, 11, 18, 21, 23];
    final List<int> compensationQuestions = [0, 3, 4, 7, 10, 13, 16, 19, 22];
    final List<int> maskingQuestions = [1, 5, 8, 11, 14, 17, 20, 23];
    final List<int> assimilationQuestions = [2, 6, 9, 12, 15, 18, 21, 24];

    int totalScore = 0;
    int compensationScore = 0;
    int maskingScore = 0;
    int assimilationScore = 0;

    answers.forEach((questionIndex, score) {
      int adjustedScore = reverseScoringQuestions.contains(questionIndex) ? 8 - score : score;

      totalScore += adjustedScore;
      if (compensationQuestions.contains(questionIndex)) {
        compensationScore += adjustedScore;
      }
      if (maskingQuestions.contains(questionIndex)) {
        maskingScore += adjustedScore;
      }
      if (assimilationQuestions.contains(questionIndex)) {
        assimilationScore += adjustedScore;
      }
    });

    return {
      'Total score': totalScore,
      'Compensation score': compensationScore,
      'Masking score': maskingScore,
      'Assimilation score': assimilationScore,
    };
  }

  @override
  Widget build(BuildContext context) {
    return TestPage(
      testName: 'catq',
      calculateResults: _calculateCATQResults,
    );
  }
}
