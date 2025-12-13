# Implementation Plan - Grades Database Schema & Sync Logic Verification

## Overview

This implementation plan provides a series of discrete, manageable verification and testing tasks to ensure the grades database infrastructure and synchronization logic are correctly implemented and functioning.

---

## Task List

- [x] 1. Database Schema Verification





  - [ ] 1.1 Connect to Supabase and verify grades table exists
    - Check table structure in Supabase dashboard
    - Verify all columns present: id, student_id, class_id, item_id, item_type, score, max_score, percentage, recorded_at
    - _Requirements: 1.1, 1.2_

  
  - [ ] 1.2 Verify column constraints and data types
    - Verify PRIMARY KEY on id
    - Verify NOT NULL constraints on required columns
    - Verify CHECK constraint on item_type (quiz|assignment)
    - Verify UNIQUE constraint on (student_id, item_id)

    - _Requirements: 1.2_
  
  - [ ] 1.3 Verify indexes are created
    - Check indexes on: (student_id), (class_id), (item_id), (item_type), (student_id, class_id)

    - Verify index names and columns
    - _Requirements: 1.4_
  
  - [ ] 1.4 Verify RLS policies are configured
    - Check policy: "Students can view their own grades"

    - Check policy: "Mentors can view grades for their classes"
    - Verify policy logic is correct
    - _Requirements: 1.6_
  
  - [ ] 1.5 Run test query and verify results
    - Execute: SELECT * FROM grades LIMIT 1
    - Verify query returns successfully
    - Verify column structure matches expectations
    - _Requirements: 1.5_

- [ ] 2. GradeModel Structure Verification
  - [ ] 2.1 Review GradeModel implementation
    - Check file: lib/features/grades/data/models/grade_model.dart
    - Verify all properties exist: id, studentId, classId, itemId, itemType, score, maxScore, percentage, recordedAt
    - Verify type mappings are correct
    - _Requirements: 2.1, 2.2_
  
  - [ ] 2.2 Verify GradeModel serialization methods
    - Check fromJson() factory constructor
    - Check toJson() method
    - Test serialization round-trip (toJson → fromJson)
    - _Requirements: 2.3, 2.4_
  
  - [ ] 2.3 Verify GradeModel computed properties
    - Check isQuizGrade property (itemType == 'quiz')
    - Check isAssignmentGrade property (itemType == 'assignment')
    - Check isPassing property (percentage >= 60)
    - _Requirements: 2.5_

- [ ] 3. GradesService Method Verification
  - [ ] 3.1 Verify fetchMyGrades() implementation
    - Check file: lib/features/grades/data/services/grades_service.dart
    - Verify method returns List<GradeModel>
    - Verify method filters by current authenticated student
    - Test method with sample data
    - _Requirements: 3.1_
  
  - [ ] 3.2 Verify fetchStudentGrades() implementation
    - Verify method accepts studentId and classId parameters
    - Verify method returns List<GradeModel> filtered by both parameters
    - Test method with sample data
    - _Requirements: 3.2_
  
  - [ ] 3.3 Verify fetchClassGrades() implementation
    - Verify method accepts classId parameter
    - Verify method returns List<GradeModel> for all students in class
    - Test method with sample data
    - _Requirements: 3.3_
  
  - [ ] 3.4 Verify calculateStudentAverage() implementation
    - Verify method accepts studentId and classId parameters
    - Verify method returns double representing average percentage
    - Verify calculation formula: sum(percentage) / count
    - Test method with sample data
    - _Requirements: 3.4_
  
  - [ ] 3.5 Verify getStudentGradesSummary() implementation
    - Verify method accepts classId parameter
    - Verify method returns List<Map> with student summaries
    - Verify each summary includes: student name, average score, quiz count, assignment count
    - Test method with sample data
    - _Requirements: 3.5_
  
  - [ ] 3.6 Verify syncGradeFromQuiz() implementation
    - Verify method accepts: studentId, classId, quizId, score, maxScore, quizTitle
    - Verify method creates/updates grade record with item_type='quiz'
    - Verify method returns GradeModel
    - Test method with sample data
    - _Requirements: 3.6_
  
  - [ ] 3.7 Verify syncGradeFromAssignment() implementation
    - Verify method accepts: studentId, classId, assignmentId, score, maxScore, assignmentTitle
    - Verify method creates/updates grade record with item_type='assignment'
    - Verify method returns GradeModel
    - Test method with sample data
    - _Requirements: 3.7_
  
  - [ ] 3.8 Verify error handling in GradesService
    - Verify all methods handle errors gracefully
    - Verify error messages are informative
    - Test error scenarios
    - _Requirements: 3.8_

- [ ] 4. Assignment Sync Verification
  - [ ] 4.1 Verify AssignmentService calls syncGradeFromAssignment()
    - Check file: lib/features/assignments/data/services/assignment_service.dart
    - Verify gradeSubmission() method calls GradesService.syncGradeFromAssignment()
    - Verify parameters passed are correct
    - _Requirements: 4.1_
  
  - [ ] 4.2 Verify grade record creation with correct values
    - Create test assignment
    - Create test submission
    - Grade submission with score
    - Query grades table and verify record exists
    - Verify: student_id, class_id, item_id, item_type='assignment', score, max_score, percentage
    - _Requirements: 4.2_
  
  - [ ] 4.3 Verify percentage calculation for assignment grades
    - Create assignment with max_score=100
    - Grade submission with score=85
    - Verify percentage = 85.0
    - Test with different values (50/100, 75/100, etc.)
    - _Requirements: 4.3_
  
  - [ ] 4.4 Verify recorded_at timestamp is set
    - Grade submission
    - Query grades table
    - Verify recorded_at is set to current timestamp
    - _Requirements: 4.4_
  
  - [ ] 4.5 Test complete flow: Create → Submit → Grade → Verify
    - Create assignment in class
    - Student submits assignment
    - Mentor grades submission with score
    - Query grades table
    - Verify grade record exists with all correct values
    - _Requirements: 4.6_

- [ ] 5. Quiz Sync Verification
  - [ ] 5.1 Verify StudentQuizService calls syncGradeFromQuiz()
    - Check file: lib/features/quiz/data/services/student_quiz_service.dart
    - Verify submitQuiz() method calls GradesService.syncGradeFromQuiz()
    - Verify parameters passed are correct
    - Verify sync is automatic (not manual)
    - _Requirements: 5.1, 5.8_
  
  - [ ] 5.2 Verify grade record creation with correct values
    - Create test quiz
    - Student submits quiz with score
    - Query grades table and verify record exists
    - Verify: student_id, class_id, item_id, item_type='quiz', score, max_score, percentage
    - _Requirements: 5.2_
  
  - [ ] 5.3 Verify percentage calculation for quiz grades
    - Create quiz with max_score=100
    - Submit quiz with score=90
    - Verify percentage = 90.0
    - Test with different values (60/100, 75/100, etc.)
    - _Requirements: 5.3_
  
  - [ ] 5.4 Verify recorded_at timestamp is set
    - Submit quiz
    - Query grades table
    - Verify recorded_at is set to current timestamp
    - _Requirements: 5.4_
  
  - [ ] 5.5 Test complete flow: Create → Submit → Verify
    - Create quiz in class
    - Student submits quiz with score
    - Query grades table
    - Verify grade record exists with all correct values
    - _Requirements: 5.6_

- [ ] 6. Data Integrity & Consistency Verification
  - [ ] 6.1 Verify UNIQUE constraint prevents duplicates
    - Create grade record for student-item pair
    - Attempt to create another grade for same pair
    - Verify constraint violation error
    - _Requirements: 6.1_
  
  - [ ] 6.2 Verify UPSERT logic for updates
    - Create grade record with score=80
    - Call sync again with score=90
    - Verify record is updated (not duplicated)
    - Verify new score=90
    - _Requirements: 6.2_
  
  - [ ] 6.3 Verify score validation
    - Attempt to sync with score=-10
    - Verify validation error
    - Attempt to sync with score > max_score
    - Verify validation error
    - _Requirements: 6.3_
  
  - [ ] 6.4 Verify max_score validation
    - Attempt to sync with max_score=0
    - Verify validation error
    - Attempt to sync with max_score=-50
    - Verify validation error
    - _Requirements: 6.4_
  
  - [ ] 6.5 Verify UUID validation
    - Attempt to sync with invalid student_id
    - Verify validation error
    - Attempt to sync with invalid class_id
    - Verify validation error
    - _Requirements: 6.5_
  
  - [ ] 6.6 Verify item_type validation
    - Attempt to sync with item_type='invalid'
    - Verify validation error
    - Verify only 'quiz' and 'assignment' are accepted
    - _Requirements: 6.6_
  
  - [ ] 6.7 Verify historical grade preservation on delete
    - Create grade record
    - Delete quiz/assignment
    - Query grades table
    - Verify grade record still exists
    - _Requirements: 6.7_
  
  - [ ] 6.8 Verify result ordering
    - Create multiple grade records with different timestamps
    - Query grades table
    - Verify results ordered by recorded_at DESC
    - _Requirements: 6.8_

- [ ] 7. RLS Policy Verification
  - [ ] 7.1 Verify student can view own grades
    - Login as student
    - Query grades table
    - Verify only own grades returned
    - _Requirements: 7.1_
  
  - [ ] 7.2 Verify mentor can view class grades
    - Login as mentor
    - Query grades table
    - Verify only grades for own classes returned
    - _Requirements: 7.2_
  
  - [ ] 7.3 Verify student cannot view other student's grades
    - Login as student A
    - Attempt to query student B's grades
    - Verify empty result (RLS blocks)
    - _Requirements: 7.3_
  
  - [ ] 7.4 Verify mentor cannot view other mentor's class grades
    - Login as mentor A
    - Attempt to query mentor B's class grades
    - Verify empty result (RLS blocks)
    - _Requirements: 7.4_
  
  - [ ] 7.5 Verify RLS policy names and logic
    - Check policy: "Students can view their own grades"
    - Check policy: "Mentors can view grades for their classes"
    - Verify policy conditions are correct
    - _Requirements: 7.5, 7.6_
  
  - [ ] 7.6 Test RLS with real data
    - Create test data with multiple students and classes
    - Test access from different user roles
    - Verify RLS works correctly
    - _Requirements: 7.7_

- [ ] 8. Error Handling & Validation Verification
  - [ ] 8.1 Verify error handling for invalid student_id
    - Call syncGradeFromQuiz with invalid student_id
    - Verify error thrown with message "Invalid student ID"
    - _Requirements: 8.1_
  
  - [ ] 8.2 Verify error handling for invalid class_id
    - Call syncGradeFromAssignment with invalid class_id
    - Verify error thrown with message "Invalid class ID"
    - _Requirements: 8.2_
  
  - [ ] 8.3 Verify error handling for score > max_score
    - Call sync with score=150, max_score=100
    - Verify error thrown with message "Score cannot exceed max_score"
    - _Requirements: 8.3_
  
  - [ ] 8.4 Verify error handling for negative score
    - Call sync with score=-10
    - Verify error thrown with message "Score cannot be negative"
    - _Requirements: 8.4_
  
  - [ ] 8.5 Verify error handling for invalid item_type
    - Call sync with item_type='invalid'
    - Verify error thrown with message "Item type must be 'quiz' or 'assignment'"
    - _Requirements: 8.5_
  
  - [ ] 8.6 Verify error handling for database connection failure
    - Simulate database connection failure
    - Verify error thrown with message "Database connection failed"
    - _Requirements: 8.6_
  
  - [ ] 8.7 Verify error handling for RLS policy violation
    - Attempt unauthorized access
    - Verify error thrown with message "Access denied"
    - _Requirements: 8.7_
  
  - [ ] 8.8 Verify error logging
    - Trigger various errors
    - Check logs for error details
    - Verify logs contain useful debugging information
    - _Requirements: 8.8_

- [ ] 9. Test Queries Verification
  - [ ] 9.1 Run COUNT query
    - Execute: SELECT COUNT(*) FROM grades
    - Verify query returns successfully
    - Verify count is correct
    - _Requirements: 9.1_
  
  - [ ] 9.2 Run filtered SELECT query by student
    - Execute: SELECT * FROM grades WHERE student_id = 'test_id'
    - Verify query returns successfully
    - Verify only grades for that student returned
    - _Requirements: 9.2_
  
  - [ ] 9.3 Run filtered SELECT query by item_type=quiz
    - Execute: SELECT * FROM grades WHERE item_type = 'quiz'
    - Verify query returns successfully
    - Verify only quiz grades returned
    - _Requirements: 9.3_
  
  - [ ] 9.4 Run filtered SELECT query by item_type=assignment
    - Execute: SELECT * FROM grades WHERE item_type = 'assignment'
    - Verify query returns successfully
    - Verify only assignment grades returned
    - _Requirements: 9.4_
  
  - [ ] 9.5 Run aggregate query for class average
    - Execute: SELECT AVG(percentage) FROM grades WHERE class_id = 'test_class'
    - Verify query returns successfully
    - Verify average is calculated correctly
    - _Requirements: 9.5_
  
  - [ ] 9.6 Run query for passing grades
    - Execute: SELECT * FROM grades WHERE percentage >= 60
    - Verify query returns successfully
    - Verify only passing grades returned
    - _Requirements: 9.6_
  
  - [ ] 9.7 Run query for failing grades
    - Execute: SELECT * FROM grades WHERE percentage < 60
    - Verify query returns successfully
    - Verify only failing grades returned
    - _Requirements: 9.7_
  
  - [ ] 9.8 Run query with ordering
    - Execute: SELECT * FROM grades ORDER BY recorded_at DESC LIMIT 10
    - Verify query returns successfully
    - Verify 10 most recent grades returned
    - Verify ordering is correct (DESC)
    - _Requirements: 9.8_

- [ ] 10. Integration Testing
  - [ ] 10.1 Test complete quiz flow
    - Create quiz in class
    - Student submits quiz with score
    - Check grades table
    - Verify grade record exists with correct values
    - _Requirements: 10.1_
  
  - [ ] 10.2 Test complete assignment flow
    - Create assignment in class
    - Student submits assignment
    - Mentor grades submission
    - Check grades table
    - Verify grade record exists with correct values
    - _Requirements: 10.2_
  
  - [ ] 10.3 Test multiple quizzes for same student
    - Create 3 quizzes in class
    - Student submits all 3 quizzes
    - Check grades table
    - Verify all 3 grade records exist
    - _Requirements: 10.3_
  
  - [ ] 10.4 Test multiple assignments for same student
    - Create 3 assignments in class
    - Student submits all 3 assignments
    - Mentor grades all 3 submissions
    - Check grades table
    - Verify all 3 grade records exist
    - _Requirements: 10.4_
  
  - [ ] 10.5 Test grade update (no duplicates)
    - Create quiz and submit with score=80
    - Check grades table (1 record)
    - Update quiz score to 90
    - Check grades table (still 1 record, not 2)
    - Verify score updated to 90
    - _Requirements: 10.5_
  
  - [ ] 10.6 Test assignment grade update (no duplicates)
    - Create assignment and grade with score=80
    - Check grades table (1 record)
    - Update grade to 90
    - Check grades table (still 1 record, not 2)
    - Verify score updated to 90
    - _Requirements: 10.6_
  
  - [ ] 10.7 Test student average calculation
    - Create 3 quizzes with scores: 80, 90, 70
    - Calculate average
    - Verify average = 80.0
    - _Requirements: 10.7_
  
  - [ ] 10.8 Test class average calculation
    - Create 3 students with grades: 80, 90, 70
    - Calculate class average
    - Verify average = 80.0
    - _Requirements: 10.8_

- [ ] 11. Checkpoint - Verify All Tests Pass
  - Ensure all verification tasks completed
  - Ensure all test queries pass
  - Ensure all integration tests pass
  - Ask the user if questions arise

- [ ] 12. Property-Based Testing
  - [ ] 12.1 Write property test for grade percentage calculation
    - **Feature: grades-database-sync-verification, Property 1: Grade Percentage Calculation Consistency**
    - **Validates: Requirements 4.7, 5.7**
    - Generate random score and max_score values
    - Verify percentage = (score / max_score) * 100
    - Run 100+ iterations
  
  - [ ] 12.2 Write property test for unique grade per item
    - **Feature: grades-database-sync-verification, Property 2: Unique Grade Per Item**
    - **Validates: Requirements 6.1, 6.2**
    - Generate random student-item pairs
    - Verify at most one grade per pair
    - Run 100+ iterations
  
  - [ ] 12.3 Write property test for quiz sync automatic trigger
    - **Feature: grades-database-sync-verification, Property 3: Quiz Sync Automatic Trigger**
    - **Validates: Requirements 5.8**
    - Generate random quiz submissions
    - Verify grade record created automatically
    - Run 100+ iterations
  
  - [ ] 12.4 Write property test for assignment sync on grade
    - **Feature: grades-database-sync-verification, Property 4: Assignment Sync on Grade**
    - **Validates: Requirements 4.1, 4.2**
    - Generate random assignment grades
    - Verify grade record created automatically
    - Run 100+ iterations
  
  - [ ] 12.5 Write property test for RLS student access control
    - **Feature: grades-database-sync-verification, Property 5: RLS Student Access Control**
    - **Validates: Requirements 7.1, 7.3**
    - Generate random student queries
    - Verify only own grades returned
    - Run 100+ iterations
  
  - [ ] 12.6 Write property test for RLS mentor access control
    - **Feature: grades-database-sync-verification, Property 6: RLS Mentor Access Control**
    - **Validates: Requirements 7.2, 7.4**
    - Generate random mentor queries
    - Verify only class grades returned
    - Run 100+ iterations
  
  - [ ] 12.7 Write property test for score validation bounds
    - **Feature: grades-database-sync-verification, Property 7: Score Validation Bounds**
    - **Validates: Requirements 8.3, 8.4**
    - Generate random invalid scores
    - Verify rejection and error
    - Run 100+ iterations
  
  - [ ] 12.8 Write property test for grade average calculation
    - **Feature: grades-database-sync-verification, Property 8: Grade Average Calculation**
    - **Validates: Requirements 3.4, 10.7**
    - Generate random grade sets
    - Verify average calculated correctly
    - Run 100+ iterations
  
  - [ ] 12.9 Write property test for historical grade preservation
    - **Feature: grades-database-sync-verification, Property 9: Historical Grade Preservation**
    - **Validates: Requirements 6.7**
    - Generate random deletions
    - Verify grades preserved
    - Run 100+ iterations
  
  - [ ] 12.10 Write property test for grade record ordering
    - **Feature: grades-database-sync-verification, Property 10: Grade Record Ordering**
    - **Validates: Requirements 6.8**
    - Generate random grade queries
    - Verify DESC ordering by recorded_at
    - Run 100+ iterations

- [ ] 13. Final Checkpoint - All Tests Pass
  - Ensure all property-based tests pass
  - Ensure all integration tests pass
  - Ensure all verification tasks complete
  - Ask the user if questions arise

