# Update: Profile Berbeda per Role

## ✅ Status: SELESAI

Profile sekarang menampilkan field yang berbeda berdasarkan role user.

---

## 📋 Perubahan yang Dilakukan

### 1. **Database Update** ✅

Tambah 2 field baru untuk Mentor:

```sql
ALTER TABLE profiles 
ADD COLUMN expertise_field TEXT,  -- Bidang Keilmuan
ADD COLUMN occupation TEXT;       -- Pekerjaan
```

**File**: `database_profile_mentor_fields.sql`

---

### 2. **Backend Update** ✅

#### Updated Files:
- ✅ `lib/features/profile/domain/entities/profile_entity.dart`
  - Tambah field: `expertiseField`, `occupation`

- ✅ `lib/features/profile/data/models/profile_model.dart`
  - Tambah field di fromJson/toJson
  - Tambah field di toEntity

---

### 3. **UI Update** ✅

#### Profile Page:
- ✅ Conditional rendering based on role
- ✅ Student: Tampilkan Alamat, Nama Orang Tua, Nomor HP Orang Tua
- ✅ Mentor/Admin: Tampilkan Bidang Keilmuan, Pekerjaan

**File**: `lib/presentation/pages/profile_page.dart`

#### Edit Profile Dialog:
- ✅ Conditional form based on role
- ✅ Student: Form Alamat, Nama Orang Tua, Nomor HP Orang Tua
- ✅ Mentor/Admin: Form Bidang Keilmuan, Pekerjaan

**File**: `lib/presentation/dialogs/edit_profile_dialog.dart`

---

## 📊 Field Mapping per Role

### **Student:**
| Label | Field Database | Type |
|-------|----------------|------|
| Nama Lengkap | `full_name` | TEXT |
| Email | `email` (auth.users) | TEXT |
| WhatsApp | `phone` | TEXT |
| Gender | `gender` | TEXT |
| Tanggal Lahir | `birth_date` | DATE |
| **Alamat** | `address` | TEXT |
| **Nama Orang Tua / Wali** | `parent_name` | TEXT |
| **Nomor HP Orang Tua / Wali** | `parent_phone` | TEXT |

### **Mentor / Admin:**
| Label | Field Database | Type |
|-------|----------------|------|
| Nama Lengkap | `full_name` | TEXT |
| Email | `email` (auth.users) | TEXT |
| WhatsApp | `phone` | TEXT |
| Gender | `gender` | TEXT |
| Tanggal Lahir | `birth_date` | DATE |
| **Bidang Keilmuan** | `expertise_field` | TEXT |
| **Pekerjaan** | `occupation` | TEXT |

---

## 🎯 Cara Kerja

### Profile Page:
```dart
// Conditional rendering
if (userRole == 'student') {
  // Tampilkan: Alamat, Nama Orang Tua, Nomor HP Orang Tua
} else if (userRole == 'mentor' || userRole == 'admin') {
  // Tampilkan: Bidang Keilmuan, Pekerjaan
}
```

### Edit Profile Dialog:
```dart
// Conditional form
if (userRole == 'student') {
  // Form: Alamat, Nama Orang Tua, Nomor HP Orang Tua
} else {
  // Form: Bidang Keilmuan, Pekerjaan
}

// Conditional save
if (userRole == 'student') {
  data['address'] = ...
  data['parent_name'] = ...
  data['parent_phone'] = ...
} else {
  data['expertise_field'] = ...
  data['occupation'] = ...
}
```

---

## 🧪 Testing Guide

### Test 1: Student Profile
```
1. Login sebagai Student
2. Buka Profile Page
3. ✅ Harus tampil: Alamat, Nama Orang Tua, Nomor HP Orang Tua
4. ✅ TIDAK tampil: Bidang Keilmuan, Pekerjaan
5. Klik Edit
6. ✅ Form harus ada: Alamat, Nama Orang Tua, Nomor HP Orang Tua
7. Isi data dan Save
8. ✅ Data harus tersimpan
```

### Test 2: Mentor Profile
```
1. Login sebagai Mentor
2. Buka Profile Page
3. ✅ Harus tampil: Bidang Keilmuan, Pekerjaan
4. ✅ TIDAK tampil: Alamat, Nama Orang Tua, Nomor HP Orang Tua
5. Klik Edit
6. ✅ Form harus ada: Bidang Keilmuan, Pekerjaan
7. Isi data (contoh: "Matematika", "Guru SD")
8. Save
9. ✅ Data harus tersimpan
```

### Test 3: Admin Profile
```
1. Login sebagai Admin
2. Buka Profile Page
3. ✅ Harus tampil: Bidang Keilmuan, Pekerjaan (sama seperti Mentor)
4. ✅ TIDAK tampil: Alamat, Nama Orang Tua, Nomor HP Orang Tua
```

---

## 📝 Contoh Data

### Student:
```json
{
  "full_name": "Zulfa",
  "phone": "081234567890",
  "gender": "Laki-laki",
  "birth_date": "2005-02-01",
  "address": "Jl. Merdeka No. 123, Jakarta",
  "parent_name": "Bapak Ahmad",
  "parent_phone": "081234567891"
}
```

### Mentor:
```json
{
  "full_name": "Pak Budi",
  "phone": "081234567892",
  "gender": "Laki-laki",
  "birth_date": "1985-05-15",
  "expertise_field": "Matematika dan Fisika",
  "occupation": "Guru SD"
}
```

---

## 🔍 Database Schema (Updated)

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone TEXT,
  gender TEXT,
  birth_date DATE,
  avatar_url TEXT,
  
  -- Student fields
  address TEXT,
  parent_name TEXT,
  parent_phone TEXT,
  
  -- Mentor fields
  expertise_field TEXT,
  occupation TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## ✅ Checklist Update

- [x] Database schema update (2 field baru)
- [x] Update ProfileEntity (domain)
- [x] Update ProfileModel (data)
- [x] Update Profile Page (conditional rendering)
- [x] Update Edit Profile Dialog (conditional form)
- [x] Testing (manual)
- [x] Documentation

---

## 📊 Summary

| Aspek | Student | Mentor/Admin |
|-------|---------|--------------|
| **Field Unik** | Alamat, Nama Orang Tua, Nomor HP Orang Tua | Bidang Keilmuan, Pekerjaan |
| **Field Sama** | Nama, Email, WhatsApp, Gender, Tanggal Lahir | Nama, Email, WhatsApp, Gender, Tanggal Lahir |
| **Total Field** | 8 field | 7 field |

---

**Status**: ✅ PRODUCTION READY  
**Tanggal**: 27 November 2025  
**Update**: Profile Role-Based Implementation
