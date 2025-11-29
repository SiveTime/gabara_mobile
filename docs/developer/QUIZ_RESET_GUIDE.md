# Panduan Reset Quiz Attempts

Dokumen ini menjelaskan cara menghapus data quiz attempts untuk testing dan development.

## 📋 Struktur Data Quiz

```
quizzes (Quiz/Kuis)
  ├── questions (Pertanyaan)
  │   └── options (Pilihan Jawaban)
  └── quiz_attempts (Percobaan Mengerjakan)
      └── quiz_answers (Jawaban Student)
```

## ⚠️ PENTING

- **Jangan hapus tabel `quizzes`, `questions`, atau `options`** - hanya hapus `quiz_attempts` dan `quiz_answers`
- Cascade delete sudah dikonfigurasi, jadi menghapus attempt akan otomatis menghapus answers-nya
- Selalu backup database sebelum menjalankan script DELETE

## 🔧 Cara Menggunakan

### 1. Akses Supabase SQL Editor

1. Buka [Supabase Dashboard](https://app.supabase.com)
2. Pilih project Anda
3. Klik **SQL Editor** di sidebar kiri
4. Klik **New Query**

### 2. Pilih Opsi Reset

#### **Opsi A: Reset Semua Attempts (PALING CEPAT)**

Gunakan jika ingin menghapus SEMUA attempt history dari semua student.

```sql
DELETE FROM quiz_answers;
DELETE FROM quiz_attempts;
```

⚠️ **Hati-hati!** Ini akan menghapus semua data attempt.

---

#### **Opsi B: Reset Quiz Tertentu (RECOMMENDED)**

Gunakan jika ingin reset attempts hanya untuk 1 quiz tertentu.

**Langkah 1:** Cari ID Quiz

```sql
SELECT id, title FROM quizzes LIMIT 10;
```

Catat ID quiz yang ingin di-reset (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

**Langkah 2:** Hapus attempts untuk quiz tersebut

```sql
DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE quiz_id = 'PASTE_QUIZ_ID_HERE'
);

DELETE FROM quiz_attempts
WHERE quiz_id = 'PASTE_QUIZ_ID_HERE';
```

Contoh:

```sql
DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE quiz_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
);

DELETE FROM quiz_attempts
WHERE quiz_id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
```

---

#### **Opsi C: Reset Attempts untuk User Tertentu**

Gunakan jika ingin reset attempts hanya untuk 1 student tertentu.

**Langkah 1:** Cari ID User

```sql
SELECT id, email FROM auth.users LIMIT 10;
```

Catat ID user yang ingin di-reset.

**Langkah 2:** Hapus attempts untuk user tersebut

```sql
DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE user_id = 'PASTE_USER_ID_HERE'
);

DELETE FROM quiz_attempts
WHERE user_id = 'PASTE_USER_ID_HERE';
```

---

#### **Opsi D: Reset Attempts untuk Quiz + User Tertentu (PALING SPESIFIK)**

Gunakan jika ingin reset attempts untuk kombinasi quiz dan student tertentu.

```sql
DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE quiz_id = 'PASTE_QUIZ_ID_HERE'
  AND user_id = 'PASTE_USER_ID_HERE'
);

DELETE FROM quiz_attempts
WHERE quiz_id = 'PASTE_QUIZ_ID_HERE'
AND user_id = 'PASTE_USER_ID_HERE';
```

---

#### **Opsi E: Reset Hanya Attempts yang In-Progress**

Gunakan jika ingin reset attempts yang belum selesai saja.

```sql
DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE quiz_id = 'PASTE_QUIZ_ID_HERE'
  AND status = 'in_progress'
);

DELETE FROM quiz_attempts
WHERE quiz_id = 'PASTE_QUIZ_ID_HERE'
AND status = 'in_progress';
```

---

## 🔍 Debugging Queries

### Lihat Semua Attempts

```sql
SELECT
  qa.id as attempt_id,
  qa.quiz_id,
  qa.user_id,
  qa.status,
  qa.started_at,
  qa.submitted_at,
  qa.score,
  qa.percentage,
  COUNT(qans.id) as answer_count
FROM quiz_attempts qa
LEFT JOIN quiz_answers qans ON qa.id = qans.attempt_id
GROUP BY qa.id, qa.quiz_id, qa.user_id, qa.status, qa.started_at, qa.submitted_at, qa.score, qa.percentage
ORDER BY qa.started_at DESC;
```

### Lihat Attempts untuk Quiz Tertentu

```sql
SELECT
  qa.id as attempt_id,
  qa.quiz_id,
  qa.user_id,
  qa.status,
  qa.started_at,
  qa.submitted_at,
  qa.score,
  qa.percentage,
  COUNT(qans.id) as answer_count
FROM quiz_attempts qa
LEFT JOIN quiz_answers qans ON qa.id = qans.attempt_id
WHERE qa.quiz_id = 'PASTE_QUIZ_ID_HERE'
GROUP BY qa.id, qa.quiz_id, qa.user_id, qa.status, qa.started_at, qa.submitted_at, qa.score, qa.percentage
ORDER BY qa.started_at DESC;
```

### Lihat Attempts untuk User Tertentu

```sql
SELECT
  qa.id as attempt_id,
  qa.quiz_id,
  qa.user_id,
  qa.status,
  qa.started_at,
  qa.submitted_at,
  qa.score,
  qa.percentage,
  COUNT(qans.id) as answer_count
FROM quiz_attempts qa
LEFT JOIN quiz_answers qans ON qa.id = qans.attempt_id
WHERE qa.user_id = 'PASTE_USER_ID_HERE'
GROUP BY qa.id, qa.quiz_id, qa.user_id, qa.status, qa.started_at, qa.submitted_at, qa.score, qa.percentage
ORDER BY qa.started_at DESC;
```

### Lihat Jumlah Attempts per Quiz

```sql
SELECT
  q.id,
  q.title,
  COUNT(qa.id) as total_attempts,
  COUNT(CASE WHEN qa.status = 'in_progress' THEN 1 END) as in_progress_count,
  COUNT(CASE WHEN qa.status = 'submitted' THEN 1 END) as submitted_count
FROM quizzes q
LEFT JOIN quiz_attempts qa ON q.id = qa.quiz_id
GROUP BY q.id, q.title
ORDER BY total_attempts DESC;
```

---

## 📝 Contoh Kasus

### Kasus 1: Student ingin mengulang quiz

**Situasi:** Student sudah mengerjakan quiz tapi ingin mencoba lagi.

**Solusi:**

1. Jalankan Opsi D (Quiz + User tertentu)
2. Student bisa langsung klik "Mulai Quiz" lagi di app

### Kasus 2: Testing - Reset semua attempts

**Situasi:** Selesai testing, ingin reset semua data untuk testing ulang.

**Solusi:**

1. Jalankan Opsi A (Hapus semua)
2. Semua student bisa mulai dari awal

### Kasus 3: Quiz ada bug, perlu di-reset

**Situasi:** Quiz ada error, sudah diperbaiki, ingin student mengulang.

**Solusi:**

1. Jalankan Opsi B (Reset quiz tertentu)
2. Semua student untuk quiz itu bisa mengulang

---

## ✅ Checklist Sebelum Menjalankan

- [ ] Sudah backup database
- [ ] Sudah cek ID yang benar (copy-paste dari query SELECT)
- [ ] Sudah baca script dengan teliti
- [ ] Sudah uncomment script yang ingin dijalankan
- [ ] Sudah ganti placeholder (PASTE_QUIZ_ID_HERE, dll)

---

## 🆘 Jika Ada Masalah

### Error: "permission denied"

Pastikan Anda login dengan akun yang punya akses admin/owner di Supabase.

### Error: "foreign key constraint"

Jangan khawatir, cascade delete sudah dikonfigurasi. Coba jalankan ulang.

### Ingin undo/restore?

Jika tidak ada backup, sayangnya data sudah hilang. Untuk development, gunakan database testing terpisah.

---

## 📚 Referensi

- [Supabase SQL Editor](https://supabase.com/docs/guides/database/sql-editor)
- [PostgreSQL DELETE](https://www.postgresql.org/docs/current/sql-delete.html)
- [Cascade Delete](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK)
