# 📋 ACTION ITEMS - NEXT SESSION

**Created:** 29 November 2025  
**For:** Next Development Session  
**Priority:** Organized by urgency

---

## 🔴 CRITICAL - DO FIRST

### 1. Timezone DST Handling

**Issue:** #1.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2-3 hours  
**Steps:**

- [ ] Research timezone package
- [ ] Implement timezone-aware storage
- [ ] Test di multiple regions (WIB, WITA, WIT)
- [ ] Update documentation

**Files to Modify:**

- `quiz_model.dart`
- `quiz_attempt_model.dart`
- Database schema (add timezone column)

---

### 2. Race Condition Fix

**Issue:** #2.2 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 1 hour  
**Steps:**

- [ ] Add guard clause di `startQuizAttempt()`
- [ ] Test double-tap scenario
- [ ] Verify only 1 attempt created

**Files to Modify:**

- `student_quiz_provider.dart`

**Test Case:**

```dart
// Simulate double-tap
await provider.startQuizAttempt();
await provider.startQuizAttempt();
// Verify: only 1 attempt in database
```

---

### 3. User Ownership Validation

**Issue:** #7.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement RLS policies di Supabase
- [ ] Add enrollment check
- [ ] Test unauthorized access
- [ ] Document security model

**Files to Modify:**

- `student_quiz_service.dart`
- Database RLS policies

---

## 🟡 HIGH PRIORITY - DO NEXT

### 4. Provider Cleanup

**Issue:** #2.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 1 hour  
**Steps:**

- [ ] Add listener cleanup
- [ ] Test memory usage
- [ ] Verify no leaks

**Files to Modify:**

- `student_quiz_provider.dart`

---

### 5. Timer Cleanup

**Issue:** #2.3 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 1 hour  
**Steps:**

- [ ] Add mounted check di timer callback
- [ ] Test dispose scenario
- [ ] Verify no errors

**Files to Modify:**

- `student_quiz_provider.dart`

---

### 6. Retry Logic

**Issue:** #4.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement exponential backoff
- [ ] Add max retry count
- [ ] Test network failure scenario
- [ ] Show retry UI

**Files to Modify:**

- `student_quiz_service.dart`
- `quiz_service.dart`

---

### 7. Timeout Handling

**Issue:** #4.2 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 1 hour  
**Steps:**

- [ ] Add timeout untuk semua async calls
- [ ] Test timeout scenario
- [ ] Show timeout error

**Files to Modify:**

- `student_quiz_service.dart`
- `quiz_service.dart`

---

### 8. Exit Confirmation

**Issue:** #5.2 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 1 hour  
**Steps:**

- [ ] Add WillPopScope
- [ ] Show confirmation dialog
- [ ] Test back button

**Files to Modify:**

- `student_quiz_taking_page.dart`

---

## 🟢 MEDIUM PRIORITY - PLAN FOR LATER

### 9. Question Count Validation

**Issue:** #3.3 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 30 minutes  
**Steps:**

- [ ] Add validation di QuizValidator
- [ ] Reject quiz tanpa questions
- [ ] Show error message

**Files to Modify:**

- `quiz_validator.dart`

---

### 10. Duration Validation

**Issue:** #3.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 30 minutes  
**Steps:**

- [ ] Add min/max duration validation
- [ ] Reject invalid durations
- [ ] Show error message

**Files to Modify:**

- `quiz_validator.dart`

---

### 11. Rate Limiting

**Issue:** #7.2 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement rate limiter
- [ ] Add cooldown period
- [ ] Test abuse scenario

**Files to Modify:**

- `student_quiz_service.dart`

---

### 12. Transaction Handling

**Issue:** #8.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement database transaction
- [ ] Test failure scenario
- [ ] Verify rollback

**Files to Modify:**

- `student_quiz_service.dart`

---

### 13. Pagination

**Issue:** #6.1 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement pagination logic
- [ ] Add lazy loading
- [ ] Test dengan banyak attempts

**Files to Modify:**

- `student_quiz_detail_page.dart`
- `student_quiz_provider.dart`

---

### 14. Caching

**Issue:** #6.2 in QUIZ_FEATURE_ANALYSIS.md  
**Effort:** 2 hours  
**Steps:**

- [ ] Implement cache layer
- [ ] Add cache invalidation
- [ ] Test cache hit/miss

**Files to Modify:**

- `student_quiz_provider.dart`

---

## 📝 TESTING CHECKLIST

### Unit Tests

- [ ] Timezone conversion tests
- [ ] Race condition tests
- [ ] Validation tests
- [ ] Error handling tests

### Integration Tests

- [ ] Create quiz → Start quiz → Submit
- [ ] Resume quiz workflow
- [ ] Network failure handling
- [ ] Concurrent user scenario

### Manual Tests

- [ ] Test di multiple timezones
- [ ] Test di slow network
- [ ] Test double-tap
- [ ] Test back button
- [ ] Test exit without saving

---

## 🔍 CODE REVIEW CHECKLIST

Before merging any changes:

- [ ] No console errors
- [ ] No warnings
- [ ] Tests passing
- [ ] Code formatted
- [ ] Comments added
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Performance acceptable

---

## 📊 ESTIMATED EFFORT

| Category        | Hours     | Priority |
| --------------- | --------- | -------- |
| Critical Fixes  | 5-6       | 🔴       |
| High Priority   | 8-10      | 🟡       |
| Medium Priority | 8-10      | 🟢       |
| **Total**       | **21-26** | -        |

**Recommendation:** Fokus pada Critical + High Priority dulu (13-16 hours = 2 sprint)

---

## 🎯 SPRINT PLANNING

### Sprint 1 (Next 2 days)

1. Timezone DST handling
2. Race condition fix
3. User ownership validation
4. Provider cleanup

**Estimated:** 6-7 hours

### Sprint 2 (Following week)

1. Timer cleanup
2. Retry logic
3. Timeout handling
4. Exit confirmation

**Estimated:** 5-6 hours

### Sprint 3 (Following week)

1. Validation improvements
2. Rate limiting
3. Transaction handling
4. Pagination

**Estimated:** 6-8 hours

---

## 📚 REFERENCE DOCUMENTS

- **Implementation Report:** `IMPLEMENTATION_REPORT_2025_11_29.md`
- **Feature Analysis:** `QUIZ_FEATURE_ANALYSIS.md`
- **Daily Summary:** `DAILY_SUMMARY.md`
- **Reset Guide:** `QUIZ_RESET_GUIDE.md`
- **Reset Script:** `RESET_QUIZ_ATTEMPTS.sql`

---

## 💬 NOTES FOR NEXT SESSION

1. **Timezone Testing**

   - Test di WIB (UTC+7), WITA (UTC+8), WIT (UTC+9)
   - Test saat DST transition
   - Document timezone assumptions

2. **Performance**

   - Profile memory usage
   - Check for leaks
   - Optimize queries

3. **Security**

   - Review RLS policies
   - Test unauthorized access
   - Implement rate limiting

4. **Documentation**
   - Update API docs
   - Add troubleshooting guide
   - Create runbook

---

## ✅ SIGN-OFF

**Current Status:** Ready for next session  
**All Critical Issues:** Identified and documented  
**Recommended Action:** Start with Critical fixes  
**Estimated Timeline:** 3-4 weeks untuk semua items

---

**Prepared by:** Kiro AI Assistant  
**Date:** 29 November 2025  
**Status:** READY FOR EXECUTION ✅
