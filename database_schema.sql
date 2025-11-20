-- ANALISIS DAN PERBAIKAN DATABASE SCHEMA
-- Masalah yang ditemukan dan perbaikan:
-- 1. announcements.class_id harus nullable untuk pengumuman global, tapi REFERENCES tidak allow NULL. Diubah ke NULLABLE.
-- 2. quiz_attempts kekurangan kolom ended_at untuk tracking waktu selesai.
-- 3. assignment_submissions kekurangan kolom graded_at dan feedback untuk penilaian.
-- 4. discussions dan discussion_replies kekurangan parent_reply_id untuk nested replies.
-- 5. meetings kekurangan duration_minutes dan status.
-- 6. classes.tutor_id sebaiknya NOT NULL karena setiap kelas punya tutor.
-- 7. Tambah indexes pada foreign keys untuk performa.
-- 8. RLS policies perlu diperbaiki: profiles sebaiknya hanya user sendiri yang bisa update, classes mungkin perlu policy lebih ketat.
-- 9. Tambah kolom created_by di announcements dan discussions untuk tracking pembuat.
-- 10. Tambah kolom is_corrected di assignment_submissions.
-- 11. Tambah kolom total_questions di quizzes untuk kalkulasi skor.
-- 12. Tambah kolom is_global di announcements untuk clarity (meskipun class_id nullable).
-- 13. Tambah policy untuk announcements: bisa dibaca semua user, tapi hanya mentor/admin yang bisa insert.
-- 14. Tambah policy untuk discussions dan replies.
-- 15. Tambah policy untuk quizzes, assignments, dll. sesuai kebutuhan.

-- 1. BERSIH-BERSIH (Hapus tabel lama jika ada)
DROP TABLE IF EXISTS
  discussion_replies, discussions, announcements, meetings,
  assignment_submissions, assignments, quiz_attempts, options,
  questions, quizzes, class_enrollments, class_subjects, subjects, classes,
  user_roles, roles, profiles
CASCADE;

-- 2. USER MANAGEMENT (Sesuai Readme: Pakai Tabel Roles Terpisah)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  gender TEXT,
  birth_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL, -- 'student', 'mentor', 'admin'
  description TEXT
);

CREATE TABLE user_roles (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
  UNIQUE(user_id, role_id)
);

-- 3. AKADEMIK
CREATE TABLE subjects (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  grade_level TEXT -- SD/SMP/SMA
);

CREATE TABLE classes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  tutor_id UUID REFERENCES auth.users(id) NOT NULL, -- Set NOT NULL
  max_students INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE class_subjects (
  id SERIAL PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id INTEGER REFERENCES subjects(id) ON DELETE CASCADE
);

CREATE TABLE class_enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(class_id, user_id)
);

-- 4. KUIS & TUGAS
CREATE TABLE quizzes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  total_questions INTEGER DEFAULT 0, -- Tambah untuk kalkulasi skor
  duration_minutes INTEGER DEFAULT 60,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  points INTEGER DEFAULT 10
);

CREATE TABLE options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT false
);

CREATE TABLE quiz_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  score DECIMAL(5,2),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE -- Tambah
);

CREATE TABLE assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  deadline TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE assignment_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  file_url TEXT,
  score DECIMAL(5,2),
  feedback TEXT, -- Tambah
  graded_at TIMESTAMP WITH TIME ZONE, -- Tambah
  is_corrected BOOLEAN DEFAULT false, -- Tambah
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. KOMUNIKASI
CREATE TABLE meetings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  meeting_date TIMESTAMP WITH TIME ZONE,
  duration_minutes INTEGER DEFAULT 60, -- Tambah
  meeting_link TEXT,
  status TEXT DEFAULT 'scheduled', -- Tambah: 'scheduled', 'ongoing', 'completed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE NULL, -- Nullable untuk global
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Tambah
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_global BOOLEAN DEFAULT false, -- Tambah untuk clarity
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE discussion_replies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discussion_id UUID REFERENCES discussions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE NULL, -- Tambah untuk nested
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. DATA SEEDING (Wajib untuk Role)
INSERT INTO roles (name, description) VALUES
('admin', 'Administrator'),
('mentor', 'Guru/Pengajar'),
('student', 'Siswa');

INSERT INTO subjects (name, description, grade_level) VALUES
('Matematika', 'Pelajaran matematika dasar', 'SD'),
('Bahasa Indonesia', 'Bahasa dan sastra Indonesia', 'SD'),
('IPA', 'Ilmu Pengetahuan Alam', 'SD');

-- 7. TRIGGER OTOMATIS (Penting agar Register Flutter jalan)
-- Update trigger ini agar support struktur tabel roles yang baru
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  target_role_id INTEGER;
  role_name TEXT;
BEGIN
  -- 1. Ambil role dari metadata, default 'student'
  role_name := COALESCE(new.raw_user_meta_data ->> 'role', 'student');

  -- 2. Insert ke profiles
  INSERT INTO public.profiles (id, full_name, phone, gender, birth_date)
  VALUES (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'phone',
    new.raw_user_meta_data ->> 'gender',
    (new.raw_user_meta_data ->> 'birth_date')::date
  );

  -- 3. Cari ID untuk role tersebut
  SELECT id INTO target_role_id FROM public.roles WHERE name = role_name;

  -- 4. Masukkan ke user_roles
  IF target_role_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role_id) VALUES (new.id, target_role_id);
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 8. INDEXES UNTUK PERFORMA
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_class_enrollments_class_id ON class_enrollments(class_id);
CREATE INDEX idx_class_enrollments_user_id ON class_enrollments(user_id);
CREATE INDEX idx_quiz_attempts_quiz_id ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);
CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_assignment_submissions_user_id ON assignment_submissions(user_id);
CREATE INDEX idx_discussion_replies_discussion_id ON discussion_replies(discussion_id);
CREATE INDEX idx_discussion_replies_parent_reply_id ON discussion_replies(parent_reply_id);

-- 9. AKTIFKAN RLS (Agar data aman) - DITINGKATKAN
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public classes view" ON classes FOR SELECT USING (true); -- Semua bisa lihat daftar kelas
CREATE POLICY "Mentors can create classes" ON classes FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role_id = (SELECT id FROM roles WHERE name = 'mentor'))
);
CREATE POLICY "Tutors can update own classes" ON classes FOR UPDATE USING (auth.uid() = tutor_id);

ALTER TABLE class_enrollments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own enrollments" ON class_enrollments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can enroll themselves" ON class_enrollments FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled users can view quizzes" ON quizzes FOR SELECT USING (
  EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = quizzes.class_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM classes WHERE id = quizzes.class_id AND tutor_id = auth.uid())
);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own attempts" ON quiz_attempts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own attempts" ON quiz_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled users can view assignments" ON assignments FOR SELECT USING (
  EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = assignments.class_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM classes WHERE id = assignments.class_id AND tutor_id = auth.uid())
);

ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own submissions" ON assignment_submissions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can submit own work" ON assignment_submissions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Tutors can grade submissions" ON assignment_submissions FOR UPDATE USING (
  EXISTS (SELECT 1 FROM assignments a JOIN classes c ON a.class_id = c.id WHERE a.id = assignment_id AND c.tutor_id = auth.uid())
);

ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "All users can view announcements" ON announcements FOR SELECT USING (true);
CREATE POLICY "Mentors and admins can create announcements" ON announcements FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM user_roles ur JOIN roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name IN ('mentor', 'admin'))
);

ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled users can view discussions" ON discussions FOR SELECT USING (
  EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = discussions.class_id AND user_id = auth.uid())
);
CREATE POLICY "Enrolled users can create discussions" ON discussions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = discussions.class_id AND user_id = auth.uid())
);

ALTER TABLE discussion_replies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled users can view replies" ON discussion_replies FOR SELECT USING (
  EXISTS (SELECT 1 FROM discussions d JOIN class_enrollments ce ON d.class_id = ce.class_id WHERE d.id = discussion_id AND ce.user_id = auth.uid())
);
CREATE POLICY "Enrolled users can create replies" ON discussion_replies FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM discussions d JOIN class_enrollments ce ON d.class_id = ce.class_id WHERE d.id = discussion_id AND ce.user_id = auth.uid())
);

ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enrolled users can view meetings" ON meetings FOR SELECT USING (
  EXISTS (SELECT 1 FROM class_enrollments WHERE class_id = meetings.class_id AND user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM classes WHERE id = meetings.class_id AND tutor_id = auth.uid())
);
CREATE POLICY "Tutors can create meetings" ON meetings FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM classes WHERE id = meetings.class_id AND tutor_id = auth.uid())
);
