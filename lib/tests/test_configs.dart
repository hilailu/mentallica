class TestConfig {
  final Map<String, int> Function(Map<int, int>) calculateResults;
  final String testName;
  final String category;

  TestConfig({
    required this.calculateResults,
    required this.testName,
    required this.category,
  });
}

final Map<String, TestConfig> testConfigurations = {
  // depression
  'PHQ9': TestConfig(
    testName: 'PHQ9',
    category: 'Depression',
    calculateResults: (answers) {
      int totalScore = 0;
      answers.forEach((_, score) {
        totalScore += score - 1;
      });
      return {
        'Total score': totalScore,
      };
    },
  ),
  // autism
  'rbq2a': TestConfig(
    testName: 'rbq2a',
    category: 'Autism',
    calculateResults: (answers) {
      int totalScore = 0;
      answers.forEach((questionIndex, score) {
        totalScore += score;
      });
      return {
        'Total score': totalScore
      };
    },
  ),
  'catq': TestConfig(
    testName: 'catq',
    category: 'Autism',
    calculateResults: (answers) {
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
    },
  ),
  'aq': TestConfig(
    testName: 'aq',
    category: 'Autism',
    calculateResults: (answers) {
      final List<int> reverseScoringQuestions = [
        1, 3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28, 29, 30, 31, 32, 34, 36, 37,
        38, 40, 44, 47, 48, 49, 50
      ];
      int totalScore = 0;
      answers.forEach((questionIndex, score) {
        score = score - 1;
        int adjustedScore = reverseScoringQuestions.contains(questionIndex)
            ? (score == 0 ? 1 : 0)
            : score;
        totalScore += adjustedScore;
      });
      return {
        'Total score': totalScore,
      };
    },
  ),
};