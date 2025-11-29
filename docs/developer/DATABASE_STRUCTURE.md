# Struktur Database Gabara LMS V2

## 📋 Daftar Tabel

### 1. **User Management** (3 tabel)
- `profiles` - Data profil user
- `roles` - Daftar role (admin, mentor, student)
- `user_roles` - Relasi user dengan role

### 2. **Akademik** (3 tabel)
- `subjects` - Mata pelajaran
- `classes` - Kelas pembelajaran
- `class_enrollments` - Pendaftaran siswa ke kelas

### 3. **Quizzes** (5 tabel)
- `quizzes` - Data kuis
- `questions` - Pertanyaan kuis
- `options` - Pilihan jawaban
- `quiz_attempts` - Percobaan mengerjakan kuis
- `quiz_answers` - Jawaban siswa

### 4. **Assignments** (2 tabel)
- `assignments` - Data tugas
- `assignment_submissions` - Pengumpulan tugas

### 5. **Meetings** (2 tabel)
- `meetings` - Jadwal pertemuan
- `meeting_attendances` - Kehadiran pertemuan

### 6. **Communication** (3 tabel)
- `announcements` - Pengumuman
- `discussions` - Topik diskusi
- `discussion_replies` - Balasan diskusi

---

## 📊 Detail Tabel

### 1. PROFILES
```sql
id              UUID (PK, FK ke auth.users)
full_name       TEXT (NOT NULL)
phone           TEXT
gender          TEXT ('Laki-laki', 'Perempuan')
birth_date      DATE
avatar_url      TEXT
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Menyimpan data profil user tambahan dari auth.users

---

### 2. ROLES
```sql
id              SERIAL (PK)
name            TEXT (UNIQUE, 'admin'|'mentor'|'student')
description     TEXT
created_at      TIMESTAMP
```
**Fungsi**: Definisi role dalam sistem

---

### 3. USER_ROLES
```sql
id              SERIAL (PK)
user_id         UUID (FK ke auth.users)
role_id         INTEGER (FK ke roles)
assigned_at     TIMESTAMP
UNIQUE(user_id, role_id)
```
**Fungsi**: Relasi many-to-many antara user dan role

---

### 4. SUBJECTS
```sql
id              SERIAL (PK)
name            TEXT (NOT NULL)
description     TEXT
grade_level     TEXT (SD/SMP/SMA)
icon_url        TEXT
is_active       BOOLEAN
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Daftar mata pelajaran

**Contoh Data**:
- Matematika (SD)
- Bahasa Indonesia (SD)
- IPA (SD)

---

### 5. CLASSES
```sql
id              UUID (PK)
name            TEXT (NOT NULL)
description     TEXT
tutor_id        UUID (FK ke auth.users, NOT NULL)
subject_id      INTEGER (FK ke subjects)
class_code      TEXT (UNIQUE) - untuk join kelas
max_students    INTEGER (default 50)
is_active       BOOLEAN
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Kelas pembelajaran yang dibuat mentor

**Relasi**:
- 1 class → 1 tutor (mentor)
- 1 class → 1 subject
- 1 class → many students (via class_enrollments)

---

### 6. CLASS_ENROLLMENTS
```sql
id              UUID (PK)
class_id        UUID (FK ke classes)
user_id         UUID (FK ke auth.users)
status          TEXT ('active'|'inactive'|'completed')
joined_at       TIMESTAMP
UNIQUE(class_id, user_id)
```
**Fungsi**: Pendaftaran siswa ke kelas

---

### 7. QUIZZES
```sql
id                  UUID (PK)
class_id            UUID (FK ke classes, NOT NULL)
title               TEXT (NOT NULL)
description         TEXT
duration_minutes    INTEGER (default 60)
passing_score       DECIMAL(5,2) (default 60.00)
max_attempts        INTEGER (default 1)
is_active           BOOLEAN
open_at             TIMESTAMP
close_at            TIMESTAMP
created_by          UUID (FK ke auth.users)
created_at          TIMESTAMP
updated_at          TIMESTAMP
```
**Fungsi**: Data kuis untuk kelas

**Fitur**:
- Durasi waktu pengerjaan
- Batas nilai kelulusan
- Maksimal percobaan
- Jadwal buka/tutup

---

### 8. QUESTIONS
```sql
id              UUID (PK)
quiz_id         UUID (FK ke quizzes, NOT NULL)
question_text   TEXT (NOT NULL)
question_type   TEXT ('multiple_choice'|'true_false'|'essay')
points          INTEGER (default 10)
order_index     INTEGER
created_at      TIMESTAMP
```
**Fungsi**: Pertanyaan dalam kuis

**Tipe Soal**:
- Multiple Choice (pilihan ganda)
- True/False (benar/salah)
- Essay (uraian)

---

### 9. OPTIONS
```sql
id              UUID (PK)
question_id     UUID (FK ke questions, NOT NULL)
option_text     TEXT (NOT NULL)
is_correct      BOOLEAN
order_index     INTEGER
created_at      TIMESTAMP
```
**Fungsi**: Pilihan jawaban untuk soal multiple choice

---

### 10. QUIZ_ATTEMPTS
```sql
id              UUID (PK)
quiz_id         UUID (FK ke quizzes, NOT NULL)
user_id         UUID (FK ke auth.users, NOT NULL)
attempt_number  INTEGER (default 1)
score           DECIMAL(5,2)
max_score       DECIMAL(5,2)
percentage      DECIMAL(5,2)
status          TEXT ('in_progress'|'submitted'|'graded')
started_at      TIMESTAMP
submitted_at    TIMESTAMP
UNIQUE(quiz_id, user_id, attempt_number)
```
**Fungsi**: Tracking percobaan siswa mengerjakan kuis

---

### 11. QUIZ_ANSWERS
```sql
id              UUID (PK)
attempt_id      UUID (FK ke quiz_attempts, NOT NULL)
question_id     UUID (FK ke questions, NOT NULL)
option_id       UUID (FK ke options) - untuk multiple choice
answer_text     TEXT - untuk essay
is_correct      BOOLEAN
points_earned   DECIMAL(5,2)
created_at      TIMESTAMP
```
**Fungsi**: Jawaban siswa untuk setiap pertanyaan

---

### 12. ASSIGNMENTS
```sql
id              UUID (PK)
class_id        UUID (FK ke classes, NOT NULL)
title           TEXT (NOT NULL)
description     TEXT
instructions    TEXT
max_score       INTEGER (default 100)
deadline        TIMESTAMP (NOT NULL)
attachment_url  TEXT
is_active       BOOLEAN
created_by      UUID (FK ke auth.users)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Tugas yang diberikan mentor

---

### 13. ASSIGNMENT_SUBMISSIONS
```sql
id              UUID (PK)
assignment_id   UUID (FK ke assignments, NOT NULL)
user_id         UUID (FK ke auth.users, NOT NULL)
content         TEXT
attachment_url  TEXT
score           DECIMAL(5,2)
feedback        TEXT
status          TEXT ('draft'|'submitted'|'graded'|'late'|'returned')
submitted_at    TIMESTAMP
graded_at       TIMESTAMP
graded_by       UUID (FK ke auth.users)
UNIQUE(assignment_id, user_id)
```
**Fungsi**: Pengumpulan tugas oleh siswa

**Status**:
- draft: Masih draft
- submitted: Sudah dikumpulkan
- graded: Sudah dinilai
- late: Terlambat
- returned: Dikembalikan untuk revisi

---

### 14. MEETINGS
```sql
id                  UUID (PK)
class_id            UUID (FK ke classes, NOT NULL)
title               TEXT (NOT NULL)
description         TEXT
meeting_date        TIMESTAMP (NOT NULL)
duration_minutes    INTEGER (default 60)
meeting_link        TEXT
meeting_type        TEXT ('online'|'offline')
location            TEXT - untuk offline
status              TEXT ('scheduled'|'ongoing'|'completed'|'cancelled')
created_by          UUID (FK ke auth.users)
created_at          TIMESTAMP
updated_at          TIMESTAMP
```
**Fungsi**: Jadwal pertemuan kelas

---

### 15. MEETING_ATTENDANCES
```sql
id              UUID (PK)
meeting_id      UUID (FK ke meetings, NOT NULL)
user_id         UUID (FK ke auth.users, NOT NULL)
status          TEXT ('present'|'absent'|'late'|'excused')
attended_at     TIMESTAMP
notes           TEXT
UNIQUE(meeting_id, user_id)
```
**Fungsi**: Tracking kehadiran siswa di pertemuan

---

### 16. ANNOUNCEMENTS
```sql
id              UUID (PK)
title           TEXT (NOT NULL)
content         TEXT (NOT NULL)
class_id        UUID (FK ke classes) - NULL = global
target_role     TEXT ('all'|'student'|'mentor'|'admin')
is_pinned       BOOLEAN
is_active       BOOLEAN
created_by      UUID (FK ke auth.users, NOT NULL)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Pengumuman untuk kelas atau global

**Tipe**:
- Global: class_id = NULL
- Kelas Spesifik: class_id = UUID kelas

---

### 17. DISCUSSIONS
```sql
id              UUID (PK)
class_id        UUID (FK ke classes, NOT NULL)
title           TEXT (NOT NULL)
content         TEXT (NOT NULL)
is_pinned       BOOLEAN
is_closed       BOOLEAN
view_count      INTEGER
created_by      UUID (FK ke auth.users, NOT NULL)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```
**Fungsi**: Topik diskusi dalam kelas

---

### 18. DISCUSSION_REPLIES
```sql
id                  UUID (PK)
discussion_id       UUID (FK ke discussions, NOT NULL)
parent_reply_id     UUID (FK ke discussion_replies) - NULL = top level
content             TEXT (NOT NULL)
is_edited           BOOLEAN
created_by          UUID (FK ke auth.users, NOT NULL)
created_at          TIMESTAMP
updated_at          TIMESTAMP
```
**Fungsi**: Balasan diskusi (support nested replies)

---

## 🔐 Row Level Security (RLS)

Semua tabel sudah dilengkapi dengan RLS policies:

### Prinsip RLS:
1. **Profiles**: User hanya bisa edit profil sendiri
2. **Classes**: Semua bisa lihat, hanya mentor yang bisa buat
3. **Enrollments**: Student bisa enroll/leave sendiri
4. **Quizzes**: Hanya enrolled student & tutor yang bisa akses
5. **Assignments**: Hanya enrolled student & tutor yang bisa akses
6. **Submissions**: Student hanya bisa lihat/edit milik sendiri
7. **Meetings**: Hanya enrolled student & tutor yang bisa akses
8. **Announcements**: Semua bisa lihat, mentor/admin yang bisa buat
9. **Discussions**: Hanya enrolled student yang bisa akses & buat

---

## 🔄 Triggers & Functions

### 1. handle_new_user()
**Fungsi**: Auto-create profile dan assign role saat user register
**Trigger**: AFTER INSERT ON auth.users

### 2. handle_updated_at()
**Fungsi**: Auto-update kolom updated_at
**Trigger**: BEFORE UPDATE pada tabel yang punya updated_at

---

## 📈 Indexes

Semua foreign keys dan kolom yang sering di-query sudah diberi index untuk performa optimal.

**Contoh**:
- `idx_classes_tutor_id` - untuk query kelas by tutor
- `idx_class_enrollments_user_id` - untuk query enrollment by user
- `idx_quiz_attempts_user_id` - untuk query attempts by user

---

## 🎯 Perbedaan dengan Schema Lama

### ✅ Yang Diperbaiki:

1. **Struktur Lebih Jelas**
   - Hapus tabel `class_subjects` (redundant, sudah ada subject_id di classes)
   - Tambah tabel `quiz_answers` untuk tracking jawaban detail
   - Tambah tabel `meeting_attendances` untuk tracking kehadiran

2. **Field Lebih Lengkap**
   - `classes.class_code` - untuk join kelas dengan kode
   - `quizzes.passing_score` - batas nilai kelulusan
   - `quiz_attempts.percentage` - persentase nilai
   - `meetings.meeting_type` - online/offline
   - `announcements.target_role` - target pengumuman

3. **Status Lebih Detail**
   - `class_enrollments.status` - active/inactive/completed
   - `quiz_attempts.status` - in_progress/submitted/graded
   - `assignment_submissions.status` - draft/submitted/graded/late/returned
   - `meetings.status` - scheduled/ongoing/completed/cancelled

4. **RLS Policies Lebih Ketat**
   - Semua tabel sudah ada RLS
   - Policy lebih spesifik per role
   - Proteksi data lebih baik

5. **Indexes Lengkap**
   - Semua FK sudah di-index
   - Query lebih cepat

---

## 🚀 Cara Implementasi

1. **Backup Database Lama** (jika ada)
   ```sql
   -- Export data penting dulu
   ```

2. **Jalankan Schema Baru**
   - Buka Supabase SQL Editor
   - Copy paste `database_schema_v2.sql`
   - Execute

3. **Verifikasi**
   - Cek semua tabel sudah terbuat
   - Cek trigger sudah aktif
   - Test registrasi user baru

4. **Test RLS**
   - Login sebagai student
   - Coba akses data kelas lain (harus gagal)
   - Coba edit profil orang lain (harus gagal)

---

## 📝 Notes

- Semua timestamp menggunakan `TIMESTAMP WITH TIME ZONE`
- UUID menggunakan `gen_random_uuid()`
- Semua foreign key menggunakan `ON DELETE CASCADE` atau `SET NULL` sesuai kebutuhan
- Constraint CHECK untuk validasi data di level database
- UNIQUE constraint untuk mencegah duplikasi data

---

**Dibuat**: 27 November 2025  
**Versi**: 2.0  
**Status**: ✅ Production Ready
