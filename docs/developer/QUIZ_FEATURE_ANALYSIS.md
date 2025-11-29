# 🔬 ANALISIS MENDALAM QUIZ FEATURE - IDENTIFIKASI POTENSI BUG

**Tanggal Analisis:** 29 November 2025  
**Scope:** Seluruh Quiz Feature (`lib/features/quiz/`)  
**Tujuan:** Identifikasi masalah tersembunyi dan sumber bug potensial

---

## 📊 STRUKTUR FEATURE OVERVIEW

```
Quiz Feature (Clean Architecture)
├── Domain Layer (Business Logic)
│   ├── Entities (Quiz, Question, Option, Attempt)
│   ├── Repositories (Interface)
│   ├── UseCases (GetQuizzes, CreateQuiz, SubmitAnswer)
│   └── Validators (QuizValidator)
├── Data Layer (Data Management)
│   ├── Models (Serialization)
│   ├── Services (Supabase Integration)
│   └── Repositories (Implementation)
└── Presentation Layer (UI)
    ├── Pages (Screens)
    ├── Providers (State Management)
    └── Widgets (UI Components)
```

---

## 🐛 POTENSI BUG & MASALAH TERIDENTIFIKASI

### KATEGORI 1: TIMEZONE & DATETIME HANDLING

#### Bug #1.1: Timezone Offset Tidak Konsisten di Region Berbeda

**Severity:** HIGH  
**File:** `quiz_model.dart`, `quiz_attempt_model.dart`

**Masalah:**

- Konversi timezone menggunakan `toUtc()` dan `toLocal()`
- Tidak ada handling untuk daylight saving time (DST)
- Jika user di region dengan DST, bisa ada offset 1 jam

**Skenario:**

```
User di region dengan DST:
- Buat quiz: 10:15 (DST aktif, UTC+7)
- Simpan: 03:15 UTC
- Baca kembali: 10:15 (DST tidak aktif, UTC+6)
- Hasil: SALAH 1 jam!
```

**Rekomendasi:**

- Gunakan timezone-aware library (timezone package)
- Store timezone info di database
- Atau gunakan fixed UTC offset untuk region tertentu

---

#### Bug #1.2: DateTime Parsing Tidak Robust

**Severity:** MEDIUM  
**File:** `quiz_model.dart` line 290

**Masalah:**

```dart
DateTime? _parseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    final parsed = DateTime.tryParse(dateString);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  } catch (e) {
    debugPrint('Error parsing DateTime: $dateString - $e');
    return null;  // ❌ Silent fail
  }
}
```

**Masalah:**

- Silent fail tanpa throw exception
- Caller tidak tahu ada error
- Bisa menyebabkan null reference di UI

**Contoh Error Case:**

- Format datetime tidak standard
- Corrupted data dari database
- Timezone info tidak valid

---

### KATEGORI 2: STATE MANAGEMENT & LIFECYCLE

#### Bug #2.1: Provider Tidak Di-dispose Dengan Benar

**Severity:** MEDIUM  
**File:** `student_quiz_provider.dart`

**Masalah:**

```dart
@override
void dispose() {
  stopTimer();
  super.dispose();
}
```

**Issue:**

- Timer di-stop, tapi tidak ada cleanup untuk listeners
- Jika provider di-recreate berkali-kali, bisa memory leak
- Tidak ada cleanup untuk async operations yang pending

**Skenario:**

```
1. User buka quiz → Provider created
2. User back → Provider disposed
3. User buka quiz lagi → Provider created (baru)
4. Repeat 100x → Memory leak!
```

---

#### Bug #2.2: Race Condition di `startQuizAttempt()`

**Severity:** MEDIUM  
**File:** `student_quiz_provider.dart` line 201

**Masalah:**

```dart
Future<bool> startQuizAttempt() async {
  if (_currentQuiz == null) return false;

  final inProgressAttempt = getInProgressAttempt();
  if (inProgressAttempt != null) {
    return await resumeQuizAttempt(inProgressAttempt);  // ❌ Async call
  }

  if (!canStartQuiz()) return false;

  _isLoading = true;
  notifyListeners();

  try {
    _currentAttempt = await studentQuizService.createAttempt(...);
    // ...
  }
}
```

**Race Condition:**

```
Thread 1: User click "Mulai Quiz"
  → startQuizAttempt() called
  → _isLoading = true
  → Waiting for createAttempt()

Thread 2: User click "Mulai Quiz" lagi (double tap)
  → startQuizAttempt() called LAGI
  → _isLoading = true (already true)
  → createAttempt() called LAGI

Result: 2 attempts created! ❌
```

**Rekomendasi:**

```dart
Future<bool> startQuizAttempt() async {
  if (_isLoading) return false;  // ✅ Guard clause

  _isLoading = true;
  notifyListeners();

  try {
    // ...
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

#### Bug #2.3: Timer Tidak Stop Saat Widget Dispose

**Severity:** MEDIUM  
**File:** `student_quiz_provider.dart` line 360

**Masalah:**

```dart
void startTimer() {
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();  // ❌ Notify setelah dispose?
    } else {
      timer.cancel();
      submitQuizAttempt();  // ❌ Async call setelah dispose?
    }
  });
}
```

**Masalah:**

- Jika widget di-dispose, timer masih berjalan
- `notifyListeners()` dipanggil pada disposed provider
- `submitQuizAttempt()` bisa dipanggil setelah dispose

**Error yang Mungkin:**

```
E/flutter: setState() called after dispose()
E/flutter: Unhandled Exception: Bad state: Cannot add new events after calling close
```

---

### KATEGORI 3: DATA VALIDATION & INTEGRITY

#### Bug #3.1: Tidak Ada Validasi Quiz Duration

**Severity:** LOW  
**File:** `quiz_validator.dart`

**Masalah:**

```dart
// Tidak ada validasi untuk durationMinutes
// Bisa input: -5, 0, 999999
```

**Skenario:**

- Quiz dengan durasi 0 menit → Timer langsung expired
- Quiz dengan durasi negatif → Undefined behavior
- Quiz dengan durasi 999999 → Overflow

---

#### Bug #3.2: Tidak Ada Validasi Max Attempts

**Severity:** LOW  
**File:** `quiz_validator.dart`

**Masalah:**

```dart
// Tidak ada validasi untuk attemptsAllowed
// Bisa input: 0, -1, 999999
```

---

#### Bug #3.3: Tidak Ada Validasi Question Count

**Severity:** MEDIUM  
**File:** `quiz_validator.dart`

**Masalah:**

```dart
// Quiz bisa dibuat tanpa pertanyaan
// Bisa menyebabkan:
// - Division by zero di score calculation
// - Empty quiz ditampilkan
```

**Contoh Error:**

```dart
final percentage = quiz.questionCount > 0
    ? (correctCount / quiz.questionCount) * 100
    : 0.0;
```

Jika `questionCount == 0`, percentage = 0 (tidak error, tapi logika salah)

---

### KATEGORI 4: NETWORK & ERROR HANDLING

#### Bug #4.1: Tidak Ada Retry Logic untuk Network Error

**Severity:** MEDIUM  
**File:** `student_quiz_service.dart`

**Masalah:**

```dart
Future<QuizAttemptModel?> createAttempt(String quizId) async {
  try {
    final response = await supabaseClient
        .from('quiz_attempts')
        .insert({...})
        .select()
        .single();
    return QuizAttemptModel.fromJson(response);
  } catch (e) {
    debugPrint('Error createAttempt: $e');
    rethrow;  // ❌ Langsung throw, tidak ada retry
  }
}
```

**Skenario:**

- Network timeout → Error
- User tidak bisa retry
- Harus buka app lagi

---

#### Bug #4.2: Tidak Ada Timeout untuk Async Operations

**Severity:** MEDIUM  
**File:** `student_quiz_service.dart`

**Masalah:**

```dart
// Tidak ada timeout
final response = await supabaseClient
    .from('quiz_attempts')
    .insert({...})
    .select()
    .single();  // ❌ Bisa hang selamanya
```

**Rekomendasi:**

```dart
final response = await supabaseClient
    .from('quiz_attempts')
    .insert({...})
    .select()
    .single()
    .timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Request timeout'),
    );
```

---

#### Bug #4.3: Error Message Tidak User-Friendly

**Severity:** LOW  
**File:** Semua service files

**Masalah:**

```dart
_errorMessage = e.toString();  // ❌ Technical error message
// Contoh: "PgException: duplicate key value violates unique constraint"
```

**Rekomendasi:**

```dart
_errorMessage = _mapErrorToUserMessage(e);

String _mapErrorToUserMessage(dynamic error) {
  if (error is TimeoutException) {
    return 'Koneksi timeout, coba lagi';
  } else if (error.toString().contains('duplicate')) {
    return 'Quiz sudah ada';
  }
  return 'Terjadi kesalahan, coba lagi';
}
```

---

### KATEGORI 5: UI/UX ISSUES

#### Bug #5.1: Tidak Ada Loading State di Dialog

**Severity:** LOW  
**File:** `start_quiz_dialog.dart`

**Masalah:**

- Dialog tidak menunjukkan loading saat `startQuizAttempt()` berjalan
- User tidak tahu apakah sedang loading atau hang

---

#### Bug #5.2: Tidak Ada Confirmation Saat Keluar Quiz

**Severity:** MEDIUM  
**File:** `student_quiz_taking_page.dart`

**Masalah:**

- User bisa back/keluar tanpa warning
- Jawaban yang sudah diisi bisa hilang

**Rekomendasi:**

```dart
Future<bool> _onWillPop() async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Keluar Quiz?'),
      content: const Text('Jawaban Anda akan hilang'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Lanjutkan'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Keluar'),
        ),
      ],
    ),
  ) ?? false;
}
```

---

#### Bug #5.3: Tidak Ada Handling untuk Quiz yang Sudah Ditutup

**Severity:** MEDIUM  
**File:** `student_quiz_detail_page.dart`

**Masalah:**

- User bisa lihat quiz yang sudah ditutup
- Tapi tidak bisa mulai (button disabled)
- UX tidak jelas

---

### KATEGORI 6: PERFORMANCE ISSUES

#### Bug #6.1: Attempt History Tidak Di-paginate

**Severity:** LOW  
**File:** `student_quiz_detail_page.dart`

**Masalah:**

```dart
_attemptHistory = await studentQuizService.fetchAttemptsByQuiz(quizId);
// ❌ Fetch semua attempts, bisa ribuan!
```

**Rekomendasi:**

- Implement pagination
- Lazy load saat scroll

---

#### Bug #6.2: Quiz Questions Tidak Di-cache

**Severity:** LOW  
**File:** `student_quiz_provider.dart`

**Masalah:**

- Setiap kali buka quiz, fetch dari database
- Bisa slow untuk quiz dengan banyak questions

---

### KATEGORI 7: SECURITY ISSUES

#### Bug #7.1: Tidak Ada Validation untuk User Ownership

**Severity:** HIGH  
**File:** `student_quiz_service.dart`

**Masalah:**

```dart
// Tidak ada check apakah user punya akses ke quiz ini
final response = await supabaseClient
    .from('quizzes')
    .select(...)
    .eq('id', quizId)
    .maybeSingle();
```

**Skenario:**

- User A bisa akses quiz dari class lain
- User A bisa lihat attempt dari user B

**Rekomendasi:**

- Implement RLS (Row Level Security) di Supabase
- Validate user enrollment di class

---

#### Bug #7.2: Tidak Ada Rate Limiting untuk Submit

**Severity:** MEDIUM  
**File:** `student_quiz_service.dart`

**Masalah:**

- User bisa submit berkali-kali dalam 1 detik
- Bisa create multiple attempts

---

### KATEGORI 8: DATA CONSISTENCY

#### Bug #8.1: Tidak Ada Transaction untuk Create Attempt + Answers

**Severity:** MEDIUM  
**File:** `student_quiz_service.dart`

**Masalah:**

```dart
// Jika network error di tengah-tengah:
// 1. Attempt created ✅
// 2. Answers insert failed ❌
// Result: Orphaned attempt!

DELETE FROM quiz_answers
WHERE attempt_id IN (
  SELECT id FROM quiz_attempts
  WHERE quiz_id = 'xxx'
);
```

**Rekomendasi:**

- Gunakan database transaction
- Atau implement retry logic

---

#### Bug #8.2: Tidak Ada Soft Delete

**Severity:** LOW  
**File:** Database schema

**Masalah:**

- Jika delete quiz, semua data hilang
- Tidak ada audit trail

---

## 📈 RISK MATRIX

| Bug ID | Severity | Likelihood | Impact                 | Priority    |
| ------ | -------- | ---------- | ---------------------- | ----------- |
| #1.1   | HIGH     | MEDIUM     | Quiz tidak bisa dibuka | 🔴 CRITICAL |
| #1.2   | MEDIUM   | LOW        | Silent fail            | 🟡 MEDIUM   |
| #2.1   | MEDIUM   | LOW        | Memory leak            | 🟡 MEDIUM   |
| #2.2   | MEDIUM   | HIGH       | Duplicate attempts     | 🔴 CRITICAL |
| #2.3   | MEDIUM   | MEDIUM     | Timer leak             | 🟡 MEDIUM   |
| #3.1   | LOW      | LOW        | Edge case              | 🟢 LOW      |
| #3.2   | LOW      | LOW        | Edge case              | 🟢 LOW      |
| #3.3   | MEDIUM   | MEDIUM     | Division by zero       | 🟡 MEDIUM   |
| #4.1   | MEDIUM   | HIGH       | User frustration       | 🟡 MEDIUM   |
| #4.2   | MEDIUM   | MEDIUM     | App hang               | 🟡 MEDIUM   |
| #4.3   | LOW      | HIGH       | UX issue               | 🟢 LOW      |
| #5.1   | LOW      | LOW        | UX issue               | 🟢 LOW      |
| #5.2   | MEDIUM   | HIGH       | Data loss              | 🟡 MEDIUM   |
| #5.3   | MEDIUM   | MEDIUM     | UX confusion           | 🟡 MEDIUM   |
| #6.1   | LOW      | LOW        | Performance            | 🟢 LOW      |
| #6.2   | LOW      | LOW        | Performance            | 🟢 LOW      |
| #7.1   | HIGH     | MEDIUM     | Security breach        | 🔴 CRITICAL |
| #7.2   | MEDIUM   | MEDIUM     | Abuse                  | 🟡 MEDIUM   |
| #8.1   | MEDIUM   | LOW        | Data inconsistency     | 🟡 MEDIUM   |
| #8.2   | LOW      | LOW        | Audit trail            | 🟢 LOW      |

---

## 🎯 REKOMENDASI PRIORITAS

### 🔴 CRITICAL (Harus diperbaiki segera)

1. **#1.1** - Timezone DST handling
2. **#2.2** - Race condition di startQuizAttempt
3. **#7.1** - User ownership validation

### 🟡 MEDIUM (Perbaiki dalam sprint berikutnya)

1. **#2.1** - Provider cleanup
2. **#2.3** - Timer cleanup
3. **#3.3** - Question count validation
4. **#4.1** - Retry logic
5. **#4.2** - Timeout handling
6. **#5.2** - Exit confirmation
7. **#5.3** - Quiz status handling
8. **#7.2** - Rate limiting
9. **#8.1** - Transaction handling

### 🟢 LOW (Nice to have)

1. **#1.2** - DateTime parsing robustness
2. **#3.1, #3.2** - Duration/attempts validation
3. **#4.3** - User-friendly error messages
4. **#5.1** - Loading state di dialog
5. **#6.1, #6.2** - Performance optimization
6. **#8.2** - Soft delete

---

## 📝 KESIMPULAN

Quiz feature sudah functional dengan perbaikan hari ini, tapi ada beberapa area yang perlu attention:

1. **Timezone handling** - Sudah diperbaiki, tapi DST masih perlu dipertimbangkan
2. **State management** - Ada potensi race condition dan memory leak
3. **Error handling** - Perlu retry logic dan timeout
4. **Security** - Perlu RLS validation dan rate limiting
5. **Data consistency** - Perlu transaction handling

Dengan prioritas yang tepat, semua issue bisa diselesaikan dalam 2-3 sprint development.

---

**Analisis Selesai:** 29 November 2025
