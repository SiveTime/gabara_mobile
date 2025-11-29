# Fitur Student Quiz - Specification

**Status:** 🔜 In Development  
**Tanggal:** 29 November 2025  
**Role:** Student

---

## 📋 Overview

Fitur ini memungkinkan student untuk:

1. Melihat list kuis yang tersedia di kelas mereka
2. Mengerjakan kuis dengan timer
3. Melihat hasil dan feedback setelah submit
4. Melihat history attempt kuis

---

## 🎯 Requirements

### Functional Requirements

#### FR1: View Available Quizzes

- Student dapat melihat list kuis di halaman kelas (Tab Kursus)
- Menampilkan:
  - Nama kuis
  - Status (Belum dibuka, Sedang berlangsung, Sudah ditutup)
  - Tanggal buka/tutup
  - Durasi
  - Jumlah attempt yang tersisa
  - Nilai tertinggi (jika sudah pernah dikerjakan)

#### FR2: Start Quiz

- Student dapat memulai kuis dengan tombol "Mulai Kuis"
- Validasi:
  - Kuis harus sudah dibuka (openAt <= now)
  - Kuis harus belum ditutup (closeAt > now)
  - Masih ada attempt tersisa (attemptsAllowed > 0)
- Tampilkan confirmation dialog sebelum mulai

#### FR3: Take Quiz

- Halaman quiz menampilkan:
  - Nama kuis
  - Timer countdown (real-time)
  - Progress bar (soal X dari Y)
  - Soal dengan tipe:
    - Multiple choice (4 pilihan)
    - True/False (2 pilihan)
  - Tombol Previous/Next untuk navigasi
  - Tombol Submit Quiz
- Student dapat:
  - Melihat semua soal sebelum submit
  - Mengubah jawaban
  - Melihat soal mana yang sudah dijawab (visual indicator)

#### FR4: Submit Quiz

- Validasi sebelum submit:
  - Konfirmasi apakah yakin submit
  - Peringatan jika ada soal yang belum dijawab
- Setelah submit:
  - Simpan jawaban ke database
  - Hitung skor otomatis
  - Redirect ke halaman hasil

#### FR5: View Quiz Results

- Tampilkan:
  - Skor akhir (X/Y)
  - Persentase
  - Grade (A, B, C, D, E)
  - Waktu pengerjaan
  - Tanggal pengerjaan
  - Feedback per soal (jawaban benar/salah)
- Tombol:
  - "Lihat Detail" → Lihat jawaban per soal
  - "Kembali ke Kelas" → Kembali ke class detail

#### FR6: View Quiz History

- Di halaman kelas, student dapat melihat:
  - List attempt kuis
  - Skor setiap attempt
  - Tanggal attempt
  - Status (Selesai, Belum Selesai)

---

## 🏗️ Architecture

### Data Models

#### QuizAttempt (Entity)

```dart
class QuizAttemptEntity {
  final String id;
  final String quizId;
  final String studentId;
  final List<StudentAnswer> answers;
  final int score;
  final int totalQuestions;
  final int durationSeconds;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final String status; // 'in_progress', 'submitted'
}
```

#### StudentAnswer (Entity)

```dart
class StudentAnswerEntity {
  final String id;
  final String attemptId;
  final String questionId;
  final String selectedOptionId;
  final bool isCorrect;
}
```

### Database Tables

#### quiz_attempts

```sql
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY,
  quiz_id UUID REFERENCES quizzes(id),
  student_id UUID REFERENCES auth.users(id),
  score INTEGER,
  total_questions INTEGER,
  duration_seconds INTEGER,
  started_at TIMESTAMP,
  submitted_at TIMESTAMP,
  status TEXT, -- 'in_progress', 'submitted'
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### student_answers

```sql
CREATE TABLE student_answers (
  id UUID PRIMARY KEY,
  attempt_id UUID REFERENCES quiz_attempts(id),
  question_id UUID REFERENCES questions(id),
  selected_option_id UUID REFERENCES options(id),
  is_correct BOOLEAN,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 📱 UI/UX Flow

### Screen 1: Quiz List (dalam Tab Kursus)

```
┌─────────────────────────────────┐
│ Kuis                            │
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Kuis 1: Pengenalan Bahasa   │ │
│ │ Status: Sedang berlangsung  │ │
│ │ Buka: 25 Nov - 30 Nov       │ │
│ │ Durasi: 30 menit            │ │
│ │ Attempt: 1/2 tersisa        │ │
│ │ Nilai tertinggi: 85         │ │
│ │                             │ │
│ │ [Mulai Kuis] [Lihat Hasil]  │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Kuis 2: Teks Eksposisi      │ │
│ │ Status: Belum dibuka        │ │
│ │ Buka: 1 Des 2025            │ │
│ │ Durasi: 45 menit            │ │
│ │                             │ │
│ │ [Mulai Kuis] (disabled)     │ │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

### Screen 2: Quiz Taking

```
┌─────────────────────────────────┐
│ ← Kuis 1: Pengenalan Bahasa     │
├─────────────────────────────────┤
│ Soal 1 dari 10        ⏱ 25:30   │
│ ████████░░░░░░░░░░░░░░░░░░░░░░ │
├─────────────────────────────────┤
│                                 │
│ Apa pengertian bahasa?          │
│                                 │
│ ○ A. Alat komunikasi            │
│ ○ B. Sistem tanda              │
│ ○ C. Kode linguistik           │
│ ○ D. Semua benar               │
│                                 │
├─────────────────────────────────┤
│ [← Sebelumnya] [Selanjutnya →]  │
│                                 │
│ [Submit Kuis]                   │
└─────────────────────────────────┘
```

### Screen 3: Quiz Results

```
┌─────────────────────────────────┐
│ Hasil Kuis                      │
├─────────────────────────────────┤
│                                 │
│ Kuis 1: Pengenalan Bahasa       │
│                                 │
│ Skor: 85/100                    │
│ Persentase: 85%                 │
│ Grade: A                        │
│                                 │
│ Waktu: 15 menit 30 detik        │
│ Tanggal: 25 Nov 2025, 10:30     │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Soal 1: ✓ Benar             │ │
│ │ Soal 2: ✗ Salah             │ │
│ │ Soal 3: ✓ Benar             │ │
│ │ ...                         │ │
│ └─────────────────────────────┘ │
│                                 │
│ [Lihat Detail] [Kembali]        │
│                                 │
└─────────────────────────────────┘
```

---

## 🔄 State Management

### QuizAttemptProvider

```dart
class QuizAttemptProvider extends ChangeNotifier {
  // State
  QuizAttemptEntity? _currentAttempt;
  List<QuizAttemptEntity> _attemptHistory;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  QuizAttemptEntity? get currentAttempt => _currentAttempt;
  List<QuizAttemptEntity> get attemptHistory => _attemptHistory;
  bool get isLoading => _isLoading;

  // Methods
  Future<void> startQuiz(String quizId);
  Future<void> saveAnswer(String questionId, String optionId);
  Future<void> submitQuiz();
  Future<void> fetchAttemptHistory(String quizId);
  Future<void> fetchAttemptDetail(String attemptId);
}
```

---

## 📁 File Structure

```
lib/features/quiz/
├── data/
│   ├── models/
│   │   ├── quiz_attempt_model.dart (NEW)
│   │   ├── student_answer_model.dart (NEW)
│   │   └── quiz_model.dart (existing)
│   ├── services/
│   │   ├── quiz_service.dart (UPDATE)
│   │   └── quiz_attempt_service.dart (NEW)
│   └── repositories/
│       └── quiz_attempt_repository.dart (NEW)
│
├── domain/
│   ├── entities/
│   │   ├── quiz_attempt_entity.dart (NEW)
│   │   ├── student_answer_entity.dart (NEW)
│   │   └── quiz_entity.dart (existing)
│   └── usecases/
│       ├── start_quiz_usecase.dart (NEW)
│       ├── submit_quiz_usecase.dart (NEW)
│       └── fetch_quiz_attempts_usecase.dart (NEW)
│
└── presentation/
    ├── pages/
    │   ├── quiz_list_page.dart (existing - mentor)
    │   ├── student_quiz_list_page.dart (NEW)
    │   ├── quiz_taking_page.dart (NEW)
    │   └── quiz_result_page.dart (NEW)
    │
    ├── widgets/
    │   ├── quiz_card.dart (existing - mentor)
    │   ├── student_quiz_card.dart (NEW)
    │   ├── quiz_question_widget.dart (NEW)
    │   ├── quiz_timer_widget.dart (NEW)
    │   └── quiz_result_widget.dart (NEW)
    │
    ├── providers/
    │   ├── quiz_provider.dart (existing - mentor)
    │   └── quiz_attempt_provider.dart (NEW)
    │
    └── utils/
        └── quiz_utils.dart (NEW - helper functions)
```

---

## 🔌 Integration Points

### 1. Class Detail Page (Tab Kursus)

- Tambah section "Kuis" di tab Kursus
- Tampilkan list kuis dengan StudentQuizCard
- Klik card → Navigate ke quiz taking page

### 2. Quiz Service (Update)

- Tambah method `fetchQuizzesByClass(classId)` untuk student
- Filter: hanya kuis yang sudah published
- Include questions dan options

### 3. Authentication

- Gunakan `AuthProvider` untuk get current user ID
- Validasi student sudah enroll di kelas

---

## ⏱️ Timeline

### Phase 1: Backend Setup (1-2 hari)

- [ ] Create database tables
- [ ] Create models & entities
- [ ] Create services & repositories

### Phase 2: Core Features (2-3 hari)

- [ ] Start quiz
- [ ] Take quiz (UI + logic)
- [ ] Submit quiz
- [ ] Calculate score

### Phase 3: Results & History (1-2 hari)

- [ ] View results
- [ ] View attempt history
- [ ] View attempt detail

### Phase 4: Integration & Polish (1 hari)

- [ ] Integrate dengan class detail page
- [ ] Testing & bug fixes
- [ ] UI polish

---

## 🧪 Testing Checklist

- [ ] Student dapat melihat list kuis di kelas
- [ ] Student dapat memulai kuis
- [ ] Timer berjalan dengan benar
- [ ] Student dapat navigasi soal
- [ ] Student dapat mengubah jawaban
- [ ] Student dapat submit kuis
- [ ] Skor dihitung dengan benar
- [ ] Hasil ditampilkan dengan benar
- [ ] History attempt tersimpan
- [ ] Attempt limit berfungsi

---

## 📝 Notes

- Timer harus real-time (tidak bisa di-manipulasi)
- Jika time's up, auto-submit
- Jika student close app, attempt bisa di-resume
- Skor dihitung otomatis berdasarkan jawaban benar
- Grade: A (90-100), B (80-89), C (70-79), D (60-69), E (<60)
