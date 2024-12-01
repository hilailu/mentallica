class TestConfig {
  final Map<String, dynamic> Function(Map<int, int>) calculateResults;
  final String name;
  final String testName;
  final String category;
  final String description;

  TestConfig({
    required this.calculateResults,
    required this.name,
    required this.testName,
    required this.category,
    required this.description,
  });
}

final Map<String, TestConfig> testConfigurations = {
  /*// depression
  'PHQ9': TestConfig(
    name: 'PHQ9',
    testName: 'PHQ9',
    category: 'Depression',
    description: '',
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
    name: 'RBQ-2A',
    testName: 'rbq2a',
    category: 'Autism',
    description: '',
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
    name: 'CAT-Q',
    testName: 'catq',
    category: 'Autism',
    description: 'A total score of 100 or above indicates you camouflage autistic traits. High CAT-Q scores correlate with social anxiety in both autistics and neurotypicals, with the exception of Masking. In autistic people, the total CAT-Q score and the Assimilation score negatively correlate with well-being. The higher your scores on these measures, the lower your well-being tends to be. In neurotypical people, all CAT-Q scores negatively correlate with well-being—not just total score and Assimilation. In autistic people, all CAT-Q scores were correlated with depression and generalised anxiety. This wasn’t tested for in the neurotypical group.',
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
        int adjustedScore = reverseScoringQuestions.contains(questionIndex)
            ? 8 - score
            : score;

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
    name: 'AQ',
    testName: 'aq',
    category: 'Autism',
    description: '',
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
  ),*/
  'beck': TestConfig(
    name: 'Шкала Бека',
    testName: 'beck',
    category: 'Депрессия',
    description: 'Шкала депрессии Бека помогает выявить уровень депрессии у пациента. В случае высоких результатов настоятельно рекомендуется консультация специалиста.',
    calculateResults: (answers) {
      int totalScore = 0;
      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 10) {
        return {
          'Итог': totalScore,
          'Результат': 'Нормальное состояние. Нет признаков депрессии.',
        };
      } else if (totalScore <= 20) {
        return {
          'Итог': totalScore,
          'Результат': 'Легкая депрессия. Рекомендуется следить за состоянием.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренная депрессия. Стоит обратиться к специалисту.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Тяжелая депрессия. Необходима срочная помощь.',
        };
      }
    },
  ),
  'zung': TestConfig(
    name: 'Шкала Зунге',
    testName: 'zung',
    category: 'Депрессия',
    description: 'Шкала депрессии Зунге позволяет оценить уровень депрессивного состояния. Этот тест помогает определить необходимость обращения к специалисту.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 25) {
        return {
          'Итог': totalScore,
          'Результат': 'Низкий уровень депрессии. Состояние в пределах нормы.',
        };
      } else if (totalScore <= 49) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренный уровень депрессии. Рекомендуется наблюдение за своим состоянием.',
        };
      } else if (totalScore <= 69) {
        return {
          'Итог': totalScore,
          'Результат': 'Высокий уровень депрессии. Следует обратиться за профессиональной консультацией.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Крайне высокий уровень депрессии. Срочно обратитесь к специалисту.',
        };
      }
    },
  ),
  'shihan': TestConfig(
    name: 'Шихан',
    testName: 'shihan',
    category: 'Тревожность',
    description: 'Тест Шихан на тревожность помогает оценить уровень тревожных симптомов. Применяется для определения, нуждается ли человек в профессиональной психотерапевтической поддержке.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Низкий уровень тревожности. Ваши симптомы тревожности находятся в пределах нормы.'
        };
      } else if (totalScore <= 25) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренный уровень тревожности. Стоит обратить внимание на свое состояние и, возможно, проконсультироваться с врачом.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Высокий уровень тревожности. Рекомендуется обратиться к специалисту для диагностики и получения рекомендаций по лечению.'
        };
      }
    },
  ),
  'behterev': TestConfig(
    name: 'Шкала Бехтерева',
    testName: 'behterev',
    category: 'Депрессия',
    description: 'Шкала самооценки депрессии помогает выявить уровень депрессивных симптомов. Высокий балл может указывать на депрессию средней или тяжелой степени и необходимость консультации с врачом.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет признаков депрессии. Однако если вы все же чувствуете себя плохо, обратитесь к специалисту.'
        };
      } else if (totalScore <= 25) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки депрессии. Возможно, вам стоит проконсультироваться с психотерапевтом или психиатром.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки депрессии. Рекомендуется обратиться к врачу для более подробной диагностики и лечения.'
        };
      }
    },
  ),
  'cesd': TestConfig(
    name: 'Шкала ЦЭИ (CES-D)',
    testName: 'cesd',
    category: 'Депрессия',
    description: 'Шкала депрессии CES-D оценивает наличие симптомов депрессии на основе самооценки. Если результат высокий, рекомендуется обратиться к специалисту для диагностики и консультации.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет выраженных признаков депрессии. Однако, если симптомы ухудшаются, рекомендуется обратиться к специалисту.'
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки депрессии. Возможно, вам стоит обратить внимание на эмоциональное состояние и проконсультироваться с психотерапевтом.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные симптомы депрессии. Рекомендуется обратиться за консультацией к психиатру или психотерапевту.'
        };
      }
    },
  ),
  'raadsr': TestConfig(
    name: 'Ритво (RRADS-R)',
    testName: 'raadsr',
    category: 'Аутизм',
    description: 'Тест RAADS-R помогает выявить признаки аутизма, особенно у взрослых.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет признаков аутизма. Если проблемы сохраняются, проконсультируйтесь с психотерапевтом.'
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки аутизма. Рекомендуется обратиться к специалисту для дальнейшего обследования.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Явные признаки аутизма. Обратитесь к врачу для диагностики и получения помощи.'
        };
      }
    },
  ),
  'aq': TestConfig(
    name: 'Коэффициент аутистического спектра',
    testName: 'aq',
    category: 'Аутизм',
    description: 'Тест AQ позволяет выявить симптомы аутизма на основе наблюдений о повседневной жизни.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 10) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет признаков аутизма. Если есть сомнения, проконсультируйтесь с врачом.'
        };
      } else if (totalScore <= 20) {
        return {
          'Итог': totalScore,
          'Результат': 'Возможные признаки аутизма. Рекомендуется консультация специалиста.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Признаки аутизма. Консультация с врачом обязательна для дальнейшей диагностики.'
        };
      }
    },
  ),
  'bapq': TestConfig(
    name: 'Расширенный фенотип аутизма',
    testName: 'bapq',
    category: 'Аутизм',
    description: 'Тест BAPQ помогает выявить более широкий спектр аутичных признаков у людей, которые не попадают в основной диагноз.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 5) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет выраженных признаков аутизма. Обратите внимание на ваше психоэмоциональное состояние.'
        };
      } else if (totalScore <= 10) {
        return {
          'Итог': totalScore,
          'Результат': 'Слабые признаки аутизма. Рекомендуется пройти консультацию у специалиста.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Явные признаки аутизма. Обратитесь к психотерапевту или психиатру для диагностики.'
        };
      }
    },
  ),
  'assq': TestConfig(
    name: 'Скрининговый опросник аутистического спектра',
    testName: 'assq',
    category: 'Аутизм',
    description: 'Тест ASSQ используется для скрининга аутизма, выявляя типичные поведенческие признаки у детей и взрослых.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 4) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет признаков аутизма. Проконсультируйтесь с врачом при наличии сомнений.'
        };
      } else if (totalScore <= 8) {
        return {
          'Итог': totalScore,
          'Результат': 'Признаки аутизма. Рекомендуется консультация с специалистом.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки аутизма. Необходима консультация психиатра.'
        };
      }
    },
  ),
  'histrionic': TestConfig(
    name: 'Истерическое расстройство',
    testName: 'histrionic',
    category: 'Личностные расстройства',
    description: 'Тест помогает выявить признаки истерического расстройства личности, связанного с поиском внимания, сильной эмоциональностью и потребностью в признании.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'У вас нет выраженных признаков истерического расстройства личности. Если проблемы сохраняются, подумайте о консультации с психологом.'
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Возможные признаки истерического расстройства личности. Рекомендуется консультация с психотерапевтом.'
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Явные признаки истерического расстройства личности. Рекомендуется лечение с помощью психотерапевта или психолога.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки истерического расстройства личности. Срочная консультация с психологом или психотерапевтом обязательна.'
        };
      }
    },
  ),
  'asperger': TestConfig(
    name: 'Синдром Аспергера',
    testName: 'asperger',
    category: 'Аутизм',
    description: 'Тест на синдром Аспергера помогает выявить признаки расстройства аутистического спектра, включая трудности в социальной коммуникации и узкие интересы.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'У вас нет выраженных признаков синдрома Аспергера. Однако, если у вас возникают сомнения, консультация с психотерапевтом может быть полезна.'
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Возможные признаки синдрома Аспергера. Рекомендуется консультация с психотерапевтом или специалистом по аутизму.'
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Явные признаки синдрома Аспергера. Рекомендуется диагностика и консультация с психологом или психотерапевтом.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки синдрома Аспергера. Срочная консультация с психотерапевтом или специалистом по аутизму обязательна.'
        };
      }
    },
  ),
  'caars': TestConfig(
    name: 'Шкала CAARS',
    testName: 'caars',
    category: 'СДВГ',
    description: 'Тест на синдром дефицита внимания и гиперактивности помогает выявить симптомы СДВГ. Если ваш балл высок, рекомендуется консультация с психиатром.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Симптомы СДВГ не выражены или незначительны.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки СДВГ. Возможно, вам стоит обратиться за помощью к специалисту.',
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки СДВГ. Рекомендуется консультация с психиатром или психотерапевтом.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Очень выраженные признаки СДВГ. Срочная консультация с врачом или психотерапевтом обязательна.',
        };
      }
    },
  ),
  'asrs': TestConfig(
    name: 'Шкала ASRS',
    testName: 'asrs',
    category: 'СДВГ',
    description: 'Тест на синдром дефицита внимания и гиперактивности для взрослых. При высоком балле рекомендуется обратиться к специалисту.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });
      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Симптомы СДВГ малозаметны или отсутствуют.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат':'Умеренные признаки СДВГ. Возможно, вам стоит проконсультироваться с психотерапевтом.',
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Явные признаки СДВГ. Рекомендуется обратиться за помощью к психиатру.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Очень выраженные признаки СДВГ. Необходима консультация специалиста в срочном порядке.',
        };
      }
    },
  ),
  'schizo': TestConfig(
    name: 'Шизофрения',
    testName: 'schizo',
    category: 'Личностные расстройства',
    description: 'Тест на склонность к шизофрении помогает выявить возможные симптомы шизофрении, включая галлюцинации, паранойю и потерю связи с реальностью.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет явных признаков склонности к шизофрении. Если симптомы сохраняются, рекомендуется консультация с врачом.'
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки склонности к шизофрении. Рекомендуется обратиться к психотерапевту или психиатру.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Серьезные признаки склонности к шизофрении. Срочная консультация с врачом психиатром обязательна.'
        };
      }
    },
  ),
  'bipolar': TestConfig(
    name: 'Биполярное расстройство',
    testName: 'bipolar',
    category: 'Личностные расстройства',
    description: 'Тест помогает выявить возможные признаки маниакально-депрессивного расстройства, включая периоды гиперактивности и депрессии.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 10) {
        return {
          'Итог': totalScore,
          'Результат': 'Нет выраженных признаков биполярного расстройства. Возможно, стоит следить за своим психоэмоциональным состоянием.'
        };
      } else if (totalScore <= 20) {
        return {
          'Итог': totalScore,
          'Результат': 'Умеренные признаки биполярного расстройства. Рекомендуется консультация с психотерапевтом.'
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки биполярного расстройства. Обратитесь к психотерапевту или психиатру для диагностики и лечения.'
        };
      }
    },
  ),
  'borderline': TestConfig(
    name: 'Пограничное расстройство личности',
    testName: 'borderline',
    category: 'Личностные расстройства',
    description: 'Этот тест помогает выявить признаки пограничного расстройства личности. Если ваш балл высок, рекомендуется обратиться к психотерапевту для дальнейшей диагностики.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат':  'У вас нет выраженных признаков пограничного расстройства личности.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат':  'Умеренные признаки пограничного расстройства личности. Возможно, стоит обратить внимание на свои эмоциональные реакции.',
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат':  'Выраженные признаки пограничного расстройства личности. Рекомендуется консультация с психотерапевтом для дальнейшего обследования.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат':  'Очень выраженные признаки пограничного расстройства личности. Обратитесь к специалисту для диагностики и разработки плана лечения.',
        };
      }
    },
  ),
  'psycho': TestConfig(
    name: 'Психопатия',
    testName: 'psycho',
    category: 'Личностные расстройства',
    description: 'Этот тест помогает выявить признаки психопатии, которые могут быть связаны с антисоциальным поведением и нарушением норм морали. Высокий балл может указывать на необходимость консультации с психиатром.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат': 'У вас нет выраженных признаков психопатии.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат':  'Умеренные признаки психопатии. Возможно, вам стоит обратить внимание на свои взаимоотношения с окружающими.',
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки психопатии. Рекомендуется обратиться к специалисту для диагностики и корректировки поведения.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат':  'Очень выраженные признаки психопатии. Срочная консультация с психотерапевтом или психиатром обязательна.',
        };
      }
    },
  ),
  'dissociative': TestConfig(
    name: 'Диссоциативное расстройство',
    testName: 'dissociative',
    category: 'Личностные расстройства',
    description: 'Этот тест помогает выявить признаки диссоциативного расстройства личности, которое может проявляться в виде смены личностей или потери памяти. При высоком балле рекомендуется обратиться к специалисту.',
    calculateResults: (answers) {
      int totalScore = 0;

      answers.forEach((questionIndex, score) {
        totalScore += score;
      });

      if (totalScore <= 15) {
        return {
          'Итог': totalScore,
          'Результат':  'У вас нет выраженных признаков диссоциативного расстройства личности.',
        };
      } else if (totalScore <= 30) {
        return {
          'Итог': totalScore,
          'Результат':  'Умеренные признаки диссоциативного расстройства личности. Возможно, стоит обратить внимание на ваше эмоциональное состояние.',
        };
      } else if (totalScore <= 45) {
        return {
          'Итог': totalScore,
          'Результат': 'Выраженные признаки диссоциативного расстройства личности. Рекомендуется консультация с психотерапевтом или психиатром.',
        };
      } else {
        return {
          'Итог': totalScore,
          'Результат':  'Очень выраженные признаки диссоциативного расстройства личности. Срочная консультация с врачом или психотерапевтом обязательна.',
        };
      }
    },
  ),
};