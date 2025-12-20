// test/features/quiz/presentation/providers/quiz_provider_test.dart
import 'dart:math';
import 'package:test/test.dart';
import 'package:gabara_mobile/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gabara_mobile/features/quiz/data/services/quiz_service.dart';

// Mock QuizService for testing
class MockQuizService extends QuizService {
  MockQuizService() : super(_createMockClient());

  static SupabaseClient _createMockClient() {
    // This won't be used in unit tests
    throw UnimplementedError('Mock client not needed for unit tests');
  }
}

// Test-only QuizProvider that doesn't require QuizService
class TestableQuizProvider extends QuizProvider {
  TestableQuizProvider() : super(_createDummyService());

  static QuizService _createDummyService() {
    // Create a minimal service - won't be used in builder tests
    return _DummyQuizService();
  }
}

class _DummyQuizService extends QuizService {
  _DummyQuizService() : super(_DummySupabaseClient());
}

class _DummySupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('QuizProvider Question Builder', () {
    late TestableQuizProvider provider;

    setUp(() {
      provider = TestableQuizProvider();
    });

    /// **Feature: quiz-mentor-feature, Property 2: Question addition increases count**
    /// *For any* quiz builder state with N questions, adding a new question
    /// SHALL result in exactly N+1 questions in the list.
    /// **Validates: Requirements 2.6**
    test(
      'Property 2: Adding question increases count by 1 (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          // Start with random number of questions (0-10)
          provider.initBuilder();
          final initialAdditions = random.nextInt(10);
          for (var j = 0; j < initialAdditions; j++) {
            provider.addQuestion();
          }

          final countBefore = provider.builderQuestions.length;

          // Add one question
          provider.addQuestion();

          final countAfter = provider.builderQuestions.length;

          expect(
            countAfter,
            equals(countBefore + 1),
            reason:
                'Adding question should increase count by 1 at iteration $i',
          );
        }
      },
    );

    /// **Feature: quiz-mentor-feature, Property 3: Question removal decreases count**
    /// *For any* quiz builder state with N questions where N > 1,
    /// removing a question SHALL result in exactly N-1 questions in the list.
    /// **Validates: Requirements 2.7**
    test(
      'Property 3: Removing question decreases count by 1 (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          // Start with at least 2 questions
          provider.initBuilder();
          final additionalQuestions = random.nextInt(9) + 1; // 1-9 more
          for (var j = 0; j < additionalQuestions; j++) {
            provider.addQuestion();
          }

          final countBefore = provider.builderQuestions.length;
          expect(
            countBefore,
            greaterThan(1),
            reason: 'Should have more than 1 question',
          );

          // Remove random question
          final indexToRemove = random.nextInt(countBefore);
          provider.removeQuestion(indexToRemove);

          final countAfter = provider.builderQuestions.length;

          expect(
            countAfter,
            equals(countBefore - 1),
            reason:
                'Removing question should decrease count by 1 at iteration $i',
          );
        }
      },
    );

    test('initBuilder creates one empty question', () {
      provider.initBuilder();
      expect(provider.builderQuestions.length, equals(1));
      expect(provider.builderQuestions[0].question, isEmpty);
      expect(
        provider.builderQuestions[0].questionType,
        equals('multiple_choice'),
      );
    });

    test('clearBuilder removes all questions', () {
      provider.initBuilder();
      provider.addQuestion();
      provider.addQuestion();
      expect(provider.builderQuestions.length, equals(3));

      provider.clearBuilder();
      expect(provider.builderQuestions.length, equals(0));
    });
  });

  group('QuizProvider Option Management', () {
    late TestableQuizProvider provider;

    setUp(() {
      provider = TestableQuizProvider();
      provider.initBuilder();
    });

    /// **Feature: quiz-mentor-feature, Property 12: Option addition increases count**
    /// *For any* multiple choice question with N options,
    /// adding an option SHALL result in exactly N+1 options.
    /// **Validates: Requirements 5.2**
    test(
      'Property 12: Adding option increases count by 1 (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          provider.initBuilder();

          // Add random number of options (0-5)
          final initialAdditions = random.nextInt(5);
          for (var j = 0; j < initialAdditions; j++) {
            provider.addOption(0);
          }

          final countBefore = provider.builderQuestions[0].optionModels.length;

          // Add one option
          provider.addOption(0);

          final countAfter = provider.builderQuestions[0].optionModels.length;

          expect(
            countAfter,
            equals(countBefore + 1),
            reason: 'Adding option should increase count by 1 at iteration $i',
          );
        }
      },
    );

    /// **Feature: quiz-mentor-feature, Property 13: Option removal decreases count**
    /// *For any* multiple choice question with N options where N > 2,
    /// removing an option SHALL result in exactly N-1 options.
    /// **Validates: Requirements 5.3**
    test(
      'Property 13: Removing option decreases count by 1 (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          provider.initBuilder();

          // Add options to have at least 3
          final additionalOptions = random.nextInt(5) + 1; // 1-5 more
          for (var j = 0; j < additionalOptions; j++) {
            provider.addOption(0);
          }

          final countBefore = provider.builderQuestions[0].optionModels.length;
          expect(
            countBefore,
            greaterThan(2),
            reason: 'Should have more than 2 options',
          );

          // Remove random option
          final indexToRemove = random.nextInt(countBefore);
          provider.removeOption(0, indexToRemove);

          final countAfter = provider.builderQuestions[0].optionModels.length;

          expect(
            countAfter,
            equals(countBefore - 1),
            reason:
                'Removing option should decrease count by 1 at iteration $i',
          );
        }
      },
    );

    /// **Feature: quiz-mentor-feature, Property 7: Single correct answer invariant**
    /// *For any* multiple choice question, selecting an option as correct
    /// SHALL mark exactly one option as correct and all others as not correct.
    /// **Validates: Requirements 5.4**
    test(
      'Property 7: Only one option is correct after setCorrectOption (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          provider.initBuilder();

          // Add random number of options (0-5)
          final additionalOptions = random.nextInt(5);
          for (var j = 0; j < additionalOptions; j++) {
            provider.addOption(0);
          }

          final optionCount = provider.builderQuestions[0].optionModels.length;

          // Set random option as correct
          final correctIndex = random.nextInt(optionCount);
          provider.setCorrectOption(0, correctIndex);

          // Count correct options
          final correctCount = provider.builderQuestions[0].optionModels
              .where((o) => o.isCorrect)
              .length;

          expect(
            correctCount,
            equals(1),
            reason: 'Exactly one option should be correct at iteration $i',
          );

          // Verify the correct one is at the expected index
          expect(
            provider.builderQuestions[0].optionModels[correctIndex].isCorrect,
            isTrue,
            reason:
                'Option at index $correctIndex should be correct at iteration $i',
          );
        }
      },
    );

    test('changeQuestionType to true_false sets Benar/Salah options', () {
      provider.changeQuestionType(0, 'true_false');

      final question = provider.builderQuestions[0];
      expect(question.questionType, equals('true_false'));
      expect(question.optionModels.length, equals(2));
      expect(question.optionModels[0].text, equals('Benar'));
      expect(question.optionModels[1].text, equals('Salah'));
    });

    test('changeQuestionType to multiple_choice resets to empty options', () {
      provider.changeQuestionType(0, 'true_false');
      provider.changeQuestionType(0, 'multiple_choice');

      final question = provider.builderQuestions[0];
      expect(question.questionType, equals('multiple_choice'));
      expect(question.optionModels.length, equals(2));
      expect(question.optionModels[0].text, isEmpty);
      expect(question.optionModels[1].text, isEmpty);
    });

    test('updateOptionText updates the correct option', () {
      provider.updateOptionText(0, 0, 'New Option Text');
      expect(
        provider.builderQuestions[0].optionModels[0].text,
        equals('New Option Text'),
      );
    });

    test('updateQuestionText updates the question', () {
      provider.updateQuestionText(0, 'What is 2+2?');
      expect(provider.builderQuestions[0].question, equals('What is 2+2?'));
    });
  });
}
