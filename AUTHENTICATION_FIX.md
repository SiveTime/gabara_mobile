# Perbaikan Sistem Autentikasi

## Perubahan yang Dilakukan

### 1. Form Registrasi
- **DIHAPUS**: Opsi pemilihan role dari form registrasi
- **DEFAULT**: Semua user yang registrasi otomatis menjadi **student**
- User tidak bisa memilih role sendiri saat registrasi
- Role hanya bisa diubah oleh admin melalui database

### 2. Dashboard Berbasis Role
Dibuat 3 dashboard terpisah sesuai role:

#### Student Dashboard (`/student-dashboard`)
- Menampilkan kelas yang diikuti
- Tugas yang sedang berjalan
- Pengumuman
- Deadline tugas/quiz

#### Mentor Dashboard (`/mentor-dashboard`)
- Menampilkan kelas yang dibuat
- Kuis yang dibuat
- Tugas yang dibuat
- Total siswa
- Tugas yang perlu dinilai
- Tombol floating action untuk membuat kelas baru

#### Admin Dashboard (`/admin-dashboard`)
- Statistik sistem (total user, mentor, siswa, kelas)
- Manajemen user
- Manajemen kelas
- Manajemen mata pelajaran
- Aktivitas terbaru sistem

### 3. Routing Otomatis
Setelah login atau registrasi, user akan diarahkan ke dashboard sesuai role:
- `admin` → `/admin-dashboard`
- `mentor` → `/mentor-dashboard`
- `student` → `/student-dashboard`

### 4. File yang Diubah

#### Modified:
- `lib/features/auth/presentation/pages/register_page.dart`
  - Hapus dropdown role
  - Update parameter register (hapus role)
  
- `lib/features/auth/presentation/pages/login_page.dart`
  - Tambah logic routing berdasarkan role
  
- `lib/features/auth/presentation/providers/auth_provider.dart`
  - Update method register dengan default role 'student'
  
- `lib/main.dart`
  - Tambah routing untuk 3 dashboard baru

#### Created:
- `lib/presentation/pages/student_dashboard_page.dart`
- `lib/presentation/pages/mentor_dashboard_page.dart`
- `lib/presentation/pages/admin_dashboard_page.dart`

### 5. Cara Mengubah Role User

Karena role tidak bisa dipilih saat registrasi, untuk membuat mentor atau admin:

**Opsi 1: Melalui Database (Supabase)**
```sql
-- Update role di tabel user_roles
UPDATE user_roles 
SET role_id = (SELECT id FROM roles WHERE name = 'mentor')
WHERE user_id = 'USER_UUID_HERE';
```

**Opsi 2: Nanti buat fitur Admin Panel**
- Admin bisa mengubah role user melalui dashboard admin
- Fitur ini akan dikembangkan di fase berikutnya

### 6. Testing

Untuk test aplikasi:

1. **Registrasi User Baru**
   - Buka aplikasi → Registrasi
   - Isi form (tanpa pilih role)
   - User otomatis jadi student
   - Redirect ke Student Dashboard

2. **Login sebagai Student**
   - Login dengan akun student
   - Akan masuk ke Student Dashboard

3. **Login sebagai Mentor** (setelah role diubah di database)
   - Login dengan akun yang sudah diubah role-nya
   - Akan masuk ke Mentor Dashboard

4. **Login sebagai Admin** (setelah role diubah di database)
   - Login dengan akun admin
   - Akan masuk ke Admin Dashboard

### 7. Next Steps

- [ ] Implementasi fitur manajemen user di Admin Dashboard
- [ ] Tambah validasi role di backend (RLS policies)
- [ ] Implementasi fitur-fitur spesifik untuk setiap dashboard
- [ ] Tambah unit tests untuk authentication flow
- [ ] Implementasi forgot password
