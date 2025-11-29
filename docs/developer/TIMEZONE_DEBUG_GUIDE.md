# Timezone Debug Guide

## Masalah

Quiz menampilkan status "Belum Dibuka" padahal waktu buka sudah terlewati.

## Root Cause Analysis

Kemungkinan penyebab:

1. DateTime dari Supabase dalam UTC, tapi tidak dikonversi ke local time
2. Konversi ganda `.toLocal()` menyebabkan waktu melompat
3. Parsing ISO8601 string tidak konsisten

## Debug Output yang Perlu Dicek

Jalankan app dan lihat console output untuk:

### 1. Parsing DateTime (dari `quiz_model.dart`)

```
Parsed DateTime: 2025-11-29T10:15:00+00:00 -> 2025-11-29 10:15:00.000Z (isUtc: true)
Converted to local: 2025-11-29 17:15:00.000 (WIB = UTC+7)
```

### 2. Status Check (dari `class_quiz_list.dart`)

```
Quiz "Quiz Geografi" status check:
  isPublished: true
  openAt: 2025-11-29 17:15:00.000
  closeAt: 2025-11-29 23:50:00.000
  now: 2025-11-29 17:20:00.000
  isNotStarted: false
  isEnded: false
  isOpen: true
```

### 3. Quiz Entity Debug (dari `quiz_entity.dart`)

Jika status bukan "Aktif", akan print:

```
Quiz "Quiz Geografi" - isOpen: published=true, afterOpen=false (now=..., openAt=...), beforeClose=true (closeAt=...)
```

## Checklist

- [ ] Lihat debug output saat app berjalan
- [ ] Verifikasi `openAt` dan `closeAt` sudah dalam local time (bukan UTC)
- [ ] Verifikasi `now` sesuai dengan waktu sistem
- [ ] Jika `isNotStarted: true` padahal seharusnya false, berarti `openAt` masih dalam UTC
- [ ] Jika `isOpen: false` padahal seharusnya true, cek perbandingan waktu

## Solusi Berdasarkan Debug Output

### Jika openAt masih UTC:

- Pastikan `_parseDateTime()` di `quiz_model.dart` dipanggil
- Verifikasi `parsed.isUtc` bernilai `true`
- Pastikan `.toLocal()` dipanggil

### Jika masih ada konversi ganda:

- Hapus semua `.toLocal()` di formatter dan entity
- Hanya panggil `.toLocal()` sekali saat parsing

### Jika perbandingan waktu salah:

- Verifikasi `DateTime.now()` mengembalikan local time
- Pastikan tidak ada timezone offset yang terlewat
