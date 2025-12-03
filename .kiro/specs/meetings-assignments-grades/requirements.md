# Requirements Document - Meetings, Assignments & Grades Integration

## Introduction

Fitur Meetings, Assignments, dan Grades pada aplikasi Gabara LMS memungkinkan mentor untuk membuat dan mengelola pertemuan kelas, memberikan tugas kepada siswa, serta melacak nilai siswa dari berbagai sumber (quiz, assignment). Fitur ini mencakup CRUD operations untuk meetings dan assignments dari perspektif mentor, serta student view untuk mengakses dan mengumpulkan tugas, serta dashboard grades yang terintegrasi.

## Glossary

- **Meeting (Pertemuan)**: Jadwal pertemuan kelas yang dapat berupa online atau offline
- **Meeting Type**: Jenis pertemuan (online/offline)
- **Meeting Link**: URL untuk pertemuan online (Zoom, Google Meet, dll)
- **Meeting Location**: Lokasi fisik untuk pertemuan offline
- **Meeting Status**: Status pertemuan (scheduled/ongoing/completed/cancelled)
- **Attendance**: Kehadiran siswa dalam pertemuan (present/absent/late/excused)
- **Assignment (Tugas)**: Tugas yang diberikan mentor kepada siswa dengan deadline
- **Assignment Submission**: Pengumpulan tugas oleh siswa
- **Submission Status**: Status pengumpulan (draft/submitted/graded/late/returned)
- **Grade (Nilai)**: Nilai yang diberikan untuk assignment atau quiz
- **Grades Tab**: Tab dashboard yang menampilkan nilai siswa dari berbagai sumber
- **Mentor**: Pengguna dengan role tutor yang membuat meetings dan assignments
- **Student**: Pengguna dengan role student yang mengikuti meetings dan mengumpulkan assignments
- **Class**: Kelas pembelajaran yang menghubungkan mentor dan students
- **Class Enrollment**: Pendaftaran siswa ke dalam kelas

## Requirements

### Requirement 1: Mentor - Create Meeting

**User Story:** As a mentor, I want to create a meeting for my class, so that I can schedule and communicate meeting details to my students.

#### Acceptance Criteria

1. WHEN a mentor navigates to Meetings section THEN the System SHALL display a list of meetings with "+ Buat Pertemuan" button
2. WHEN a mentor taps "+ Buat Pertemuan" THEN the System SHALL navigate to CreateMeetingPage with form fields
3. WHEN CreateMeetingPage loads THEN the System SHALL display form with fields: Judul Pertemuan (text), Deskripsi (textarea), Kelas (dropdown), Tanggal Pertemuan (date picker), Waktu Mulai (time picker HH:MM), Durasi (number in minutes), Tipe Pertemuan (dropdown: online/offline)
4. WHEN Tipe Pertemuan is "online" THEN the System SHALL display additional field: Meeting Link (URL input)
5. WHEN Tipe Pertemuan is "offline" THEN the System SHALL display additional field: Lokasi (text input)
6. WHEN a mentor taps "Simpan" with valid data THEN the System SHALL create meeting record with status "scheduled" and navigate to MeetingDetailPage
7. WHEN a mentor attempts to save without required fields THEN the System SHALL display validation error and prevent submission
8. WHEN a mentor taps "Batal" THEN the System SHALL navigate back without saving

### Requirement 2: Mentor - Read/View Meetings

**User Story:** As a mentor, I want to view all meetings I have created, so that I can manage and monitor my class meetings.

#### Acceptance Criteria

1. WHEN a mentor opens Meetings page THEN the System SHALL display list of meetings created by that mentor
2. WHEN displaying meetings list THEN the System SHALL show each meeting as a card with: title, description, date/time, meeting type badge, status badge, and action buttons
3. WHEN meeting status is "scheduled" THEN the System SHALL display blue badge "Dijadwalkan"
4. WHEN meeting status is "ongoing" THEN the System SHALL display orange badge "Sedang Berlangsung"
5. WHEN meeting status is "completed" THEN the System SHALL display green badge "Selesai"
6. WHEN meeting status is "cancelled" THEN the System SHALL display red badge "Dibatalkan"
7. WHEN a mentor taps on a meeting card THEN the System SHALL navigate to MeetingDetailPage showing full meeting details
8. WHEN MeetingDetailPage loads THEN the System SHALL display: title, description, date/time, meeting type, meeting link (if online), location (if offline), duration, enrolled students count, and attendance list
9. WHEN displaying attendance list THEN the System SHALL show each student with their attendance status (present/absent/late/excused) and allow mentor to update status

### Requirement 3: Mentor - Update Meeting

**User Story:** As a mentor, I want to edit meeting details, so that I can update information if plans change.

#### Acceptance Criteria

1. WHEN a mentor opens MeetingDetailPage THEN the System SHALL display an "Edit" button
2. WHEN a mentor taps "Edit" THEN the System SHALL navigate to EditMeetingPage with form pre-populated with existing data
3. WHEN a mentor modifies fields and taps "Simpan" THEN the System SHALL update meeting record and navigate back to MeetingDetailPage
4. WHEN a mentor taps "Batal" THEN the System SHALL discard changes and navigate back

### Requirement 4: Mentor - Delete Meeting

**User Story:** As a mentor, I want to delete a meeting, so that I can remove meetings that are no longer needed.

#### Acceptance Criteria

1. WHEN a mentor opens MeetingDetailPage THEN the System SHALL display a "Hapus" button
2. WHEN a mentor taps "Hapus" THEN the System SHALL show confirmation dialog
3. WHEN a mentor confirms deletion THEN the System SHALL delete meeting record and navigate back to meetings list
4. WHEN a mentor cancels deletion THEN the System SHALL close dialog and remain on MeetingDetailPage

### Requirement 5: Mentor - Create Assignment

**User Story:** As a mentor, I want to create and assign tasks to my students, so that I can assess their understanding and progress.

#### Acceptance Criteria

1. WHEN a mentor navigates to Assignments section THEN the System SHALL display list of assignments with "+ Buat Tugas" button
2. WHEN a mentor taps "+ Buat Tugas" THEN the System SHALL navigate to CreateAssignmentPage with form fields
3. WHEN CreateAssignmentPage loads THEN the System SHALL display form with fields: Judul Tugas (text), Deskripsi (textarea), Kelas (dropdown), Deadline (date picker), Waktu Deadline (time picker HH:MM), Max Score (number), Attachment (file upload optional)
4. WHEN a mentor taps "Simpan" with valid data THEN the System SHALL create assignment record with status "active" and navigate to AssignmentDetailPage
5. WHEN a mentor attempts to save without required fields THEN the System SHALL display validation error and prevent submission
6. WHEN a mentor taps "Batal" THEN the System SHALL navigate back without saving

### Requirement 6: Mentor - Read/View Assignments

**User Story:** As a mentor, I want to view all assignments I have created and their submission status, so that I can track student progress.

#### Acceptance Criteria

1. WHEN a mentor opens Assignments page THEN the System SHALL display list of assignments created by that mentor
2. WHEN displaying assignments list THEN the System SHALL show each assignment as a card with: title, description, deadline, max score, submission count, and action buttons
3. WHEN a mentor taps on an assignment card THEN the System SHALL navigate to AssignmentDetailPage
4. WHEN AssignmentDetailPage loads THEN the System SHALL display: title, description, deadline, max score, attachment (if any), and submissions list
5. WHEN displaying submissions list THEN the System SHALL show each student with: student name, submission status (draft/submitted/graded/late/returned), submission date, score (if graded), and action buttons
6. WHEN a mentor taps on a submission THEN the System SHALL navigate to SubmissionDetailPage showing student's submission content and allow grading

### Requirement 7: Mentor - Update Assignment

**User Story:** As a mentor, I want to edit assignment details before deadline, so that I can make corrections or clarifications.

#### Acceptance Criteria

1. WHEN a mentor opens AssignmentDetailPage THEN the System SHALL display an "Edit" button
2. WHEN a mentor taps "Edit" THEN the System SHALL navigate to EditAssignmentPage with form pre-populated with existing data
3. WHEN a mentor modifies fields and taps "Simpan" THEN the System SHALL update assignment record and navigate back to AssignmentDetailPage
4. WHEN a mentor taps "Batal" THEN the System SHALL discard changes and navigate back
5. WHEN assignment has submissions THEN the System SHALL prevent editing deadline and max score to maintain data integrity

### Requirement 8: Mentor - Delete Assignment

**User Story:** As a mentor, I want to delete an assignment, so that I can remove assignments that are no longer needed.

#### Acceptance Criteria

1. WHEN a mentor opens AssignmentDetailPage THEN the System SHALL display a "Hapus" button
2. WHEN a mentor taps "Hapus" THEN the System SHALL show confirmation dialog
3. WHEN a mentor confirms deletion THEN the System SHALL delete assignment record and all related submissions, then navigate back to assignments list
4. WHEN a mentor cancels deletion THEN the System SHALL close dialog and remain on AssignmentDetailPage

### Requirement 9: Mentor - Grade Assignment Submission

**User Story:** As a mentor, I want to grade student submissions and provide feedback, so that I can assess student work and provide guidance.

#### Acceptance Criteria

1. WHEN a mentor opens SubmissionDetailPage THEN the System SHALL display student's submission content and a grading form
2. WHEN grading form loads THEN the System SHALL display fields: Score (number input, max = assignment max_score), Feedback (textarea), and "Simpan Nilai" button
3. WHEN a mentor enters score and feedback and taps "Simpan Nilai" THEN the System SHALL update submission with status "graded", save score and feedback, and navigate back to AssignmentDetailPage
4. WHEN a mentor saves grade THEN the System SHALL record the grading timestamp
5. WHEN a submission is already graded THEN the System SHALL allow mentor to update the grade and feedback

### Requirement 10: Student - View Meetings

**User Story:** As a student, I want to view meetings scheduled for my classes, so that I can attend and participate in class sessions.

#### Acceptance Criteria

1. WHEN a student navigates to Meetings section THEN the System SHALL display list of meetings for classes the student is enrolled in
2. WHEN displaying meetings list THEN the System SHALL show each meeting as a card with: title, date/time, meeting type, status badge, and meeting link (if online and meeting is ongoing/scheduled)
3. WHEN a student taps on a meeting card THEN the System SHALL navigate to StudentMeetingDetailPage
4. WHEN StudentMeetingDetailPage loads THEN the System SHALL display: title, description, date/time, meeting type, meeting link (if online), location (if offline), duration, and mentor name
5. WHEN meeting is online and status is "scheduled" or "ongoing" THEN the System SHALL display "Buka Meeting" button linking to meeting URL

### Requirement 11: Student - View Assignments

**User Story:** As a student, I want to view assignments assigned to my classes, so that I can complete and submit my work.

#### Acceptance Criteria

1. WHEN a student navigates to Assignments section THEN the System SHALL display list of assignments for classes the student is enrolled in
2. WHEN displaying assignments list THEN the System SHALL show each assignment as a card with: title, deadline, max score, submission status badge, and action buttons
3. WHEN assignment deadline has not passed THEN the System SHALL display blue badge "Aktif"
4. WHEN assignment deadline has passed THEN the System SHALL display red badge "Tertutup"
5. WHEN a student has not submitted THEN the System SHALL display gray badge "Belum Dikumpulkan"
6. WHEN a student has submitted but not graded THEN the System SHALL display yellow badge "Menunggu Penilaian"
7. WHEN a student's submission is graded THEN the System SHALL display green badge "Dinilai" with score
8. WHEN a student taps on an assignment card THEN the System SHALL navigate to StudentAssignmentDetailPage

### Requirement 12: Student - Submit Assignment

**User Story:** As a student, I want to submit my assignment work, so that I can complete the task and receive a grade.

#### Acceptance Criteria

1. WHEN StudentAssignmentDetailPage loads THEN the System SHALL display: assignment title, description, deadline, max score, attachment (if any), and submission form
2. WHEN submission form loads THEN the System SHALL display: text input for submission content, file upload (optional), and "Kumpulkan" button
3. WHEN a student enters content and taps "Kumpulkan" THEN the System SHALL create submission record with status "submitted", record submission timestamp, and show success message
4. WHEN a student has already submitted THEN the System SHALL display their submission content and allow editing if deadline has not passed
5. WHEN a student taps "Edit" on their submission THEN the System SHALL allow modifying content and re-submit
6. WHEN a student's submission is graded THEN the System SHALL display score and feedback from mentor

### Requirement 13: Grades Tab - Display Student Grades

**User Story:** As a student, I want to view my grades from all sources (quizzes, assignments), so that I can track my academic progress.

#### Acceptance Criteria

1. WHEN a student navigates to Grades tab THEN the System SHALL display a grades dashboard
2. WHEN Grades dashboard loads THEN the System SHALL display: overall GPA/average score, and list of grades by class
3. WHEN displaying grades by class THEN the System SHALL show: class name, and list of items (quizzes and assignments) with scores
4. WHEN displaying each grade item THEN the System SHALL show: item title, item type (Quiz/Assignment), score, max score, percentage, and date
5. WHEN a student taps on a grade item THEN the System SHALL navigate to detail page showing full information about that quiz or assignment result

### Requirement 14: Grades Tab - Display Mentor View

**User Story:** As a mentor, I want to view grades for all my students, so that I can monitor class performance and identify students who need help.

#### Acceptance Criteria

1. WHEN a mentor navigates to Grades tab THEN the System SHALL display a grades dashboard
2. WHEN Grades dashboard loads THEN the System SHALL display: class selector dropdown, and list of students with their grades
3. WHEN a mentor selects a class THEN the System SHALL display all students enrolled in that class with their average scores
4. WHEN displaying student grades THEN the System SHALL show: student name, average score, number of quizzes completed, number of assignments graded, and action button to view detailed grades
5. WHEN a mentor taps on a student THEN the System SHALL navigate to StudentGradesDetailPage showing all grades for that student in that class

### Requirement 15: Attendance Tracking

**User Story:** As a mentor, I want to track student attendance in meetings, so that I can monitor participation and identify absent students.

#### Acceptance Criteria

1. WHEN a mentor opens MeetingDetailPage THEN the System SHALL display attendance section with list of enrolled students
2. WHEN displaying attendance list THEN the System SHALL show: student name, attendance status (present/absent/late/excused), and allow mentor to update status
3. WHEN a mentor taps on a student's attendance status THEN the System SHALL show dropdown with options: present, absent, late, excused
4. WHEN a mentor selects a status THEN the System SHALL update attendance record immediately
5. WHEN a mentor marks attendance THEN the System SHALL record the timestamp of when attendance was marked

### Requirement 16: Data Validation & Integrity

**User Story:** As a system, I want to ensure data integrity and consistency, so that the application maintains reliable information.

#### Acceptance Criteria

1. WHEN creating a meeting THEN the System SHALL validate that start date/time is not in the past
2. WHEN creating an assignment THEN the System SHALL validate that deadline is not in the past
3. WHEN grading a submission THEN the System SHALL validate that score is between 0 and max_score
4. WHEN a student submits after deadline THEN the System SHALL mark submission as "late" and allow mentor to decide whether to accept
5. WHEN deleting a meeting with attendance records THEN the System SHALL preserve attendance data for historical records
6. WHEN deleting an assignment with submissions THEN the System SHALL preserve submission data for historical records

### Requirement 17: Notifications & Alerts

**User Story:** As a user, I want to receive notifications about important events, so that I stay informed about meetings and assignments.

#### Acceptance Criteria

1. WHEN a mentor creates a meeting THEN the System SHALL send notification to all enrolled students
2. WHEN a mentor creates an assignment THEN the System SHALL send notification to all enrolled students
3. WHEN assignment deadline is approaching (24 hours before) THEN the System SHALL send reminder notification to students who haven't submitted
4. WHEN a student's submission is graded THEN the System SHALL send notification to the student
5. WHEN a mentor marks a student as absent THEN the System SHALL record the event (notification optional for future enhancement)

### Requirement 18: Sync & Offline Support

**User Story:** As a user, I want the app to work smoothly even with poor connectivity, so that I can access information reliably.

#### Acceptance Criteria

1. WHEN a user is offline THEN the System SHALL cache previously loaded meetings and assignments
2. WHEN a user is offline and attempts to create/edit/delete THEN the System SHALL queue the action and sync when online
3. WHEN a user comes back online THEN the System SHALL automatically sync queued actions
4. WHEN sync fails THEN the System SHALL show error message and allow user to retry

