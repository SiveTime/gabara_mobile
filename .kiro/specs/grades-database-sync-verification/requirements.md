# Requirements Document - Grades Database Schema & Sync Logic Verification

## Introduction

This specification focuses on verifying and validating the grades database infrastructure and ensuring proper synchronization between quiz attempts, assignment submissions, and the centralized grades table. The goal is to establish a reliable foundation for the grades tracking system that aggregates scores from multiple sources (quizzes and assignments) into a unified grades table for easy access and reporting.

## Glossary

- **Grades Table**: Centralized PostgreSQL table storing all grades from quizzes and assignments
- **Grade Record**: Individual entry in grades table with student_id, class_id, item_id, item_type, score, max_score, percentage
- **Quiz Sync**: Process of recording quiz attempt scores to grades table
- **Assignment Sync**: Process of recording assignment submission grades to grades table
- **Item Type**: Classification of grade source (quiz or assignment)
- **Item ID**: UUID reference to the quiz or assignment that generated the grade
- **Percentage**: Calculated score percentage (score / max_score * 100)
- **RLS Policy**: Row-Level Security policy controlling data access in Supabase
- **GradeModel**: Dart model representing a grade record in the application
- **GradesService**: Service layer handling grade operations and synchronization
- **StudentQuizService**: Service handling student quiz attempts
- **AssignmentService**: Service handling assignment submissions and grading

## Requirements

### Requirement 1: Database Schema Verification

**User Story:** As a developer, I want to verify the grades table schema is correctly set up in Supabase, so that I can ensure data integrity and proper structure.

#### Acceptance Criteria

1. WHEN checking the grades table in Supabase THEN the System SHALL have a grades table with columns: id (UUID), student_id (UUID), class_id (UUID), item_id (UUID), item_type (TEXT), score (DECIMAL), max_score (DECIMAL), percentage (DECIMAL), recorded_at (TIMESTAMP)
2. WHEN checking column constraints THEN the System SHALL enforce: id as PRIMARY KEY, student_id NOT NULL, class_id NOT NULL, item_id NOT NULL, item_type NOT NULL with CHECK constraint (quiz|assignment), score NOT NULL, max_score NOT NULL, percentage NOT NULL, recorded_at DEFAULT NOW()
3. WHEN checking unique constraints THEN the System SHALL have UNIQUE constraint on (student_id, item_id) to prevent duplicate grades for same item
4. WHEN checking indexes THEN the System SHALL have indexes on: (student_id), (class_id), (item_id), (item_type), (student_id, class_id)
5. WHEN running test query SELECT * FROM grades LIMIT 1 THEN the System SHALL return successfully with proper column structure
6. WHEN checking RLS policies THEN the System SHALL have policy allowing students to view their own grades and mentors to view grades for their classes

### Requirement 2: GradeModel Structure Verification

**User Story:** As a developer, I want to verify the GradeModel matches the database schema, so that serialization and deserialization work correctly.

#### Acceptance Criteria

1. WHEN examining GradeModel THEN the System SHALL have properties: id, studentId, classId, itemId, itemType, score, maxScore, percentage, recordedAt
2. WHEN examining GradeModel THEN the System SHALL have proper type mappings: id (String), studentId (String), classId (String), itemId (String), itemType (String), score (double), maxScore (double), percentage (double), recordedAt (DateTime)
3. WHEN examining GradeModel THEN the System SHALL have fromJson() factory constructor for deserialization from Supabase
4. WHEN examining GradeModel THEN the System SHALL have toJson() method for serialization to Supabase
5. WHEN examining GradeModel THEN the System SHALL have computed properties: isQuizGrade (itemType == 'quiz'), isAssignmentGrade (itemType == 'assignment'), isPassing (percentage >= 60)

### Requirement 3: GradesService Method Verification

**User Story:** As a developer, I want to verify all GradesService methods are implemented and working, so that grade operations function correctly.

#### Acceptance Criteria

1. WHEN calling GradesService.fetchMyGrades() THEN the System SHALL return List<GradeModel> for current authenticated student
2. WHEN calling GradesService.fetchStudentGrades(studentId, classId) THEN the System SHALL return List<GradeModel> filtered by student and class
3. WHEN calling GradesService.fetchClassGrades(classId) THEN the System SHALL return List<GradeModel> for all students in a class
4. WHEN calling GradesService.calculateStudentAverage(studentId, classId) THEN the System SHALL return double representing average percentage for student in class
5. WHEN calling GradesService.getStudentGradesSummary(classId) THEN the System SHALL return List<Map> with student name, average score, quiz count, assignment count
6. WHEN calling GradesService.syncGradeFromQuiz() THEN the System SHALL insert or update grade record with item_type='quiz'
7. WHEN calling GradesService.syncGradeFromAssignment() THEN the System SHALL insert or update grade record with item_type='assignment'
8. WHEN calling any GradesService method THEN the System SHALL handle errors gracefully and return appropriate error messages

### Requirement 4: Assignment Sync Verification

**User Story:** As a developer, I want to verify assignment grades are properly synced to the grades table, so that assignment scores appear in the grades dashboard.

#### Acceptance Criteria

1. WHEN a mentor grades an assignment submission THEN the System SHALL call GradesService.syncGradeFromAssignment() with correct parameters
2. WHEN GradesService.syncGradeFromAssignment() is called THEN the System SHALL create or update grade record in grades table with: student_id, class_id, item_id (assignment_id), item_type='assignment', score, max_score, percentage
3. WHEN calculating percentage THEN the System SHALL use formula: (score / max_score) * 100
4. WHEN syncing assignment grade THEN the System SHALL set recorded_at to current timestamp
5. WHEN syncing assignment grade THEN the System SHALL return GradeModel object with synced data
6. WHEN test: Create assignment → Submit → Grade THEN the System SHALL verify grade appears in grades table with correct values
7. WHEN test: Grade percentage calculated THEN the System SHALL verify percentage matches expected calculation

### Requirement 5: Quiz Sync Verification

**User Story:** As a developer, I want to verify quiz scores are properly synced to the grades table, so that quiz results appear in the grades dashboard.

#### Acceptance Criteria

1. WHEN a student submits a quiz THEN the System SHALL call GradesService.syncGradeFromQuiz() with correct parameters
2. WHEN GradesService.syncGradeFromQuiz() is called THEN the System SHALL create or update grade record in grades table with: student_id, class_id, item_id (quiz_id), item_type='quiz', score, max_score, percentage
3. WHEN calculating percentage THEN the System SHALL use formula: (score / max_score) * 100
4. WHEN syncing quiz grade THEN the System SHALL set recorded_at to current timestamp
5. WHEN syncing quiz grade THEN the System SHALL return GradeModel object with synced data
6. WHEN test: Create quiz → Submit → Verify grade THEN the System SHALL verify grade appears in grades table with correct values
7. WHEN test: Grade percentage calculated THEN the System SHALL verify percentage matches expected calculation
8. WHEN StudentQuizService submits quiz THEN the System SHALL automatically call sync method (not manual)

### Requirement 6: Data Integrity & Consistency

**User Story:** As a developer, I want to ensure grades data maintains integrity and consistency, so that the system is reliable.

#### Acceptance Criteria

1. WHEN inserting grade record THEN the System SHALL enforce UNIQUE constraint on (student_id, item_id) to prevent duplicates
2. WHEN updating existing grade THEN the System SHALL use UPSERT logic (INSERT ... ON CONFLICT ... DO UPDATE)
3. WHEN syncing grade THEN the System SHALL validate score is between 0 and max_score
4. WHEN syncing grade THEN the System SHALL validate max_score is greater than 0
5. WHEN syncing grade THEN the System SHALL validate student_id, class_id, item_id are valid UUIDs
6. WHEN syncing grade THEN the System SHALL validate item_type is either 'quiz' or 'assignment'
7. WHEN deleting quiz or assignment THEN the System SHALL preserve grade records for historical tracking
8. WHEN querying grades THEN the System SHALL return results ordered by recorded_at DESC (most recent first)

### Requirement 7: RLS Policy Verification

**User Story:** As a developer, I want to verify Row-Level Security policies are correctly configured, so that data access is properly restricted.

#### Acceptance Criteria

1. WHEN a student queries grades THEN the System SHALL only return grades where student_id = auth.uid()
2. WHEN a mentor queries grades THEN the System SHALL only return grades for classes where mentor is tutor
3. WHEN a student attempts to view another student's grades THEN the System SHALL return empty result (RLS blocks access)
4. WHEN a mentor attempts to view grades for classes they don't teach THEN the System SHALL return empty result (RLS blocks access)
5. WHEN checking RLS policies THEN the System SHALL have policy: "Students can view their own grades"
6. WHEN checking RLS policies THEN the System SHALL have policy: "Mentors can view grades for their classes"
7. WHEN testing RLS THEN the System SHALL verify policies work correctly with test queries

### Requirement 8: Error Handling & Validation

**User Story:** As a developer, I want proper error handling in grade operations, so that issues are caught and reported clearly.

#### Acceptance Criteria

1. WHEN syncing grade with invalid student_id THEN the System SHALL throw error with message "Invalid student ID"
2. WHEN syncing grade with invalid class_id THEN the System SHALL throw error with message "Invalid class ID"
3. WHEN syncing grade with score > max_score THEN the System SHALL throw error with message "Score cannot exceed max_score"
4. WHEN syncing grade with negative score THEN the System SHALL throw error with message "Score cannot be negative"
5. WHEN syncing grade with invalid item_type THEN the System SHALL throw error with message "Item type must be 'quiz' or 'assignment'"
6. WHEN database connection fails THEN the System SHALL throw error with message "Database connection failed"
7. WHEN RLS policy blocks access THEN the System SHALL throw error with message "Access denied"
8. WHEN any error occurs THEN the System SHALL log error details for debugging

### Requirement 9: Test Queries & Verification

**User Story:** As a developer, I want to run test queries to verify the grades system works end-to-end, so that I can confirm everything is functioning correctly.

#### Acceptance Criteria

1. WHEN running test query: SELECT COUNT(*) FROM grades THEN the System SHALL return count of all grades
2. WHEN running test query: SELECT * FROM grades WHERE student_id = 'test_id' THEN the System SHALL return grades for specific student
3. WHEN running test query: SELECT * FROM grades WHERE item_type = 'quiz' THEN the System SHALL return only quiz grades
4. WHEN running test query: SELECT * FROM grades WHERE item_type = 'assignment' THEN the System SHALL return only assignment grades
5. WHEN running test query: SELECT AVG(percentage) FROM grades WHERE class_id = 'test_class' THEN the System SHALL return class average
6. WHEN running test query: SELECT * FROM grades WHERE percentage >= 60 THEN the System SHALL return passing grades
7. WHEN running test query: SELECT * FROM grades WHERE percentage < 60 THEN the System SHALL return failing grades
8. WHEN running test query: SELECT * FROM grades ORDER BY recorded_at DESC LIMIT 10 THEN the System SHALL return 10 most recent grades

### Requirement 10: Integration Testing

**User Story:** As a developer, I want to test the complete flow from quiz/assignment to grades table, so that I can verify end-to-end functionality.

#### Acceptance Criteria

1. WHEN test: Create quiz → Student submits → Check grades table THEN the System SHALL verify grade record exists with correct values
2. WHEN test: Create assignment → Student submits → Mentor grades → Check grades table THEN the System SHALL verify grade record exists with correct values
3. WHEN test: Multiple quizzes for same student THEN the System SHALL verify all grades appear in grades table
4. WHEN test: Multiple assignments for same student THEN the System SHALL verify all grades appear in grades table
5. WHEN test: Update quiz score THEN the System SHALL verify grade record is updated (not duplicated)
6. WHEN test: Update assignment grade THEN the System SHALL verify grade record is updated (not duplicated)
7. WHEN test: Calculate student average THEN the System SHALL verify average is calculated correctly from all grades
8. WHEN test: Calculate class average THEN the System SHALL verify class average includes all students' grades

