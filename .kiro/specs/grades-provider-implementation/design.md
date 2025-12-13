# Design Document - Grades Provider Implementation

## Overview

The GradesProvider is a ChangeNotifier-based state management component that manages grades data for both student and mentor views. It provides methods for loading grades, syncing grades from quizzes and assignments, filtering grades, calculating averages, and maintaining consistent state.

---

## Architecture

### Provider Layer

```
┌─────────────────────────────────────────────────────────────┐
│ GradesProvider (ChangeNotifier)                             │
├─────────────────────────────────────────────────────────────┤
│ State Variables:                                            │
│ ├─ _grades: List<GradeModel>                               │
│ ├─ _gradesByClass: Map<String, List<GradeModel>>           │
│ ├─ _studentSummaries: List<Map<String, dynamic>>           │
│ ├─ _overallGPA: double                                     │
│ ├─ _classAverage: double                                   │
│ ├─ _isLoading: bool                                        │
│ ├─ _errorMessage: String?                                  │
│ └─ _selectedClassId: String?                               │
│                                                             │
│ Public Methods:                                             │
│ ├─ loadMyGrades()                                          │
│ ├─ loadStudentGrades(studentId, classId)                   │
│ ├─ loadClassGradesSummary(classId)                         │
│ ├─ syncGradeFromQuiz(...)                                  │
│ ├─ syncGradeFromAssignment(...)                            │
│ ├─ setSelectedClass(classId)                               │
│ ├─ clearGrades()                                           │
│ └─ clearError()                                            │
│                                                             │
│ Computed Properties:                                        │
│ ├─ quizGrades                                              │
│ ├─ assignmentGrades                                        │
│ ├─ passingGrades                                           │
│ ├─ failingGrades                                           │
│ ├─ currentAverage                                          │
│ ├─ currentWeightedAverage                                  │
│ ├─ totalItems                                              │
│ ├─ quizCount                                               │
│ └─ assignmentCount                                         │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│ GradesService                                               │
├─────────────────────────────────────────────────────────────┤
│ ├─ fetchMyGrades()                                          │
│ ├─ fetchStudentGrades(studentId, classId)                  │
│ ├─ fetchClassGrades(classId)                               │
│ ├─ calculateStudentAverage(studentId, classId)             │
│ ├─ getStudentGradesSummary(classId)                        │
│ ├─ syncGradeFromQuiz(...)                                  │
│ └─ syncGradeFromAssignment(...)                            │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow - Load Student Grades

```
GradesPage (Student navigates to Grades tab)
  ↓
Consumer<GradesProvider>(
  builder: (context, provider, child) {
    provider.loadMyGrades()
  }
)
  ↓
GradesProvider.loadMyGrades()
  ├─ Set _isLoading = true
  ├─ Clear _errorMessage
  ├─ notifyListeners()
  ↓
GradesService.fetchMyGrades()
  ├─ Query grades table
  ├─ Return List<GradeModel>
  ↓
GradesProvider receives grades
  ├─ Update _grades
  ├─ Call GradesService.getGradesByClass()
  ├─ Update _gradesByClass
  ├─ Call GradesService.getOverallGPA()
  ├─ Update _overallGPA
  ├─ Set _isLoading = false
  ├─ notifyListeners()
  ↓
UI rebuilds with grades data
```

### Data Flow - Sync Grade from Quiz

```
StudentQuizDetailPage (Student submits quiz)
  ↓
StudentQuizProvider.submitQuiz()
  ↓
StudentQuizService.submitQuiz()
  ├─ Calculate score
  ├─ Call GradesService.syncGradeFromQuiz()
  ├─ GradesService creates grade record
  ↓
GradesProvider.syncGradeFromQuiz()
  ├─ Call GradesService.syncGradeFromQuiz()
  ├─ Receive GradeModel
  ├─ Check if grade exists in _grades
  ├─ Update or insert grade
  ├─ notifyListeners()
  ↓
UI updates with new grade
```

---

## Components and Interfaces

### 1. GradesProvider Class

```dart
class GradesProvider extends ChangeNotifier {
  final GradesService gradesService;

  GradesProvider(this.gradesService);

  // State variables
  List<GradeModel> _grades = [];
  Map<String, List<GradeModel>> _gradesByClass = {};
  List<Map<String, dynamic>> _studentSummaries = [];
  double _overallGPA = 0;
  double _classAverage = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedClassId;

  // Getters
  List<GradeModel> get grades => _grades;
  Map<String, List<GradeModel>> get gradesByClass => _gradesByClass;
  List<Map<String, dynamic>> get studentSummaries => _studentSummaries;
  double get overallGPA => _overallGPA;
  double get classAverage => _classAverage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedClassId => _selectedClassId;

  // Methods...
}
```

### 2. GradeCalculator Helper

```dart
class GradeCalculator {
  static double calculateAverage(List<GradeModel> grades) {
    if (grades.isEmpty) return 0;
    final sum = grades.fold<double>(0, (sum, grade) => sum + grade.percentage);
    return (sum / grades.length).toStringAsFixed(2) as double;
  }

  static double calculateWeightedAverage(List<GradeModel> grades) {
    if (grades.isEmpty) return 0;
    
    final quizGrades = grades.where((g) => g.isQuizGrade).toList();
    final assignmentGrades = grades.where((g) => g.isAssignmentGrade).toList();
    
    double quizAvg = quizGrades.isEmpty ? 0 : 
      quizGrades.fold<double>(0, (sum, g) => sum + g.percentage) / quizGrades.length;
    
    double assignmentAvg = assignmentGrades.isEmpty ? 0 :
      assignmentGrades.fold<double>(0, (sum, g) => sum + g.percentage) / assignmentGrades.length;
    
    // Weights: 40% quiz, 60% assignment
    return ((quizAvg * 0.4) + (assignmentAvg * 0.6)).toStringAsFixed(2) as double;
  }
}
```

---

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Loading State Consistency

*For any* async operation in GradesProvider, _isLoading SHALL be true during operation and false after completion (success or error), and notifyListeners() SHALL be called when _isLoading changes.

**Validates: Requirements 2.1, 2.6, 3.1, 3.5**

### Property 2: Error State Management

*For any* exception thrown during async operation, _errorMessage SHALL be set to exception message, _isLoading SHALL be set to false, and notifyListeners() SHALL be called.

**Validates: Requirements 2.7, 3.6, 15.1-15.4**

### Property 3: Grade Sync Idempotence

*For any* grade sync operation, syncing the same grade multiple times SHALL result in a single updated record in _grades, not duplicates.

**Validates: Requirements 5.3, 6.3**

### Property 4: Computed Property Correctness

*For any* computed property (quizGrades, assignmentGrades, passingGrades, failingGrades), the returned list SHALL be a correct filter of _grades based on the property's criteria.

**Validates: Requirements 7.1-7.4, 8.1-8.4**

### Property 5: Average Calculation Accuracy

*For any* average calculation (currentAverage, currentWeightedAverage), the returned value SHALL equal the mathematically correct average of the input grades, rounded to 2 decimal places.

**Validates: Requirements 9.3-9.5, 10.3-10.5**

### Property 6: Count Accuracy

*For any* count getter (totalItems, quizCount, assignmentCount), the returned value SHALL equal the length of the corresponding filtered list.

**Validates: Requirements 11.1-11.4**

### Property 7: State Consistency After Update

*For any* state update operation, all related state variables SHALL remain consistent with each other, and notifyListeners() SHALL be called exactly once per operation.

**Validates: Requirements 16.1-16.5**

### Property 8: Empty State Handling

*For any* operation on empty _grades, the system SHALL return appropriate empty values (0 for counts, 0 for averages, empty lists for filters) without throwing exceptions.

**Validates: Requirements 9.2, 10.2, 11.4**

### Property 9: Grade Update vs Insert

*For any* grade sync operation, if a grade with the same itemId already exists in _grades, the system SHALL update the existing record; otherwise, it SHALL insert a new record.

**Validates: Requirements 5.2-5.4, 6.2-6.4**

### Property 10: Listener Notification Timing

*For any* state change, notifyListeners() SHALL be called after all state updates are complete, ensuring UI receives consistent state.

**Validates: Requirements 2.6, 3.5, 4.5, 12.3, 13.6, 14.2**

---

## Error Handling

### Error Categories

1. **Service Errors**
   - GradesService throws exception
   - Network connectivity issues
   - Database query failures

2. **State Errors**
   - Invalid state transitions
   - Concurrent operation conflicts
   - State corruption

3. **Business Logic Errors**
   - Invalid grade data
   - Missing required fields
   - Calculation errors

### Error Response

```dart
Future<void> loadMyGrades() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    _grades = await gradesService.fetchMyGrades();
    _gradesByClass = await gradesService.getGradesByClass();
    _overallGPA = await gradesService.getOverallGPA();
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## Testing Strategy

### Unit Testing

- Test state initialization
- Test getters return correct values
- Test computed properties with various inputs
- Test error handling
- Test state consistency

### Property-Based Testing

- **Property 1**: Loading state consistency (100+ iterations)
- **Property 2**: Error state management (100+ iterations)
- **Property 3**: Grade sync idempotence (100+ iterations)
- **Property 4**: Computed property correctness (100+ iterations)
- **Property 5**: Average calculation accuracy (100+ iterations)
- **Property 6**: Count accuracy (100+ iterations)
- **Property 7**: State consistency after update (100+ iterations)
- **Property 8**: Empty state handling (100+ iterations)
- **Property 9**: Grade update vs insert (100+ iterations)
- **Property 10**: Listener notification timing (100+ iterations)

### Integration Testing

- Test loadMyGrades() with real GradesService
- Test loadStudentGrades() with real GradesService
- Test loadClassGradesSummary() with real GradesService
- Test syncGradeFromQuiz() with real GradesService
- Test syncGradeFromAssignment() with real GradesService
- Test multiple operations in sequence
- Test error scenarios

---

## Success Criteria

✅ GradesProvider properly initialized  
✅ All state variables initialized correctly  
✅ All getters working correctly  
✅ loadMyGrades() working correctly  
✅ loadStudentGrades() working correctly  
✅ loadClassGradesSummary() working correctly  
✅ syncGradeFromQuiz() working correctly  
✅ syncGradeFromAssignment() working correctly  
✅ All computed properties working correctly  
✅ Error handling robust  
✅ State consistency maintained  
✅ All tests passing  

