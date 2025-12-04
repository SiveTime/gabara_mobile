# Pre-Requirements Checklist - Forum Diskusi Feature

## ✅ Database Schema

- [x] `discussions` table exists in database_schema_v2.sql
- [x] `discussion_replies` table exists in database_schema_v2.sql
- [x] Foreign key to `classes` table
- [x] Foreign key to `auth.users` table
- [x] `parent_reply_id` for nested replies
- [x] `is_closed` field for discussion status
- [x] Indexes for performance

## ✅ Existing Infrastructure

- [x] Supabase client configured in main.dart
- [x] Provider pattern established
- [x] Clean Architecture structure in place
- [x] Auth system with role detection
- [x] Class enrollment system
- [x] Profile system with full_name

## ✅ Dependencies

- [x] `provider` package for state management
- [x] `supabase_flutter` package for backend
- [x] `intl` package for date formatting
- [x] `equatable` package for entity comparison

## ⚠️ Required Before Implementation

### 1. Verify Database Tables

```sql
-- Check discussions table exists
SELECT * FROM discussions LIMIT 1;

-- Check discussion_replies table exists
SELECT * FROM discussion_replies LIMIT 1;
```

### 2. Verify RLS Policies

- [ ] Create RLS policies for discussions table
- [ ] Create RLS policies for discussion_replies table
- [ ] Test policies with different roles

### 3. Verify Class Enrollment Query

```dart
// Need to verify this query works
final enrollments = await supabaseClient
    .from('class_enrollments')
    .select('class_id, classes(id, name)')
    .eq('user_id', userId);
```

### 4. Verify Profile Query

```dart
// Need to verify this query works for getting username
final profile = await supabaseClient
    .from('profiles')
    .select('full_name')
    .eq('id', userId)
    .single();
```

## 📋 Pre-Implementation Tasks

1. [ ] Run database migration if tables don't exist
2. [ ] Create RLS policies (see design.md)
3. [ ] Test Supabase queries manually
4. [ ] Verify role detection works (student vs mentor)
5. [ ] Create feature folder structure

## 🔧 Folder Structure to Create

```
lib/features/discussions/
├── data/
│   ├── models/
│   └── services/
├── domain/
│   ├── entities/
│   └── validators/
└── presentation/
    ├── pages/
    ├── providers/
    └── widgets/
```

## 📝 Notes

- Database schema already exists, no migration needed
- RLS policies need to be created for role-based access
- Existing patterns from meetings/assignments can be referenced
- @mention system is new, needs careful implementation
