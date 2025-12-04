# Forum Diskusi Feature - Arsitektur Teknis

## Ringkasan Eksekutif

Fitur Forum Diskusi adalah sistem diskusi berbasis kelas yang memungkinkan siswa untuk membuat topik diskusi, memberikan balasan, dan mentor untuk memoderasi. Sistem ini dibangun dengan arsitektur clean architecture dan mendukung offline-first functionality.

## Struktur Arsitektur

```
lib/features/discussions/
├── data/
│   ├── models/
│   │   ├── discussion_model.dart
│   │   └── reply_model.dart
│   └── services/
│       ├── discussion_service.dart
│       └── discussion_cache_service.dart
├── domain/
│   ├── entities/
│   │   ├── discussion_entity.dart
│   │   └── reply_entity.dart
│   └── validators/
│       ├── discussion_validator.dart
│       └── reply_validator.dart
├── presentation/
│   ├── pages/
│   │   ├── discussion_list_page.dart
│   │   ├── discussion_detail_page.dart
│   │   └── create_discussion_page.dart
│   ├── providers/
│   │   └── discussion_provider.dart
│   └── widgets/
│       ├── discussion_card.dart
│       ├── reply_card.dart
│       ├── reply_input.dart
│       ├── mention_text.dart
│       └── status_badge.dart
```

## Layer Breakdown

### 1. Data Layer

#### Models

- **DiscussionModel**: Representasi diskusi dengan serialization/deserialization

  - Fields: id, title, content, created_by, class_id, is_closed, created_at, updated_at
  - Methods: fromJson(), toJson(), fromEntity(), toEntity()

- **ReplyModel**: Representasi balasan dengan nested reply support
  - Fields: id, content, created_by, discussion_id, parent_reply_id, created_at, updated_at
  - Methods: fromJson(), toJson(), fromEntity(), toEntity()

#### Services

**DiscussionService** - Integrasi Supabase

- `createDiscussion()`: Insert diskusi baru ke database
- `fetchDiscussionsByClass()`: Query diskusi berdasarkan class_id
- `fetchDiscussionsByStudent()`: Query diskusi untuk kelas yang diikuti siswa
- `fetchDiscussionsByMentor()`: Query diskusi untuk kelas mentor
- `fetchDiscussionById()`: Get diskusi dengan replies
- `updateDiscussionStatus()`: Toggle is_closed status
- `deleteDiscussion()`: Hapus diskusi (cascade delete replies)
- `createReply()`: Insert balasan baru
- `fetchRepliesByDiscussion()`: Get semua balasan untuk diskusi
- `updateReply()`: Update konten balasan
- `deleteReply()`: Hapus balasan
- `getParentReplyAuthor()`: Get username untuk @mention

**DiscussionCacheService** - Offline Support

- `cacheDiscussions()`: Simpan diskusi ke SharedPreferences
- `getCachedDiscussions()`: Ambil diskusi dari cache
- `cachePendingDiscussion()`: Queue diskusi offline
- `getPendingDiscussions()`: Get diskusi yang pending
- `syncPendingDiscussions()`: Sync diskusi offline saat online
- `clearCache()`: Hapus cache

### 2. Domain Layer

#### Entities

- **DiscussionEntity**: Pure domain object untuk diskusi
- **ReplyEntity**: Pure domain object untuk balasan

#### Validators

- **DiscussionValidator**

  - `validateTitle()`: Check not empty, max 255 chars
  - `validateContent()`: Check not empty
  - `validateClassEnrollment()`: Verify user enrolled in class
  - `validateUserRole()`: Ensure only students can create

- **ReplyValidator**
  - `validateContent()`: Check not empty
  - `validateDiscussionOpen()`: Ensure discussion is open
  - `validateUserRole()`: Ensure only students can reply
  - `validateParentReply()`: Verify parent reply exists if nested

### 3. Presentation Layer

#### Pages

- **DiscussionListPage**: List diskusi dengan filter & sort

  - Filter: All, Open, Closed
  - Sort: Newest, Oldest, Most Replies
  - Role-based: Student dapat create, Mentor read-only

- **DiscussionDetailPage**: Detail diskusi dengan replies

  - Display: Full discussion + nested replies
  - Actions: Reply (student), Toggle status (creator/mentor)
  - Offline: Show cached data dengan pending indicator

- **CreateDiscussionPage**: Form membuat diskusi
  - Fields: Class (dropdown), Title, Content
  - Validation: Real-time feedback
  - Offline: Queue untuk sync nanti

#### Providers

- **DiscussionProvider** (StateNotifier)
  - State: discussions, currentDiscussion, replies, loading, error
  - Methods: loadDiscussions(), loadDetail(), createDiscussion(), createReply(), toggleStatus()
  - Offline: Automatic cache loading & sync

#### Widgets

- **DiscussionCard**: Display diskusi dalam list
- **ReplyCard**: Display balasan dengan nested support
- **ReplyInput**: Input balasan dengan @mention
- **MentionText**: Highlight @username (support nama dengan spasi)
- **StatusBadge**: Badge Terbuka/Ditutup

## Data Flow

### Create Discussion Flow

```
User Input → CreateDiscussionPage
    ↓
DiscussionValidator.validate()
    ↓
DiscussionProvider.createDiscussion()
    ↓
DiscussionService.createDiscussion() (online)
    ↓
DiscussionCacheService.cacheDiscussions() (cache)
    ↓
Update UI
```

### Offline Flow

```
User Action (offline)
    ↓
DiscussionCacheService.cachePendingDiscussion()
    ↓
Show pending indicator
    ↓
ConnectivityService detects online
    ↓
DiscussionCacheService.syncPendingDiscussions()
    ↓
Update UI
```

### Reply with @Mention Flow

```
User reply to reply
    ↓
ReplyInput adds @ParentAuthor prefix
    ↓
DiscussionValidator.validate()
    ↓
DiscussionProvider.createReply()
    ↓
DiscussionService.createReply()
    ↓
MentionText highlights @username
    ↓
Display in ReplyCard
```

## Database Schema

### discussions table

```sql
CREATE TABLE discussions (
  id UUID PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES profiles(id),
  class_id UUID NOT NULL REFERENCES classes(id),
  is_closed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### discussion_replies table

```sql
CREATE TABLE discussion_replies (
  id UUID PRIMARY KEY,
  content TEXT NOT NULL,
  created_by UUID NOT NULL REFERENCES profiles(id),
  discussion_id UUID NOT NULL REFERENCES discussions(id) ON DELETE CASCADE,
  parent_reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## RLS Policies

### discussions table

- Students: SELECT (enrolled classes), INSERT (enrolled classes), UPDATE own (is_closed only)
- Mentors: SELECT (their classes), UPDATE any (is_closed only)

### discussion_replies table

- Students: SELECT (accessible discussions), INSERT (open discussions), UPDATE own
- Mentors: SELECT (read-only), cannot INSERT

## Offline Support

### Caching Strategy

1. **Cache-First Loading**: Load dari cache dulu, update dari server
2. **Pending Queue**: Queue operasi offline, sync saat online
3. **Conflict Resolution**: Server data wins pada sync

### SharedPreferences Keys

- `discussions_cache`: List diskusi
- `pending_discussions`: Queue diskusi offline
- `pending_replies`: Queue balasan offline
- `last_sync`: Timestamp sync terakhir

## Error Handling

### Network Errors

- Catch PostgrestException
- Show user-friendly messages
- Queue untuk retry

### Validation Errors

- Real-time feedback di form
- Clear error messages
- Prevent submission jika invalid

### Authorization Errors

- Check user role sebelum action
- Hide UI elements untuk unauthorized users
- Show message jika unauthorized

## Performance Considerations

1. **Query Optimization**

- Use indexed columns (created_by, class_id, discussion_id)
- Limit replies per page (pagination)
- Cache frequently accessed data

2. **UI Performance**

- Use ListView.builder untuk list
- Lazy load nested replies
- Debounce search/filter

3. **Memory Management**

- Clear cache periodically
- Dispose providers properly
- Limit cache size

## Security

1. **RLS Policies**: Database-level access control
2. **Input Validation**: Server-side validation
3. **Authorization**: Role-based access control
4. **Data Encryption**: Supabase handles encryption at rest

## Testing Strategy

### Unit Tests

- Model serialization/deserialization
- Validator logic
- Provider state management

### Integration Tests

- Complete user flows
- RLS policy enforcement
- Offline sync behavior

### Property-Based Tests

- Discussion creation authorization
- Reply mention consistency
- Mentor read-only access
- Closed discussion reply prevention

## Future Improvements

1. **Advanced Features**

- Search diskusi
- Bookmark/favorite diskusi
- Notification untuk @mention
- Rich text editor

2. **Performance**

- Implement pagination
- Add database indexes
- Optimize queries

3. **Analytics**

- Track discussion engagement
- Monitor mentor moderation
- Analyze student participation

4. **Moderation**

- Report inappropriate content
- Automated content filtering
- Moderation dashboard
