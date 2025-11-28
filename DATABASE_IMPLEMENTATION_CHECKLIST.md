# Checklist Implementasi Database Gabara LMS V2

## 📋 Langkah-langkah Implementasi

### ✅ FASE 1: Persiapan (5 menit)

- [ ] **Backup Database Lama** (jika ada data penting)
  ```sql
  -- Export data dari tabel penting:
  -- - profiles
  -- - classes
  -- - class_enrollments
  ```

- [ ] **Buka Supabase Dashboard**
  - Login ke https://supabase.com
  - Pilih project Gabara LMS
  - Buka SQL Editor

- [ ] **Siapkan File Schema**
  - Buka file `database_schema_v2.sql`
  - Copy semua isinya

---

### ✅ FASE 2: Eksekusi Schema (10 menit)

- [ ] **Jalankan Script SQL**
  1. Paste script ke Supabase SQL Editor
  2. Klik "Run" atau tekan Ctrl+Enter
  3. Tunggu sampai selesai (±30 detik)
  4. Cek output: harus "Success"

- [ ] **Verifikasi Tabel Terbuat**
  - Buka "Table Editor" di Supabase
  - Cek semua 18 tabel ada:
    - [ ] profiles
    - [ ] roles
    - [ ] user_roles
    - [ ] subjects
    - [ ] classes
    - [ ] class_enrollments
    - [ ] quizzes
    - [ ] questions
    - [ ] options
    - [ ] quiz_attempts
    - [ ] quiz_answers
    - [ ] assignments
    - [ ] assignment_submissions
    - [ ] meetings
    - [ ] meeting_attendances
    - [ ] announcements
    - [ ] discussions
    - [ ] discussion_replies

- [ ] **Verifikasi Data Seeding**
  ```sql
  -- Cek roles
  SELECT * FROM roles;
  -- Harus ada: admin, mentor, student
  
  -- Cek subjects
  SELECT * FROM subjects;
  -- Harus ada: Matematika, Bahasa Indonesia, IPA, IPS, Bahasa Inggris
  ```

---

### ✅ FASE 3: Testing Trigger (5 menit)

- [ ] **Test Registrasi User Baru**
  1. Buka aplikasi Flutter
  2. Registrasi user baru dengan data:
     - Nama: Test Student
     - Email: test@student.com
     - Password: test123
     - Phone: 081234567890
     - Gender: Laki-laki
     - Birth Date: 2010-01-01
  3. Submit registrasi

- [ ] **Verifikasi Auto-Create Profile**
  ```sql
  -- Cek profile terbuat otomatis
  SELECT 
    p.id, 
    p.full_name, 
    p.phone,
    r.name as role
  FROM profiles p
  JOIN user_roles ur ON ur.user_id = p.id
  JOIN roles r ON r.id = ur.role_id
  WHERE p.full_name = 'Test Student';
  
  -- Harus muncul 1 row dengan role = 'student'
  ```

- [ ] **Test Login**
  - Login dengan email: test@student.com
  - Password: test123
  - Harus berhasil masuk ke Student Dashboard

---

### ✅ FASE 4: Testing RLS Policies (10 menit)

#### Test 1: Profile Access
- [ ] **Login sebagai Student**
- [ ] **Coba Edit Profile Sendiri** → Harus BERHASIL
- [ ] **Coba Lihat Profile Orang Lain** → Harus BERHASIL (read only)
- [ ] **Coba Edit Profile Orang Lain** → Harus GAGAL

#### Test 2: Class Access
- [ ] **Buat User Mentor** (via SQL)
  ```sql
  -- Ubah role user pertama jadi mentor
  UPDATE user_roles 
  SET role_id = (SELECT id FROM roles WHERE name = 'mentor')
  WHERE user_id = (SELECT id FROM auth.users ORDER BY created_at ASC LIMIT 1);
  ```

- [ ] **Login sebagai Mentor**
- [ ] **Buat Kelas Baru** → Harus BERHASIL
  - Nama: Kelas Matematika SD 1
  - Subject: Matematika
  - Max Students: 30

- [ ] **Login sebagai Student**
- [ ] **Lihat Daftar Kelas** → Harus BERHASIL (bisa lihat semua kelas)
- [ ] **Join Kelas** → Harus BERHASIL
- [ ] **Coba Edit Kelas** → Harus GAGAL (bukan tutor)

#### Test 3: Quiz Access
- [ ] **Login sebagai Mentor**
- [ ] **Buat Quiz di Kelas** → Harus BERHASIL
  - Title: Quiz Matematika 1
  - Duration: 60 menit
  - Passing Score: 70

- [ ] **Login sebagai Student (belum join kelas)**
- [ ] **Coba Lihat Quiz** → Harus GAGAL (belum enrolled)

- [ ] **Join Kelas Dulu**
- [ ] **Lihat Quiz Lagi** → Harus BERHASIL

#### Test 4: Assignment Access
- [ ] **Login sebagai Mentor**
- [ ] **Buat Assignment** → Harus BERHASIL
  - Title: Tugas Matematika 1
  - Deadline: 1 minggu dari sekarang

- [ ] **Login sebagai Student (enrolled)**
- [ ] **Lihat Assignment** → Harus BERHASIL
- [ ] **Submit Assignment** → Harus BERHASIL
- [ ] **Coba Edit Submission Orang Lain** → Harus GAGAL

---

### ✅ FASE 5: Testing Indexes (5 menit)

- [ ] **Test Query Performance**
  ```sql
  -- Query 1: Get classes by tutor (harus cepat)
  EXPLAIN ANALYZE
  SELECT * FROM classes WHERE tutor_id = 'USER_UUID_MENTOR';
  
  -- Query 2: Get enrollments by user (harus cepat)
  EXPLAIN ANALYZE
  SELECT * FROM class_enrollments WHERE user_id = 'USER_UUID_STUDENT';
  
  -- Query 3: Get quiz attempts by user (harus cepat)
  EXPLAIN ANALYZE
  SELECT * FROM quiz_attempts WHERE user_id = 'USER_UUID_STUDENT';
  ```

- [ ] **Verifikasi Indexes Aktif**
  ```sql
  -- Lihat semua indexes
  SELECT 
    tablename, 
    indexname, 
    indexdef 
  FROM pg_indexes 
  WHERE schemaname = 'public'
  ORDER BY tablename, indexname;
  ```

---

### ✅ FASE 6: Data Migration (Jika Ada Data Lama)

- [ ] **Migrate Profiles**
  ```sql
  -- Jika ada data lama di tabel profiles_old
  INSERT INTO profiles (id, full_name, phone, gender, birth_date)
  SELECT id, full_name, phone, gender, birth_date
  FROM profiles_old;
  ```

- [ ] **Migrate Classes**
  ```sql
  -- Jika ada data lama di tabel classes_old
  INSERT INTO classes (id, name, description, tutor_id, subject_id, max_students)
  SELECT id, name, description, tutor_id, subject_id, max_students
  FROM classes_old;
  ```

- [ ] **Migrate Enrollments**
  ```sql
  -- Jika ada data lama
  INSERT INTO class_enrollments (class_id, user_id, joined_at)
  SELECT class_id, user_id, joined_at
  FROM class_enrollments_old;
  ```

---

### ✅ FASE 7: Update Flutter App (15 menit)

- [ ] **Update Model Classes**
  - Sesuaikan field di model dengan schema baru
  - Tambah field baru yang ada di schema

- [ ] **Update Service Classes**
  - Sesuaikan query dengan tabel baru
  - Tambah service untuk tabel baru (meeting_attendances, quiz_answers)

- [ ] **Test API Calls**
  - Test create class
  - Test join class
  - Test create quiz
  - Test submit assignment

---

### ✅ FASE 8: Final Verification (5 menit)

- [ ] **Cek Semua Fitur Berjalan**
  - [ ] Registrasi user baru
  - [ ] Login (student, mentor, admin)
  - [ ] Create class (mentor)
  - [ ] Join class (student)
  - [ ] Create quiz (mentor)
  - [ ] Take quiz (student)
  - [ ] Create assignment (mentor)
  - [ ] Submit assignment (student)
  - [ ] Create meeting (mentor)
  - [ ] Create announcement (mentor/admin)
  - [ ] Create discussion (student)

- [ ] **Cek RLS Bekerja**
  - Student tidak bisa edit kelas orang lain
  - Student tidak bisa lihat quiz kelas yang belum di-join
  - Student tidak bisa edit submission orang lain

- [ ] **Cek Performance**
  - Query cepat (< 100ms)
  - Tidak ada N+1 query problem

---

## 🎯 Troubleshooting

### Problem 1: Trigger tidak jalan
**Gejala**: Profile tidak terbuat otomatis saat registrasi

**Solusi**:
```sql
-- Cek trigger ada
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- Jika tidak ada, buat ulang
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### Problem 2: RLS terlalu ketat
**Gejala**: User tidak bisa akses data yang seharusnya bisa

**Solusi**:
```sql
-- Disable RLS sementara untuk testing
ALTER TABLE nama_tabel DISABLE ROW LEVEL SECURITY;

-- Setelah fix policy, enable lagi
ALTER TABLE nama_tabel ENABLE ROW LEVEL SECURITY;
```

### Problem 3: Foreign Key Error
**Gejala**: Error saat insert data karena FK tidak valid

**Solusi**:
```sql
-- Cek FK constraint
SELECT 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name = 'nama_tabel';
```

### Problem 4: Query Lambat
**Gejala**: Query memakan waktu > 1 detik

**Solusi**:
```sql
-- Analyze query
EXPLAIN ANALYZE SELECT * FROM tabel WHERE kondisi;

-- Jika tidak pakai index, buat index baru
CREATE INDEX idx_nama ON tabel(kolom);
```

---

## 📊 Metrics Success

### ✅ Database Setup Berhasil Jika:
- [ ] Semua 18 tabel terbuat
- [ ] Data seeding berhasil (3 roles, 5 subjects)
- [ ] Trigger auto-create profile berjalan
- [ ] RLS policies aktif dan bekerja
- [ ] Indexes terpasang semua
- [ ] Query performance < 100ms
- [ ] Registrasi user baru berhasil
- [ ] Login berhasil untuk semua role
- [ ] CRUD operations berjalan normal

---

## 🚀 Next Steps Setelah Database Ready

1. **Update Flutter Models** - Sesuaikan dengan schema baru
2. **Implement API Services** - Lengkapi semua CRUD operations
3. **Add Unit Tests** - Test semua repository & service
4. **Add Integration Tests** - Test flow lengkap
5. **Deploy to Production** - Setelah semua test pass

---

**Estimasi Total Waktu**: 60 menit  
**Tingkat Kesulitan**: Medium  
**Prerequisites**: Akses Supabase, Flutter project ready

---

**Dibuat**: 27 November 2025  
**Status**: Ready to Execute
