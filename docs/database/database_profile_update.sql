-- ============================================
-- UPDATE DATABASE SCHEMA - PROFILE FIELDS
-- Menambah field untuk alamat dan info orang tua
-- ============================================

-- Tambah field baru ke tabel profiles
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS parent_name TEXT,
ADD COLUMN IF NOT EXISTS parent_phone TEXT;

-- Verifikasi struktur tabel
-- Jalankan query ini untuk cek field sudah ditambahkan:
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'profiles' 
-- ORDER BY ordinal_position;

-- ============================================
-- SELESAI
-- ============================================
-- Langkah selanjutnya:
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Verifikasi field sudah ada
-- 3. Lanjut ke implementasi backend
-- ============================================
