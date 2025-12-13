# Design Document - Add Quiz Sync to Grades

## Overview

This design document outlines the implementation of automatic quiz score synchronization to the grades table. When a student submits a quiz, the system automatically creates or updates a grade record in the centralized grades table, making the score immediately available in the grades dashboard.

---

## Architecture

### Quiz Submission Flow

```
StudentQuizDetailPage (Student submits quiz)
  ↓
StudentQuizProvider.submitQuiz()
  ↓
StudentQuizService.submitAttempt()
  ├─ Calculate score from answers
  ├─ Update quiz_attempts table
  ├─ Call GradesService.syncGradeFromQuiz()
  │  ├─ Validate parameters
  │  ├─ Check for existing grade
  │  ├─ INSERT or UPDATE grades table
  │  └─ Return GradeModel
  ├─ Handle sync errors (log but don't fail)
  └─ Return QuizAttemptModel
  ↓
UI displays quiz result
  ↓
GradesProvider notified (via listener)
  ↓
Grades dashboard updates automatically
```

### Data Flow

```
Quiz Submission
  ↓
Score Calculation
  ├─ Count correct answers
  ├─ Calculate percentage: (correct / total) * 100
  └─ Store in quiz_attempts
  ↓
Grade Sync
  ├─ Extract: studentId, classId, quizId, score, maxScore
  ├─ Call GradesService.syncGradeFromQuiz()
  ├─ Create/Update grades table
  └─ Return GradeModel
  ↓
Error Handling
  ├─ Log any errors
  ├─ Don't fail quiz submission
  └─ Allow student to see result
  ↓
Grades Dashboard
  ├─ GradesProvider notified
  ├─ Refresh grades list
  └─ Display new grade
```

---

## Components and Interfaces

### 1. StudentQuizService.submitAttempt()

```dart
Future<QuizAttemptModel?> submitAttempt(
  String attemptId,
  Map<String, String?> answers,
  QuizModel quiz,
) async {
  // 1. Calculate score
  int correctCount = 0;
  final answerRecords = <Map<String, dynamic>>[];
  
  for (final question in quiz.questions) {
    final selectedOptionId = answers[question.id];
    bool? isCorrect;
    
    if (selectedOptionId != null) {
      final selectedOption = question.options.firstWhere(
        (o) => o.id == selectedOptionId,
      );
      isCorrect = selectedOption.isCorrect;
      if (isCorrect) correctCount++;
    }
    
    answerRecords.add({
      'attempt_id': attemptId,
      'question_id': question.id,
      'option_id': selectedOptionId,
      'is_correct': isCorrect,
    });
  }
  
  // 2. Insert answers
  if (answerRecords.isNotEmpty) {
    await supabaseClient.from('quiz_answers').insert(answerRecords);
  }
  
  // 3. Calculate percentage
  final percentage = quiz.questionCount > 0
    ? (correctCount / quiz.questionCount) * 100
    : 0.0;
  
  // 4. Update attempt
  await supabaseClient
    .from('quiz_attempts')
    .update({
      'submitted_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'submitted',
      'score': correctCount.toDouble(),
      'max_score': quiz.questionCount.toDouble(),
      'percentage': percentage,
    })
    .eq('id', attemptId);
  
  // 5. Sync grade to grades table
  if (quiz.classId != null) {
    try {
      final gradesService = GradesService(supabaseClient);
      await gradesService.syncGradeFromQuiz(
        studentId: user.id,
        classId: quiz.classId!,
        quizId: quiz.id,
        score: correctCount.toDouble(),
        maxScore: quiz.questionCount.toDouble(),
        quizTitle: quiz.title,
      );
      debugPrint('Grade synced for quiz: ${quiz.title}');
    } catch (gradeError) {
      debugPrint('Error syncing grade: $gradeError');
      // Don't fail quiz submission
    }
  }
  
  // 6. Return updated attempt
  return await fetchAttemptById(attemptId);
}
```

### 2. Error Handling Strategy

```dart
try {
  // Sync grade
  await gradesService.syncGradeFromQuiz(...);
} catch (e) {
  // Log error but don't fail
  debugPrint('Grade sync error: $e');
  // Continue with quiz submission
}
```

### 3. Logging Strategy

```dart
// Log quiz submission
debugPrint('Quiz submitted: $quizId');

// Log grade sync start
debugPrint('Syncing grade for quiz: ${quiz.title}');

// Log grade sync success
debugPrint('Grade synced successfully');

// Log grade sync error
debugPrint('Error syncing grade: $error');
```

---

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Quiz Sync Automatic Trigger

*For any* quiz submission by a student, the system SHALL automatically call GradesService.syncGradeFromQuiz() without manual intervention, creating a corresponding grade record.

**Validates: Requirements 1.1, 1.2**

### Property 2: Score Calculation Accuracy

*For any* quiz with N questions where student answers C correctly, the calculated score SHALL equal (C / N) * 100, rounded to 2 decimal places.

**Validates: Requirements 3.1-3.5**

### Property 3: Grade Sync Non-Blocking

*For any* quiz submission, if grade sync fails, the system SHALL still complete the quiz submission and return the quiz result to the student.

**Validates: Requirements 1.4, 1.5**

### Property 4: Error Logging

*For any* error during grade sync, the system SHALL log the error with sufficient detail for debugging without including sensitive student data.

**Validates: Requirements 5.1-5.5**

### Property 5: Multiple Attempts Tracking

*For any* student taking a quiz multiple times, each attempt SHALL create a separate grade record, and the most recent attempt SHALL be returned when querying grades.

**Validates: Requirements 8.1-8.5**

### Property 6: Performance Guarantee

*For any* grade sync operation, the operation SHALL complete within 1 second and SHALL not block the quiz submission process.

**Validates: Requirements 9.1-9.5**

### Property 7: Backwards Compatibility

*For any* quiz without a classId, the system SHALL skip grade sync gracefully without throwing an error or failing the quiz submission.

**Validates: Requirements 10.1-10.5**

### Property 8: Score Validation

*For any* quiz submission, the calculated score SHALL be between 0 and 100 (inclusive), and SHALL never be negative or exceed 100.

**Validates: Requirements 3.1-3.5**

---

## Error Handling

### Error Categories

1. **Quiz Not Found**
   - Handle gracefully
   - Log error
   - Don't fail submission

2. **Student Not Enrolled**
   - Handle gracefully
   - Log error
   - Don't fail submission

3. **Database Error**
   - Handle gracefully
   - Log error
   - Don't fail submission

4. **Grade Sync Failure**
   - Log error
   - Don't fail submission
   - Allow student to see result

### Error Response

```dart
try {
  await gradesService.syncGradeFromQuiz(...);
} catch (e) {
  debugPrint('Error syncing grade: $e');
  // Continue - don't fail quiz submission
}
```

---

## Testing Strategy

### Unit Testing

- Test score calculation with various inputs
- Test error handling for each error scenario
- Test logging output
- Test with edge cases (0 questions, all correct, all wrong)

### Property-Based Testing

- **Property 1**: Quiz sync automatic trigger (100+ iterations)
- **Property 2**: Score calculation accuracy (100+ iterations)
- **Property 3**: Grade sync non-blocking (100+ iterations)
- **Property 4**: Error logging (100+ iterations)
- **Property 5**: Multiple attempts tracking (100+ iterations)
- **Property 6**: Performance guarantee (100+ iterations)
- **Property 7**: Backwards compatibility (100+ iterations)
- **Property 8**: Score validation (100+ iterations)

### Integration Testing

- Test complete quiz → grades flow
- Test with multiple attempts
- Test with different score values
- Test error scenarios
- Test performance

---

## Success Criteria

✅ Quiz submission automatically syncs to grades  
✅ Grade record created with correct values  
✅ Score calculated correctly  
✅ Error handling robust  
✅ Logging comprehensive  
✅ Unit tests passing  
✅ Property-based tests passing  
✅ Integration tests passing  
✅ Performance acceptable  
✅ Backwards compatible  

