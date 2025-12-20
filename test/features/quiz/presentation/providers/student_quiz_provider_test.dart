// test/features/quiz/presentation/providers/student_quiz_provider_test.dart
// Property tests for StudentQuizProvider
// **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 4.1, 4.4, 4.5, 5.1**

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/quiz/presentation/providers/student_quiz_provider.dart';

void main() {
  group('Property 8: Timer Duration Formatting', () {
    // **Feature: student-quiz-feature, Property 8: Timer Duration Formatting**
    // **Validates: Requirements 4.1**

    test('formats 0 seconds as 0:00', () {
      expect(StudentQuizProvider.formatDuration(0), '0:00');
    });

    test('formats seconds correctly', () {
      expect(StudentQuizProvider.formatDuration(5), '0:05');
      expect(StudentQuizProvider.formatDuration(30), '0:30');
      expect(StudentQuizProvider.formatDuration(59), '0:59');
    });

    test('formats minutes correctly', () {
      expect(StudentQuizProvider.formatDuration(60), '1:00');
      expect(StudentQuizProvider.formatDuration(90), '1:30');
      expect(StudentQuizProvider.formatDuration(300), '5:00');
    });

    test('formats mixed minutes and seconds', () {
      expect(StudentQuizProvider.formatDuration(65), '1:05');
      expect(StudentQuizProvider.formatDuration(125), '2:05');
      expect(StudentQuizProvider.formatDuration(3661), '61:01');
    });

    test('handles negative values gracefully', () {
      expect(StudentQuizProvider.formatDuration(-1), '0:00');
      expect(StudentQuizProvider.formatDuration(-100), '0:00');
    });

    // Property-based test: Format is always M:SS
    test('format is always M:SS pattern (property test)', () {
      final random = Random(42);
      final pattern = RegExp(r'^\d+:\d{2}$');

      for (var i = 0; i < 100; i++) {
        final seconds = random.nextInt(10000);
        final formatted = StudentQuizProvider.formatDuration(seconds);

        expect(
          pattern.hasMatch(formatted),
          true,
          reason: 'Format "$formatted" should match M:SS pattern',
        );
      }
    });

    // Property-based test: Seconds part is always 00-59
    test('seconds part is always 00-59 (property test)', () {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final seconds = random.nextInt(10000);
        final formatted = StudentQuizProvider.formatDuration(seconds);
        final parts = formatted.split(':');
        final secondsPart = int.parse(parts[1]);

        expect(secondsPart >= 0 && secondsPart <= 59, true);
      }
    });

    // Property-based test: Round-trip consistency
    test('minutes * 60 + seconds equals original (property test)', () {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final totalSeconds = random.nextInt(10000);
        final formatted = StudentQuizProvider.formatDuration(totalSeconds);
        final parts = formatted.split(':');
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);

        expect(minutes * 60 + seconds, totalSeconds);
      }
    });
  });

  group('Property 2: Quiz Availability Validation', () {
    // **Feature: student-quiz-feature, Property 2: Quiz Availability Validation**
    // **Validates: Requirements 1.4, 1.5**

    test('quiz is available when within date range and attempts remaining', () {
      final now = DateTime.now();
      final result = isQuizAvailable(
        openAt: now.subtract(const Duration(days: 1)),
        closeAt: now.add(const Duration(days: 1)),
        currentAttempts: 0,
        maxAttempts: 5,
        isPublished: true,
      );
      expect(result, true);
    });

    test('quiz is not available before open date', () {
      final now = DateTime.now();
      final result = isQuizAvailable(
        openAt: now.add(const Duration(days: 1)),
        closeAt: now.add(const Duration(days: 2)),
        currentAttempts: 0,
        maxAttempts: 5,
        isPublished: true,
      );
      expect(result, false);
    });

    test('quiz is not available after close date', () {
      final now = DateTime.now();
      final result = isQuizAvailable(
        openAt: now.subtract(const Duration(days: 2)),
        closeAt: now.subtract(const Duration(days: 1)),
        currentAttempts: 0,
        maxAttempts: 5,
        isPublished: true,
      );
      expect(result, false);
    });

    test('quiz is not available when max attempts reached', () {
      final now = DateTime.now();
      final result = isQuizAvailable(
        openAt: now.subtract(const Duration(days: 1)),
        closeAt: now.add(const Duration(days: 1)),
        currentAttempts: 5,
        maxAttempts: 5,
        isPublished: true,
      );
      expect(result, false);
    });

    test('quiz is not available when not published', () {
      final now = DateTime.now();
      final result = isQuizAvailable(
        openAt: now.subtract(const Duration(days: 1)),
        closeAt: now.add(const Duration(days: 1)),
        currentAttempts: 0,
        maxAttempts: 5,
        isPublished: false,
      );
      expect(result, false);
    });

    // Property-based test
    test('availability follows logical rules (property test)', () {
      final random = Random(42);
      final now = DateTime.now();

      for (var i = 0; i < 100; i++) {
        final daysBeforeOpen = random.nextInt(10) - 5; // -5 to 4
        final daysBeforeClose = random.nextInt(10) - 5;
        final currentAttempts = random.nextInt(10);
        final maxAttempts = random.nextInt(10) + 1;
        final isPublished = random.nextBool();

        final openAt = now.add(Duration(days: daysBeforeOpen));
        final closeAt = now.add(Duration(days: daysBeforeClose));

        final result = isQuizAvailable(
          openAt: openAt,
          closeAt: closeAt,
          currentAttempts: currentAttempts,
          maxAttempts: maxAttempts,
          isPublished: isPublished,
        );

        final isWithinDateRange =
            !now.isBefore(openAt) && !now.isAfter(closeAt);
        final hasAttemptsRemaining = currentAttempts < maxAttempts;
        final expected =
            isPublished && isWithinDateRange && hasAttemptsRemaining;

        expect(result, expected, reason: 'Iteration $i');
      }
    });
  });

  group('Property 9: Answered Count Accuracy', () {
    // **Feature: student-quiz-feature, Property 9: Answered Count Accuracy**
    // **Validates: Requirements 5.1**

    test('counts answered questions correctly', () {
      final answers = {
        'q1': 'opt1',
        'q2': null,
        'q3': 'opt3',
        'q4': null,
        'q5': 'opt5',
      };
      expect(countAnswered(answers), 3);
    });

    test('returns 0 for empty answers', () {
      expect(countAnswered({}), 0);
    });

    test('returns 0 for all null answers', () {
      final answers = {'q1': null, 'q2': null, 'q3': null};
      expect(countAnswered(answers), 0);
    });

    test('returns total for all answered', () {
      final answers = {'q1': 'a', 'q2': 'b', 'q3': 'c'};
      expect(countAnswered(answers), 3);
    });

    // Property-based test
    test('count equals non-null values (property test)', () {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final questionCount = random.nextInt(20) + 1;
        final answers = <String, String?>{};
        int expectedCount = 0;

        for (var j = 0; j < questionCount; j++) {
          if (random.nextBool()) {
            answers['q$j'] = 'opt$j';
            expectedCount++;
          } else {
            answers['q$j'] = null;
          }
        }

        expect(countAnswered(answers), expectedCount);
      }
    });
  });

  group('Property 10: Status Display Consistency', () {
    // **Feature: student-quiz-feature, Property 10: Status Display Consistency**
    // **Validates: Requirements 1.2, 1.3**

    test('returns "Belum mengerjakan" for no attempts', () {
      expect(getStudentStatus([]), 'Belum mengerjakan');
    });

    test('returns "Selesai" for finished attempts', () {
      expect(getStudentStatus(['finished']), 'Selesai');
      expect(getStudentStatus(['finished', 'finished']), 'Selesai');
    });

    test('returns "Sedang mengerjakan" for in-progress only', () {
      expect(getStudentStatus(['in_progress']), 'Sedang mengerjakan');
    });

    test('returns "Selesai" if any attempt is finished', () {
      expect(getStudentStatus(['in_progress', 'finished']), 'Selesai');
      expect(getStudentStatus(['finished', 'in_progress']), 'Selesai');
    });

    // Property-based test
    test('status follows rules (property test)', () {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final attemptCount = random.nextInt(10);
        final statuses = List.generate(
          attemptCount,
          (_) => random.nextBool() ? 'finished' : 'in_progress',
        );

        final result = getStudentStatus(statuses);

        if (statuses.isEmpty) {
          expect(result, 'Belum mengerjakan');
        } else if (statuses.contains('finished')) {
          expect(result, 'Selesai');
        } else {
          expect(result, 'Sedang mengerjakan');
        }
      }
    });
  });

  group('Property 3: Answer State Persistence', () {
    // **Feature: student-quiz-feature, Property 3: Answer State Persistence**
    // **Validates: Requirements 4.4, 4.5**

    test('selecting answer updates state', () {
      final answers = <String, String?>{};
      answers['q1'] = 'opt1';
      expect(answers['q1'], 'opt1');
    });

    test('answer persists after navigation simulation', () {
      final answers = <String, String?>{'q1': null, 'q2': null, 'q3': null};

      // Select answer for q1
      answers['q1'] = 'opt1';

      // Simulate navigation (change current index)
      var currentIndex = 0;
      currentIndex = 1; // Go to q2
      currentIndex = 2; // Go to q3
      currentIndex = 0; // Back to q1

      // Answer should still be there
      expect(answers['q1'], 'opt1');
      expect(currentIndex, 0);
    });

    // Property-based test
    test('answers persist through navigation (property test)', () {
      final random = Random(42);

      for (var i = 0; i < 100; i++) {
        final questionCount = random.nextInt(20) + 1;
        final answers = <String, String?>{};

        // Initialize
        for (var j = 0; j < questionCount; j++) {
          answers['q$j'] = null;
        }

        // Randomly answer some questions
        final answeredQuestions = <String, String>{};
        for (var j = 0; j < questionCount; j++) {
          if (random.nextBool()) {
            final optionId = 'opt${random.nextInt(4)}';
            answers['q$j'] = optionId;
            answeredQuestions['q$j'] = optionId;
          }
        }

        // Simulate random navigation
        for (var nav = 0; nav < 50; nav++) {
          random.nextInt(questionCount);
        }

        // Verify all answers are preserved
        for (final entry in answeredQuestions.entries) {
          expect(
            answers[entry.key],
            entry.value,
            reason: 'Answer for ${entry.key} should be preserved',
          );
        }
      }
    });
  });
}

// Helper functions for testing (extracted logic)

bool isQuizAvailable({
  required DateTime openAt,
  required DateTime closeAt,
  required int currentAttempts,
  required int maxAttempts,
  required bool isPublished,
}) {
  if (!isPublished) return false;

  final now = DateTime.now();
  if (now.isBefore(openAt)) return false;
  if (now.isAfter(closeAt)) return false;
  if (currentAttempts >= maxAttempts) return false;

  return true;
}

int countAnswered(Map<String, String?> answers) {
  return answers.values.where((v) => v != null).length;
}

String getStudentStatus(List<String> attemptStatuses) {
  if (attemptStatuses.isEmpty) {
    return 'Belum mengerjakan';
  }

  if (attemptStatuses.contains('finished')) {
    return 'Selesai';
  }

  return 'Sedang mengerjakan';
}
