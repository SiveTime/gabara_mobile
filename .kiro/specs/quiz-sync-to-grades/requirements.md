# Requirements Document - Add Quiz Sync to Grades

## Introduction

This specification focuses on ensuring quiz scores are automatically synced to the grades table when a quiz is submitted. The goal is to create a seamless integration between the quiz system and the grades tracking system, ensuring that all quiz results are immediately available in the grades dashboard.

## Glossary

- **Quiz Submission**: When a student completes and submits a quiz
- **Quiz Attempt**: A single attempt by a student to complete a quiz
- **Quiz Score**: The number of correct answers out of total questions
- **Grade Sync**: Process of recording quiz score to grades table
- **Automatic Sync**: Sync triggered automatically without manual intervention
- **StudentQuizService**: Service handling student quiz operations
- **GradesService**: Service handling grade operations
- **Quiz Attempt Model**: Data model representing a quiz attempt
- **Grade Record**: Entry in grades table for a quiz

## Requirements

### Requirement 1: Quiz Submission Sync Trigger

**User Story:** As a system, I want quiz scores to be automatically synced when a student submits a quiz, so that grades are immediately available in the dashboard.

#### Acceptance Criteria

1. WHEN a student submits a quiz THEN the System SHALL automatically call GradesService.syncGradeFromQuiz()
2. WHEN GradesService.syncGradeFromQuiz() is called THEN the System SHALL pass: studentId, classId, quizId, score, maxScore, quizTitle
3. WHEN quiz submission is successful THEN the System SHALL create or update grade record in grades table
4. WHEN quiz submission fails THEN the System SHALL log error but not fail the quiz submission
5. WHEN grade sync fails THEN the System SHALL allow student to see quiz result anyway

### Requirement 2: Quiz Attempt Tracking

**User Story:** As a developer, I want to verify quiz attempts are properly tracked with scores, so that grades can be synced accurately.

#### Acceptance Criteria

1. WHEN a quiz attempt is created THEN the System SHALL have score field in QuizAttemptModel
2. WHEN a quiz is submitted THEN the System SHALL calculate score from correct answers
3. WHEN score is calculated THEN the System SHALL use formula: correctCount / totalQuestions
4. WHEN score is calculated THEN the System SHALL store in quiz_attempts table
5. WHEN score is stored THEN the System SHALL pass to sync method

### Requirement 3: Score Calculation Verification

**User Story:** As a developer, I want to verify score calculations are correct, so that grades reflect accurate performance.

#### Acceptance Criteria

1. WHEN a student answers all questions correctly THEN the System SHALL calculate score = 100%
2. WHEN a student answers half correctly THEN the System SHALL calculate score = 50%
3. WHEN a student answers no questions correctly THEN the System SHALL calculate score = 0%
4. WHEN calculating score THEN the System SHALL use formula: (correctCount / totalQuestions) * 100
5. WHEN score is calculated THEN the System SHALL round to 2 decimal places

### Requirement 4: Error Handling

**User Story:** As a developer, I want proper error handling in quiz sync, so that issues are caught and reported.

#### Acceptance Criteria

1. WHEN quiz not found THEN the System SHALL handle gracefully and log error
2. WHEN student not enrolled in class THEN the System SHALL handle gracefully and log error
3. WHEN database error occurs THEN the System SHALL handle gracefully and log error
4. WHEN grade sync fails THEN the System SHALL not prevent quiz submission
5. WHEN error occurs THEN the System SHALL log error details for debugging

### Requirement 5: Logging and Debugging

**User Story:** As a developer, I want detailed logging of quiz sync operations, so that I can debug issues.

#### Acceptance Criteria

1. WHEN quiz is submitted THEN the System SHALL log "Quiz submitted: [quizId]"
2. WHEN grade sync starts THEN the System SHALL log "Syncing grade for quiz: [quizTitle]"
3. WHEN grade sync succeeds THEN the System SHALL log "Grade synced successfully"
4. WHEN grade sync fails THEN the System SHALL log error message with details
5. WHEN logging THEN the System SHALL not include sensitive student data

### Requirement 6: Unit Testing

**User Story:** As a developer, I want unit tests for quiz sync, so that functionality is verified.

#### Acceptance Criteria

1. WHEN running unit tests THEN the System SHALL test quiz submission calls sync
2. WHEN running unit tests THEN the System SHALL test score calculation
3. WHEN running unit tests THEN the System SHALL test error handling
4. WHEN running unit tests THEN the System SHALL test with various score values
5. WHEN running unit tests THEN the System SHALL achieve 80%+ code coverage

### Requirement 7: Integration Testing

**User Story:** As a developer, I want integration tests for complete quiz to grades flow, so that end-to-end functionality is verified.

#### Acceptance Criteria

1. WHEN running integration tests THEN the System SHALL test: Create quiz → Submit → Grade recorded
2. WHEN running integration tests THEN the System SHALL verify grade appears in grades table
3. WHEN running integration tests THEN the System SHALL verify grade has correct values
4. WHEN running integration tests THEN the System SHALL test with multiple attempts
5. WHEN running integration tests THEN the System SHALL test with different score values

### Requirement 8: Multiple Attempts Handling

**User Story:** As a system, I want to handle multiple quiz attempts correctly, so that each attempt is tracked separately.

#### Acceptance Criteria

1. WHEN student takes quiz multiple times THEN the System SHALL create separate grade records
2. WHEN student retakes quiz THEN the System SHALL update grade record for same quiz
3. WHEN student has multiple attempts THEN the System SHALL track all attempts
4. WHEN querying grades THEN the System SHALL return most recent attempt
5. WHEN calculating average THEN the System SHALL include all attempts

### Requirement 9: Performance Optimization

**User Story:** As a system, I want quiz sync to be performant, so that user experience is not impacted.

#### Acceptance Criteria

1. WHEN syncing grade THEN the System SHALL complete within 1 second
2. WHEN syncing grade THEN the System SHALL not block quiz submission
3. WHEN syncing grade THEN the System SHALL use efficient database queries
4. WHEN syncing grade THEN the System SHALL minimize database round trips
5. WHEN syncing grade THEN the System SHALL handle concurrent requests

### Requirement 10: Backwards Compatibility

**User Story:** As a system, I want quiz sync to be backwards compatible, so that existing quizzes continue to work.

#### Acceptance Criteria

1. WHEN quiz has no classId THEN the System SHALL skip grade sync gracefully
2. WHEN quiz is from old system THEN the System SHALL handle gracefully
3. WHEN student is not in class THEN the System SHALL handle gracefully
4. WHEN grade sync is not available THEN the System SHALL not fail quiz submission
5. WHEN system is updated THEN the System SHALL not break existing functionality

