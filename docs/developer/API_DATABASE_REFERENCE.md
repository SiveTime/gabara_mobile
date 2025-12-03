# 🔧 API & DATABASE REFERENCE

**Date:** December 3, 2025  
**Status:** ✅ COMPLETE  
**Target Audience:** Backend Developers, Database Administrators  
**Document Type:** Technical Reference

---

## 📋 TABLE OF CONTENTS

1. [Database Schema](#database-schema)
2. [API Endpoints](#api-endpoints)
3. [Data Models](#data-models)
4. [Error Handling](#error-handling)
5. [Authentication](#authentication)
6. [Rate Limiting](#rate-limiting)
7. [Examples](#examples)

---

## DATABASE SCHEMA

### Meetings Table

```sql
CREATE TABLE meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  meeting_type VARCHAR(50) NOT NULL CHECK (meeting_type IN ('online', 'offline')),
  meeting_link VARCHAR(500),
  location VARCHAR(255),
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Indexes
  INDEX idx_meetings_class_id (class_id),
  INDEX idx_meetings_created_by (created_by),
  INDEX idx_meetings_meeting_date (meeting_date),
  INDEX idx_meetings_status (status)
);
```

**Constraints:**
- `meeting_type` must be 'online' or 'offline'
- `status` must be one of: scheduled, ongoing, completed, cancelled
- `meeting_date` must be in future for new meetings
- `duration_minutes` must be positive

**Indexes:**
- `class_id` - for filtering by class
- `created_by` - for filtering by mentor
- `meeting_date` - for sorting by date
- `status` - for filtering by status

---

### Attendance Table

```sql
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  status VARCHAR(50) NOT NULL CHECK (status IN ('present', 'absent', 'late')),
  marked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Unique constraint
  UNIQUE(meeting_id, student_id),
  
  -- Indexes
  INDEX idx_attendance_meeting_id (meeting_id),
  INDEX idx_attendance_student_id (student_id),
  INDEX idx_attendance_status (status)
);
```

**Constraints:**
- `status` must be one of: present, absent, late
- `meeting_id` and `student_id` combination must be unique
- Cascade delete when meeting is deleted

**Indexes:**
- `meeting_id` - for fetching attendance by meeting
- `student_id` - for fetching attendance by student
- `status` - for filtering by status

---

### Assignments Table

```sql
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  meeting_id UUID REFERENCES meetings(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  max_score INTEGER DEFAULT 100 CHECK (max_score > 0),
  attachment_url VARCHAR(500),
  is_active BOOLEAN DEFAULT true,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Indexes
  INDEX idx_assignments_class_id (class_id),
  INDEX idx_assignments_meeting_id (meeting_id),
  INDEX idx_assignments_created_by (created_by),
  INDEX idx_assignments_deadline (deadline),
  INDEX idx_assignments_is_active (is_active)
);
```

**Constraints:**
- `max_score` must be positive
- `deadline` must be in future for new assignments
- `meeting_id` is optional (can be NULL)
- Cascade delete when class is deleted
- Set NULL when meeting is deleted

**Indexes:**
- `class_id` - for filtering by class
- `meeting_id` - for filtering by meeting
- `created_by` - for filtering by mentor
- `deadline` - for sorting by deadline
- `is_active` - for filtering active assignments

---

### Assignment Submissions Table

```sql
CREATE TABLE assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT,
  attachment_url VARCHAR(500),
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'late', 'graded')),
  submitted_at TIMESTAMP WITH TIME ZONE,
  score DECIMAL(5,2) CHECK (score >= 0 AND score <= 100),
  feedback TEXT,
  graded_at TIMESTAMP WITH TIME ZONE,
  graded_by UUID REFERENCES auth.users(id),
  
  -- Unique constraint
  UNIQUE(assignment_id, user_id),
  
  -- Indexes
  INDEX idx_submissions_assignment_id (assignment_id),
  INDEX idx_submissions_user_id (user_id),
  INDEX idx_submissions_status (status),
  INDEX idx_submissions_submitted_at (submitted_at)
);
```

**Constraints:**
- `status` must be one of: draft, submitted, late, graded
- `score` must be between 0 and 100
- `assignment_id` and `user_id` combination must be unique
- Cascade delete when assignment is deleted

**Indexes:**
- `assignment_id` - for fetching submissions by assignment
- `user_id` - for fetching submissions by student
- `status` - for filtering by status
- `submitted_at` - for sorting by submission time

---

## API ENDPOINTS

### Meetings Endpoints

#### Create Meeting

```
POST /api/meetings
Content-Type: application/json
Authorization: Bearer {token}

{
  "class_id": "uuid",
  "title": "string",
  "description": "string",
  "meeting_date": "2025-12-03T10:00:00Z",
  "duration_minutes": 60,
  "meeting_type": "online|offline",
  "meeting_link": "string",
  "location": "string"
}

Response: 201 Created
{
  "id": "uuid",
  "class_id": "uuid",
  "title": "string",
  "description": "string",
  "meeting_date": "2025-12-03T10:00:00Z",
  "duration_minutes": 60,
  "meeting_type": "online",
  "meeting_link": "string",
  "location": "string",
  "status": "scheduled",
  "created_by": "uuid",
  "created_at": "2025-12-03T09:00:00Z",
  "updated_at": "2025-12-03T09:00:00Z"
}
```

**Validation:**
- `title` required, max 255 chars
- `meeting_date` required, must be future
- `duration_minutes` required, must be positive
- `meeting_type` required, must be 'online' or 'offline'
- `meeting_link` required if online
- `location` required if offline

---

#### Get Meetings by Mentor

```
GET /api/meetings?mentor=true
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": "uuid",
    "class_id": "uuid",
    "title": "string",
    ...
  }
]
```

**Query Parameters:**
- `mentor=true` - get meetings created by current user
- `class_id=uuid` - filter by class
- `status=scheduled` - filter by status
- `sort=date` - sort by date
- `limit=10` - pagination limit
- `offset=0` - pagination offset

---

#### Get Meeting by ID

```
GET /api/meetings/{id}
Authorization: Bearer {token}

Response: 200 OK
{
  "id": "uuid",
  "class_id": "uuid",
  "title": "string",
  ...
}
```

---

#### Update Meeting

```
PUT /api/meetings/{id}
Content-Type: application/json
Authorization: Bearer {token}

{
  "title": "string",
  "description": "string",
  "meeting_date": "2025-12-03T10:00:00Z",
  "duration_minutes": 60,
  "meeting_type": "online|offline",
  "meeting_link": "string",
  "location": "string",
  "status": "scheduled|ongoing|completed|cancelled"
}

Response: 200 OK
{
  "id": "uuid",
  ...
}
```

**Validation:**
- User must be creator of meeting
- Cannot update if meeting already started

---

#### Delete Meeting

```
DELETE /api/meetings/{id}
Authorization: Bearer {token}

Response: 204 No Content
```

**Validation:**
- User must be creator of meeting
- Cascade deletes attendance records

---

#### Mark Attendance

```
POST /api/meetings/{id}/attendance
Content-Type: application/json
Authorization: Bearer {token}

{
  "student_id": "uuid",
  "status": "present|absent|late"
}

Response: 201 Created
{
  "id": "uuid",
  "meeting_id": "uuid",
  "student_id": "uuid",
  "status": "present",
  "marked_at": "2025-12-03T10:00:00Z"
}
```

---

#### Get Attendance

```
GET /api/meetings/{id}/attendance
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": "uuid",
    "meeting_id": "uuid",
    "student_id": "uuid",
    "status": "present",
    "marked_at": "2025-12-03T10:00:00Z",
    "student_name": "string"
  }
]
```

---

### Assignments Endpoints

#### Create Assignment

```
POST /api/assignments
Content-Type: application/json
Authorization: Bearer {token}

{
  "class_id": "uuid",
  "meeting_id": "uuid|null",
  "title": "string",
  "description": "string",
  "deadline": "2025-12-10T23:59:59Z",
  "max_score": 100,
  "attachment_url": "string",
  "is_active": true
}

Response: 201 Created
{
  "id": "uuid",
  "class_id": "uuid",
  "meeting_id": "uuid|null",
  "title": "string",
  ...
}
```

**Validation:**
- `title` required, max 255 chars
- `deadline` required, must be future
- `max_score` required, must be positive
- `class_id` required

---

#### Get Assignments by Mentor

```
GET /api/assignments?mentor=true
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": "uuid",
    "class_id": "uuid",
    ...
  }
]
```

**Query Parameters:**
- `mentor=true` - get assignments created by current user
- `class_id=uuid` - filter by class
- `meeting_id=uuid` - filter by meeting
- `sort=deadline` - sort by deadline
- `limit=10` - pagination limit
- `offset=0` - pagination offset

---

#### Get Assignment by ID

```
GET /api/assignments/{id}
Authorization: Bearer {token}

Response: 200 OK
{
  "id": "uuid",
  "class_id": "uuid",
  ...
}
```

---

#### Update Assignment

```
PUT /api/assignments/{id}
Content-Type: application/json
Authorization: Bearer {token}

{
  "title": "string",
  "description": "string",
  "deadline": "2025-12-10T23:59:59Z",
  "max_score": 100,
  "attachment_url": "string",
  "is_active": true
}

Response: 200 OK
{
  "id": "uuid",
  ...
}
```

**Validation:**
- User must be creator of assignment
- Cannot update if submissions exist

---

#### Delete Assignment

```
DELETE /api/assignments/{id}
Authorization: Bearer {token}

Response: 204 No Content
```

**Validation:**
- User must be creator of assignment
- Cascade deletes submissions

---

#### Submit Assignment

```
POST /api/assignments/{id}/submit
Content-Type: application/json
Authorization: Bearer {token}

{
  "content": "string",
  "attachment_url": "string"
}

Response: 201 Created
{
  "id": "uuid",
  "assignment_id": "uuid",
  "user_id": "uuid",
  "content": "string",
  "attachment_url": "string",
  "status": "submitted|late",
  "submitted_at": "2025-12-03T10:00:00Z"
}
```

**Validation:**
- User must be enrolled in class
- Cannot submit if already graded
- Automatically detects late submission

---

#### Get Submissions

```
GET /api/assignments/{id}/submissions
Authorization: Bearer {token}

Response: 200 OK
[
  {
    "id": "uuid",
    "assignment_id": "uuid",
    "user_id": "uuid",
    "content": "string",
    "status": "submitted",
    "submitted_at": "2025-12-03T10:00:00Z",
    "score": 85,
    "feedback": "string",
    "student_name": "string"
  }
]
```

**Query Parameters:**
- `status=submitted` - filter by status
- `sort=submitted_at` - sort by submission time
- `limit=10` - pagination limit
- `offset=0` - pagination offset

---

#### Grade Submission

```
POST /api/submissions/{id}/grade
Content-Type: application/json
Authorization: Bearer {token}

{
  "score": 85,
  "feedback": "string"
}

Response: 200 OK
{
  "id": "uuid",
  "assignment_id": "uuid",
  "user_id": "uuid",
  "status": "graded",
  "score": 85,
  "feedback": "string",
  "graded_at": "2025-12-03T10:00:00Z",
  "graded_by": "uuid"
}
```

**Validation:**
- User must be creator of assignment
- `score` must be between 0 and max_score
- Cannot grade if already graded

---

## DATA MODELS

### MeetingModel

```dart
class MeetingModel {
  final String id;
  final String classId;
  final String title;
  final String? description;
  final DateTime meetingDate;
  final int durationMinutes;
  final String meetingType; // 'online' or 'offline'
  final String? meetingLink;
  final String? location;
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

---

### AttendanceModel

```dart
class AttendanceModel {
  final String id;
  final String meetingId;
  final String studentId;
  final String status; // 'present', 'absent', 'late'
  final DateTime? markedAt;
  final String? studentName;
}
```

---

### AssignmentModel

```dart
class AssignmentModel {
  final String id;
  final String classId;
  final String? meetingId;
  final String title;
  final String? description;
  final DateTime deadline;
  final int maxScore;
  final String? attachmentUrl;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

---

### SubmissionModel

```dart
class SubmissionModel {
  final String id;
  final String assignmentId;
  final String userId;
  final String content;
  final String? attachmentUrl;
  final String status; // 'draft', 'submitted', 'late', 'graded'
  final DateTime? submittedAt;
  final double? score;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final String? studentName;
}
```

---

## ERROR HANDLING

### Error Response Format

```json
{
  "error": "error_code",
  "message": "Human readable message",
  "details": {
    "field": "error details"
  }
}
```

### Common Error Codes

| Code | Status | Message |
|------|--------|---------|
| `UNAUTHORIZED` | 401 | User not authenticated |
| `FORBIDDEN` | 403 | User not authorized |
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `CONFLICT` | 409 | Resource already exists |
| `INTERNAL_ERROR` | 500 | Server error |

### Example Error Response

```json
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid input data",
  "details": {
    "title": "Title is required",
    "meeting_date": "Meeting date must be in future"
  }
}
```

---

## AUTHENTICATION

### Bearer Token

All API requests require Bearer token in Authorization header:

```
Authorization: Bearer {token}
```

### Token Acquisition

Tokens are obtained through Supabase authentication:

```dart
final response = await supabaseClient.auth.signInWithPassword(
  email: email,
  password: password,
);
final token = response.session?.accessToken;
```

### Token Refresh

Tokens expire after 1 hour. Refresh using:

```dart
final response = await supabaseClient.auth.refreshSession();
final newToken = response.session?.accessToken;
```

---

## RATE LIMITING

### Limits

- **Authenticated Users:** 1000 requests per hour
- **Unauthenticated:** 100 requests per hour
- **Burst:** 50 requests per minute

### Rate Limit Headers

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1701619200
```

### Rate Limit Exceeded

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Retry-After: 60
```

---

## EXAMPLES

### Example 1: Create Meeting

```dart
final meetingService = MeetingService(supabaseClient);

final meeting = MeetingModel(
  id: '', // Will be generated
  classId: 'class-123',
  title: 'Introduction to Dart',
  description: 'Learn Dart basics',
  meetingDate: DateTime(2025, 12, 10, 10, 0),
  durationMinutes: 60,
  meetingType: 'online',
  meetingLink: 'https://meet.google.com/abc-def-ghi',
  location: null,
  status: 'scheduled',
  createdBy: 'user-123',
);

final created = await meetingService.createMeeting(meeting);
print('Meeting created: ${created?.id}');
```

---

### Example 2: Mark Attendance

```dart
final attendance = await meetingService.markAttendance(
  meetingId: 'meeting-123',
  studentId: 'student-456',
  status: 'present',
);

print('Attendance marked: ${attendance?.id}');
```

---

### Example 3: Create Assignment

```dart
final assignmentService = AssignmentService(supabaseClient);

final assignment = AssignmentModel(
  id: '',
  classId: 'class-123',
  meetingId: 'meeting-123',
  title: 'Dart Assignment 1',
  description: 'Complete the Dart exercises',
  deadline: DateTime(2025, 12, 15, 23, 59),
  maxScore: 100,
  attachmentUrl: 'https://example.com/assignment.pdf',
  isActive: true,
  createdBy: 'user-123',
);

final created = await assignmentService.createAssignment(assignment);
print('Assignment created: ${created?.id}');
```

---

### Example 4: Submit Assignment

```dart
final submission = SubmissionModel(
  id: '',
  assignmentId: 'assignment-123',
  userId: 'student-456',
  content: 'My solution to the assignment',
  attachmentUrl: 'https://example.com/submission.pdf',
  status: 'draft',
);

final submitted = await assignmentService.submitAssignment(submission);
print('Submission status: ${submitted?.status}'); // 'submitted' or 'late'
```

---

### Example 5: Grade Submission

```dart
final graded = await assignmentService.gradeSubmission(
  submissionId: 'submission-123',
  score: 85,
  feedback: 'Great work! Well done.',
);

print('Grade: ${graded?.score}');
```

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2025  
**Status:** ✅ COMPLETE
