# Entity Relationship Diagram (ERD) - Gabara LMS

## 📊 Diagram Relasi Tabel

```
┌─────────────────┐
│   auth.users    │ (Supabase Auth)
│  (Built-in)     │
└────────┬────────┘
         │
         │ 1:1
         ▼
┌─────────────────┐
│    profiles     │
│─────────────────│
│ id (PK, FK)     │
│ full_name       │
│ phone           │
│ gender          │
│ birth_date      │
│ avatar_url      │
└─────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐      ┌─────────────────┐
│   user_roles    │ N:1  │     roles       │
│─────────────────│◄─────│─────────────────│
│ id (PK)         │      │ id (PK)         │
│ user_id (FK)    │      │ name (UNIQUE)   │
│ role_id (FK)    │      │ description     │
└─────────────────┘      └─────────────────┘
                         (admin, mentor, student)


┌─────────────────────────────────────────────────────────────┐
│                      AKADEMIK SECTION                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│    subjects     │
│─────────────────│
│ id (PK)         │
│ name            │
│ description     │
│ grade_level     │
│ is_active       │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│    classes      │
│─────────────────│
│ id (PK)         │
│ name            │
│ description     │
│ tutor_id (FK)   │───────► auth.users (mentor)
│ subject_id (FK) │
│ class_code      │
│ max_students    │
│ is_active       │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌──────────────────────┐
│  class_enrollments   │
│──────────────────────│
│ id (PK)              │
│ class_id (FK)        │
│ user_id (FK)         │───► auth.users (student)
│ status               │
│ joined_at            │
└──────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                       QUIZZES SECTION                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│    classes      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│    quizzes      │
│─────────────────│
│ id (PK)         │
│ class_id (FK)   │
│ title           │
│ duration_min    │
│ passing_score   │
│ max_attempts    │
│ open_at         │
│ close_at        │
│ created_by (FK) │───► auth.users (mentor)
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│   questions     │
│─────────────────│
│ id (PK)         │
│ quiz_id (FK)    │
│ question_text   │
│ question_type   │
│ points          │
│ order_index     │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│    options      │
│─────────────────│
│ id (PK)         │
│ question_id(FK) │
│ option_text     │
│ is_correct      │
│ order_index     │
└─────────────────┘

┌─────────────────┐
│    quizzes      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│ quiz_attempts   │
│─────────────────│
│ id (PK)         │
│ quiz_id (FK)    │
│ user_id (FK)    │───► auth.users (student)
│ attempt_number  │
│ score           │
│ percentage      │
│ status          │
│ started_at      │
│ submitted_at    │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│  quiz_answers   │
│─────────────────│
│ id (PK)         │
│ attempt_id (FK) │
│ question_id(FK) │
│ option_id (FK)  │
│ answer_text     │
│ is_correct      │
│ points_earned   │
└─────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                    ASSIGNMENTS SECTION                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│    classes      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│  assignments    │
│─────────────────│
│ id (PK)         │
│ class_id (FK)   │
│ title           │
│ description     │
│ instructions    │
│ max_score       │
│ deadline        │
│ attachment_url  │
│ created_by (FK) │───► auth.users (mentor)
└────────┬────────┘
         │
         │ 1:N
         ▼
┌──────────────────────┐
│ assignment_          │
│   submissions        │
│──────────────────────│
│ id (PK)              │
│ assignment_id (FK)   │
│ user_id (FK)         │───► auth.users (student)
│ content              │
│ attachment_url       │
│ score                │
│ feedback             │
│ status               │
│ submitted_at         │
│ graded_at            │
│ graded_by (FK)       │───► auth.users (mentor)
└──────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                     MEETINGS SECTION                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│    classes      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│    meetings     │
│─────────────────│
│ id (PK)         │
│ class_id (FK)   │
│ title           │
│ description     │
│ meeting_date    │
│ duration_min    │
│ meeting_link    │
│ meeting_type    │
│ location        │
│ status          │
│ created_by (FK) │───► auth.users (mentor)
└────────┬────────┘
         │
         │ 1:N
         ▼
┌──────────────────────┐
│  meeting_           │
│   attendances        │
│──────────────────────│
│ id (PK)              │
│ meeting_id (FK)      │
│ user_id (FK)         │───► auth.users (student)
│ status               │
│ attended_at          │
│ notes                │
└──────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│                  COMMUNICATION SECTION                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  announcements  │
│─────────────────│
│ id (PK)         │
│ title           │
│ content         │
│ class_id (FK)   │───► classes (NULL = global)
│ target_role     │
│ is_pinned       │
│ is_active       │
│ created_by (FK) │───► auth.users (mentor/admin)
└─────────────────┘


┌─────────────────┐
│    classes      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐
│  discussions    │
│─────────────────│
│ id (PK)         │
│ class_id (FK)   │
│ title           │
│ content         │
│ is_pinned       │
│ is_closed       │
│ view_count      │
│ created_by (FK) │───► auth.users (student/mentor)
└────────┬────────┘
         │
         │ 1:N
         ▼
┌──────────────────────┐
│  discussion_         │
│    replies           │
│──────────────────────│
│ id (PK)              │
│ discussion_id (FK)   │
│ parent_reply_id (FK) │───► discussion_replies (self-ref)
│ content              │
│ is_edited            │
│ created_by (FK)      │───► auth.users
└──────────────────────┘
```

---

## 🔗 Relasi Utama

### 1. User Management
```
auth.users ──1:1──► profiles
auth.users ──1:N──► user_roles ──N:1──► roles
```

### 2. Classes & Enrollments
```
subjects ──1:N──► classes
auth.users (mentor) ──1:N──► classes
classes ──1:N──► class_enrollments ──N:1──► auth.users (student)
```

### 3. Quizzes
```
classes ──1:N──► quizzes ──1:N──► questions ──1:N──► options
quizzes ──1:N──► quiz_attempts ──1:N──► quiz_answers
quiz_answers ──N:1──► questions
quiz_answers ──N:1──► options
```

### 4. Assignments
```
classes ──1:N──► assignments ──1:N──► assignment_submissions
assignment_submissions ──N:1──► auth.users (student)
assignment_submissions ──N:1──► auth.users (graded_by: mentor)
```

### 5. Meetings
```
classes ──1:N──► meetings ──1:N──► meeting_attendances
meeting_attendances ──N:1──► auth.users (student)
```

### 6. Communication
```
classes ──1:N──► announcements (optional, NULL = global)
classes ──1:N──► discussions ──1:N──► discussion_replies
discussion_replies ──1:N──► discussion_replies (nested, self-referencing)
```

---

## 📋 Kardinalitas

| Relasi | Tipe | Keterangan |
|--------|------|------------|
| auth.users → profiles | 1:1 | Setiap user punya 1 profile |
| auth.users → user_roles | 1:N | User bisa punya banyak role |
| roles → user_roles | 1:N | 1 role bisa dimiliki banyak user |
| subjects → classes | 1:N | 1 subject bisa punya banyak kelas |
| auth.users (mentor) → classes | 1:N | 1 mentor bisa buat banyak kelas |
| classes → class_enrollments | 1:N | 1 kelas bisa punya banyak siswa |
| classes → quizzes | 1:N | 1 kelas bisa punya banyak kuis |
| quizzes → questions | 1:N | 1 kuis punya banyak pertanyaan |
| questions → options | 1:N | 1 pertanyaan punya banyak pilihan |
| quizzes → quiz_attempts | 1:N | 1 kuis bisa dikerjakan banyak kali |
| quiz_attempts → quiz_answers | 1:N | 1 attempt punya banyak jawaban |
| classes → assignments | 1:N | 1 kelas punya banyak tugas |
| assignments → submissions | 1:N | 1 tugas punya banyak pengumpulan |
| classes → meetings | 1:N | 1 kelas punya banyak pertemuan |
| meetings → attendances | 1:N | 1 meeting punya banyak kehadiran |
| classes → discussions | 1:N | 1 kelas punya banyak diskusi |
| discussions → replies | 1:N | 1 diskusi punya banyak balasan |
| replies → replies | 1:N | Nested replies (self-referencing) |

---

## 🎯 Foreign Keys Summary

### Tabel dengan FK ke auth.users:
- profiles (id)
- user_roles (user_id)
- classes (tutor_id)
- class_enrollments (user_id)
- quizzes (created_by)
- quiz_attempts (user_id)
- assignments (created_by)
- assignment_submissions (user_id, graded_by)
- meetings (created_by)
- meeting_attendances (user_id)
- announcements (created_by)
- discussions (created_by)
- discussion_replies (created_by)

### Tabel dengan FK ke classes:
- class_enrollments (class_id)
- quizzes (class_id)
- assignments (class_id)
- meetings (class_id)
- announcements (class_id) - NULLABLE
- discussions (class_id)

---

## 💡 Catatan Penting

1. **Self-Referencing**: `discussion_replies.parent_reply_id` → `discussion_replies.id` untuk nested replies

2. **Nullable FK**: 
   - `announcements.class_id` bisa NULL (untuk global announcement)
   - `discussion_replies.parent_reply_id` bisa NULL (untuk top-level reply)

3. **Composite Unique**:
   - `user_roles(user_id, role_id)` - user tidak bisa punya role duplikat
   - `class_enrollments(class_id, user_id)` - user tidak bisa enroll 2x di kelas sama
   - `quiz_attempts(quiz_id, user_id, attempt_number)` - tracking attempt ke-berapa
   - `assignment_submissions(assignment_id, user_id)` - 1 user 1 submission per tugas
   - `meeting_attendances(meeting_id, user_id)` - 1 user 1 attendance per meeting

4. **ON DELETE Behavior**:
   - `CASCADE` - hapus child records jika parent dihapus
   - `SET NULL` - set NULL jika parent dihapus (untuk created_by, graded_by, dll)

---

**Dibuat**: 27 November 2025  
**Versi**: 2.0  
**Format**: ASCII ERD
