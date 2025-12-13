# Requirements Document - Grades Provider Implementation

## Introduction

This specification focuses on implementing and enhancing the GradesProvider to properly manage grades state, provide computed properties for analytics, and integrate with the GradesService. The GradesProvider is the central state management component that handles loading, filtering, and calculating grades data for both student and mentor views.

## Glossary

- **GradesProvider**: ChangeNotifier class managing grades state and business logic
- **State Variables**: Private fields storing grades data (_grades, _gradesByClass, etc.)
- **Getters**: Public accessors for state variables
- **Computed Properties**: Derived values calculated from state (currentAverage, quizGrades, etc.)
- **Notifiers**: Methods that update state and call notifyListeners()
- **Loading State**: Boolean flag indicating async operation in progress
- **Error State**: String containing error message if operation failed
- **Student View**: Grades dashboard for students showing own grades
- **Mentor View**: Grades dashboard for mentors showing class grades
- **GPA**: Grade Point Average calculated from all grades
- **Class Average**: Average grade for all students in a class
- **Weighted Average**: Average calculated with weights for different grade types

## Requirements

### Requirement 1: GradesProvider Initialization

**User Story:** As a developer, I want the GradesProvider to be properly initialized with all necessary state variables, so that the provider can manage grades data correctly.

#### Acceptance Criteria

1. WHEN GradesProvider is instantiated THEN the System SHALL initialize with GradesService dependency
2. WHEN GradesProvider is instantiated THEN the System SHALL initialize all state variables: _grades (empty list), _gradesByClass (empty map), _studentSummaries (empty list), _overallGPA (0), _classAverage (0), _isLoading (false), _errorMessage (null), _selectedClassId (null)
3. WHEN GradesProvider is instantiated THEN the System SHALL have all required getters: grades, gradesByClass, studentSummaries, overallGPA, classAverage, isLoading, errorMessage, selectedClassId
4. WHEN accessing any getter THEN the System SHALL return the current state value without modification

### Requirement 2: Load Student Grades

**User Story:** As a student, I want the app to load my grades when I navigate to the Grades tab, so that I can see my academic performance.

#### Acceptance Criteria

1. WHEN calling loadMyGrades() THEN the System SHALL set _isLoading = true and notify listeners
2. WHEN calling loadMyGrades() THEN the System SHALL call GradesService.fetchMyGrades()
3. WHEN GradesService returns grades THEN the System SHALL update _grades with returned list
4. WHEN GradesService returns grades THEN the System SHALL call GradesService.getGradesByClass() and update _gradesByClass
5. WHEN GradesService returns grades THEN the System SHALL call GradesService.getOverallGPA() and update _overallGPA
6. WHEN loadMyGrades() completes successfully THEN the System SHALL set _isLoading = false, clear _errorMessage, and notify listeners
7. WHEN loadMyGrades() throws exception THEN the System SHALL set _errorMessage to exception message, set _isLoading = false, and notify listeners
8. WHEN loadMyGrades() is called multiple times THEN the System SHALL handle concurrent calls gracefully

### Requirement 3: Load Student Grades for Specific Class

**User Story:** As a mentor, I want to load grades for a specific student in a specific class, so that I can review their performance in that class.

#### Acceptance Criteria

1. WHEN calling loadStudentGrades(studentId, classId) THEN the System SHALL set _isLoading = true and notify listeners
2. WHEN calling loadStudentGrades(studentId, classId) THEN the System SHALL call GradesService.fetchStudentGrades(studentId, classId)
3. WHEN GradesService returns grades THEN the System SHALL update _grades with returned list
4. WHEN GradesService returns grades THEN the System SHALL call GradesService.calculateStudentAverage(studentId, classId) and update _classAverage
5. WHEN loadStudentGrades() completes successfully THEN the System SHALL set _isLoading = false, clear _errorMessage, and notify listeners
6. WHEN loadStudentGrades() throws exception THEN the System SHALL set _errorMessage to exception message, set _isLoading = false, and notify listeners

### Requirement 4: Load Class Grades Summary

**User Story:** As a mentor, I want to load a summary of all students' grades in my class, so that I can see overall class performance.

#### Acceptance Criteria

1. WHEN calling loadClassGradesSummary(classId) THEN the System SHALL set _isLoading = true and notify listeners
2. WHEN calling loadClassGradesSummary(classId) THEN the System SHALL set _selectedClassId = classId
3. WHEN calling loadClassGradesSummary(classId) THEN the System SHALL call GradesService.getStudentGradesSummary(classId)
4. WHEN GradesService returns summary THEN the System SHALL update _studentSummaries with returned list
5. WHEN loadClassGradesSummary() completes successfully THEN the System SHALL set _isLoading = false, clear _errorMessage, and notify listeners
6. WHEN loadClassGradesSummary() throws exception THEN the System SHALL set _errorMessage to exception message, set _isLoading = false, and notify listeners

### Requirement 5: Sync Grade from Quiz

**User Story:** As a system, I want to sync quiz grades to the provider when a student completes a quiz, so that grades are immediately available in the dashboard.

#### Acceptance Criteria

1. WHEN calling syncGradeFromQuiz() with valid parameters THEN the System SHALL call GradesService.syncGradeFromQuiz()
2. WHEN GradesService returns grade THEN the System SHALL check if grade already exists in _grades by itemId
3. WHEN grade exists THEN the System SHALL update existing grade in _grades
4. WHEN grade does not exist THEN the System SHALL insert new grade at beginning of _grades list
5. WHEN grade is synced THEN the System SHALL notify listeners to update UI
6. WHEN syncGradeFromQuiz() throws exception THEN the System SHALL set _errorMessage and notify listeners
7. WHEN syncGradeFromQuiz() completes THEN the System SHALL return the synced GradeModel or null on error

### Requirement 6: Sync Grade from Assignment

**User Story:** As a system, I want to sync assignment grades to the provider when a mentor grades a submission, so that grades are immediately available in the dashboard.

#### Acceptance Criteria

1. WHEN calling syncGradeFromAssignment() with valid parameters THEN the System SHALL call GradesService.syncGradeFromAssignment()
2. WHEN GradesService returns grade THEN the System SHALL check if grade already exists in _grades by itemId
3. WHEN grade exists THEN the System SHALL update existing grade in _grades
4. WHEN grade does not exist THEN the System SHALL insert new grade at beginning of _grades list
5. WHEN grade is synced THEN the System SHALL notify listeners to update UI
6. WHEN syncGradeFromAssignment() throws exception THEN the System SHALL set _errorMessage and notify listeners
7. WHEN syncGradeFromAssignment() completes THEN the System SHALL return the synced GradeModel or null on error

### Requirement 7: Filter Grades by Type

**User Story:** As a student, I want to filter my grades by type (quiz or assignment), so that I can see specific categories of grades.

#### Acceptance Criteria

1. WHEN accessing quizGrades getter THEN the System SHALL return list of grades where isQuizGrade = true
2. WHEN accessing assignmentGrades getter THEN the System SHALL return list of grades where isAssignmentGrade = true
3. WHEN _grades is empty THEN the System SHALL return empty list for both filters
4. WHEN _grades contains mixed types THEN the System SHALL correctly filter by type

### Requirement 8: Filter Grades by Status

**User Story:** As a student, I want to filter my grades by passing/failing status, so that I can identify areas needing improvement.

#### Acceptance Criteria

1. WHEN accessing passingGrades getter THEN the System SHALL return list of grades where isPassing = true (percentage >= 60)
2. WHEN accessing failingGrades getter THEN the System SHALL return list of grades where isPassing = false (percentage < 60)
3. WHEN _grades is empty THEN the System SHALL return empty list for both filters
4. WHEN _grades contains mixed statuses THEN the System SHALL correctly filter by status

### Requirement 9: Calculate Current Average

**User Story:** As a student, I want to see my current average grade, so that I can track my overall academic performance.

#### Acceptance Criteria

1. WHEN accessing currentAverage getter THEN the System SHALL calculate average of all percentage values in _grades
2. WHEN _grades is empty THEN the System SHALL return 0
3. WHEN _grades contains values THEN the System SHALL return arithmetic mean of percentages
4. WHEN calculating average THEN the System SHALL use GradeCalculator.calculateAverage() helper
5. WHEN average is calculated THEN the System SHALL round to 2 decimal places

### Requirement 10: Calculate Weighted Average

**User Story:** As a student, I want to see my weighted average grade, so that I can understand my performance with different grade types weighted appropriately.

#### Acceptance Criteria

1. WHEN accessing currentWeightedAverage getter THEN the System SHALL calculate weighted average of grades
2. WHEN _grades is empty THEN the System SHALL return 0
3. WHEN _grades contains values THEN the System SHALL use GradeCalculator.calculateWeightedAverage() helper
4. WHEN calculating weighted average THEN the System SHALL apply weights to different grade types
5. WHEN weighted average is calculated THEN the System SHALL round to 2 decimal places

### Requirement 11: Get Grade Counts

**User Story:** As a student, I want to see how many quizzes and assignments I have completed, so that I can track my progress.

#### Acceptance Criteria

1. WHEN accessing totalItems getter THEN the System SHALL return length of _grades
2. WHEN accessing quizCount getter THEN the System SHALL return length of quizGrades list
3. WHEN accessing assignmentCount getter THEN the System SHALL return length of assignmentGrades list
4. WHEN _grades is empty THEN the System SHALL return 0 for all counts

### Requirement 12: Set Selected Class

**User Story:** As a mentor, I want to select a class to view its grades, so that I can focus on specific class performance.

#### Acceptance Criteria

1. WHEN calling setSelectedClass(classId) THEN the System SHALL update _selectedClassId = classId
2. WHEN calling setSelectedClass(null) THEN the System SHALL clear _selectedClassId
3. WHEN setSelectedClass() is called THEN the System SHALL notify listeners
4. WHEN _selectedClassId is updated THEN the System SHALL be available via selectedClassId getter

### Requirement 13: Clear Grades

**User Story:** As a system, I want to clear all grades data from the provider, so that I can reset state when needed.

#### Acceptance Criteria

1. WHEN calling clearGrades() THEN the System SHALL reset _grades to empty list
2. WHEN calling clearGrades() THEN the System SHALL reset _gradesByClass to empty map
3. WHEN calling clearGrades() THEN the System SHALL reset _studentSummaries to empty list
4. WHEN calling clearGrades() THEN the System SHALL reset _overallGPA to 0
5. WHEN calling clearGrades() THEN the System SHALL reset _classAverage to 0
6. WHEN calling clearGrades() THEN the System SHALL notify listeners

### Requirement 14: Clear Error Message

**User Story:** As a UI component, I want to clear error messages from the provider, so that old errors don't persist.

#### Acceptance Criteria

1. WHEN calling clearError() THEN the System SHALL set _errorMessage = null
2. WHEN calling clearError() THEN the System SHALL notify listeners
3. WHEN clearError() is called THEN the System SHALL be reflected in errorMessage getter

### Requirement 15: Error Handling

**User Story:** As a developer, I want proper error handling in all provider methods, so that errors are caught and reported clearly.

#### Acceptance Criteria

1. WHEN any async method throws exception THEN the System SHALL catch exception and set _errorMessage
2. WHEN exception is caught THEN the System SHALL set _isLoading = false
3. WHEN exception is caught THEN the System SHALL notify listeners
4. WHEN exception is caught THEN the System SHALL not crash the app
5. WHEN error message is set THEN the System SHALL be accessible via errorMessage getter

### Requirement 16: State Consistency

**User Story:** As a developer, I want the provider to maintain consistent state, so that UI always reflects accurate data.

#### Acceptance Criteria

1. WHEN _grades is updated THEN the System SHALL maintain consistency with _gradesByClass
2. WHEN grades are loaded THEN the System SHALL ensure _isLoading is set to false before notifying
3. WHEN error occurs THEN the System SHALL ensure _isLoading is set to false
4. WHEN state is updated THEN the System SHALL always call notifyListeners()
5. WHEN multiple operations occur THEN the System SHALL handle them without state corruption

