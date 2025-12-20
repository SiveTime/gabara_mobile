-- Script untuk menghapus semua quiz attempts dan answers
-- Gunakan script ini untuk reset data quiz student saat testing
-- ⚠️ HATI-HATI: Script ini akan menghapus SEMUA attempt history!

-- Opsi 1: Hapus semua quiz attempts dan answers (SEMUA STUDENT)
-- Uncomment jika ingin menghapus semua data
/*
DELETE FROM quiz_answers;
DELETE FROM quiz_attempts;
*/

-- Opsi 2: Hapus attempts untuk quiz tertentu (RECOMMENDED)
-- Ganti 'QUIZ_ID_HERE' dengan ID quiz yang ingin di-reset
-- Contoh: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
/*
DELETE FROM quiz_answers 
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts 
  WHERE quiz_id = 'QUIZ_ID_HERE'
);

DELETE FROM quiz_attempts 
WHERE quiz_id = 'QUIZ_ID_HERE';
*/

-- Opsi 3: Hapus attempts untuk user tertentu (RECOMMENDED)
-- Ganti 'USER_ID_HERE' dengan ID user/student yang ingin di-reset
-- Contoh: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
/*
DELETE FROM quiz_answers 
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts 
  WHERE user_id = 'USER_ID_HERE'
);

DELETE FROM quiz_attempts 
WHERE user_id = 'USER_ID_HERE';
*/

-- Opsi 4: Hapus attempts untuk quiz tertentu dan user tertentu (MOST SPECIFIC)
-- Ganti 'QUIZ_ID_HERE' dan 'USER_ID_HERE' dengan ID yang sesuai
/*
DELETE FROM quiz_answers 
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts 
  WHERE quiz_id = 'QUIZ_ID_HERE' 
  AND user_id = 'USER_ID_HERE'
);

DELETE FROM quiz_attempts 
WHERE quiz_id = 'QUIZ_ID_HERE' 
AND user_id = 'USER_ID_HERE';
*/

-- Opsi 5: Hapus attempts yang in_progress saja (untuk quiz tertentu)
-- Ganti 'QUIZ_ID_HERE' dengan ID quiz
/*
DELETE FROM quiz_answers 
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts 
  WHERE quiz_id = 'QUIZ_ID_HERE'
  AND status = 'in_progress'
);

DELETE FROM quiz_attempts 
WHERE quiz_id = 'QUIZ_ID_HERE'
AND status = 'in_progress';
*/

-- ============================================
-- CONTOH PENGGUNAAN PRAKTIS
-- ============================================

-- Contoh 1: Reset semua attempts untuk user dengan email tertentu
-- Uncomment dan jalankan setelah mengganti email
/*
DELETE FROM quiz_answers 
WHERE attempt_id IN (
  SELECT qa.id FROM quiz_attempts qa
  JOIN auth.users au ON qa.user_id = au.id
  WHERE au.email = 'student@example.com'
);

DELETE FROM quiz_attempts 
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email = 'student@example.com'
);
*/

-- Contoh 2: Lihat semua quiz attempts untuk debugging
-- Uncomment untuk melihat data
/*
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
*/

-- Contoh 3: Lihat attempts untuk quiz tertentu
-- Uncomment dan ganti QUIZ_ID_HERE
/*
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
WHERE qa.quiz_id = 'QUIZ_ID_HERE'
GROUP BY qa.id, qa.quiz_id, qa.user_id, qa.status, qa.started_at, qa.submitted_at, qa.score, qa.percentage
ORDER BY qa.started_at DESC;
*/

-- Contoh 4: Lihat attempts untuk user tertentu
-- Uncomment dan ganti USER_ID_HERE
/*
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
WHERE qa.user_id = 'USER_ID_HERE'
GROUP BY qa.id, qa.quiz_id, qa.user_id, qa.status, qa.started_at, qa.submitted_at, qa.score, qa.percentage
ORDER BY qa.started_at DESC;
*/
