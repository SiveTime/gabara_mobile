-- ============================================
-- GABARA LMS - DATABASE SCHEMA V2
-- Platform LMS untuk Anak-anak Desa
-- ============================================
-- Fitur: Auth, Classes, Subjects, Quizzes, Assignments, 
--        Meetings, Announcements, Discussions
-- Roles: Admin, Mentor, Student
-- ============================================

-- 1. BERSIHKAN DATABASE (HATI-HATI: Ini akan hapus semua data!)
DROP TABLE IF EXISTS
  discussion_replies, discussions, 
  announcements, 
  meeting_attendances, meetings,
  assignment_submissions, assignments, 
  quiz_answers, quiz_attempts, options, questions, quizzes,
  class_enrollments, class_subjects, 
  classes, subjects,
  user_roles, roles, 
  profiles
CASCADE;

-- ============================================
-- 2. USER MANAGEMENT & AUTHENTICATION
-- ============================================

-- Tabel Profiles (Ekstensi dari auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  gender TEXT CHECK (gender IN ('Laki-laki', 'Perempuan')),
  birth_date DATE,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Roles
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL CHECK (name IN ('admin', 'mentor', 'student')),
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel User Roles (Many-to-Many)
CREATE TABLE user_roles (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE NOT NULL,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, role_id)
);

-- ============================================
-- 3. AKADEMIK - SUBJECTS & CLASSES
-- ============================================

-- Tabel Subjects (Mata Pelajaran)
CREATE TABLE subjects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  grade_level TEXT, -- SD, SMP, SMA
  icon_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Classes (Kelas)
CREATE TABLE classes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  tutor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
  subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
  class_code TEXT UNIQUE, -- Kode untuk join kelas
  max_students INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Class Enrollments (Pendaftaran Kelas)
CREATE TABLE class_enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'completed')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(class_id, user_id)
);

-- ============================================
-- 4. QUIZZES (KUIS)
-- ============================================

-- Tabel Quizzes
CREATE TABLE quizzes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER DEFAULT 60,
  passing_score DECIMAL(5,2) DEFAULT 60.00,
  max_attempts INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  open_at TIMESTAMP WITH TIME ZONE,
  close_at TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Questions (Pertanyaan)
CREATE TABLE questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'true_false', 'essay')),
  points INTEGER DEFAULT 10,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Options (Pilihan Jawaban)
CREATE TABLE options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE NOT NULL,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT false,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Quiz Attempts (Percobaan Kuis)
CREATE TABLE quiz_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  attempt_number INTEGER DEFAULT 1,
  score DECIMAL(5,2),
  max_score DECIMAL(5,2),
  percentage DECIMAL(5,2),
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'submitted', 'graded')),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  submitted_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(quiz_id, user_id, attempt_number)
);

-- Tabel Quiz Answers (Jawaban Kuis)
CREATE TABLE quiz_answers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  attempt_id UUID REFERENCES quiz_attempts(id) ON DELETE CASCADE NOT NULL,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE NOT NULL,
  option_id UUID REFERENCES options(id) ON DELETE SET NULL, -- Untuk multiple choice
  answer_text TEXT, -- Untuk essay
  is_correct BOOLEAN,
  points_earned DECIMAL(5,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 5. ASSIGNMENTS (TUGAS)
-- ============================================

-- Tabel Assignments
CREATE TABLE assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  instructions TEXT,
  max_score INTEGER DEFAULT 100,
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  attachment_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Assignment Submissions
CREATE TABLE assignment_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  attachment_url TEXT,
  score DECIMAL(5,2),
  feedback TEXT,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('draft', 'submitted', 'graded', 'late', 'returned')),
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  graded_at TIMESTAMP WITH TIME ZONE,
  graded_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  UNIQUE(assignment_id, user_id)
);

-- ============================================
-- 6. MEETINGS (PERTEMUAN)
-- ============================================

-- Tabel Meetings
CREATE TABLE meetings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  meeting_link TEXT,
  meeting_type TEXT DEFAULT 'online' CHECK (meeting_type IN ('online', 'offline')),
  location TEXT, -- Untuk offline
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabel Meeting Attendances (Kehadiran)
CREATE TABLE meeting_attendances (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  meeting_id UUID REFERENCES meetings(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'absent' CHECK (status IN ('present', 'absent', 'late', 'excused')),
  attended_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  UNIQUE(meeting_id, user_id)
);

-- ============================================
-- 7. ANNOUNCEMENTS (PENGUMUMAN)
-- ============================================

-- Tabel Announcements
CREATE TABLE announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE, -- NULL = global announcement
  target_role TEXT CHECK (target_role IN ('all', 'student', 'mentor', 'admin')),
  is_pinned BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 8. DISCUSSIONS (FORUM DISKUSI)
-- ============================================

-- Tabel Discussions
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

-- Tabel Discussion Replies (Balasan Diskusi)
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

-- ============================================
-- 9. DATA SEEDING (Data Awal)
-- ============================================

-- Insert Roles
INSERT INTO roles (name, description) VALUES
('admin', 'Administrator dengan akses penuh ke sistem'),
('mentor', 'Pengajar/Tutor yang mengelola kelas dan materi'),
('student', 'Siswa yang mengikuti pembelajaran');

-- Insert Sample Subjects
INSERT INTO subjects (name, description, grade_level) VALUES
('Matematika', 'Pelajaran matematika dasar', 'SD'),
('Bahasa Indonesia', 'Bahasa dan sastra Indonesia', 'SD'),
('IPA', 'Ilmu Pengetahuan Alam', 'SD'),
('IPS', 'Ilmu Pengetahuan Sosial', 'SD'),
('Bahasa Inggris', 'Bahasa Inggris dasar', 'SD');

-- ============================================
-- 10. FUNCTIONS & TRIGGERS
-- ============================================

-- Function untuk auto-create profile dan assign role saat user register
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  target_role_id INTEGER;
  role_name TEXT;
BEGIN
  -- 1. Ambil role dari metadata, default 'student'
  role_name := COALESCE(NEW.raw_user_meta_data->>'role', 'student');

  -- 2. Insert ke profiles
  INSERT INTO public.profiles (id, full_name, phone, gender, birth_date)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'gender',
    (NEW.raw_user_meta_data->>'birth_date')::date
  );

  -- 3. Cari ID untuk role tersebut
  SELECT id INTO target_role_id FROM public.roles WHERE name = role_name;

  -- 4. Masukkan ke user_roles
  IF target_role_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role_id) 
    VALUES (NEW.id, target_role_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger untuk auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function untuk update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers untuk updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON subjects
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON classes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON assignments
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON meetings
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON discussions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON discussion_replies
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 11. INDEXES (Untuk Performance)
-- ============================================

-- User Roles
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- Classes
CREATE INDEX idx_classes_tutor_id ON classes(tutor_id);
CREATE INDEX idx_classes_subject_id ON classes(subject_id);
CREATE INDEX idx_classes_is_active ON classes(is_active);

-- Class Enrollments
CREATE INDEX idx_class_enrollments_class_id ON class_enrollments(class_id);
CREATE INDEX idx_class_enrollments_user_id ON class_enrollments(user_id);
CREATE INDEX idx_class_enrollments_status ON class_enrollments(status);

-- Quizzes
CREATE INDEX idx_quizzes_class_id ON quizzes(class_id);
CREATE INDEX idx_quizzes_created_by ON quizzes(created_by);
CREATE INDEX idx_questions_quiz_id ON questions(quiz_id);
CREATE INDEX idx_options_question_id ON options(question_id);

-- Quiz Attempts
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_answers_attempt_id ON quiz_answers(attempt_id);

-- Assignments
CREATE INDEX idx_assignments_class_id ON assignments(class_id);
CREATE INDEX idx_assignments_created_by ON assignments(created_by);
CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_user_id ON assignment_submissions(user_id);

-- Meetings
CREATE INDEX idx_meetings_class_id ON meetings(class_id);
CREATE INDEX idx_meetings_created_by ON meetings(created_by);
CREATE INDEX idx_meeting_attendances_meeting_id ON meeting_attendances(meeting_id);
CREATE INDEX idx_meeting_attendances_user_id ON meeting_attendances(user_id);

-- Announcements
CREATE INDEX idx_announcements_class_id ON announcements(class_id);
CREATE INDEX idx_announcements_created_by ON announcements(created_by);

-- Discussions
CREATE INDEX idx_discussions_class_id ON discussions(class_id);
CREATE INDEX idx_discussions_created_by ON discussions(created_by);
CREATE INDEX idx_discussion_replies_discussion_id ON discussion_replies(discussion_id);
CREATE INDEX idx_discussion_replies_parent_reply_id ON discussion_replies(parent_reply_id);

-- ============================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- PROFILES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- CLASSES
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view active classes" ON classes
  FOR SELECT USING (is_active = true);

CREATE POLICY "Mentors can create classes" ON classes
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name IN ('mentor', 'admin')
    )
  );

CREATE POLICY "Tutors can update own classes" ON classes
  FOR UPDATE USING (auth.uid() = tutor_id);

CREATE POLICY "Admins can delete classes" ON classes
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

-- CLASS ENROLLMENTS
ALTER TABLE class_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own enrollments" ON class_enrollments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Students can enroll themselves" ON class_enrollments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave classes" ON class_enrollments
  FOR DELETE USING (auth.uid() = user_id);

-- QUIZZES
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view quizzes" ON quizzes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = quizzes.class_id AND ce.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = quizzes.class_id AND c.tutor_id = auth.uid()
    )
  );

CREATE POLICY "Tutors can manage quizzes" ON quizzes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = quizzes.class_id AND c.tutor_id = auth.uid()
    )
  );

-- QUIZ ATTEMPTS
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own attempts" ON quiz_attempts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own attempts" ON quiz_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own attempts" ON quiz_attempts
  FOR UPDATE USING (auth.uid() = user_id);

-- ASSIGNMENTS
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view assignments" ON assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = assignments.class_id AND ce.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = assignments.class_id AND c.tutor_id = auth.uid()
    )
  );

CREATE POLICY "Tutors can manage assignments" ON assignments
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = assignments.class_id AND c.tutor_id = auth.uid()
    )
  );

-- ASSIGNMENT SUBMISSIONS
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own submissions" ON assignment_submissions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Students can submit assignments" ON assignment_submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students can update own submissions" ON assignment_submissions
  FOR UPDATE USING (auth.uid() = user_id AND status IN ('draft', 'submitted'));

CREATE POLICY "Tutors can grade submissions" ON assignment_submissions
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM assignments a
      JOIN classes c ON a.class_id = c.id
      WHERE a.id = assignment_submissions.assignment_id 
      AND c.tutor_id = auth.uid()
    )
  );

-- MEETINGS
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view meetings" ON meetings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = meetings.class_id AND ce.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = meetings.class_id AND c.tutor_id = auth.uid()
    )
  );

CREATE POLICY "Tutors can manage meetings" ON meetings
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = meetings.class_id AND c.tutor_id = auth.uid()
    )
  );

-- ANNOUNCEMENTS
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view announcements" ON announcements
  FOR SELECT USING (is_active = true);

CREATE POLICY "Mentors and admins can create announcements" ON announcements
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name IN ('mentor', 'admin')
    )
  );

CREATE POLICY "Creators can update own announcements" ON announcements
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Creators can delete own announcements" ON announcements
  FOR DELETE USING (auth.uid() = created_by);

-- DISCUSSIONS
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view discussions" ON discussions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = discussions.class_id AND ce.user_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = discussions.class_id AND c.tutor_id = auth.uid()
    )
  );

CREATE POLICY "Enrolled users can create discussions" ON discussions
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = discussions.class_id AND ce.user_id = auth.uid()
    )
  );

CREATE POLICY "Creators can update own discussions" ON discussions
  FOR UPDATE USING (auth.uid() = created_by);

-- DISCUSSION REPLIES
ALTER TABLE discussion_replies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enrolled users can view replies" ON discussion_replies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM discussions d
      JOIN class_enrollments ce ON d.class_id = ce.class_id
      WHERE d.id = discussion_replies.discussion_id AND ce.user_id = auth.uid()
    )
  );

CREATE POLICY "Enrolled users can create replies" ON discussion_replies
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM discussions d
      JOIN class_enrollments ce ON d.class_id = ce.class_id
      WHERE d.id = discussion_replies.discussion_id AND ce.user_id = auth.uid()
    )
  );

CREATE POLICY "Creators can update own replies" ON discussion_replies
  FOR UPDATE USING (auth.uid() = created_by);

-- ============================================
-- SELESAI! Database siap digunakan
-- ============================================
-- Langkah selanjutnya:
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Test registrasi user baru
-- 3. Test create class, quiz, assignment
-- 4. Verifikasi RLS policies bekerja dengan baik
-- ============================================
