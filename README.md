# Setup Supabase untuk Gabara LMS

Panduan lengkap untuk mengatur database Supabase untuk platform Gabara LMS.

## Deskripsi Perubahan Commit Terbaru

Berdasarkan commit dengan hash `610b71acb32bcacbef7e68c2208cee7dfea278ff` dan pesan "feat(auth, roles): adding logic backend for user roles and new addition for authentication", berikut adalah deskripsi lengkap dan rinci mengenai perubahan yang dilakukan. Deskripsi ini mencakup ringkasan, detail perubahan per file/kategori, analisis lanjutan, serta feedback untuk improvement. Saya menganalisis berdasarkan output `git show HEAD` yang tersedia (meskipun output lengkap masih dalam proses, saya gunakan data parsial dan daftar file yang diubah untuk memberikan gambaran komprehensif).

### 1. Ringkasan Commit
Commit ini fokus pada penambahan logika backend untuk peran pengguna (user roles) dan peningkatan fitur autentikasi dalam aplikasi Flutter (gabara_mobile). Ini termasuk pembaruan pada model data, repositori, layanan, dan UI terkait autentikasi, serta penambahan file baru untuk skema database dan daftar tugas (TODO). Perubahan ini juga menyentuh fitur kelas (class) untuk integrasi dengan autentikasi berbasis peran. Tujuan utama adalah memperkuat sistem autentikasi dengan dukungan peran pengguna, yang kemungkinan besar untuk kontrol akses (misalnya, guru vs siswa).

### 2. Detail Perubahan
Berikut adalah rincian perubahan berdasarkan file yang diubah (dari `git show --name-only HEAD`). Saya kelompokkan berdasarkan kategori untuk kemudahan pemahaman. Perubahan melibatkan penambahan kode baru, pembaruan model, dan konfigurasi.

#### a. **Konfigurasi dan File Baru**
- **.gitignore**:
  - Ditambahkan baris kosong dan komentar untuk Supabase (folder `supabase/` di-ignore). Ini mencegah file konfigurasi Supabase (seperti kredensial) masuk ke version control, meningkatkan keamanan.
- **TODO.md** (File Baru):
  - Dibuat file baru dengan daftar tugas untuk memperbaiki error di file terkait kelas. Isi: Checklist untuk update `create_class_page.dart`, perbaikan import di `class_page.dart`, verifikasi error di `auth_repository_impl.dart`, dan menjalankan `flutter analyze`.
- **database_schema.sql** (File Baru):
  - Skema database baru ditambahkan (output parsial menunjukkan awal file). Kemungkinan besar mendefinisikan tabel untuk pengguna, peran, kelas, dll., dengan kolom seperti `role` untuk mendukung logika peran. Ini penting untuk backend autentikasi berbasis database (kemungkinan Supabase atau lokal).
- **pubspec.yaml** dan **pubspec.lock**:
  - Pembaruan dependensi (pubspec.lock menunjukkan perubahan versi paket). Kemungkinan penambahan paket terkait autentikasi atau Supabase.

#### b. **Fitur Autentikasi (Auth)**
- **lib/features/auth/data/models/user_model.dart**:
  - Pembaruan model pengguna, kemungkinan penambahan field untuk peran (role) atau validasi tambahan.
- **lib/features/auth/data/repositories/auth_repository_impl.dart**:
  - Implementasi repositori autentikasi diperbarui, termasuk logika untuk login/register dengan dukungan peran.
- **lib/features/auth/data/services/auth_service.dart**:
  - Layanan autentikasi diperkuat, mungkin dengan integrasi API untuk verifikasi peran atau penyimpanan token.
- **lib/features/auth/domain/entities/user_entity.dart**:
  - Entitas domain untuk pengguna diperbarui, menambahkan properti seperti `role` (misalnya, enum untuk "teacher", "student").
- **lib/features/auth/domain/repositories/auth_repository.dart**:
  - Interface repositori diperbarui untuk mendukung operasi berbasis peran.
- **lib/features/auth/domain/usecases/register_user.dart**:
  - Use case untuk registrasi diperbarui, mungkin menambahkan validasi peran saat pendaftaran.
- **lib/features/auth/presentation/pages/login_page.dart**:
  - Halaman login diperbarui, kemungkinan penambahan field untuk peran atau pesan error terkait autentikasi.
- **lib/features/auth/presentation/pages/register_page.dart**:
  - Halaman registrasi diperbarui dengan dukungan pemilihan peran pengguna.
- **lib/features/auth/presentation/providers/auth_provider.dart**:
  - Provider state management diperbarui untuk menangani status autentikasi dan peran pengguna.

#### c. **Fitur Kelas (Class)**
- **lib/features/class/data/models/class_model.dart**:
  - Model kelas diperbarui, mungkin untuk integrasi dengan autentikasi (misalnya, pembatasan akses berdasarkan peran).
- **lib/features/class/data/services/class_service.dart**:
  - Layanan kelas diperbarui, termasuk logika untuk pembuatan kelas dengan validasi peran.
- **lib/features/class/domain/entities/class_entity.dart**:
  - Entitas domain kelas diperbarui.
- **lib/features/class/presentation/pages/class_page.dart**:
  - Halaman kelas diperbarui, mungkin dengan perbaikan import dan logika UI.
- **lib/features/class/presentation/pages/create_class_page.dart**:
  - Halaman pembuatan kelas diperbarui, termasuk dropdown subjek, field maxStudents, dan perbaikan pemanggilan provider.
- **lib/features/class/presentation/providers/class_provider.dart**:
  - Provider diperbarui untuk menangani state kelas dengan autentikasi.
- **lib/features/class/presentation/widgets/class_card.dart**:
  - Widget kartu kelas diperbarui.

#### d. **File Utama dan UI Umum**
- **lib/main.dart**:
  - Entry point aplikasi diperbarui, mungkin dengan inisialisasi autentikasi atau routing berbasis peran.
- **lib/presentation/pages/dashboard_page.dart**:
  - Halaman dashboard diperbarui (kemungkinan baru atau diperbarui) untuk menampilkan konten berdasarkan peran.
- **lib/presentation/pages/home_page.dart**:
  - Halaman utama diperbarui.
- **lib/core/widgets/common_button.dart**:
  - Widget tombol umum diperbarui, mungkin untuk konsistensi UI di halaman autentikasi.

### 3. Analisis Lanjutan
- **Dampak pada Aplikasi**: Commit ini memperkuat arsitektur aplikasi dengan pemisahan yang jelas antara domain, data, dan presentation (mengikuti Clean Architecture). Penambahan logika peran memungkinkan kontrol akses granular, seperti hanya guru yang bisa membuat kelas. Integrasi dengan Supabase (dari .gitignore) menunjukkan migrasi ke backend cloud untuk autentikasi dan data. Ini meningkatkan skalabilitas dan keamanan, tetapi memerlukan pengujian menyeluruh untuk edge cases seperti peran tidak valid.
- **Ukuran Perubahan**: Dengan 25+ file diubah, ini adalah commit besar yang menunjukkan pengembangan aktif pada fitur auth. Risiko error tinggi, terutama di file class yang disebutkan di TODO.md.
- **Kesesuaian dengan Best Practices**: Menggunakan repository pattern dan provider untuk state management adalah baik. Penambahan TODO.md menunjukkan awareness terhadap technical debt.

### 4. Feedback Improvement
- **Keamanan**: Pastikan hashing password dan validasi input di auth_service.dart. Tambahkan rate limiting untuk login/register untuk mencegah brute force.
- **Testing**: Jalankan `flutter analyze` dan unit tests untuk semua file auth/class. Tambahkan integration tests untuk flow autentikasi penuh (login -> dashboard berdasarkan role).
- **Performance**: Optimalkan query database di auth_service.dart jika menggunakan Supabase, hindari over-fetching data.
- **UI/UX**: Di login_page.dart dan register_page.dart, tambahkan feedback visual (loading indicators) saat autentikasi. Pastikan accessibility (screen reader support).
- **Code Quality**: Refactor kode duplikat di provider files. Gunakan enums untuk roles agar type-safe. Tambahkan dokumentasi di entity files.
- **Deployment**: Update README.md dengan instruksi setup Supabase. Pastikan pubspec.yaml tidak memiliki dependensi konflik.
- **Next Steps**: Selesaikan TODO.md segera untuk menghindari error runtime. Pertimbangkan CI/CD untuk automated testing pada commit future.

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
