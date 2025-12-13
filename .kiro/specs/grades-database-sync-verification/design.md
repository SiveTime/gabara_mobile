# Design Document - Grades Database Schema & Sync Logic Verification

## Overview

This design document outlines the verification and validation strategy for the grades database infrastructure and synchronization logic. The goal is to ensure that:

1. The PostgreSQL grades table is correctly structured in Supabase
2. The GradeModel in Dart matches the database schema
3. All GradesService methods are implemented and functional
4. Assignment submissions properly sync to the grades table
5. Quiz attempts properly sync to the grades table
6. Data integrity and consistency are maintained
7. Row-Level Security policies are correctly configured
8. Error handling is robust and informative
9. Test queries verify the system works correctly
10. End-to-end integration testing confirms complete functionality

---

## Architecture

### Database Layer

```
┌─────────────────────────────────────────────────────────────┐
│ Supabase PostgreSQL                                         │
├─────────────────────────────────────────────────────────────┤
│ grades table                                                │
│ ├─ id (UUID, PRIMARY KEY)                                  │
│ ├─ student_id (UUID, NOT NULL, FK → auth.users)            │
│ ├─ class_id (UUID, NOT NULL, FK → classes)                 │
│ ├─ item_id (UUID, NOT NULL)                                │
│ ├─ item_type (TEXT, CHECK: quiz|assignment)                │
│ ├─ score (DECIMAL, NOT NULL)                               │
│ ├─ max_score (DECIMAL, NOT NULL)                           │
│ ├─ percentage (DECIMAL, NOT NULL)                          │
│ ├─ recorded_at (TIMESTAMP, DEFAULT NOW())                  │
│ ├─ UNIQUE(student_id, item_id)                             │
│ └─ Indexes: (student_id), (class_id), (item_id),           │
│             (item_type), (student_id, class_id)            │
│                                                             │
│ RLS Policies:                                               │
│ ├─ Students can view own grades                            │
│ └─ Mentors can view grades for their classes               │
└─────────────────────────────────────────────────────────────┘
```

### Service Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ GradesService                                               │
├─────────────────────────────────────────────────────────────┤
│ Methods:                                                    │
│ ├─ fetchMyGrades()                                          │
│ ├─ fetchStudentGrades(studentId, classId)                  │
│ ├─ fetchClassGrades(classId)                               │
│ ├─ calculateStudentAverage(studentId, classId)             │
│ ├─ getStudentGradesSummary(classId)                        │
│ ├─ syncGradeFromQuiz(...)                                  │
│ ├─ syncGradeFromAssignment(...)                            │
│ └─ Error handling & validation                             │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│ Supabase Client                                             │
├─────────────────────────────────────────────────────────────┤
│ ├─ INSERT/UPDATE grades                                    │
│ ├─ SELECT grades with filters                              │
│ ├─ RLS policy enforcement                                  │
│ └─ Error handling                                          │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow - Quiz Sync

```
StudentQuizDetailPage (Student submits quiz)
  ↓
StudentQuizProvider.submitQuiz()
  ↓
StudentQuizService.submitQuiz()
  ↓
Calculate score & percentage
  ↓
GradesService.syncGradeFromQuiz(
    studentId, classId, quizId, score, maxScore
  )
  ↓
Validate inputs
  ↓
INSERT/UPDATE grades table
  ↓
Return GradeModel
  ↓
Update UI with success message
```

### Data Flow - Assignment Sync

```
SubmissionDetailPage (Mentor grades submission)
  ↓
AssignmentProvider.gradeSubmission()
  ↓
AssignmentService.gradeSubmission()
  ↓
Update submission with score & feedback
  ↓
GradesService.syncGradeFromAssignment(
    studentId, classId, assignmentId, score, maxScore
  )
  ↓
Validate inputs
  ↓
INSERT/UPDATE grades table
  ↓
Return GradeModel
  ↓
Update UI with success message
```

---

## Components and Interfaces

### 1. GradeModel

```dart
class GradeModel {
  final String id;
  final String studentId;
  final String classId;
  final String itemId;
  final String itemType; // 'quiz' or 'assignment'
  final double score;
  final double maxScore;
  final double percentage;
  final DateTime recordedAt;

  GradeModel({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.itemId,
    required this.itemType,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.recordedAt,
  });

  // Computed properties
  bool get isQuizGrade => itemType == 'quiz';
  bool get isAssignmentGrade => itemType == 'assignment';
  bool get isPassing => percentage >= 60;

  // Serialization
  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      classId: json['class_id'] as String,
      itemId: json['item_id'] as String,
      itemType: json['item_type'] as String,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['max_score'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'item_id': itemId,
      'item_type': itemType,
      'score': score,
      'max_score': maxScore,
      'percentage': percentage,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}
```

### 2. GradesService Interface

```dart
abstract class GradesService {
  // Fetch operations
  Future<List<GradeModel>> fetchMyGrades();
  Future<List<GradeModel>> fetchStudentGrades(String studentId, String classId);
  Future<List<GradeModel>> fetchClassGrades(String classId);
  
  // Calculation operations
  Future<double> calculateStudentAverage(String studentId, String classId);
  Future<List<Map<String, dynamic>>> getStudentGradesSummary(String classId);
  
  // Sync operations
  Future<GradeModel?> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  });
  
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  });
}
```

### 3. Verification Checklist

#### Database Schema Verification
- [ ] grades table exists in Supabase
- [ ] All columns present with correct types
- [ ] Constraints properly configured
- [ ] Indexes created for performance
- [ ] UNIQUE constraint on (student_id, item_id)
- [ ] RLS policies configured

#### GradeModel Verification
- [ ] All properties match database columns
- [ ] Type mappings correct (String, double, DateTime)
- [ ] fromJson() factory works correctly
- [ ] toJson() method works correctly
- [ ] Computed properties (isQuizGrade, isPassing) work
- [ ] Serialization round-trip successful

#### GradesService Verification
- [ ] fetchMyGrades() returns correct data
- [ ] fetchStudentGrades() filters correctly
- [ ] fetchClassGrades() returns all class grades
- [ ] calculateStudentAverage() calculates correctly
- [ ] getStudentGradesSummary() returns summary data
- [ ] syncGradeFromQuiz() creates/updates correctly
- [ ] syncGradeFromAssignment() creates/updates correctly
- [ ] Error handling works for all methods

#### Assignment Sync Verification
- [ ] AssignmentService calls syncGradeFromAssignment()
- [ ] Grade record created with correct values
- [ ] Percentage calculated correctly
- [ ] recorded_at timestamp set
- [ ] Test: Create → Submit → Grade → Verify

#### Quiz Sync Verification
- [ ] StudentQuizService calls syncGradeFromQuiz()
- [ ] Grade record created with correct values
- [ ] Percentage calculated correctly
- [ ] recorded_at timestamp set
- [ ] Test: Create → Submit → Verify

#### Data Integrity Verification
- [ ] UNIQUE constraint prevents duplicates
- [ ] UPSERT logic works for updates
- [ ] Validation catches invalid data
- [ ] Historical records preserved on delete
- [ ] Results ordered by recorded_at DESC

#### RLS Policy Verification
- [ ] Students see only own grades
- [ ] Mentors see only their class grades
- [ ] Cross-access blocked
- [ ] Policies logged and tested

#### Error Handling Verification
- [ ] Invalid student_id caught
- [ ] Invalid class_id caught
- [ ] Score validation works
- [ ] item_type validation works
- [ ] Database errors handled
- [ ] RLS errors handled

#### Test Queries Verification
- [ ] COUNT query works
- [ ] Filtered SELECT queries work
- [ ] Aggregate queries work
- [ ] Ordering works
- [ ] All queries return expected results

#### Integration Testing Verification
- [ ] Quiz → Grades flow works end-to-end
- [ ] Assignment → Grades flow works end-to-end
- [ ] Multiple items tracked correctly
- [ ] Updates don't create duplicates
- [ ] Averages calculated correctly

---

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Grade Percentage Calculation Consistency

*For any* grade record with score and max_score values, the percentage field SHALL equal (score / max_score) * 100, rounded to 2 decimal places.

**Validates: Requirements 4.7, 5.7**

### Property 2: Unique Grade Per Item

*For any* student and item combination, there SHALL be at most one grade record in the grades table. Attempting to sync a grade for the same student-item pair SHALL update the existing record, not create a duplicate.

**Validates: Requirements 6.1, 6.2**

### Property 3: Quiz Sync Automatic Trigger

*For any* quiz submission by a student, the system SHALL automatically call GradesService.syncGradeFromQuiz() without manual intervention, creating a corresponding grade record.

**Validates: Requirements 5.8**

### Property 4: Assignment Sync on Grade

*For any* assignment submission graded by a mentor, the system SHALL automatically call GradesService.syncGradeFromAssignment(), creating a corresponding grade record with the assigned score.

**Validates: Requirements 4.1, 4.2**

### Property 5: RLS Student Access Control

*For any* student querying the grades table, the system SHALL only return grade records where student_id equals the authenticated user's ID, regardless of other filters applied.

**Validates: Requirements 7.1, 7.3**

### Property 6: RLS Mentor Access Control

*For any* mentor querying the grades table, the system SHALL only return grade records for classes where the mentor is the tutor, regardless of other filters applied.

**Validates: Requirements 7.2, 7.4**

### Property 7: Score Validation Bounds

*For any* grade sync operation, if score is negative or greater than max_score, the system SHALL reject the operation and return an error without modifying the database.

**Validates: Requirements 8.3, 8.4**

### Property 8: Grade Average Calculation

*For any* student in a class, the calculated average SHALL equal the arithmetic mean of all percentage values for that student's grades in that class, rounded to 2 decimal places.

**Validates: Requirements 3.4, 10.7**

### Property 9: Historical Grade Preservation

*For any* quiz or assignment deletion, existing grade records referencing that item SHALL remain in the grades table for historical tracking and shall not be deleted.

**Validates: Requirements 6.7**

### Property 10: Grade Record Ordering

*For any* query returning multiple grade records, the results SHALL be ordered by recorded_at in descending order (most recent first) unless explicitly specified otherwise.

**Validates: Requirements 6.8**

---

## Error Handling

### Error Categories

1. **Validation Errors**
   - Invalid student_id format
   - Invalid class_id format
   - Invalid item_id format
   - Score out of bounds (negative or > max_score)
   - max_score <= 0
   - Invalid item_type (not 'quiz' or 'assignment')

2. **Database Errors**
   - Connection failures
   - Constraint violations
   - RLS policy violations
   - Transaction failures

3. **Business Logic Errors**
   - Student not enrolled in class
   - Quiz/assignment not found
   - Submission not found
   - Unauthorized access

### Error Response Format

```dart
class GradeException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  GradeException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'GradeException: $message';
}
```

---

## Testing Strategy

### Unit Testing

- Test GradeModel serialization/deserialization
- Test percentage calculation logic
- Test validation functions
- Test error handling

### Property-Based Testing

- **Property 1**: Grade percentage calculation (100+ iterations)
- **Property 2**: Unique grade per item (100+ iterations)
- **Property 3**: Quiz sync automatic trigger (100+ iterations)
- **Property 4**: Assignment sync on grade (100+ iterations)
- **Property 5**: RLS student access control (100+ iterations)
- **Property 6**: RLS mentor access control (100+ iterations)
- **Property 7**: Score validation bounds (100+ iterations)
- **Property 8**: Grade average calculation (100+ iterations)
- **Property 9**: Historical grade preservation (100+ iterations)
- **Property 10**: Grade record ordering (100+ iterations)

### Integration Testing

- Test complete quiz → grades flow
- Test complete assignment → grades flow
- Test multiple grades for same student
- Test grade updates (no duplicates)
- Test average calculations
- Test RLS policies with real data
- Test error scenarios

### Test Queries

```sql
-- Verify table structure
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'grades';

-- Count all grades
SELECT COUNT(*) FROM grades;

-- Get grades for specific student
SELECT * FROM grades WHERE student_id = 'test_id';

-- Get quiz grades only
SELECT * FROM grades WHERE item_type = 'quiz';

-- Get assignment grades only
SELECT * FROM grades WHERE item_type = 'assignment';

-- Calculate class average
SELECT AVG(percentage) FROM grades WHERE class_id = 'test_class';

-- Get passing grades
SELECT * FROM grades WHERE percentage >= 60;

-- Get failing grades
SELECT * FROM grades WHERE percentage < 60;

-- Get recent grades
SELECT * FROM grades ORDER BY recorded_at DESC LIMIT 10;

-- Check for duplicates
SELECT student_id, item_id, COUNT(*) 
FROM grades 
GROUP BY student_id, item_id 
HAVING COUNT(*) > 1;
```

---

## Implementation Phases

### Phase 1: Database Verification (1-2 hours)
- Verify grades table exists and has correct schema
- Verify indexes are created
- Verify RLS policies are configured
- Run test queries

### Phase 2: Code Review (1-2 hours)
- Review GradeModel implementation
- Review GradesService implementation
- Review AssignmentService sync calls
- Review StudentQuizService sync calls

### Phase 3: Testing (2-3 hours)
- Run unit tests
- Run property-based tests
- Run integration tests
- Test error scenarios
- Verify end-to-end flows

### Phase 4: Documentation (1 hour)
- Document findings
- Document any issues found
- Document fixes applied
- Create verification report

---

## Success Criteria

✅ Grades table verified with correct schema  
✅ GradeModel matches database structure  
✅ All GradesService methods working  
✅ Assignment grades syncing correctly  
✅ Quiz grades syncing correctly  
✅ Data integrity maintained  
✅ RLS policies working correctly  
✅ Error handling robust  
✅ Test queries passing  
✅ End-to-end integration working  

