# Design Document - Forum Diskusi Feature

## Overview

Fitur Forum Diskusi adalah sistem diskusi berbasis thread yang memungkinkan student untuk berinteraksi dan berdiskusi dalam konteks kelas. Sistem ini memiliki pembatasan role yang jelas: student dapat membuat dan membalas diskusi, sedangkan mentor hanya dapat memoderasi (membuka/menutup) diskusi tanpa berpartisipasi.

### Key Features

1. **Discussion Management**: Student dapat membuat thread diskusi dalam kelas
2. **Reply System**: Student dapat membalas diskusi dan reply lain dengan sistem @mention
3. **Moderation**: Student creator dan Mentor dapat membuka/menutup diskusi
4. **Role-based Access**: Pembatasan akses berdasarkan role (student vs mentor)
5. **Nested Replies**: Sistem reply bersarang dengan @username mention

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer (Pages, Widgets, Providers)              │
├─────────────────────────────────────────────────────────────┤
│ - DiscussionPages (List, Create, Detail)                    │
│ - ReplyWidgets (ReplyCard, ReplyInput, MentionText)         │
│ - DiscussionProvider (State Management)                     │
├─────────────────────────────────────────────────────────────┤
│ Domain Layer (Entities, Repositories, UseCases)             │
├─────────────────────────────────────────────────────────────┤
│ - DiscussionEntity, ReplyEntity                             │
│ - DiscussionRepository Interface                            │
│ - UseCases (CreateDiscussion, CreateReply, ToggleStatus)    │
├─────────────────────────────────────────────────────────────┤
│ Data Layer (Models, Services)                               │
├─────────────────────────────────────────────────────────────┤
│ - DiscussionModel, ReplyModel                               │
│ - DiscussionService (Supabase CRUD)                         │
├─────────────────────────────────────────────────────────────┤
│ Supabase Backend                                            │
├─────────────────────────────────────────────────────────────┤
│ - discussions, discussion_replies tables                    │
│ - RLS policies untuk role-based security                    │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action (Create Discussion)
  ↓
Page (CreateDiscussionPage)
  ↓
Provider (DiscussionProvider.createDiscussion())
  ↓
Service (DiscussionService.createDiscussion())
  ↓
Supabase (INSERT into discussions table)
  ↓
Response (Discussion created)
  ↓
Provider (Update state, notifyListeners)
  ↓
UI (Navigate to detail page)
```

---

## Components and Interfaces

### 1. Discussion Feature

#### DiscussionEntity

```dart
class DiscussionEntity {
  final String id;
  final String classId;
  final String title;
  final String content;
  final bool isPinned;
  final bool isClosed;
  final int viewCount;
  final String createdBy;        // student user_id
  final String? creatorName;     // student full_name (from profiles)
  final String? className;       // class name (from classes)
  final DateTime createdAt;
  final DateTime updatedAt;
  final int replyCount;          // computed field
}
```

#### ReplyEntity

```dart
class ReplyEntity {
  final String id;
  final String discussionId;
  final String? parentReplyId;   // null = top-level reply, not null = nested reply
  final String content;
  final bool isEdited;
  final String createdBy;        // student user_id
  final String? authorName;      // student full_name (from profiles)
  final String? mentionedUser;   // @username of parent reply author
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReplyEntity>? nestedReplies; // for UI rendering
}
```

#### DiscussionService Interface

```dart
abstract class IDiscussionService {
  // Discussion CRUD
  Future<DiscussionModel?> createDiscussion(DiscussionModel discussion);
  Future<List<DiscussionModel>> fetchDiscussionsByClass(String classId);
  Future<List<DiscussionModel>> fetchDiscussionsByStudent(String studentId);
  Future<List<DiscussionModel>> fetchDiscussionsByMentor(String mentorId);
  Future<DiscussionModel?> fetchDiscussionById(String discussionId);
  Future<DiscussionModel?> updateDiscussionStatus(String discussionId, bool isClosed);
  Future<void> deleteDiscussion(String discussionId);

  // Reply CRUD
  Future<ReplyModel?> createReply(ReplyModel reply);
  Future<List<ReplyModel>> fetchRepliesByDiscussion(String discussionId);
  Future<ReplyModel?> updateReply(ReplyModel reply);
  Future<void> deleteReply(String replyId);

  // Utility
  Future<List<Map<String, dynamic>>> getEnrolledClasses(String studentId);
  Future<List<Map<String, dynamic>>> getMentorClasses(String mentorId);
  Future<String?> getUsernameById(String userId);
}
```

---

## Data Models

### Database Schema (Already exists in database_schema_v2.sql)

#### discussions table

```sql
-- Tabel Discussions (sudah ada)
CREATE TABLE discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT false,
  is_closed BOOLEAN DEFAULT false,
  view_count INTEGER DEFAULT 0,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### discussion_replies table

```sql
-- Tabel Discussion Replies (sudah ada)
CREATE TABLE discussion_replies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES discussions(id) ON DELETE CASCADE NOT NULL,
  parent_reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE, -- NULL = top level reply
  content TEXT NOT NULL,
  is_edited BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### DiscussionModel

```dart
class DiscussionModel extends DiscussionEntity {
  DiscussionModel({
    required String id,
    required String classId,
    required String title,
    required String content,
    bool isPinned = false,
    bool isClosed = false,
    int viewCount = 0,
    required String createdBy,
    String? creatorName,
    String? className,
    required DateTime createdAt,
    required DateTime updatedAt,
    int replyCount = 0,
  });

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      isClosed: json['is_closed'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      createdBy: json['created_by'] as String,
      creatorName: json['profiles']?['full_name'] as String?,
      className: json['classes']?['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      replyCount: json['reply_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_closed': isClosed,
      'view_count': viewCount,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

### ReplyModel

```dart
class ReplyModel extends ReplyEntity {
  ReplyModel({
    required String id,
    required String discussionId,
    String? parentReplyId,
    required String content,
    bool isEdited = false,
    required String createdBy,
    String? authorName,
    String? mentionedUser,
    required DateTime createdAt,
    required DateTime updatedAt,
    List<ReplyModel>? nestedReplies,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as String,
      discussionId: json['discussion_id'] as String,
      parentReplyId: json['parent_reply_id'] as String?,
      content: json['content'] as String,
      isEdited: json['is_edited'] as bool? ?? false,
      createdBy: json['created_by'] as String,
      authorName: json['profiles']?['full_name'] as String?,
      mentionedUser: json['mentioned_user'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'discussion_id': discussionId,
      'parent_reply_id': parentReplyId,
      'content': content,
      'is_edited': isEdited,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

---

## Correctness Properties

### Property 1: Discussion Creation Authorization

**For any** discussion creation attempt, only users with role "student" who are enrolled in the target class should be able to create discussions.

**Validates: Requirements 1.1-1.8**

### Property 2: Reply Authorization

**For any** reply creation attempt, only users with role "student" who are enrolled in the discussion's class should be able to create replies.

**Validates: Requirements 3.1-3.7**

### Property 3: Mentor Read-Only Access

**For any** mentor accessing a discussion, they should only be able to view discussions and replies, not create or reply.

**Validates: Requirements 5.1-5.6, 6.1-6.6**

### Property 4: Discussion Status Toggle Authorization

**For any** discussion status change (open/close), only the discussion creator (student) OR any mentor of the class should be able to toggle the status.

**Validates: Requirements 4.1-4.6, 6.1-6.6**

### Property 5: Reply Mention Consistency

**For any** reply with parent_reply_id, the content should contain "@username" mention of the parent reply's author.

**Validates: Requirements 7.1-7.5**

### Property 6: Closed Discussion Reply Prevention

**For any** discussion with status "closed", no new replies should be allowed regardless of user role.

**Validates: Requirements 3.5, 4.3, 6.3**

### Property 7: Cascade Delete Integrity

**For any** deleted discussion, all related replies should be cascade deleted.

**Validates: Requirements 9.4-9.6**

### Property 8: Reply Hierarchy Consistency

**For any** reply with parent_reply_id, the parent reply must exist and belong to the same discussion.

**Validates: Requirements 3.3-3.4, 7.1-7.5**

### Property 9: Class Enrollment Validation

**For any** discussion or reply creation, the user must be enrolled in the target class.

**Validates: Requirements 1.3, 2.1, 3.1**

### Property 10: Discussion Visibility Scope

**For any** user viewing discussions, they should only see discussions from classes they are enrolled in (student) or teach (mentor).

**Validates: Requirements 2.1, 5.1**

---

## UI Components

### Pages

#### 1. DiscussionListPage

```
┌─────────────────────────────────────────┐
│ Forum Diskusi                    [Filter]│
├─────────────────────────────────────────┤
│ [+ Buat Diskusi] (student only)         │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [Terbuka] Judul Diskusi 1           │ │
│ │ Preview konten diskusi...           │ │
│ │ 👤 Nama Student • 📚 Kelas A        │ │
│ │ 💬 12 balasan • 📅 2 jam lalu       │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ [Ditutup] Judul Diskusi 2           │ │
│ │ Preview konten diskusi...           │ │
│ │ 👤 Nama Student • 📚 Kelas B        │ │
│ │ 💬 5 balasan • 📅 1 hari lalu       │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

#### 2. CreateDiscussionPage (Student Only)

```
┌─────────────────────────────────────────┐
│ ← Buat Diskusi Baru                     │
├─────────────────────────────────────────┤
│ Kelas                                   │
│ ┌─────────────────────────────────────┐ │
│ │ Pilih Kelas                       ▼ │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Judul Diskusi                           │
│ ┌─────────────────────────────────────┐ │
│ │ Masukkan judul diskusi...           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Konten                                  │
│ ┌─────────────────────────────────────┐ │
│ │                                     │ │
│ │ Tulis konten diskusi...             │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Batal]                      [Posting]  │
└─────────────────────────────────────────┘
```

#### 3. DiscussionDetailPage

```
┌─────────────────────────────────────────┐
│ ← Detail Diskusi        [Tutup Diskusi] │
├─────────────────────────────────────────┤
│ [Terbuka]                               │
│ Judul Diskusi                           │
│ ─────────────────────────────────────── │
│ Konten lengkap diskusi yang dibuat      │
│ oleh student...                         │
│ ─────────────────────────────────────── │
│ 👤 Nama Student • 📚 Kelas A            │
│ 📅 2 jam lalu                           │
├─────────────────────────────────────────┤
│ Balasan (12)                            │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 👤 Student A                        │ │
│ │ Ini adalah balasan pertama...       │ │
│ │ 📅 1 jam lalu            [Balas]    │ │
│ │  ┌───────────────────────────────┐  │ │
│ │  │ 👤 Student B                  │  │ │
│ │  │ @StudentA Ini balasan nested..│  │ │
│ │  │ 📅 30 menit lalu     [Balas]  │  │ │
│ │  └───────────────────────────────┘  │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ (Student Only - if discussion is open)  │
│ ┌─────────────────────────────────────┐ │
│ │ Tulis balasan...              [>]   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ (If discussion is closed)               │
│ ⚠️ Diskusi ini telah ditutup            │
└─────────────────────────────────────────┘
```

### Widgets

#### 1. DiscussionCard

- Menampilkan preview diskusi dalam list
- Status badge (Terbuka/Ditutup)
- Creator name, class name, reply count, timestamp

#### 2. ReplyCard

- Menampilkan single reply
- Support nested replies dengan indentation
- @mention highlighting
- Balas button (student only, if discussion open)

#### 3. ReplyInput

- Text input untuk menulis balasan
- @mention prefix jika reply to reply
- Send button

#### 4. MentionText

- Widget untuk highlight @username dalam text
- Clickable mention (optional)

#### 5. StatusBadge

- Badge untuk status diskusi (Terbuka/Ditutup)
- Green untuk open, Red untuk closed

---

## Error Handling

### Discussion Errors

- **DiscussionNotFound**: Discussion dengan ID tidak ditemukan
- **UnauthorizedDiscussionCreate**: User bukan student atau tidak enrolled
- **UnauthorizedDiscussionAccess**: User tidak memiliki akses ke kelas
- **DiscussionClosed**: Tidak bisa reply karena diskusi ditutup
- **InvalidDiscussionData**: Data diskusi tidak valid (title/content kosong)

### Reply Errors

- **ReplyNotFound**: Reply dengan ID tidak ditemukan
- **UnauthorizedReplyCreate**: User bukan student atau tidak enrolled
- **ParentReplyNotFound**: Parent reply tidak ditemukan
- **InvalidReplyData**: Data reply tidak valid (content kosong)
- **DiscussionClosedForReply**: Diskusi sudah ditutup, tidak bisa reply

### Authorization Errors

- **MentorCannotCreateDiscussion**: Mentor tidak bisa membuat diskusi
- **MentorCannotReply**: Mentor tidak bisa membalas diskusi
- **NotDiscussionOwner**: Bukan pemilik diskusi (untuk student toggle status)
- **NotClassMentor**: Bukan mentor kelas (untuk mentor toggle status)

---

## Testing Strategy

### Unit Testing

**Discussion Service Tests**

- Test create discussion dengan valid data (student)
- Test create discussion dengan mentor (should fail)
- Test fetch discussions by class
- Test fetch discussions by student enrollment
- Test fetch discussions by mentor classes
- Test update discussion status (student owner)
- Test update discussion status (mentor)
- Test delete discussion

**Reply Service Tests**

- Test create reply dengan valid data (student)
- Test create reply dengan mentor (should fail)
- Test create nested reply dengan @mention
- Test create reply on closed discussion (should fail)
- Test fetch replies by discussion
- Test delete reply

### Property-Based Testing

**Property 1: Discussion Creation Authorization**

- Generate random user (student/mentor)
- Attempt to create discussion
- Verify only students can create

**Property 2: Reply Authorization**

- Generate random user (student/mentor)
- Attempt to create reply
- Verify only students can reply

**Property 3: Mentor Read-Only Access**

- Generate mentor user
- Attempt various actions
- Verify only read and status toggle allowed

**Property 4: Discussion Status Toggle Authorization**

- Generate random user and discussion
- Attempt to toggle status
- Verify only creator or mentor can toggle

**Property 5: Reply Mention Consistency**

- Create nested reply
- Verify @mention is present in content

**Property 6: Closed Discussion Reply Prevention**

- Close discussion
- Attempt to create reply
- Verify reply is rejected

### Integration Testing

**Discussion Flow**

- Student create discussion → View discussion → Reply → Close discussion
- Mentor view discussion → Close discussion → Student cannot reply

**Reply Flow**

- Student reply to discussion → Another student reply to reply → Verify @mention

---

## Implementation Phases

### Phase 1: Data Layer (Day 1-2)

- Create DiscussionModel and ReplyModel
- Create DiscussionService with Supabase integration
- Implement CRUD operations
- Add RLS policies for role-based access

### Phase 2: Domain Layer (Day 2-3)

- Create entities
- Create repository interface
- Create validators
- Implement business logic for authorization

### Phase 3: Presentation Layer - Student (Day 3-5)

- Create DiscussionListPage
- Create CreateDiscussionPage
- Create DiscussionDetailPage
- Create ReplyInput widget
- Create DiscussionProvider

### Phase 4: Presentation Layer - Mentor (Day 5-6)

- Modify pages for mentor view (read-only)
- Add moderation controls
- Test role-based UI

### Phase 5: Testing & Polish (Day 6-7)

- Write unit tests
- Write property tests
- Write integration tests
- Bug fixes and optimization

---

## Security Considerations

### Row Level Security (RLS)

1. **Discussions**:

   - Students can view discussions for enrolled classes
   - Students can create discussions for enrolled classes
   - Students can update own discussions (status only)
   - Mentors can view discussions for their classes
   - Mentors can update any discussion status in their classes

2. **Discussion Replies**:
   - Students can view replies for discussions they can access
   - Students can create replies for open discussions in enrolled classes
   - Students can update own replies
   - Mentors can view replies (read-only)
   - Mentors cannot create replies

### Input Validation

- Validate title length (max 255 chars)
- Validate content is not empty
- Sanitize text inputs (prevent XSS)
- Validate class enrollment before operations

### Authorization Checks

- Verify student role before create discussion/reply
- Verify class enrollment before operations
- Verify discussion ownership for student status toggle
- Verify mentor role for mentor status toggle

---

## Performance Considerations

1. **Pagination**: Implement pagination for discussions and replies
2. **Lazy Loading**: Load replies only when discussion is opened
3. **Caching**: Cache discussion list for quick access
4. **Indexing**: Add database indexes on class_id, created_by, discussion_id
5. **Reply Count**: Use computed field or trigger for reply count

---

## Future Enhancements

1. **Real-time Updates**: Supabase realtime for live replies
2. **Notifications**: Notify when someone replies to your discussion
3. **Rich Text**: Support markdown or rich text in content
4. **File Attachments**: Allow attaching files to discussions
5. **Search**: Full-text search for discussions
6. **Reactions**: Like/upvote replies
7. **Report**: Report inappropriate content
8. **Pin Discussions**: Mentor can pin important discussions
