# Forum Diskusi - Implementation Guide untuk Developer

## Quick Start

### Prerequisites

- Flutter SDK >= 3.0
- Dart >= 3.0
- Supabase project setup
- SharedPreferences package
- Riverpod untuk state management

### Setup

1. **Install Dependencies**

```bash
flutter pub get
```

2. **Database Setup**

```bash
# Run migration scripts
psql -U postgres -d your_db < database_forum_discussion_rls.sql
```

3. **Environment Configuration**

```dart
// lib/config/supabase_config.dart
const String SUPABASE_URL = 'your_url';
const String SUPABASE_ANON_KEY = 'your_key';
```

## File Structure & Responsibilities

### Data Layer

#### discussion_model.dart

```dart
class DiscussionModel {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final String classId;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Serialization
  factory DiscussionModel.fromJson(Map<String, dynamic> json)
  factory DiscussionModel.fromEntity(DiscussionEntity entity)
  Map<String, dynamic> toJson()
  DiscussionEntity toEntity()
}
```

**Key Methods**:

- `fromJson()`: Parse dari Supabase response
- `toJson()`: Serialize untuk cache/upload
- `fromEntity()`: Convert dari domain entity
- `toEntity()`: Convert ke domain entity

#### reply_model.dart

```dart
class ReplyModel {
  final String id;
  final String content;
  final String createdBy;
  final String discussionId;
  final String? parentReplyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested replies
  List<ReplyModel>? nestedReplies;
}
```

**Key Methods**:

- Support nested replies via `parentReplyId`
- Recursive parsing untuk nested structure

#### discussion_service.dart

```dart
class DiscussionService {
  final SupabaseClient supabase;

  // CRUD Operations
  Future<DiscussionModel> createDiscussion(...)
  Future<List<DiscussionModel>> fetchDiscussionsByClass(String classId)
  Future<List<DiscussionModel>> fetchDiscussionsByStudent(String userId)
  Future<List<DiscussionModel>> fetchDiscussionsByMentor(String userId)
  Future<DiscussionModel> fetchDiscussionById(String id)
  Future<void> updateDiscussionStatus(String id, bool isClosed)
  Future<void> deleteDiscussion(String id)

  // Reply Operations
  Future<ReplyModel> createReply(...)
  Future<List<ReplyModel>> fetchRepliesByDiscussion(String discussionId)
  Future<void> updateReply(String id, String content)
  Future<void> deleteReply(String id)
  Future<String> getParentReplyAuthor(String replyId)
}
```

**Implementation Notes**:

- Use Supabase RLS untuk authorization
- Handle PostgrestException untuk error
- Implement retry logic untuk network errors
- Cache frequently accessed data

#### discussion_cache_service.dart

```dart
class DiscussionCacheService {
  final SharedPreferences prefs;

  // Cache Operations
  Future<void> cacheDiscussions(List<DiscussionModel> discussions)
  Future<List<DiscussionModel>> getCachedDiscussions()
  Future<void> cachePendingDiscussion(DiscussionModel discussion)
  Future<List<DiscussionModel>> getPendingDiscussions()
  Future<void> syncPendingDiscussions(DiscussionService service)
  Future<void> clearCache()
}
```

**Cache Keys**:

- `discussions_cache`: JSON array dari discussions
- `pending_discussions`: Queue untuk offline discussions
- `pending_replies`: Queue untuk offline replies
- `last_sync`: Timestamp sync terakhir

### Domain Layer

#### discussion_entity.dart & reply_entity.dart

```dart
class DiscussionEntity {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final String classId;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ReplyEntity {
  final String id;
  final String content;
  final String createdBy;
  final String discussionId;
  final String? parentReplyId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Purpose**: Pure domain objects, independent dari framework

#### discussion_validator.dart

```dart
class DiscussionValidator {
  static String? validateTitle(String title) {
    if (title.isEmpty) return 'Judul tidak boleh kosong';
    if (title.length > 255) return 'Judul maksimal 255 karakter';
    return null;
  }

  static String? validateContent(String content) {
    if (content.isEmpty) return 'Konten tidak boleh kosong';
    return null;
  }

  static Future<String?> validateClassEnrollment(
    String userId,
    String classId,
    SupabaseClient supabase
  ) async {
    // Check user enrolled in class
  }

  static String? validateUserRole(String role) {
    if (role != 'student') return 'Hanya siswa yang bisa membuat diskusi';
    return null;
  }
}
```

#### reply_validator.dart

```dart
class ReplyValidator {
  static String? validateContent(String content) {
    if (content.isEmpty) return 'Balasan tidak boleh kosong';
    return null;
  }

  static Future<String?> validateDiscussionOpen(
    String discussionId,
    SupabaseClient supabase
  ) async {
    // Check discussion is_closed = false
  }

  static String? validateUserRole(String role) {
    if (role != 'student') return 'Hanya siswa yang bisa memberi balasan';
    return null;
  }

  static Future<String?> validateParentReply(
    String? parentReplyId,
    SupabaseClient supabase
  ) async {
    // Check parent reply exists
  }
}
```

### Presentation Layer

#### discussion_provider.dart

```dart
class DiscussionState {
  final List<DiscussionModel> discussions;
  final DiscussionModel? currentDiscussion;
  final List<ReplyModel> replies;
  final bool isLoading;
  final String? error;
  final bool isOnline;
  final List<DiscussionModel> pendingDiscussions;
}

class DiscussionProvider extends StateNotifier<DiscussionState> {
  final DiscussionService service;
  final DiscussionCacheService cacheService;
  final ConnectivityService connectivityService;

  // Load Operations
  Future<void> loadDiscussions(String classId)
  Future<void> loadDiscussionDetail(String discussionId)

  // Create Operations
  Future<void> createDiscussion(String title, String content, String classId)
  Future<void> createReply(String content, String discussionId, String? parentReplyId)

  // Update Operations
  Future<void> toggleDiscussionStatus(String discussionId)
  Future<void> updateReply(String replyId, String content)

  // Delete Operations
  Future<void> deleteDiscussion(String discussionId)
  Future<void> deleteReply(String replyId)

  // Offline Support
  Future<void> syncPendingData()
}
```

**State Management**:

- Use Riverpod StateNotifier
- Immutable state objects
- Proper error handling
- Loading states

#### Pages

**discussion_list_page.dart**

```dart
class DiscussionListPage extends ConsumerWidget {
  // Features:
  // - Display discussions list
  // - Filter: All, Open, Closed
  // - Sort: Newest, Oldest, Most Replies
  // - Create button (student only)
  // - Offline indicator
  // - Pending discussions marker
}
```

**discussion_detail_page.dart**

```dart
class DiscussionDetailPage extends ConsumerWidget {
  // Features:
  // - Display full discussion
  // - Display nested replies
  // - Reply input (student only, if open)
  // - Toggle status button (creator/mentor)
  // - Delete button (creator)
  // - Offline support
}
```

**create_discussion_page.dart**

```dart
class CreateDiscussionPage extends ConsumerWidget {
  // Features:
  // - Class dropdown (enrolled classes only)
  // - Title input with validation
  // - Content textarea with validation
  // - Post/Cancel buttons
  // - Offline queue support
}
```

#### Widgets

**discussion_card.dart**

```dart
class DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;
  final VoidCallback onTap;

  // Display:
  // - Title
  // - Content preview (truncated)
  // - Creator name
  // - Class name
  // - Reply count
  // - Timestamp
  // - Status badge
  // - Pending indicator (if offline)
}
```

**reply_card.dart**

```dart
class ReplyCard extends StatelessWidget {
  final ReplyModel reply;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final bool canDelete;
  final int nestLevel;

  // Display:
  // - Author name
  // - Content with @mention highlight
  // - Timestamp
  // - Balas button (if discussion open)
  // - Delete button (if creator)
  // - Nested replies with indentation
}
```

**mention_text.dart**

```dart
class MentionText extends StatelessWidget {
  final String text;
  final String? mentionedName;
  final TextStyle? style;

  // Features:
  // - Parse @username in text
  // - Highlight @username with blue color
  // - Support names with spaces
  // - Smart detection: stop at lowercase words
}
```

**reply_input.dart**

```dart
class ReplyInput extends ConsumerWidget {
  final String discussionId;
  final String? parentReplyId;
  final String? parentAuthorName;

  // Features:
  // - Text input field
  // - @mention prefix (if replying to reply)
  // - Send button
  // - Validation feedback
  // - Offline queue support
}
```

**status_badge.dart**

```dart
class StatusBadge extends StatelessWidget {
  final bool isClosed;

  // Display:
  // - Green "Terbuka" if open
  // - Red "Ditutup" if closed
}
```

## Common Patterns

### Error Handling

```dart
try {
  await service.createDiscussion(...);
} on PostgrestException catch (e) {
  // Handle database errors
  state = state.copyWith(error: e.message);
} catch (e) {
  // Handle other errors
  state = state.copyWith(error: 'Terjadi kesalahan');
}
```

### Offline Support

```dart
if (connectivityService.isOnline) {
  // Create on server
  await service.createDiscussion(...);
} else {
  // Queue for later
  await cacheService.cachePendingDiscussion(...);
}
```

### Validation

```dart
final titleError = DiscussionValidator.validateTitle(title);
if (titleError != null) {
  // Show error
  return;
}
```

### Role-Based Access

```dart
if (userRole == 'student') {
  // Show create button
} else if (userRole == 'mentor') {
  // Show moderation button
}
```

## Testing

### Unit Tests

```dart
test('DiscussionModel serialization', () {
  final json = {...};
  final model = DiscussionModel.fromJson(json);
  expect(model.toJson(), json);
});
```

### Integration Tests

```dart
testWidgets('Create discussion flow', (tester) async {
  await tester.pumpWidget(MyApp());
  // Navigate to create page
  // Fill form
  // Submit
  // Verify discussion created
});
```

### Property Tests

```dart
test('Discussion creation authorization', () {
  forall(
    (user, discussion) {
      if (user.role != 'student') {
        expect(() => createDiscussion(user, discussion), throwsException);
      }
    },
  );
});
```

## Debugging Tips

1. **Enable Supabase Logging**

```dart
SupabaseClient.initialize(
  url: SUPABASE_URL,
  anonKey: SUPABASE_ANON_KEY,
  debug: true,
);
```

2. **Check RLS Policies**

```sql
SELECT * FROM pg_policies WHERE tablename = 'discussions';
```

3. **Monitor Cache**

```dart
final cached = await cacheService.getCachedDiscussions();
print('Cached: ${cached.length}');
```

4. **Test Offline Mode**

- Use Flutter DevTools Network tab
- Throttle network in Chrome DevTools
- Disable WiFi/Mobile data

## Performance Optimization

1. **Database Queries**

- Add indexes on frequently queried columns
- Use pagination for large lists
- Limit nested replies depth

2. **UI Rendering**

- Use ListView.builder instead of ListView
- Implement lazy loading for replies
- Debounce search/filter operations

3. **Memory Management**

- Clear cache periodically
- Dispose providers properly
- Limit cache size to 10MB

## Deployment Checklist

- [ ] All tests passing
- [ ] No console errors/warnings
- [ ] RLS policies verified
- [ ] Offline sync tested
- [ ] Error messages user-friendly
- [ ] Performance acceptable
- [ ] Security review completed
- [ ] Documentation updated
