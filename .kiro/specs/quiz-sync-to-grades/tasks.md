# Implementation Plan - Add Quiz Sync to Grades

## Overview

This implementation plan provides a series of discrete, manageable tasks to ensure quiz scores are automatically synced to the grades table when a quiz is submitted.

---

## Task List

- [ ] 1. Review Current Quiz Sync Implementation
  - [ ] 1.1 Examine StudentQuizService.submitAttempt() method
    - Check file: lib/features/quiz/data/services/student_quiz_service.dart
    - Verify score calculation logic
    - Verify GradesService.syncGradeFromQuiz() is called
    - _Requirements: 1.1, 1.2_
  
  - [ ] 1.2 Verify QuizAttemptModel has score field
    - Check file: lib/features/quiz/data/models/quiz_attempt_model.dart
    - Verify score property exists
    - Verify max_score property exists
    - Verify percentage property exists
    - _Requirements: 2.1_

- [ ] 2. Verify Score Calculation
  - [ ] 2.1 Test score calculation with 100% correct
    - Create quiz with 10 questions
    - Answer all 10 correctly
    - Verify score = 100%
    - _Requirements: 3.1_
  
  - [ ] 2.2 Test score calculation with 50% correct
    - Create quiz with 10 questions
    - Answer 5 correctly
    - Verify score = 50%
    - _Requirements: 3.2_
  
  - [ ] 2.3 Test score calculation with 0% correct
    - Create quiz with 10 questions
    - Answer 0 correctly
    - Verify score = 0%
    - _Requirements: 3.3_
  
  - [ ] 2.4 Verify score formula
    - Verify formula: (correctCount / totalQuestions) * 100
    - Verify rounding to 2 decimal places
    - _Requirements: 3.4, 3.5_

- [ ] 3. Verify Error Handling
  - [ ] 3.1 Test error handling for quiz not found
    - Attempt to sync grade for non-existent quiz
    - Verify error is handled gracefully
    - Verify quiz submission still succeeds
    - _Requirements: 4.1_
  
  - [ ] 3.2 Test error handling for student not enrolled
    - Attempt to sync grade for student not in class
    - Verify error is handled gracefully
    - Verify quiz submission still succeeds
    - _Requirements: 4.2_
  
  - [ ] 3.3 Test error handling for database error
    - Simulate database connection failure
    - Verify error is handled gracefully
    - Verify quiz submission still succeeds
    - _Requirements: 4.3_
  
  - [ ] 3.4 Verify grade sync doesn't fail quiz submission
    - Cause grade sync to fail
    - Verify quiz submission still succeeds
    - Verify student can see quiz result
    - _Requirements: 4.4_
  
  - [ ] 3.5 Verify error logging
    - Trigger various errors
    - Check logs for error details
    - Verify logs don't include sensitive data
    - _Requirements: 4.5_

- [ ] 4. Verify Logging
  - [ ] 4.1 Verify quiz submission logging
    - Submit quiz
    - Check logs for "Quiz submitted: [quizId]"
    - _Requirements: 5.1_
  
  - [ ] 4.2 Verify grade sync start logging
    - Submit quiz
    - Check logs for "Syncing grade for quiz: [quizTitle]"
    - _Requirements: 5.2_
  
  - [ ] 4.3 Verify grade sync success logging
    - Submit quiz successfully
    - Check logs for "Grade synced successfully"
    - _Requirements: 5.3_
  
  - [ ] 4.4 Verify grade sync error logging
    - Cause grade sync to fail
    - Check logs for error message with details
    - _Requirements: 5.4_
  
  - [ ] 4.5 Verify no sensitive data in logs
    - Review all logs
    - Verify no student names, emails, or IDs in logs
    - _Requirements: 5.5_

- [ ] 5. Write Unit Tests
  - [ ] 5.1 Test quiz submission calls sync
    - Mock GradesService
    - Submit quiz
    - Verify syncGradeFromQuiz() was called
    - _Requirements: 6.1_
  
  - [ ] 5.2 Test score calculation
    - Test with various correct/incorrect counts
    - Verify score calculated correctly
    - _Requirements: 6.2_
  
  - [ ] 5.3 Test error handling
    - Test each error scenario
    - Verify errors handled gracefully
    - _Requirements: 6.3_
  
  - [ ] 5.4 Test with various score values
    - Test with 0%, 25%, 50%, 75%, 100%
    - Verify all calculated correctly
    - _Requirements: 6.4_
  
  - [ ] 5.5 Achieve 80%+ code coverage
    - Run coverage report
    - Verify 80%+ coverage for quiz sync code
    - _Requirements: 6.5_

- [ ] 6. Write Integration Tests
  - [ ] 6.1 Test complete quiz to grades flow
    - Create quiz
    - Student submits quiz
    - Verify grade recorded in grades table
    - _Requirements: 7.1_
  
  - [ ] 6.2 Verify grade appears in grades table
    - Submit quiz
    - Query grades table
    - Verify grade record exists
    - _Requirements: 7.2_
  
  - [ ] 6.3 Verify grade has correct values
    - Submit quiz with known score
    - Query grades table
    - Verify all values correct (student_id, class_id, item_id, item_type, score, max_score, percentage)
    - _Requirements: 7.3_
  
  - [ ] 6.4 Test with multiple attempts
    - Student takes quiz twice
    - Verify both attempts tracked
    - Verify most recent is returned
    - _Requirements: 7.4_
  
  - [ ] 6.5 Test with different score values
    - Test with 0%, 50%, 100%
    - Verify all grades recorded correctly
    - _Requirements: 7.5_

- [ ] 7. Test Multiple Attempts Handling
  - [ ] 7.1 Test separate grade records for each attempt
    - Student takes quiz twice
    - Verify two grade records created
    - _Requirements: 8.1_
  
  - [ ] 7.2 Test grade update on retake
    - Student takes quiz, gets 80%
    - Student retakes quiz, gets 90%
    - Verify grade updated to 90%
    - _Requirements: 8.2_
  
  - [ ] 7.3 Test all attempts tracked
    - Student takes quiz 3 times
    - Query grades table
    - Verify all 3 attempts tracked
    - _Requirements: 8.3_
  
  - [ ] 7.4 Test most recent attempt returned
    - Student takes quiz multiple times
    - Query grades
    - Verify most recent attempt returned
    - _Requirements: 8.4_
  
  - [ ] 7.5 Test average includes all attempts
    - Student takes quiz 3 times: 80%, 90%, 70%
    - Calculate average
    - Verify average = 80%
    - _Requirements: 8.5_

- [ ] 8. Performance Testing
  - [ ] 8.1 Test sync completes within 1 second
    - Submit quiz
    - Measure grade sync time
    - Verify < 1 second
    - _Requirements: 9.1_
  
  - [ ] 8.2 Test sync doesn't block submission
    - Submit quiz
    - Verify quiz result returned immediately
    - Verify grade sync happens in background
    - _Requirements: 9.2_
  
  - [ ] 8.3 Test efficient database queries
    - Review GradesService queries
    - Verify minimal database round trips
    - _Requirements: 9.3, 9.4_
  
  - [ ] 8.4 Test concurrent requests
    - Submit multiple quizzes concurrently
    - Verify all grades synced correctly
    - _Requirements: 9.5_

- [ ] 9. Test Backwards Compatibility
  - [ ] 9.1 Test quiz without classId
    - Create quiz without classId
    - Student submits quiz
    - Verify grade sync skipped gracefully
    - Verify quiz submission succeeds
    - _Requirements: 10.1_
  
  - [ ] 9.2 Test old system quizzes
    - Test with quizzes from old system
    - Verify handled gracefully
    - _Requirements: 10.2_
  
  - [ ] 9.3 Test student not in class
    - Student not enrolled in class
    - Student submits quiz
    - Verify handled gracefully
    - _Requirements: 10.3_
  
  - [ ] 9.4 Test grade sync unavailable
    - Disable grade sync
    - Student submits quiz
    - Verify quiz submission succeeds
    - _Requirements: 10.4_
  
  - [ ] 9.5 Test system update compatibility
    - Update system
    - Verify existing quizzes still work
    - _Requirements: 10.5_

- [ ] 10. Property-Based Testing
  - [ ] 10.1 Write property test for quiz sync automatic trigger
    - **Feature: quiz-sync-to-grades, Property 1: Quiz Sync Automatic Trigger**
    - **Validates: Requirements 1.1, 1.2**
    - Generate random quiz submissions
    - Verify sync called automatically
    - Run 100+ iterations
  
  - [ ] 10.2 Write property test for score calculation accuracy
    - **Feature: quiz-sync-to-grades, Property 2: Score Calculation Accuracy**
    - **Validates: Requirements 3.1-3.5**
    - Generate random correct/total counts
    - Verify score calculated correctly
    - Run 100+ iterations
  
  - [ ] 10.3 Write property test for grade sync non-blocking
    - **Feature: quiz-sync-to-grades, Property 3: Grade Sync Non-Blocking**
    - **Validates: Requirements 1.4, 1.5**
    - Generate random sync failures
    - Verify submission still succeeds
    - Run 100+ iterations
  
  - [ ] 10.4 Write property test for error logging
    - **Feature: quiz-sync-to-grades, Property 4: Error Logging**
    - **Validates: Requirements 5.1-5.5**
    - Generate random errors
    - Verify logging correct
    - Run 100+ iterations
  
  - [ ] 10.5 Write property test for multiple attempts tracking
    - **Feature: quiz-sync-to-grades, Property 5: Multiple Attempts Tracking**
    - **Validates: Requirements 8.1-8.5**
    - Generate random multiple attempts
    - Verify all tracked correctly
    - Run 100+ iterations
  
  - [ ] 10.6 Write property test for performance guarantee
    - **Feature: quiz-sync-to-grades, Property 6: Performance Guarantee**
    - **Validates: Requirements 9.1-9.5**
    - Generate random submissions
    - Verify sync completes within 1 second
    - Run 100+ iterations
  
  - [ ] 10.7 Write property test for backwards compatibility
    - **Feature: quiz-sync-to-grades, Property 7: Backwards Compatibility**
    - **Validates: Requirements 10.1-10.5**
    - Generate random old/new quizzes
    - Verify all handled correctly
    - Run 100+ iterations
  
  - [ ] 10.8 Write property test for score validation
    - **Feature: quiz-sync-to-grades, Property 8: Score Validation**
    - **Validates: Requirements 3.1-3.5**
    - Generate random scores
    - Verify all between 0-100
    - Run 100+ iterations

- [ ] 11. Checkpoint - Verify All Tests Pass
  - Ensure all unit tests pass
  - Ensure all property-based tests pass
  - Ensure all integration tests pass
  - Ask the user if questions arise

- [ ] 12. Final Checkpoint - All Tests Pass
  - Ensure all tests pass
  - Ensure all requirements met
  - Ask the user if questions arise

