# Setup Supabase untuk Gabara LMS

Panduan lengkap untuk mengatur database Supabase untuk platform Gabara LMS.

## Daftar Isi
- [Persiapan](#persiapan)
- [Tabel Database](#tabel-database)
  - [Users (Ekstensi auth.users)](#users-ekstensi-authusers)
  - [Roles](#roles)
  - [User_roles](#user_roles)
  - [Classes](#classes)
  - [Subjects (Mata Pelajaran)](#subjects-mata-pelajaran)
  - [Class_subjects](#class_subjects)
  - [Quizzes](#quizzes)
  - [Questions](#questions)
  - [Options](#options)
  - [Quiz_attempts](#quiz_attempts)
  - [Assignments (Tugas)](#assignments-tugas)
  - [Assignment_submissions](#assignment_submissions)
  - [Meetings](#meetings)
  - [Announcements](#announcements)
  - [Discussions](#discussions)
  - [Discussion_replies](#discussion_replies)
- [Row Level Security (RLS) Policies](#row-level-security-rls-policies)
- [Data Seeding](#data-seeding)

## Persiapan

1. Buat project baru di [Supabase](https://supabase.com)
2. Catat URL project dan anon key
3. Update file `lib/main.dart` dengan URL dan anon key yang benar

## Tabel Database

### Users (Ekstensi auth.users)

Tabel ini menggunakan `auth.users` dari Supabase Auth dengan kolom tambahan di tabel `profiles`.

**Tabel: profiles**
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  gender TEXT CHECK (gender IN ('Laki-laki', 'Perempuan')),
  birth_date DATE,
  role TEXT DEFAULT 'student' CHECK (role IN ('admin', 'mentor', 'student')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Roles

**Tabel: roles**
```sql
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL CHECK (name IN ('admin', 'mentor', 'student')),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### User_roles

**Tabel: user_roles**
```sql
CREATE TABLE user_roles (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
  assigned_by UUID REFERENCES auth.users(id),
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, role_id)
);
```

### Classes

**Tabel: classes**
```sql
CREATE TABLE classes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  tutor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
  schedule TEXT, -- JSON string untuk jadwal
  max_students INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Subjects (Mata Pelajaran)

**Tabel: subjects**
```sql
CREATE TABLE subjects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  grade_level TEXT, -- SD, SMP, SMA, dll
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Class_subjects

**Tabel: class_subjects**
```sql
CREATE TABLE class_subjects (
  id SERIAL PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE,
  UNIQUE(class_id, subject_id)
);
```

### Quizzes

**Tabel: quizzes**
```sql
CREATE TABLE quizzes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  open_at TIMESTAMP WITH TIME ZONE,
  close_at TIMESTAMP WITH TIME ZONE,
  duration_minutes INTEGER DEFAULT 60,
  attempts_allowed INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Questions

**Tabel: questions**
```sql
CREATE TABLE questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  question_type TEXT DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer')),
  points INTEGER DEFAULT 1,
  order_index INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Options

**Tabel: options**
```sql
CREATE TABLE options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT false,
  order_index INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Quiz_attempts

**Tabel: quiz_attempts**
```sql
CREATE TABLE quiz_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  score DECIMAL(5,2),
  answers JSONB, -- Menyimpan jawaban dalam format JSON
  attempt_number INTEGER DEFAULT 1,
  UNIQUE(quiz_id, user_id, attempt_number)
);
```

### Assignments (Tugas)

**Tabel: assignments**
```sql
CREATE TABLE assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  max_score INTEGER DEFAULT 100,
  instructions TEXT,
  attachments JSONB, -- Array of file URLs
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Assignment_submissions

**Tabel: assignment_submissions**
```sql
CREATE TABLE assignment_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  content TEXT,
  attachments JSONB, -- Array of file URLs
  score DECIMAL(5,2),
  feedback TEXT,
  graded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  graded_at TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('draft', 'submitted', 'graded', 'late')),
  UNIQUE(assignment_id, user_id)
);
```

### Meetings

**Tabel: meetings**
```sql
CREATE TABLE meetings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  scheduled_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  meeting_link TEXT, -- Zoom/Google Meet link
  is_online BOOLEAN DEFAULT true,
  location TEXT, -- Jika offline
  is_mandatory BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Announcements

**Tabel: announcements**
```sql
CREATE TABLE announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  target_audience TEXT DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'mentors', 'admins')),
  target_class_id UUID REFERENCES classes(id) ON DELETE CASCADE, -- NULL jika untuk semua
  is_pinned BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Discussions

**Tabel: discussions**
```sql
CREATE TABLE discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_pinned BOOLEAN DEFAULT false,
  is_closed BOOLEAN DEFAULT false,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

### Discussion_replies

**Tabel: discussion_replies**
```sql
CREATE TABLE discussion_replies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES discussions(id) ON DELETE CASCADE,
  parent_reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE, -- NULL untuk reply level 1
  content TEXT NOT NULL,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_edited BOOLEAN DEFAULT false,
  edited_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
```

## Row Level Security (RLS) Policies

### Contoh RLS untuk tabel classes:
```sql
-- Enable RLS
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Policy untuk admin: bisa lihat semua kelas
CREATE POLICY "Admin can view all classes" ON classes
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = auth.uid() AND r.name = 'admin'
  )
);

-- Policy untuk mentor: bisa lihat kelas yang mereka buat
CREATE POLICY "Mentor can view own classes" ON classes
FOR SELECT USING (
  tutor_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = auth.uid() AND r.name = 'mentor'
  )
);

-- Policy untuk student: bisa lihat kelas yang mereka ikuti
CREATE POLICY "Student can view enrolled classes" ON classes
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM class_enrollments ce
    WHERE ce.class_id = classes.id AND ce.user_id = auth.uid()
  )
);
```

*Note: Buat RLS policies serupa untuk semua tabel sesuai dengan role permissions.*

## Data Seeding

### Insert Roles:
```sql
INSERT INTO roles (name, description) VALUES
('admin', 'Administrator dengan akses penuh'),
('mentor', 'Mentor yang membimbing siswa'),
('student', 'Siswa yang belajar');
```

### Insert Sample Subjects:
```sql
INSERT INTO subjects (name, description, grade_level) VALUES
('Matematika', 'Pelajaran matematika dasar', 'SD'),
('Bahasa Indonesia', 'Pelajaran bahasa Indonesia', 'SD'),
('IPA', 'Ilmu Pengetahuan Alam', 'SD');
```

### Insert Sample Classes:
```sql
INSERT INTO classes (name, description, subject_id) VALUES
('Kelas Matematika SD 1', 'Kelas matematika untuk siswa SD kelas 1', 1),
('Kelas Bahasa Indonesia SD 1', 'Kelas bahasa Indonesia untuk siswa SD kelas 1', 2);
```

*Note: Lakukan seeding data sesuai kebutuhan testing.*

## Setup Lengkap

1. Jalankan SQL queries di atas di Supabase SQL Editor
2. Setup RLS policies untuk setiap tabel
3. Seed data awal
4. Test koneksi dari aplikasi Flutter
5. Implementasi API endpoints sesuai TODO_BACKEND.md

## Catatan

- Pastikan semua foreign key constraints sudah benar
- Setup triggers untuk updated_at columns jika diperlukan
- Backup database sebelum production deployment
- Monitor performance dan adjust indexes jika perlu
