# Refactor CRUD Kelas - Mentor Dashboard

**Tanggal:** 28 November 2025  
**Status:** ✅ Selesai

---

## Masalah Sebelumnya

1. Setelah mentor membuat kelas, notifikasi "kelas berhasil dibuat" muncul, tapi halaman Kelasku tidak me-load data baru
2. `ClassCard` masih menggunakan data dummy untuk participants
3. Tidak ada fitur Edit dan Delete kelas
4. Kode kelas (`class_code`) tidak di-generate otomatis

---

## Perubahan yang Dilakukan

### 1. `lib/features/class/data/services/class_service.dart`

| Method                 | Perubahan                                                         |
| ---------------------- | ----------------------------------------------------------------- |
| `getEnrolledClasses()` | Baru - Query kelas yang di-enroll student via `class_enrollments` |
| `getMyClasses()`       | Perbaikan query relasi `profiles`                                 |
| `createClass()`        | Menambahkan auto-generate `class_code` (6 karakter)               |
| `updateClass()`        | Baru - Update kelas berdasarkan ID                                |
| `deleteClass()`        | Baru - Hapus kelas berdasarkan ID                                 |
| `joinClass()`          | Implementasi real (sebelumnya dummy)                              |

### 2. `lib/features/class/presentation/providers/class_provider.dart`

| Method          | Perubahan                                            |
| --------------- | ---------------------------------------------------- |
| `createClass()` | Sekarang memanggil `fetchMyClasses()` setelah sukses |
| `updateClass()` | Baru                                                 |
| `deleteClass()` | Baru                                                 |

### 3. `lib/features/class/domain/entities/class_entity.dart`

Menambahkan field:

- `subjectId` (int?) - untuk edit kelas
- `createdAt` (DateTime?) - untuk sorting/display

### 4. `lib/features/class/data/models/class_model.dart`

- Update `fromJson()` untuk handle field baru
- Perbaikan null safety pada parsing

### 5. `lib/features/class/presentation/widgets/class_card.dart`

| Fitur            | Perubahan                                     |
| ---------------- | --------------------------------------------- |
| Data dummy       | Dihapus                                       |
| Kode kelas       | Ditampilkan dengan tombol copy (untuk mentor) |
| Menu Edit/Delete | Ditambahkan (untuk mentor)                    |
| Avatar tutor     | Hanya tampil untuk student                    |
| Badge            | Menampilkan nama mata pelajaran               |

### 6. `lib/features/class/presentation/pages/class_page.dart`

| Fitur               | Perubahan                                |
| ------------------- | ---------------------------------------- |
| Empty state         | Berbeda untuk mentor dan student         |
| Header              | Menampilkan jumlah kelas                 |
| Delete confirmation | Dialog konfirmasi sebelum hapus          |
| ClassCard           | Passing `isMentor`, `onEdit`, `onDelete` |

### 7. `lib/features/class/presentation/pages/create_class_page.dart`

- UI lebih informatif dengan info auto-generate kode
- Perbaikan async/mounted handling

### 8. `lib/features/class/presentation/pages/edit_class_page.dart` (BARU)

Halaman baru untuk edit kelas dengan fitur:

- Menampilkan kode kelas (read-only)
- Form edit: nama, mata pelajaran, deskripsi, kuota

### 9. `lib/main.dart`

Menambahkan route:

```dart
'/edit-class' -> EditClassPage(classEntity: args)
```

---

## Alur CRUD Kelas (Mentor)

```
┌─────────────────────────────────────────────────────────┐
│                    MENTOR DASHBOARD                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [+ Buat Kelas]                                         │
│       │                                                  │
│       ▼                                                  │
│  ┌─────────────────┐                                    │
│  │ CreateClassPage │ → Auto-generate class_code         │
│  └────────┬────────┘                                    │
│           │ success                                      │
│           ▼                                              │
│  ┌─────────────────┐                                    │
│  │   ClassPage     │ ← fetchMyClasses()                 │
│  │   (Kelasku)     │                                    │
│  └────────┬────────┘                                    │
│           │                                              │
│           ▼                                              │
│  ┌─────────────────┐                                    │
│  │   ClassCard     │                                    │
│  │  ┌───────────┐  │                                    │
│  │  │ [⋮] Menu  │  │                                    │
│  │  │ - Edit    │──┼──→ EditClassPage                   │
│  │  │ - Delete  │──┼──→ Confirmation Dialog             │
│  │  └───────────┘  │                                    │
│  │  [🔑 ABC123]   │ ← Copy to clipboard                 │
│  └─────────────────┘                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Database Schema Reference

```sql
-- Tabel Classes
CREATE TABLE classes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  tutor_id UUID REFERENCES auth.users(id),
  subject_id INTEGER REFERENCES subjects(id),
  class_code TEXT UNIQUE,  -- Auto-generated 6 chars
  max_students INTEGER DEFAULT 50,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Testing Checklist

- [x] Mentor buat kelas → kode otomatis di-generate
- [x] Setelah create, list kelas ter-refresh
- [x] Kode kelas bisa di-copy
- [x] Edit kelas berfungsi
- [x] Delete kelas dengan konfirmasi
- [x] Empty state berbeda untuk mentor/student
- [ ] Student join kelas dengan kode (perlu test)

---

## Next Steps

1. Implementasi fitur di dalam kelas (Kursus, Peserta, Diskusi, Nilai)
2. Notifikasi real-time saat ada siswa baru join
3. Export daftar siswa

---

## Update: Refactor TutorAppDrawer

**Tanggal:** 28 November 2025

### Perubahan pada `lib/presentation/layout/tutor_app_drawer.dart`

| Sebelum                       | Sesudah                                                       |
| ----------------------------- | ------------------------------------------------------------- |
| Menggunakan placeholder pages | Menggunakan halaman real (`MentorDashboardPage`, `ClassPage`) |
| Navigasi langsung tanpa cek   | Navigasi dengan cek `activeRoute` untuk hindari reload        |
| Tidak ada badge role          | Menambahkan badge "MENTOR" di header                          |
| Tidak ada menu Tugas          | Menambahkan menu Tugas (coming soon)                          |
| Style tidak konsisten         | Konsisten dengan `StudentAppDrawer`                           |

### Menu Drawer Mentor

| Menu      | Route Key   | Halaman               | Status         |
| --------- | ----------- | --------------------- | -------------- |
| Dashboard | `dashboard` | `MentorDashboardPage` | ✅ Aktif       |
| Kelasku   | `class`     | `ClassPage`           | ✅ Aktif       |
| Kuis      | `quiz`      | -                     | 🔜 Coming Soon |
| Tugas     | `tugas`     | -                     | 🔜 Coming Soon |

---

## Update: Penyesuaian UI ClassCard sesuai Mockup

**Tanggal:** 28 November 2025

### Perubahan pada `ClassCard`

| Elemen              | Sebelum             | Sesudah                           |
| ------------------- | ------------------- | --------------------------------- |
| Badge               | Nama mata pelajaran | Tahun ajaran "2025/2026"          |
| Avatar Tutor        | Di pojok kanan atas | Overlap di border image/content   |
| Participant Avatars | Tidak ada           | Ditambahkan (GF, DM, FN, +N)      |
| Footer              | Kode kelas + kuota  | Participant avatars + Mentor name |
| Menu Mentor         | Icon di pojok       | Menu dengan opsi Copy Kode        |

### Perubahan pada `ClassPage`

| Elemen        | Sebelum              | Sesudah                               |
| ------------- | -------------------- | ------------------------------------- |
| Tombol Enroll | Di AppBar            | Di dalam body, sebelah header "Kelas" |
| Header        | Terpisah dari list   | Bagian dari ListView                  |
| Layout        | Column dengan header | Single ListView dengan header item    |

### Tampilan Mockup yang Diimplementasi

```
┌─────────────────────────────────────┐
│ ☰  [GARASI BELAJAR LOGO]        ⋮  │
├─────────────────────────────────────┤
│                                     │
│ Kelas                    [+ Enroll] │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [Peta Indonesia Merah]          │ │
│ │ ┌──────────┐              ┌──┐  │ │
│ │ │2025/2026 │              │AP│  │ │
│ │ └──────────┘              └──┘  │ │
│ ├─────────────────────────────────┤ │
│ │ Bahasa Indonesia                │ │
│ │                                 │ │
│ │ Mata pelajaran Bahasa Indonesia │ │
│ │ ini dirancang untuk...          │ │
│ │                                 │ │
│ │ (GF)(DM)(FN)(+1)  Mentor: Aditya│ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

---

## Fix: Database Query Error - Foreign Key Relationship

**Tanggal:** 28 November 2025

### Error

```
PostgrestException: Could not find a relationship between 'classes' and 'profiles'
in the schema cache. Searched for a foreign key relationship using the hint
'classes_tutor_id_fkey' but no matches were found.
```

### Penyebab

- `classes.tutor_id` mereferensi ke `auth.users(id)`, bukan langsung ke `profiles(id)`
- Meskipun `profiles.id = auth.users.id`, Supabase tidak bisa resolve relasi otomatis

### Solusi

Refactor query di `class_service.dart` dengan pendekatan 2-step:

1. Query classes dengan subjects (tanpa join profiles)
2. Query profiles terpisah berdasarkan tutor_id
3. Map hasil ke ClassModel

```dart
// Helper: Map classes with tutor names from profiles
Future<List<ClassModel>> _mapClassesWithTutorNames(List<dynamic> classes) async {
  // Get unique tutor IDs
  final tutorIds = classes.map((c) => c['tutor_id']).toSet().toList();

  // Fetch profiles for tutors
  final profiles = await supabaseClient
      .from('profiles')
      .select('id, full_name')
      .inFilter('id', tutorIds);

  // Map tutor names
  Map<String, String> tutorNames = {};
  for (var profile in profiles) {
    tutorNames[profile['id']] = profile['full_name'];
  }

  // Return ClassModel with tutor names
  return classes.map((json) {
    final tutorName = tutorNames[json['tutor_id']] ?? 'Mentor';
    return ClassModel.fromJson({
      ...json,
      'tutor': {'full_name': tutorName},
    });
  }).toList();
}
```

### Status

✅ Fixed - Data kelas sekarang bisa di-load dengan benar

---

## Fix: Tombol Enroll Hilang & Dashboard Student Statis

**Tanggal:** 28 November 2025

### Masalah yang Ditemukan

1. **Tombol Enroll hilang** - Tombol hanya muncul di ListView header, tidak muncul saat empty state
2. **Dashboard student statis** - Count "Kelas Diikuti" hardcoded "0"
3. **Route `/class` tidak ada** - Tidak bisa navigasi dari dashboard ke halaman kelas

### Perbaikan

#### 1. `class_page.dart` - Empty State dengan Tombol Enroll

```dart
Widget _buildEmptyState(bool isMentor) {
  return Column(
    children: [
      // Header dengan tombol Enroll untuk student
      if (!isMentor)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kelas', ...),
            ElevatedButton.icon(
              onPressed: () => _showEnrollDialog(context),
              label: Text("Enroll"),
              ...
            ),
          ],
        ),
      // Empty state content
      Image.asset('assets/kosong.png', ...),
      ...
    ],
  );
}
```

#### 2. `student_dashboard_page.dart` - Data Dinamis

- Import `ClassProvider`
- Fetch enrolled classes di `initState()`
- Tampilkan count dari `classProvider.classes.length`
- Tambah `RefreshIndicator` untuk pull-to-refresh
- Card "Kelas Diikuti" bisa di-tap untuk navigasi ke `/class`

#### 3. `main.dart` - Route Baru

```dart
routes: {
  ...
  '/class': (context) => const ClassPage(),
  ...
},
```

### Status

✅ Fixed - Tombol Enroll muncul di empty state dan dashboard student menampilkan data dinamis

---

## Fix: Delete Kelas Tidak Berfungsi

**Tanggal:** 28 November 2025

### Penyebab

RLS Policy di Supabase hanya mengizinkan **admin** untuk DELETE:

```sql
CREATE POLICY "Admins can delete classes" ON classes
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );
```

### Solusi: Soft Delete

Implementasi soft delete dengan set `is_active = false`:

```dart
Future<void> deleteClass(String classId) async {
  final user = supabaseClient.auth.currentUser;
  if (user == null) throw Exception('User tidak login');

  // Soft delete: set is_active = false
  final response = await supabaseClient
      .from('classes')
      .update({'is_active': false})
      .eq('id', classId)
      .eq('tutor_id', user.id)
      .select();

  if ((response as List).isEmpty) {
    throw Exception('Gagal menghapus kelas');
  }
}
```

### Perubahan Tambahan

- `getMyClasses()` sekarang filter `.eq('is_active', true)`

### (Opsional) Update RLS Policy untuk Hard Delete

Jika ingin mentor bisa hard delete, jalankan SQL ini di Supabase:

```sql
-- Drop existing policy
DROP POLICY IF EXISTS "Admins can delete classes" ON classes;

-- Create new policy: Tutors can delete own classes, Admins can delete any
CREATE POLICY "Tutors and Admins can delete classes" ON classes
  FOR DELETE USING (
    auth.uid() = tutor_id
    OR EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );
```

### Status

✅ Fixed - Delete kelas sekarang menggunakan soft delete

---

## Update: Refactor Mentor Dashboard - Data Dinamis

**Tanggal:** 28 November 2025

### Perubahan pada `mentor_dashboard_page.dart`

| Elemen          | Sebelum         | Sesudah                         |
| --------------- | --------------- | ------------------------------- |
| Kelas Dibuat    | Hardcoded "0"   | Data dari `ClassProvider`       |
| Summary Card    | Tidak clickable | Clickable, navigasi ke `/class` |
| Pengumuman      | Section statis  | Diganti dengan "Kelas Terbaru"  |
| Kelas Terbaru   | Tidak ada       | Menampilkan 3 kelas terbaru     |
| Pull-to-refresh | Tidak ada       | Ditambahkan                     |

### Fitur Baru

1. **Kelas Terbaru** - Menampilkan 3 kelas terbaru dengan:

   - Nama kelas
   - Mata pelajaran
   - Kode kelas
   - Tap untuk ke detail kelas

2. **Summary Card Clickable** - Card "Kelas Dibuat" bisa di-tap untuk navigasi ke halaman kelas

3. **Pull-to-refresh** - Dashboard bisa di-refresh untuk update data

### Layout Dashboard Mentor

```
┌─────────────────────────────────────┐
│ ☰  [GARASI BELAJAR LOGO]        ⋮  │
├─────────────────────────────────────┤
│ Selamat datang, [Nama]              │
│ Mentor                              │
├─────────────────────────────────────┤
│ ┌───────────┐  ┌───────────┐        │
│ │ 📚        │  │ ❓        │        │
│ │ Kelas     │  │ Kuis      │        │
│ │ Dibuat    │  │ Dibuat    │        │
│ │ [N]       │  │ 0         │        │
│ └───────────┘  └───────────┘        │
│ ┌───────────┐  ┌───────────┐        │
│ │ 📝        │  │ 👥        │        │
│ │ Tugas     │  │ Total     │        │
│ │ Dibuat    │  │ Siswa     │        │
│ │ 0         │  │ 0         │        │
│ └───────────┘  └───────────┘        │
├─────────────────────────────────────┤
│ Kelas Terbaru                       │
│ ┌─────────────────────────────────┐ │
│ │ 📚 Matematika Dasar    [ABC123] │ │
│ │    Matematika                   │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 📚 Bahasa Indonesia    [XYZ789] │ │
│ │    Bahasa Indonesia             │ │
│ └─────────────────────────────────┘ │
│         [Lihat Semua Kelas]         │
├─────────────────────────────────────┤
│ Tugas yang Perlu Dinilai            │
│ Tidak ada tugas yang perlu dinilai  │
└─────────────────────────────────────┘
                              [+ Buat Kelas]
```

### Status

✅ Selesai - Dashboard mentor sekarang menampilkan data dinamis
