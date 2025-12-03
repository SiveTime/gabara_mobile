# Design Document - Meetings, Assignments & Grades Integration

## Overview

Fitur Meetings, Assignments, dan Grades adalah sistem terintegrasi yang memungkinkan mentor mengelola pertemuan kelas dan tugas siswa, serta memberikan nilai. Sistem ini juga menyediakan dashboard grades yang menampilkan nilai siswa dari berbagai sumber (quiz dan assignment) dalam satu tempat terpusat.

### Key Features

1. **Meeting Management**: CRUD operations untuk meetings dengan tracking attendance
2. **Assignment Management**: CRUD operations untuk assignments dengan submission tracking
3. **Grading System**: Mentor dapat memberikan nilai untuk assignment submissions
4. **Grades Dashboard**: Terintegrasi dengan quiz grades untuk menampilkan nilai komprehensif
5. **Student Views**: Student dapat melihat meetings, assignments, dan grades mereka
6. **Attendance Tracking**: Mentor dapat mencatat kehadiran siswa dalam meetings

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer (Pages, Widgets, Providers)              │
├─────────────────────────────────────────────────────────────┤
│ - MeetingPages (Create, Read, Update, Delete)               │
│ - AssignmentPages (Create, Read, Update, Delete)            │
│ - SubmissionPages (View, Submit, Grade)                     │
│ - GradesPages (Dashboard, Detail)                           │
│ - Providers (State Management)                              │
├─────────────────────────────────────────────────────────────┤
│ Domain Layer (Entities, Repositories, UseCases)             │
├─────────────────────────────────────────────────────────────┤
│ - MeetingEntity, AssignmentEntity, SubmissionEntity         │
│ - MeetingRepository, AssignmentRepository                   │
│ - UseCases (CreateMeeting, SubmitAssignment, etc)           │
├─────────────────────────────────────────────────────────────┤
│ Data Layer (Models, Services)                               │
├─────────────────────────────────────────────────────────────┤
│ - MeetingModel, AssignmentModel, SubmissionModel            │
│ - MeetingService, AssignmentService (Supabase)              │
│ - Local Cache (Hive/SQLite for offline support)             │
├─────────────────────────────────────────────────────────────┤
│ Supabase Backend                                            │
├─────────────────────────────────────────────────────────────┤
│ - meetings, assignments, submissions, attendance tables     │
│ - RLS policies untuk security                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action (Create Meeting)
  ↓
Page (CreateMeetingPage)
  ↓
Provider (MeetingProvider.createMeeting())
  ↓
UseCase (CreateMeeting)
  ↓
Repository (MeetingRepository)
  ↓
Service (MeetingService)
  ↓
Supabase (INSERT into meetings table)
  ↓
Response (Meeting created)
  ↓
Provider (Update state, notifyListeners)
  ↓
UI (Navigate to detail page)
```

---

## Components and Interfaces

### 1. Meeting Feature

#### MeetingEntity
```dart
class MeetingEntity {
  final String id;
  final String classId;
  final String title;
  final String description;
  final DateTime meetingDate;
  final int durationMinutes;
  final String meetingType; // 'online' | 'offline'
  final String? meetingLink; // for online meetings
  final String? location; // for offline meetings
  final String status; // 'scheduled' | 'ongoing' | 'completed' | 'cancelled'
  final String createdBy; // mentor user_id
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### MeetingService Interface
```dart
abstract class IMeetingService {
  Future<MeetingModel?> createMeeting(MeetingModel meeting);
  Future<List<MeetingModel>> fetchMeetingsByMentor(String mentorId);
  Future<List<MeetingModel>> fetchMeetingsByClass(String classId);
  Future<MeetingModel?> fetchMeetingById(String meetingId);
  Future<MeetingModel?> updateMeeting(MeetingModel meeting);
  Future<void> deleteMeeting(String meetingId);
  Future<void> markAttendance(String meetingId, String studentId, String status);
  Future<List<AttendanceModel>> fetchAttendance(String meetingId);
}
```

### 2. Assignment Feature

#### AssignmentEntity
```dart
class AssignmentEntity {
  final String id;
  final String classId;
  final String title;
  final String description;
  final DateTime deadline;
  final int maxScore;
  final String? attachmentUrl;
  final String status; // 'active' | 'closed'
  final String createdBy; // mentor user_id
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### SubmissionEntity
```dart
class SubmissionEntity {
  final String id;
  final String assignmentId;
  final String studentId;
  final String content;
  final String? attachmentUrl;
  final String status; // 'draft' | 'submitted' | 'graded' | 'late' | 'returned'
  final DateTime? submittedAt;
  final double? score;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### AssignmentService Interface
```dart
abstract class IAssignmentService {
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment);
  Future<List<AssignmentModel>> fetchAssignmentsByMentor(String mentorId);
  Future<List<AssignmentModel>> fetchAssignmentsByClass(String classId);
  Future<AssignmentModel?> fetchAssignmentById(String assignmentId);
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment);
  Future<void> deleteAssignment(String assignmentId);
  
  Future<SubmissionModel?> submitAssignment(SubmissionModel submission);
  Future<List<SubmissionModel>> fetchSubmissions(String assignmentId);
  Future<SubmissionModel?> fetchSubmission(String submissionId);
  Future<SubmissionModel?> gradeSubmission(String submissionId, double score, String feedback);
}
```

### 3. Grades Feature

#### GradeEntity
```dart
class GradeEntity {
  final String id;
  final String studentId;
  final String classId;
  final String itemId; // quiz_id or assignment_id
  final String itemType; // 'quiz' | 'assignment'
  final double score;
  final double maxScore;
  final double percentage;
  final DateTime recordedAt;
}
```

#### GradesService Interface
```dart
abstract class IGradesService {
  Future<List<GradeEntity>> fetchStudentGrades(String studentId, String classId);
  Future<List<GradeEntity>> fetchClassGrades(String classId);
  Future<double> calculateStudentAverage(String studentId, String classId);
  Future<void> syncGradesFromQuiz(String quizAttemptId);
  Future<void> syncGradesFromAssignment(String submissionId);
}
```

---

## Data Models

### Database Schema

#### meetings table
```sql
CREATE TABLE meetings (
  id UUID PRIMARY KEY,
  class_id UUID NOT NULL REFERENCES classes(id),
  title TEXT NOT NULL,
  description TEXT,
  meeting_date TIMESTAMP NOT NULL,
  duration_minutes INTEGER NOT NULL,
  meeting_type TEXT NOT NULL, -- 'online' | 'offline'
  meeting_link TEXT, -- for online
  location TEXT, -- for offline
  status TEXT NOT NULL DEFAULT 'scheduled',
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### attendance table
```sql
CREATE TABLE attendance (
  id UUID PRIMARY KEY,
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL, -- 'present' | 'absent' | 'late' | 'excused'
  marked_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(meeting_id, student_id)
);
```

#### assignments table
```sql
CREATE TABLE assignments (
  id UUID PRIMARY KEY,
  class_id UUID NOT NULL REFERENCES classes(id),
  title TEXT NOT NULL,
  description TEXT,
  deadline TIMESTAMP NOT NULL,
  max_score INTEGER NOT NULL,
  attachment_url TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### submissions table
```sql
CREATE TABLE submissions (
  id UUID PRIMARY KEY,
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT NOT NULL,
  attachment_url TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  submitted_at TIMESTAMP,
  score DECIMAL(5,2),
  feedback TEXT,
  graded_at TIMESTAMP,
  graded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(assignment_id, student_id)
);
```

#### grades table
```sql
CREATE TABLE grades (
  id UUID PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  class_id UUID NOT NULL REFERENCES classes(id),
  item_id UUID NOT NULL, -- quiz_id or assignment_id
  item_type TEXT NOT NULL, -- 'quiz' | 'assignment'
  score DECIMAL(5,2) NOT NULL,
  max_score DECIMAL(5,2) NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  recorded_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(student_id, item_id)
);
```

---

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Meeting Creation Consistency
**For any** valid meeting data, creating a meeting should result in a meeting record in the database with all fields correctly stored and retrievable.

**Validates: Requirements 1.1-1.8**

### Property 2: Meeting Status Transitions
**For any** meeting, the status should only transition through valid states: scheduled → ongoing → completed (or cancelled at any point).

**Validates: Requirements 2.1-2.9**

### Property 3: Assignment Deadline Immutability After Submission
**For any** assignment with at least one submission, the deadline should not be modifiable to maintain data integrity.

**Validates: Requirements 7.1-7.5**

### Property 4: Submission Score Bounds
**For any** graded submission, the score should be between 0 and the assignment's max_score.

**Validates: Requirements 9.1-9.5**

### Property 5: Late Submission Detection
**For any** submission submitted after the assignment deadline, the submission status should be marked as "late".

**Validates: Requirements 12.1-12.6**

### Property 6: Grade Calculation Accuracy
**For any** student in a class, the calculated average grade should equal the sum of all item scores divided by the count of graded items.

**Validates: Requirements 13.1-13.5**

### Property 7: Attendance Record Uniqueness
**For any** meeting, there should be exactly one attendance record per enrolled student.

**Validates: Requirements 15.1-15.5**

### Property 8: Cascade Delete Preservation
**For any** deleted meeting or assignment, related records (attendance, submissions) should be preserved for historical audit trail.

**Validates: Requirements 16.1-16.6**

### Property 9: Submission Status Consistency
**For any** submission, the status should reflect the actual state: draft (not submitted), submitted (submitted but not graded), graded (has score), late (submitted after deadline), returned (graded and returned for revision).

**Validates: Requirements 12.1-12.6**

### Property 10: Mentor Authorization
**For any** meeting or assignment, only the creating mentor should be able to edit or delete it.

**Validates: Requirements 3.1-3.4, 7.1-7.5, 8.1-8.4**

---

## Error Handling

### Meeting Errors
- **MeetingNotFound**: Meeting dengan ID tidak ditemukan
- **InvalidMeetingDate**: Tanggal meeting di masa lalu
- **InvalidMeetingType**: Tipe meeting tidak valid (online/offline)
- **MissingMeetingLink**: Meeting online tanpa meeting link
- **UnauthorizedMeetingAccess**: User bukan pembuat meeting

### Assignment Errors
- **AssignmentNotFound**: Assignment dengan ID tidak ditemukan
- **InvalidDeadline**: Deadline di masa lalu
- **InvalidMaxScore**: Max score negatif atau 0
- **AssignmentHasSubmissions**: Tidak bisa edit deadline/score jika ada submissions
- **UnauthorizedAssignmentAccess**: User bukan pembuat assignment

### Submission Errors
- **SubmissionNotFound**: Submission dengan ID tidak ditemukan
- **SubmissionAlreadyGraded**: Tidak bisa edit submission yang sudah dinilai
- **InvalidScore**: Score di luar range 0-maxScore
- **DeadlinePassed**: Tidak bisa submit setelah deadline (tapi bisa dengan status late)
- **DuplicateSubmission**: Student sudah submit untuk assignment ini

### Grades Errors
- **NoGradesFound**: Tidak ada grades untuk student/class
- **GradeCalculationError**: Error saat menghitung average grade
- **SyncError**: Error saat sync grades dari quiz/assignment

---

## Testing Strategy

### Unit Testing

**Meeting Service Tests**
- Test create meeting dengan valid data
- Test create meeting dengan invalid date (past)
- Test fetch meetings by mentor
- Test update meeting
- Test delete meeting
- Test mark attendance

**Assignment Service Tests**
- Test create assignment dengan valid data
- Test create assignment dengan invalid deadline
- Test fetch assignments by class
- Test update assignment (with and without submissions)
- Test delete assignment
- Test cascade delete submissions

**Submission Service Tests**
- Test submit assignment
- Test late submission detection
- Test grade submission
- Test update submission before deadline
- Test prevent edit after grading

**Grades Service Tests**
- Test calculate student average
- Test fetch student grades
- Test sync grades from quiz
- Test sync grades from assignment

### Property-Based Testing

**Property 1: Meeting Creation Consistency**
- Generate random valid meeting data
- Create meeting
- Fetch meeting by ID
- Verify all fields match

**Property 2: Meeting Status Transitions**
- Generate random meeting
- Test valid status transitions
- Verify invalid transitions are rejected

**Property 3: Assignment Deadline Immutability**
- Create assignment
- Create submission
- Attempt to update deadline
- Verify deadline unchanged

**Property 4: Submission Score Bounds**
- Generate random assignment with max_score
- Generate random score between 0 and max_score
- Grade submission
- Verify score is within bounds

**Property 5: Late Submission Detection**
- Create assignment with deadline
- Submit after deadline
- Verify status is "late"

**Property 6: Grade Calculation Accuracy**
- Create multiple submissions with scores
- Calculate average
- Verify average = sum / count

**Property 7: Attendance Record Uniqueness**
- Create meeting
- Mark attendance for multiple students
- Verify exactly one record per student

**Property 8: Cascade Delete Preservation**
- Create meeting with attendance records
- Delete meeting
- Verify attendance records still exist

**Property 9: Submission Status Consistency**
- Test all status transitions
- Verify status reflects actual state

**Property 10: Mentor Authorization**
- Create meeting as mentor A
- Attempt to edit as mentor B
- Verify unauthorized error

### Integration Testing

**Meeting Flow**
- Create meeting → View meeting → Update meeting → Delete meeting
- Create meeting → Mark attendance → View attendance

**Assignment Flow**
- Create assignment → View assignment → Student submit → Mentor grade → View grades

**Grades Flow**
- Complete quiz → Complete assignment → View grades dashboard
- Verify grades from both sources appear

### Test Framework

- **Unit Tests**: `flutter_test` with `mockito` for mocking Supabase
- **Property Tests**: `glados` for property-based testing
- **Integration Tests**: `integration_test` package

---

## Implementation Phases

### Phase 1: Data Layer & Models (Week 1)
- Create entities (Meeting, Assignment, Submission, Grade)
- Create models with serialization
- Create services (MeetingService, AssignmentService)
- Create repositories

### Phase 2: Domain Layer (Week 1)
- Create use cases
- Create validators
- Create repository interfaces

### Phase 3: Presentation Layer - Mentor (Week 2)
- Create meeting pages (CRUD)
- Create assignment pages (CRUD)
- Create submission grading page
- Create providers

### Phase 4: Presentation Layer - Student (Week 2)
- Create student meeting view
- Create student assignment view
- Create submission page
- Create student providers

### Phase 5: Grades Integration (Week 3)
- Create grades service
- Create grades dashboard (mentor & student)
- Integrate with quiz grades
- Create grades providers

### Phase 6: Testing & Polish (Week 3)
- Write unit tests
- Write property tests
- Write integration tests
- Bug fixes and optimization

---

## Security Considerations

### Row Level Security (RLS)

1. **Meetings**: Only mentor who created can view/edit/delete. Students can view meetings for their classes.
2. **Assignments**: Only mentor who created can view/edit/delete. Students can view assignments for their classes.
3. **Submissions**: Students can only view/edit their own submissions. Mentors can view all submissions for their assignments.
4. **Attendance**: Only mentor who created meeting can view/edit. Students can view their own attendance.
5. **Grades**: Students can only view their own grades. Mentors can view grades for their classes.

### Input Validation

- Validate all date/time inputs
- Validate score ranges
- Validate file uploads (size, type)
- Sanitize text inputs

### Authorization Checks

- Verify mentor ownership before edit/delete
- Verify student enrollment before allowing submission
- Verify deadline before allowing submission

---

## Performance Considerations

1. **Pagination**: Implement pagination for large lists (meetings, assignments, submissions)
2. **Caching**: Cache frequently accessed data (class info, student list)
3. **Lazy Loading**: Load submissions only when needed
4. **Indexing**: Add database indexes on frequently queried fields (class_id, created_by, student_id)
5. **Batch Operations**: Batch mark attendance for multiple students

---

## Future Enhancements

1. **Notifications**: Send notifications for meetings, assignments, grades
2. **Offline Support**: Cache data locally for offline access
3. **Analytics**: Track student engagement and performance trends
4. **Rubrics**: Support detailed grading rubrics for assignments
5. **Peer Review**: Allow students to review each other's work
6. **Late Submission Policy**: Configurable late submission penalties
7. **Bulk Operations**: Bulk grade submissions, bulk mark attendance
8. **Export**: Export grades to CSV/PDF

