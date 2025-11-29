# Timezone Fixes Summary

## Perubahan yang Sudah Dilakukan

### 1. `lib/features/quiz/data/models/quiz_model.dart`

- Tambah import `package:flutter/foundation.dart`
- Ubah parsing `openAt` dan `closeAt` menggunakan helper function `_parseDateTime()`
- Tambah helper function `_parseDateTime()` yang:
  - Parse ISO8601 string
  - Cek apakah DateTime dalam UTC (`parsed.isUtc`)
  - Jika UTC, konversi ke local time dengan `.toLocal()`
  - Print debug info

### 2. `lib/features/quiz/utils/date_formatter.dart`

- Hapus semua `.toLocal()` karena DateTime sudah dalam local time setelah parsing
- Update comment untuk menjelaskan bahwa DateTime sudah dalam local time

### 3. `lib/features/quiz/domain/entities/quiz_entity.dart`

- Tambah import `package:flutter/foundation.dart`
- Hapus `.toLocal()` di getter `isOpen`, `isNotStarted`, `isEnded`
- Tambah debug logging di `isOpen` untuk print info saat quiz tidak bisa dibuka

### 4. `lib/features/quiz/presentation/providers/student_quiz_provider.dart`

- Hapus `.toLocal()` di `canStartQuiz()` dan `getCannotStartReason()`
- DateTime sudah dalam local time dari parsing

### 5. `lib/features/class/presentation/widgets/class_quiz_list.dart`

- Tambah import `package:flutter/foundation.dart`
- Tambah debug logging di `_buildStatusBadge()` untuk print:
  - Quiz title
  - isPublished status
  - openAt, closeAt, now
  - isNotStarted, isEnded, isOpen values

## Cara Menggunakan Debug Output

1. Jalankan app: `flutter run`
2. Buka class detail dan lihat quiz list
3. Lihat console output untuk debug info
4. Bandingkan dengan TIMEZONE_DEBUG_GUIDE.md

## Expected Output

Jika semuanya bekerja dengan benar:

- `openAt` dan `closeAt` harus dalam local time (WIB = UTC+7)
- `now` harus sesuai dengan waktu sistem
- `isOpen` harus `true` jika waktu sekarang antara openAt dan closeAt
- Status badge harus menampilkan "Aktif" (hijau)

## Jika Masih Bermasalah

1. Cek apakah `_parseDateTime()` dipanggil (lihat debug output "Parsed DateTime")
2. Cek apakah `parsed.isUtc` bernilai `true`
3. Cek apakah `.toLocal()` berhasil mengkonversi waktu
4. Verifikasi timezone sistem sudah benar (WIB = UTC+7)
