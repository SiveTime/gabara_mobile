# Implementation Plan - Meetings, Assignments & Grades

## Overview

Implementation plan untuk fitur Meetings, Assignments, dan Grades Integration. Setiap task dirancang untuk incremental progress dengan testing di setiap tahap.

---

## Phase 1: Data Layer & Models Setup

- [x] 1. Set up project structure and core interfaces


  - Create directory structure: `lib/features/meetings/`, `lib/features/assignments/`, `lib/features/grades/`
  - Each feature follows: `data/`, `domain/`, `presentation/`
  - Create base service interfaces
  - _Requirements: 1.1, 5.1, 13.1_



- [ ] 1.1 Create Meeting entities and models
  - Define `MeetingEntity` with all required fields
  - Create `MeetingModel` with serialization (fromJson, toJson)
  - Create `AttendanceEntity` and `AttendanceModel`
  - Add validation methods


  - _Requirements: 1.1, 2.1_

- [ ] 1.2 Write property test for Meeting model serialization
  - **Property 1: Meeting Creation Consistency**

  - **Validates: Requirements 1.1-1.8**

- [ ] 1.3 Create Assignment entities and models
  - Define `AssignmentEntity` with all required fields


  - Create `AssignmentModel` with serialization
  - Create `SubmissionEntity` and `SubmissionModel`
  - Add validation methods
  - _Requirements: 5.1, 12.1_

- [x] 1.4 Write property test for Assignment model serialization

  - **Property 3: Assignment Deadline Immutability After Submission**


  - **Validates: Requirements 7.1-7.5**

- [ ] 1.5 Create Grade entities and models
  - Define `GradeEntity` with all required fields
  - Create `GradeModel` with serialization
  - Add calculation methods (percentage, average)
  - _Requirements: 13.1, 14.1_


- [ ] 1.6 Write property test for Grade calculation accuracy
  - **Property 6: Grade Calculation Accuracy**


  - **Validates: Requirements 13.1-13.5**

- [ ] 1.7 Create database schema migration scripts
  - Create SQL migration for meetings table
  - Create SQL migration for attendance table
  - Create SQL migration for assignments table


  - Create SQL migration for submissions table
  - Create SQL migration for grades table
  - Add indexes for performance
  - _Requirements: 16.1-16.6_

- [ ] 1.8 Checkpoint - Verify all models and migrations
  - Ensure all models compile without errors

  - Verify database schema is correct


  - Test model serialization/deserialization

---

## Phase 2: Domain Layer - Repositories & UseCases


- [x] 2. Create repository interfaces and implementations


  - Create `IMeetingRepository` interface
  - Create `MeetingRepositoryImpl` implementation
  - Create `IAssignmentRepository` interface
  - Create `AssignmentRepositoryImpl` implementation
  - Create `IGradesRepository` interface

  - Create `GradesRepositoryImpl` implementation
  - _Requirements: 1.1, 5.1, 13.1_



- [ ] 2.1 Create Meeting use cases
  - `CreateMeetingUseCase`

  - `GetMeetingsByMentorUseCase`
  - `GetMeetingsByClassUseCase`
  - `UpdateMeetingUseCase`
  - `DeleteMeetingUseCase`

  - `MarkAttendanceUseCase`

  - _Requirements: 1.1-1.8, 2.1-2.9_

- [ ] 2.2 Create Assignment use cases
  - `CreateAssignmentUseCase`


  - `GetAssignmentsByMentorUseCase`
  - `GetAssignmentsByClassUseCase`
  - `UpdateAssignmentUseCase`
  - `DeleteAssignmentUseCase`


  - `SubmitAssignmentUseCase`


  - `GradeSubmissionUseCase`
  - _Requirements: 5.1-5.8, 9.1-9.5, 12.1-12.6_

- [ ] 2.3 Create Grades use cases
  - `GetStudentGradesUseCase`
  - `GetClassGradesUseCase`
  - `CalculateStudentAverageUseCase`

  - `SyncGradesFromQuizUseCase`
  - `SyncGradesFromAssignmentUseCase`
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 2.4 Create validators
  - `MeetingValidator` (validate date, type, link/location)
  - `AssignmentValidator` (validate deadline, max_score)
  - `SubmissionValidator` (validate score bounds)
  - `GradeValidator` (validate grade data)
  - _Requirements: 16.1-16.6_



- [ ] 2.5 Write property tests for use cases
  - **Property 2: Meeting Status Transitions**
  - **Property 4: Submission Score Bounds**
  - **Property 5: Late Submission Detection**

  - **Validates: Requirements 2.1-2.9, 9.1-9.5, 12.1-12.6**

- [x] 2.6 Checkpoint - Verify all use cases and validators


  - Ensure all use cases compile
  - Test validator logic with various inputs

---


## Phase 3: Data Layer - Services & Supabase Integration


- [ ] 3. Create Supabase services
  - Create `MeetingService` with CRUD operations
  - Create `AssignmentService` with CRUD operations
  - Create `GradesService` with calculation and sync

  - Implement error handling for all services
  - _Requirements: 1.1-1.8, 5.1-5.8, 13.1-13.5_







- [ ] 3.1 Implement MeetingService
  - `createMeeting()` - Insert meeting record
  - `fetchMeetingsByMentor()` - Query meetings by mentor
  - `fetchMeetingsByClass()` - Query meetings by class
  - `fetchMeetingById()` - Get single meeting
  - `updateMeeting()` - Update meeting record


  - `deleteMeeting()` - Delete meeting (cascade delete attendance)
  - `markAttendance()` - Insert/update attendance record
  - `fetchAttendance()` - Get attendance list for meeting
  - _Requirements: 1.1-1.8, 2.1-2.9, 15.1-15.5_


- [ ] 3.2 Write property test for Meeting service
  - **Property 7: Attendance Record Uniqueness**
  - **Property 8: Cascade Delete Preservation**
  - **Validates: Requirements 15.1-15.5, 16.1-16.6**




- [ ] 3.3 Implement AssignmentService
  - `createAssignment()` - Insert assignment record
  - `fetchAssignmentsByMentor()` - Query assignments by mentor
  - `fetchAssignmentsByClass()` - Query assignments by class
  - `fetchAssignmentById()` - Get single assignment
  - `updateAssignment()` - Update assignment (with validation)
  - `deleteAssignment()` - Delete assignment (cascade delete submissions)
  - `submitAssignment()` - Insert submission record


  - `fetchSubmissions()` - Get submissions for assignment
  - `fetchSubmission()` - Get single submission
  - `gradeSubmission()` - Update submission with score/feedback
  - _Requirements: 5.1-5.8, 9.1-9.5, 12.1-12.6_

- [x] 3.4 Write property test for Assignment service

  - **Property 9: Submission Status Consistency**
  - **Validates: Requirements 12.1-12.6**

- [ ] 3.5 Implement GradesService
  - `fetchStudentGrades()` - Get all grades for student in class


  - `fetchClassGrades()` - Get all grades for class
  - `calculateStudentAverage()` - Calculate average grade
  - `syncGradesFromQuiz()` - Create grade record from quiz attempt
  - `syncGradesFromAssignment()` - Create grade record from submission
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 3.6 Write property test for Grades service
  - **Property 6: Grade Calculation Accuracy**

  - **Validates: Requirements 13.1-13.5**

- [x] 3.7 Implement RLS policies in Supabase


  - RLS for meetings table (mentor can CRUD own, students can READ)
  - RLS for attendance table (mentor can CRUD, students can READ own)
  - RLS for assignments table (mentor can CRUD own, students can READ)
  - RLS for submissions table (mentor can READ/UPDATE, students can CRUD own)
  - RLS for grades table (students can READ own, mentors can READ class)
  - _Requirements: 10.1-10.5, 11.1-11.8, 16.1-16.6_

- [ ] 3.8 Checkpoint - Verify all services and RLS
  - Test all CRUD operations
  - Verify RLS policies work correctly



  - Test error handling

---

## Phase 4: Presentation Layer - Mentor Meeting Management

- [ ] 4. Create Mentor Meeting Pages
  - Create `MeetingListPage` - Display list of meetings
  - Create `CreateMeetingPage` - Form to create meeting
  - Create `MeetingDetailPage` - View meeting details and attendance
  - Create `EditMeetingPage` - Edit meeting details


  - Create `MeetingProvider` - State management
  - _Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5_

- [ ] 4.1 Implement MeetingListPage
  - Display list of meetings created by mentor
  - Show meeting cards with title, date, type, status
  - Implement status badges (scheduled, ongoing, completed, cancelled)
  - Add "+ Buat Pertemuan" button
  - Add edit and delete buttons on each card

  - Implement navigation to detail page
  - _Requirements: 2.1-2.9_

- [ ] 4.2 Write unit tests for MeetingListPage
  - Test display of meeting list
  - Test navigation to create page
  - Test navigation to detail page
  - Test edit/delete button functionality


- [ ] 4.3 Implement CreateMeetingPage
  - Create form with all required fields
  - Implement conditional fields (meeting link for online, location for offline)
  - Add form validation
  - Implement save and cancel buttons
  - Navigate to detail page on success


  - _Requirements: 1.1-1.8_

- [ ] 4.4 Write unit tests for CreateMeetingPage
  - Test form validation
  - Test conditional field display

  - Test save functionality
  - Test cancel functionality

- [ ] 4.5 Implement MeetingDetailPage
  - Display meeting details (title, description, date, type, link/location, duration)


  - Display attendance list with status for each student
  - Allow mentor to update attendance status
  - Add edit and delete buttons
  - Show confirmation dialog on delete


  - _Requirements: 2.1-2.9, 15.1-15.5_


- [ ] 4.6 Write unit tests for MeetingDetailPage
  - Test display of meeting details


  - Test attendance list display
  - Test attendance status update
  - Test edit/delete functionality

- [ ] 4.7 Implement EditMeetingPage
  - Pre-populate form with existing meeting data
  - Allow editing of all fields
  - Implement save and cancel buttons
  - Navigate back to detail page on success


  - _Requirements: 3.1-3.4_

- [ ] 4.8 Write unit tests for EditMeetingPage
  - Test form pre-population
  - Test save functionality
  - Test cancel functionality

- [ ] 4.9 Implement MeetingProvider
  - State management for meetings
  - Methods: createMeeting, fetchMeetings, updateMeeting, deleteMeeting, markAttendance
  - Error handling and loading states

  - _Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5_



- [ ] 4.10 Write property test for Meeting authorization
  - **Property 10: Mentor Authorization**
  - **Validates: Requirements 3.1-3.4**

- [ ] 4.11 Checkpoint - Verify all mentor meeting pages
  - Test all pages load correctly
  - Test all CRUD operations
  - Test navigation between pages

---





## Phase 5: Presentation Layer - Mentor Assignment Management

- [ ] 5. Create Mentor Assignment Pages
  - Create `AssignmentListPage` - Display list of assignments
  - Create `CreateAssignmentPage` - Form to create assignment
  - Create `AssignmentDetailPage` - View assignment and submissions
  - Create `EditAssignmentPage` - Edit assignment details





  - Create `SubmissionDetailPage` - View and grade submission
  - Create `AssignmentProvider` - State management
  - _Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5_

- [x] 5.1 Implement AssignmentListPage


  - Display list of assignments created by mentor
  - Show assignment cards with title, deadline, max score, submission count
  - Add "+ Buat Tugas" button
  - Add edit and delete buttons on each card
  - Implement navigation to detail page


  - _Requirements: 6.1-6.6_

- [ ] 5.2 Write unit tests for AssignmentListPage
  - Test display of assignment list
  - Test navigation to create page

  - Test navigation to detail page

- [x] 5.3 Implement CreateAssignmentPage

  - Create form with all required fields
  - Add file upload for attachment (optional)
  - Add form validation
  - Implement save and cancel buttons
  - Navigate to detail page on success
  - _Requirements: 5.1-5.8_


- [ ] 5.4 Write unit tests for CreateAssignmentPage
  - Test form validation

  - Test file upload
  - Test save functionality

- [ ] 5.5 Implement AssignmentDetailPage
  - Display assignment details (title, description, deadline, max score, attachment)
  - Display submissions list with student name, status, score
  - Show submission count and grading progress
  - Add edit and delete buttons

  - Show confirmation dialog on delete
  - _Requirements: 6.1-6.6_


- [ ] 5.6 Write unit tests for AssignmentDetailPage
  - Test display of assignment details
  - Test submissions list display
  - Test navigation to submission detail

- [ ] 5.7 Implement EditAssignmentPage
  - Pre-populate form with existing assignment data
  - Prevent editing deadline/max_score if submissions exist
  - Implement save and cancel buttons

  - Navigate back to detail page on success



  - _Requirements: 7.1-7.5_

- [ ] 5.8 Write unit tests for EditAssignmentPage
  - Test form pre-population
  - Test deadline/score edit prevention




  - Test save functionality

- [ ] 5.9 Implement SubmissionDetailPage
  - Display student's submission content
  - Display grading form (score input, feedback textarea)
  - Allow mentor to grade submission
  - Show existing grade if already graded

  - Allow updating grade



  - _Requirements: 9.1-9.5_


- [ ] 5.10 Write unit tests for SubmissionDetailPage
  - Test display of submission content
  - Test grading form


  - Test grade save functionality
  - Test grade update functionality

- [ ] 5.11 Implement AssignmentProvider
  - State management for assignments and submissions

  - Methods: createAssignment, fetchAssignments, updateAssignment, deleteAssignment
  - Methods: submitAssignment, fetchSubmissions, gradeSubmission
  - Error handling and loading states


  - _Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5_

- [ ] 5.12 Write property test for Assignment authorization
  - **Property 10: Mentor Authorization**
  - **Validates: Requirements 8.1-8.4**

- [x] 5.13 Checkpoint - Verify all mentor assignment pages

  - Test all pages load correctly
  - Test all CRUD operations

  - Test grading functionality


---

## Phase 6: Presentation Layer - Student Views


- [ ] 6. Create Student Meeting & Assignment Pages
  - Create `StudentMeetingListPage` - Display meetings for student's classes
  - Create `StudentMeetingDetailPage` - View meeting details
  - Create `StudentAssignmentListPage` - Display assignments for student's classes
  - Create `StudentAssignmentDetailPage` - View assignment and submit




  - Create `StudentProvider` - State management
  - _Requirements: 10.1-10.5, 11.1-11.8, 12.1-12.6_


- [ ] 6.1 Implement StudentMeetingListPage
  - Display meetings for classes student is enrolled in
  - Show meeting cards with title, date, type, status
  - Show meeting link for online meetings

  - Add navigation to detail page




  - _Requirements: 10.1-10.5_

- [ ] 6.2 Write unit tests for StudentMeetingListPage
  - Test display of meetings for enrolled classes
  - Test meeting link display for online meetings

  - Test navigation to detail page



- [ ] 6.3 Implement StudentMeetingDetailPage
  - Display meeting details (title, description, date, type, link/location)



  - Show "Buka Meeting" button for online meetings
  - Show mentor name

  - _Requirements: 10.1-10.5_

- [ ] 6.4 Write unit tests for StudentMeetingDetailPage
  - Test display of meeting details


  - Test meeting link button

- [ ] 6.5 Implement StudentAssignmentListPage
  - Display assignments for classes student is enrolled in


  - Show assignment cards with title, deadline, max score, submission status
  - Show status badges (Aktif, Tertutup, Belum Dikumpulkan, Menunggu Penilaian, Dinilai)
  - Add navigation to detail page
  - _Requirements: 11.1-11.8_

- [ ] 6.6 Write unit tests for StudentAssignmentListPage
  - Test display of assignments
  - Test status badge display
  - Test navigation to detail page

- [ ] 6.7 Implement StudentAssignmentDetailPage
  - Display assignment details (title, description, deadline, max score, attachment)
  - Display submission form (text input, file upload optional)
  - Show existing submission if already submitted
  - Allow editing submission if deadline not passed
  - Show grade and feedback if graded
  - _Requirements: 12.1-12.6_

- [ ] 6.8 Write unit tests for StudentAssignmentDetailPage
  - Test display of assignment details
  - Test submission form
  - Test submit functionality
  - Test edit functionality
  - Test display of grade and feedback

- [ ] 6.9 Implement StudentProvider
  - State management for student meetings and assignments
  - Methods: fetchMeetings, fetchAssignments, submitAssignment
  - Error handling and loading states
  - _Requirements: 10.1-10.5, 11.1-11.8, 12.1-12.6_

- [ ] 6.10 Checkpoint - Verify all student pages
  - Test all pages load correctly
  - Test submission functionality
  - Test display of grades

---

## Phase 7: Grades Integration

- [ ] 7. Create Grades Dashboard & Integration
  - Create `GradesPage` - Main grades dashboard
  - Create `StudentGradesPage` - Student view of grades
  - Create `MentorGradesPage` - Mentor view of class grades
  - Create `StudentGradesDetailPage` - Detailed grades for student
  - Create `GradesProvider` - State management
  - Integrate with existing quiz grades
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 7.1 Implement GradesPage (Router)
  - Route to StudentGradesPage or MentorGradesPage based on role
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 7.2 Implement StudentGradesPage
  - Display overall GPA/average score
  - Display grades by class
  - Show each grade item (quiz, assignment) with score, max score, percentage
  - Add navigation to detail page
  - _Requirements: 13.1-13.5_

- [ ] 7.3 Write unit tests for StudentGradesPage
  - Test display of overall GPA
  - Test display of grades by class
  - Test display of grade items



- [ ] 7.4 Implement MentorGradesPage
  - Display class selector dropdown
  - Display list of students with average scores
  - Show quiz count and assignment count
  - Add navigation to student detail page
  - _Requirements: 14.1-14.5_

- [ ] 7.5 Write unit tests for MentorGradesPage
  - Test display of class selector
  - Test display of student list
  - Test navigation to student detail

- [ ] 7.6 Implement StudentGradesDetailPage
  - Display all grades for student in selected class
  - Show grades from both quizzes and assignments
  - Display score, max score, percentage, date for each
  - _Requirements: 13.1-13.5_

- [ ] 7.7 Write unit tests for StudentGradesDetailPage
  - Test display of all grades
  - Test display of quiz and assignment grades

- [ ] 7.8 Implement GradesProvider
  - State management for grades
  - Methods: fetchStudentGrades, fetchClassGrades, calculateAverage
  - Methods: syncGradesFromQuiz, syncGradesFromAssignment
  - Error handling and loading states
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 7.9 Integrate with Quiz Grades
  - When quiz is submitted, create grade record
  - When assignment is graded, create grade record
  - Ensure grades appear in grades dashboard
  - _Requirements: 13.1-13.5, 14.1-14.5_

- [ ] 7.10 Write property test for Grade calculation
  - **Property 6: Grade Calculation Accuracy**
  - **Validates: Requirements 13.1-13.5**

- [ ] 7.11 Checkpoint - Verify grades integration
  - Test grades appear from both sources
  - Test average calculation
  - Test mentor view shows correct data

---

## Phase 8: Testing & Polish

- [ ] 8. Write comprehensive integration tests
  - Test complete meeting flow (create → view → update → delete)
  - Test complete assignment flow (create → submit → grade → view grades)
  - Test grades integration with quiz
  - Test authorization and RLS
  - _Requirements: All_

- [ ] 8.1 Integration test - Meeting flow
  - Create meeting → View meeting → Mark attendance → Update meeting → Delete meeting
  - Verify all data persists correctly

- [ ] 8.2 Integration test - Assignment flow
  - Create assignment → Student submit → Mentor grade → View in grades
  - Verify all data persists correctly

- [ ] 8.3 Integration test - Grades integration
  - Complete quiz → Complete assignment → View grades dashboard
  - Verify grades from both sources appear

- [ ] 8.4 Integration test - Authorization
  - Test mentor can only edit own meetings/assignments
  - Test student can only view own submissions
  - Test RLS policies work correctly

- [ ] 8.5 Bug fixes and optimization
  - Fix any bugs found during testing
  - Optimize database queries
  - Improve error messages
  - Add loading states where needed

- [ ] 8.6 Final checkpoint - All tests passing
  - Ensure all unit tests pass
  - Ensure all property tests pass
  - Ensure all integration tests pass
  - Verify no console errors

---

## Notes

- All optional tasks (marked with *) are property-based tests and unit tests
- These can be skipped for MVP but are recommended for production
- Each checkpoint should verify all previous work is functioning correctly
- Use `flutter test` to run tests
- Use `flutter analyze` to check for lint issues
- Ensure all code follows project conventions

