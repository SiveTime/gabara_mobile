# Langkah-Langkah Debugging Timezone Issue

## Step 1: Jalankan App dengan Debug Output

```bash
flutter run -v
```

## Step 2: Navigasi ke Class Detail

1. Buka app
2. Masuk ke dashboard
3. Buka salah satu kelas
4. Klik tab "Kursus"

## Step 3: Lihat Debug Output di Console

Cari output berikut:

### A. Parsing DateTime (dari quiz_model.dart)

```
Parsed DateTime: 2025-11-29T10:15:00+00:00 -> 2025-11-29 10:15:00.000Z (isUtc: true)
Converted to local: 2025-11-29 17:15:00.000
```

**Apa yang dicek:**

- Apakah `isUtc: true`? (Jika false, berarti data sudah dalam local time)
- Apakah waktu berubah setelah `.toLocal()`? (Harus berubah +7 jam untuk WIB)

### B. Status Check (dari class_quiz_list.dart)

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

**Apa yang dicek:**

- Apakah `openAt` dan `closeAt` dalam local time? (Harus jam 17:15 dan 23:50, bukan 10:15 dan 00:50)
- Apakah `now` sesuai dengan waktu sistem?
- Apakah `isOpen: true`? (Jika false, lihat step 4)

### C. Quiz Entity Debug (dari quiz_entity.dart)

Jika status bukan "Aktif", akan muncul:

```
Quiz "Quiz Geografi" - isOpen: published=true, afterOpen=false (now=..., openAt=...), beforeClose=true (closeAt=...)
```

**Apa yang dicek:**

- Apakah `afterOpen: false`? (Berarti `now` lebih kecil dari `openAt`)
- Apakah `beforeClose: false`? (Berarti `now` lebih besar dari `closeAt`)

## Step 4: Analisis Hasil

### Skenario 1: openAt masih dalam UTC

**Gejala:**

- `openAt: 2025-11-29 10:15:00.000` (bukan 17:15)
- `isNotStarted: true` padahal seharusnya false

**Solusi:**

- Cek apakah `_parseDateTime()` dipanggil
- Cek apakah `parsed.isUtc` bernilai `true`
- Pastikan `.toLocal()` dipanggil

### Skenario 2: Konversi ganda

**Gejala:**

- `openAt: 2025-11-30 00:15:00.000` (melompat 7 jam lebih)
- Status badge menampilkan "Belum Dibuka" padahal seharusnya "Aktif"

**Solusi:**

- Cek apakah ada `.toLocal()` yang dipanggil dua kali
- Hapus `.toLocal()` di formatter dan entity

### Skenario 3: Perbandingan waktu salah

**Gejala:**

- `openAt` dan `closeAt` sudah benar
- `now` sudah benar
- Tapi `isOpen: false`

**Solusi:**

- Cek logika perbandingan di `isOpen` getter
- Pastikan menggunakan `isAfter()`, `isBefore()`, `isAtSameMomentAs()`

## Step 5: Verifikasi Perbaikan

Setelah perbaikan, cek:

1. Status badge menampilkan "Aktif" (hijau)
2. Debug output menunjukkan `isOpen: true`
3. Waktu yang ditampilkan sesuai dengan yang diatur

## Troubleshooting

### Debug output tidak muncul

- Pastikan menggunakan `flutter run -v`
- Cek apakah ada filter di console
- Cari keyword "Parsed DateTime" atau "Quiz.\*status check"

### Waktu masih salah

- Cek timezone sistem: `date` (Linux/Mac) atau `Get-Date` (Windows)
- Pastikan timezone sudah diatur ke WIB (UTC+7)
- Restart app setelah mengubah timezone

### Masih ada error

- Cek apakah semua file sudah di-save
- Jalankan `flutter clean` dan `flutter pub get`
- Rebuild app: `flutter run`
