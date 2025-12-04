# Forum Diskusi - Troubleshooting Guide

## Common Issues & Solutions

### 1. PostgrestException: Foreign Key Violation

**Error**: `PostgrestException: new row violates foreign key constraint`

**Cause**: Trying to create discussion/reply with invalid user_id or class_id

**Solution**:

```dart
// Verify user exists in profiles table
final user = await supabase
  .from('profiles')
  .select()
  .eq('id', userId)
  .single();

// Verify class exists
final classData = await supabase
  .from('classes')
  .select()
  .eq('id', classId)
  .single();

// Verify user enrolled in class
final enrollment = await supabase
  .from('class_enrollments')
  .select()
  .eq('user_id', userId)
  .eq('class_id', classId)
  .single();
```

### 2. RLS Policy Denies Access

**Error**: `PostgrestException: new row violates row-level security policy`

**Cause**: User doesn't have permission per RLS policy

**Solution**:

```sql
-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'discussions';

-- Verify user role
SELECT role FROM profiles WHERE id = 'user_id';

-- Test policy manually
SELECT * FROM discussions
WHERE created_by = 'user_id'
AND (SELECT role FROM profiles WHERE id = 'user_id') = 'student';
```

### 3. @Mention Not Highlighting Correctly

**Error**: Only first name highlighted, not full name with spaces

**Cause**: MentionText widget stops at first space

**Solution**: Already fixed in latest version. The algorithm now:

- Continues highlighting while words start with capital letter
- Stops when encountering lowercase word (like "gurt", "bro")
- Supports up to 5 words in name

**Test**:

```dart
final text = '@Tsaqif Hisyam Saputra gurt';
final widget = MentionText(text: text, mentionedName: 'Tsaqif Hisyam Saputra');
// Should highlight: @Tsaqif Hisyam Saputra
// Normal: gurt
```

### 4. Offline Data Not Syncing

**Error**: Pending discussions not syncing when back online

**Cause**: ConnectivityService not detecting online status change

**Solution**:

```dart
// Check connectivity service
final isOnline = await connectivityService.isOnline;
print('Online: $isOnline');

// Manually trigger sync
await discussionProvider.syncPendingData();

// Check pending queue
final pending = await cacheService.getPendingDiscussions();
print('Pending: ${pending.length}');

// Verify cache keys
final prefs = await SharedPreferences.getInstance();
print('Keys: ${prefs.getKeys()}');
```

### 5. Nested Replies Not Displaying

**Error**: Nested replies showing but not indented or not visible

**Cause**: ReplyCard not handling nested structure correctly

**Solution**:

```dart
// Verify parent_reply_id is set
final reply = await supabase
  .from('discussion_replies')
  .select()
  .eq('id', replyId)
  .single();
print('Parent: ${reply['parent_reply_id']}');

// Check ReplyCard nestLevel parameter
ReplyCard(
  reply: reply,
  nestLevel: 1, // Increase for deeper nesting
)

// Verify indentation in ReplyCard
Padding(
  padding: EdgeInsets.only(left: nestLevel * 16.0),
  child: ...,
)
```

### 6. Discussion Status Toggle Not Working

**Error**: Button click doesn't update is_closed status

**Cause**: User not authorized or RLS policy blocking update

**Solution**:

```dart
// Verify user is creator or mentor
final discussion = await supabase
  .from('discussions')
  .select()
  .eq('id', discussionId)
  .single();

final isCreator = discussion['created_by'] == currentUserId;
final isMentor = currentUserRole == 'mentor';

if (!isCreator && !isMentor) {
  throw Exception('Not authorized');
}

// Check RLS policy allows update
-- RLS should allow:
-- Students: UPDATE own discussions (is_closed only)
-- Mentors: UPDATE any discussion in their classes (is_closed only)
```

### 7. Cache Growing Too Large

**Error**: SharedPreferences cache exceeds size limit

**Cause**: Cache not being cleared periodically

**Solution**:

```dart
// Clear old cache
await cacheService.clearCache();

// Implement cache size limit
const int MAX_CACHE_SIZE = 10 * 1024 * 1024; // 10MB

// Periodic cleanup
Timer.periodic(Duration(days: 7), (_) async {
  await cacheService.clearCache();
});

// Monitor cache size
final prefs = await SharedPreferences.getInstance();
final keys = prefs.getKeys();
int totalSize = 0;
for (final key in keys) {
  final value = prefs.getString(key);
  totalSize += value?.length ?? 0;
}
print('Cache size: ${totalSize / 1024 / 1024}MB');
```

### 8. Form Validation Not Working

**Error**: Invalid form submitted or validation not showing

**Cause**: Validator not called or error not displayed

**Solution**:

```dart
// Ensure validator is called
final titleError = DiscussionValidator.validateTitle(title);
if (titleError != null) {
  setState(() => _titleError = titleError);
  return;
}

// Display error in UI
if (_titleError != null)
  Text(_titleError!, style: TextStyle(color: Colors.red))

// Test validator
test('Title validation', () {
  expect(DiscussionValidator.validateTitle(''), isNotNull);
  expect(DiscussionValidator.validateTitle('a' * 256), isNotNull);
  expect(DiscussionValidator.validateTitle('Valid Title'), isNull);
});
```

### 9. Replies Not Loading

**Error**: Discussion detail page shows no replies

**Cause**: Query not fetching replies or parsing error

**Solution**:

```dart
// Verify replies exist in database
final replies = await supabase
  .from('discussion_replies')
  .select()
  .eq('discussion_id', discussionId);
print('Replies: ${replies.length}');

// Check parsing
try {
  final models = replies.map((r) => ReplyModel.fromJson(r)).toList();
  print('Parsed: ${models.length}');
} catch (e) {
  print('Parse error: $e');
}

// Verify nested replies
final nestedReplies = replies.where((r) => r['parent_reply_id'] != null);
print('Nested: ${nestedReplies.length}');
```

### 10. User Role Not Recognized

**Error**: Student sees mentor features or vice versa

**Cause**: User role not loaded or cached incorrectly

**Solution**:

```dart
// Verify user role in profiles table
final profile = await supabase
  .from('profiles')
  .select('role')
  .eq('id', userId)
  .single();
print('Role: ${profile['role']}');

// Check role in provider
print('Current role: ${discussionProvider.currentUserRole}');

// Clear and reload
await discussionProvider.reloadUserRole();

// Verify role-based UI
if (userRole == 'student') {
  // Show student features
} else if (userRole == 'mentor') {
  // Show mentor features
}
```

## Database Debugging

### Check Discussion Data

```sql
SELECT
  d.id,
  d.title,
  d.created_by,
  p.full_name,
  d.class_id,
  d.is_closed,
  COUNT(dr.id) as reply_count
FROM discussions d
LEFT JOIN profiles p ON d.created_by = p.id
LEFT JOIN discussion_replies dr ON d.id = dr.discussion_id
GROUP BY d.id, p.full_name
ORDER BY d.created_at DESC;
```

### Check Reply Hierarchy

```sql
SELECT
  id,
  content,
  created_by,
  parent_reply_id,
  CASE
    WHEN parent_reply_id IS NULL THEN 'Root'
    ELSE 'Nested'
  END as type
FROM discussion_replies
WHERE discussion_id = 'discussion_id'
ORDER BY created_at;
```

### Check RLS Policies

```sql
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE tablename IN ('discussions', 'discussion_replies')
ORDER BY tablename, policyname;
```

### Check User Permissions

```sql
SELECT
  p.id,
  p.full_name,
  p.role,
  COUNT(ce.id) as enrolled_classes
FROM profiles p
LEFT JOIN class_enrollments ce ON p.id = ce.user_id
WHERE p.id = 'user_id'
GROUP BY p.id, p.full_name, p.role;
```

## Performance Debugging

### Slow Queries

```dart
// Enable query logging
final response = await supabase
  .from('discussions')
  .select('*, discussion_replies(*)')
  .eq('class_id', classId);

// Check query time
final stopwatch = Stopwatch()..start();
// ... query ...
stopwatch.stop();
print('Query time: ${stopwatch.elapsedMilliseconds}ms');
```

### Memory Leaks

```dart
// Check provider disposal
@override
void dispose() {
  ref.invalidate(discussionProvider);
  super.dispose();
}

// Monitor memory
import 'dart:developer' as developer;
developer.Timeline.instantSync('Memory check');
```

### UI Performance

```dart
// Use DevTools Performance tab
// Check for jank in frame rendering
// Profile with --profile flag
flutter run --profile
```

## Testing Offline Mode

### Simulate Offline

```dart
// Method 1: Disable network in DevTools
// Chrome DevTools → Network → Offline

// Method 2: Mock connectivity service
class MockConnectivityService extends ConnectivityService {
  @override
  Future<bool> get isOnline async => false;
}

// Method 3: Throttle network
// Chrome DevTools → Network → Slow 3G
```

### Test Sync

```dart
// Create discussion offline
await discussionProvider.createDiscussion(...);

// Verify pending
final pending = await cacheService.getPendingDiscussions();
expect(pending.length, 1);

// Go online
// Trigger sync
await discussionProvider.syncPendingData();

// Verify synced
final synced = await supabase
  .from('discussions')
  .select()
  .eq('title', 'Test');
expect(synced.length, 1);
```

## Logs & Monitoring

### Enable Debug Logging

```dart
// In main.dart
void main() {
  // Enable Supabase logging
  SupabaseClient.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    debug: true,
  );

  runApp(MyApp());
}
```

### Check Logs

```bash
# Flutter logs
flutter logs

# Supabase logs (in dashboard)
# Supabase → Logs → API

# Database logs
# Supabase → Logs → Database
```

## Getting Help

1. **Check existing issues**: Search GitHub issues
2. **Enable debug mode**: Set debug: true in Supabase
3. **Check database**: Verify data in Supabase dashboard
4. **Test with curl**: Test API directly
5. **Check RLS**: Verify policies in Supabase dashboard
6. **Review logs**: Check Flutter logs and Supabase logs
