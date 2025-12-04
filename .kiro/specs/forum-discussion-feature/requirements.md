# Requirements Document - Forum Diskusi Feature

## Introduction

Fitur Forum Diskusi pada aplikasi Gabara LMS memungkinkan student untuk membuat dan berpartisipasi dalam diskusi kelas. Forum ini dirancang untuk meningkatkan interaksi antar student dalam pembelajaran. Mentor memiliki peran sebagai moderator yang dapat membuka/menutup forum diskusi, namun tidak dapat berpartisipasi dalam diskusi.

## Glossary

- **Discussion (Diskusi)**: Thread diskusi yang dibuat oleh student dalam sebuah kelas
- **Reply (Balasan)**: Komentar/balasan pada thread diskusi
- **Nested Reply**: Balasan terhadap balasan lain (reply to reply)
- **Mention (@username)**: Sistem penyebutan nama user yang dibalas
- **Discussion Status**: Status diskusi (open/closed)
- **Discussion Creator**: Student yang membuat thread diskusi
- **Moderator**: Mentor yang dapat membuka/menutup forum diskusi
- **Student**: Pengguna dengan role student yang dapat membuat dan membalas diskusi
- **Mentor**: Pengguna dengan role mentor yang hanya dapat moderasi (buka/tutup) diskusi
- **Class**: Kelas pembelajaran yang menghubungkan mentor dan students
- **Class Enrollment**: Pendaftaran siswa ke dalam kelas

## Requirements

### Requirement 1: Student - Create Discussion

**User Story:** As a student, I want to create a discussion thread in my class, so that I can ask questions or start conversations with my classmates.

#### Acceptance Criteria

1. WHEN a student navigates to Forum Diskusi section THEN the System SHALL display a list of discussions with "+ Buat Diskusi" button
2. WHEN a student taps "+ Buat Diskusi" THEN the System SHALL navigate to CreateDiscussionPage with form fields
3. WHEN CreateDiscussionPage loads THEN the System SHALL display form with fields: Judul Diskusi (text), Konten (textarea), Kelas (dropdown - only enrolled classes)
4. WHEN a student taps "Posting" with valid data THEN the System SHALL create discussion record with status "open" and navigate to DiscussionDetailPage
5. WHEN a student attempts to post without required fields THEN the System SHALL display validation error and prevent submission
6. WHEN a student taps "Batal" THEN the System SHALL navigate back without saving
7. WHEN discussion is created THEN the System SHALL record the creator's user_id and timestamp
8. WHEN a mentor attempts to create discussion THEN the System SHALL NOT display "+ Buat Diskusi" button (mentor cannot create discussions)

### Requirement 2: Student - View Discussions

**User Story:** As a student, I want to view all discussions in my enrolled classes, so that I can participate in class conversations.

#### Acceptance Criteria

1. WHEN a student opens Forum Diskusi page THEN the System SHALL display list of discussions for classes the student is enrolled in
2. WHEN displaying discussions list THEN the System SHALL show each discussion as a card with: title, content preview (truncated), creator name, class name, reply count, status badge, and created date
3. WHEN discussion status is "open" THEN the System SHALL display green badge "Terbuka"
4. WHEN discussion status is "closed" THEN the System SHALL display red badge "Ditutup"
5. WHEN a student taps on a discussion card THEN the System SHALL navigate to DiscussionDetailPage showing full discussion and replies
6. WHEN DiscussionDetailPage loads THEN the System SHALL display: title, full content, creator name, class name, created date, status, and list of replies
7. WHEN displaying replies THEN the System SHALL show each reply with: content, author name, created date, and nested replies (if any)
8. WHEN a reply is a response to another reply THEN the System SHALL display "@username" mention at the beginning of the reply content

### Requirement 3: Student - Reply to Discussion

**User Story:** As a student, I want to reply to discussions, so that I can participate in conversations and help my classmates.

#### Acceptance Criteria

1. WHEN a student opens DiscussionDetailPage with status "open" THEN the System SHALL display a reply input field at the bottom
2. WHEN a student enters text and taps "Kirim" THEN the System SHALL create reply record and display it in the replies list
3. WHEN a student taps "Balas" on an existing reply THEN the System SHALL show reply input with "@username" prefix (username of the reply author being responded to)
4. WHEN a student submits a reply to another reply THEN the System SHALL store parent_reply_id and display "@username" mention in the reply content
5. WHEN discussion status is "closed" THEN the System SHALL hide reply input field and display message "Diskusi ini telah ditutup"
6. WHEN a mentor attempts to reply THEN the System SHALL NOT display reply input field (mentor cannot reply)
7. WHEN reply is created THEN the System SHALL record the author's user_id and timestamp

### Requirement 4: Student - Manage Own Discussion

**User Story:** As a student who created a discussion, I want to open or close my discussion, so that I can control when the conversation ends.

#### Acceptance Criteria

1. WHEN a student opens DiscussionDetailPage for their own discussion THEN the System SHALL display "Tutup Diskusi" button (if status is "open") or "Buka Diskusi" button (if status is "closed")
2. WHEN a student taps "Tutup Diskusi" THEN the System SHALL show confirmation dialog
3. WHEN a student confirms closing THEN the System SHALL update discussion status to "closed" and disable reply functionality
4. WHEN a student taps "Buka Diskusi" THEN the System SHALL show confirmation dialog
5. WHEN a student confirms opening THEN the System SHALL update discussion status to "open" and enable reply functionality
6. WHEN a student views discussion they did NOT create THEN the System SHALL NOT display open/close buttons

### Requirement 5: Mentor - View Discussions

**User Story:** As a mentor, I want to view all discussions in my classes, so that I can monitor student conversations and moderate if needed.

#### Acceptance Criteria

1. WHEN a mentor opens Forum Diskusi page THEN the System SHALL display list of discussions for classes the mentor teaches
2. WHEN displaying discussions list THEN the System SHALL show each discussion as a card with: title, content preview, creator name, class name, reply count, status badge, and created date
3. WHEN a mentor taps on a discussion card THEN the System SHALL navigate to DiscussionDetailPage showing full discussion and replies
4. WHEN DiscussionDetailPage loads for mentor THEN the System SHALL display: title, full content, creator name, class name, created date, status, and list of replies (read-only)
5. WHEN mentor views discussion THEN the System SHALL NOT display reply input field (mentor cannot reply)
6. WHEN mentor views discussion THEN the System SHALL NOT display "+ Buat Diskusi" button (mentor cannot create discussions)

### Requirement 6: Mentor - Moderate Discussion

**User Story:** As a mentor, I want to open or close any discussion in my class, so that I can moderate conversations and maintain a healthy learning environment.

#### Acceptance Criteria

1. WHEN a mentor opens DiscussionDetailPage for any discussion in their class THEN the System SHALL display "Tutup Diskusi" button (if status is "open") or "Buka Diskusi" button (if status is "closed")
2. WHEN a mentor taps "Tutup Diskusi" THEN the System SHALL show confirmation dialog with reason input (optional)
3. WHEN a mentor confirms closing THEN the System SHALL update discussion status to "closed" and disable reply functionality for all students
4. WHEN a mentor taps "Buka Diskusi" THEN the System SHALL show confirmation dialog
5. WHEN a mentor confirms opening THEN the System SHALL update discussion status to "open" and enable reply functionality for all students
6. WHEN a mentor closes a discussion THEN the System SHALL record the moderator's user_id and timestamp

### Requirement 7: Reply Mention System

**User Story:** As a student, I want to see who I'm replying to with @username mention, so that the conversation context is clear.

#### Acceptance Criteria

1. WHEN a student replies to another reply THEN the System SHALL automatically prepend "@username" to the reply content
2. WHEN displaying a reply with mention THEN the System SHALL highlight the "@username" text (different color/style)
3. WHEN a reply has parent_reply_id THEN the System SHALL display "@username" of the parent reply author
4. WHEN the mentioned user views the discussion THEN the System SHALL highlight replies that mention them (optional enhancement)
5. WHEN displaying nested replies THEN the System SHALL show visual indentation or threading to indicate reply hierarchy

### Requirement 8: Discussion List Filtering & Sorting

**User Story:** As a user, I want to filter and sort discussions, so that I can find relevant conversations easily.

#### Acceptance Criteria

1. WHEN viewing discussions list THEN the System SHALL display filter options: All, Open Only, Closed Only
2. WHEN viewing discussions list THEN the System SHALL display sort options: Newest First, Oldest First, Most Replies
3. WHEN a user selects a filter THEN the System SHALL update the list to show only matching discussions
4. WHEN a user selects a sort option THEN the System SHALL reorder the list accordingly
5. WHEN viewing discussions list THEN the System SHALL display class filter dropdown (for users enrolled in multiple classes)

### Requirement 9: Data Validation & Integrity

**User Story:** As a system, I want to ensure data integrity and consistency, so that the application maintains reliable information.

#### Acceptance Criteria

1. WHEN creating a discussion THEN the System SHALL validate that title is not empty and max 255 characters
2. WHEN creating a discussion THEN the System SHALL validate that content is not empty
3. WHEN creating a reply THEN the System SHALL validate that content is not empty
4. WHEN a discussion is deleted THEN the System SHALL cascade delete all related replies
5. WHEN a user is deleted THEN the System SHALL preserve discussions and replies with "Deleted User" placeholder
6. WHEN displaying discussions THEN the System SHALL handle deleted users gracefully

### Requirement 10: Real-time Updates (Optional Enhancement)

**User Story:** As a user, I want to see new replies in real-time, so that I can have a more interactive conversation experience.

#### Acceptance Criteria

1. WHEN a new reply is posted THEN the System SHALL update the discussion detail page in real-time for all viewers
2. WHEN a discussion status changes THEN the System SHALL update the UI in real-time for all viewers
3. WHEN viewing discussion list THEN the System SHALL show indicator for discussions with new replies since last visit
