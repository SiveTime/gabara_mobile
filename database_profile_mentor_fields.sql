-- ============================================
-- UPDATE DATABASE SCHEMA - MENTOR FIELDS
-- Menambah field untuk bidang keilmuan dan pekerjaan
-- ============================================

-- Tambah field baru untuk mentor
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS expertise_field TEXT,  -- Bidang Keilmuan
ADD COLUMN IF NOT EXISTS occupation TEXT;       -- Pekerjaan

-- Verifikasi struktur tabel
-- Jalankan query ini untuk cek field sudah ditambahkan:
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'profiles' 
-- ORDER BY ordinal_position;

-- ============================================
-- CATATAN:
-- - expertise_field: Untuk mentor (Bidang Keilmuan)
-- - occupation: Untuk mentor (Pekerjaan)
-- - parent_name: Untuk student (Nama Orang Tua)
-- - parent_phone: Untuk student (Nomor HP Orang Tua)
-- - address: Untuk student (Alamat)
-- ============================================

-- ============================================
-- SELESAI
-- ============================================
-- Langkah selanjutnya:
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Verifikasi field sudah ada
-- 3. Lanjut ke update backend
-- ============================================
