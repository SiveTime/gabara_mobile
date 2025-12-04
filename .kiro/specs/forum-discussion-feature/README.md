# 📚 Forum Diskusi Feature Spec

**Date:** December 3, 2025  
**Status:** 📋 READY FOR IMPLEMENTATION  
**Version:** 1.0

---

## 📌 Overview

Fitur Forum Diskusi memungkinkan student untuk membuat dan berpartisipasi dalam diskusi kelas. Mentor berperan sebagai moderator yang dapat membuka/menutup diskusi tanpa berpartisipasi.

---

## 🎯 Key Features

1. **Student dapat membuat forum diskusi** dalam kelas yang diikuti
2. **Student dapat membalas diskusi** dengan sesama student
3. **Sistem @mention** untuk menyebut nama student yang dibalas
4. **Student creator dapat membuka/menutup** diskusi yang dibuat
5. **Mentor hanya dapat memoderasi** (buka/tutup) diskusi, tidak bisa join

---

## 📂 Spec Files

| File                            | Description                                           |
| ------------------------------- | ----------------------------------------------------- |
| `requirements.md`               | User stories dan acceptance criteria                  |
| `design.md`                     | Architecture, data models, dan correctness properties |
| `tasks.md`                      | Implementation plan dengan 51 tasks                   |
| `PRE_REQUIREMENTS_CHECKLIST.md` | Pre-requirements checklist                            |

---

## 👥 Roles & Permissions

| Action                    | Student               | Mentor                |
| ------------------------- | --------------------- | --------------------- |
| View Discussions          | ✅ (enrolled classes) | ✅ (teaching classes) |
| Create Discussion         | ✅                    | ❌                    |
| Reply to Discussion       | ✅                    | ❌                    |
| Reply to Reply (@mention) | ✅                    | ❌                    |
| Close/Open Own Discussion | ✅ (creator only)     | N/A                   |
| Close/Open Any Discussion | ❌                    | ✅ (moderator)        |

---

## 🏗️ Architecture

```
lib/features/discussions/
├── data/
│   ├── models/
│   │   ├── discussion_model.dart
│   │   └── reply_model.dart
│   └── services/
│       └── discussion_service.dart
├── domain/
│   ├── entities/
│   │   ├── discussion_entity.dart
│   │   └── reply_entity.dart
│   └── validators/
│       ├── discussion_validator.dart
│       └── reply_validator.dart
└── presentation/
    ├── pages/
    │   ├── discussion_list_page.dart
    │   ├── create_discussion_page.dart
    │   └── discussion_detail_page.dart
    ├── providers/
    │   └── discussion_provider.dart
    └── widgets/
        ├── discussion_card.dart
        ├── reply_card.dart
        ├── reply_input.dart
        ├── mention_text.dart
        └── status_badge.dart
```

---

## 📊 Database Tables (Already Exist)

- `discussions` - Thread diskusi
- `discussion_replies` - Balasan diskusi

---

## ⏱️ Estimated Timeline

| Phase                      | Duration        | Tasks        |
| -------------------------- | --------------- | ------------ |
| Phase 1: Data Layer        | 1-2 days        | Tasks 1-6    |
| Phase 2: Domain Layer      | 1 day           | Tasks 7-10   |
| Phase 3: Student List      | 1-2 days        | Tasks 11-16  |
| Phase 4: Create Discussion | 1 day           | Tasks 17-20  |
| Phase 5: Detail & Reply    | 2 days          | Tasks 21-28  |
| Phase 6: Status Management | 1 day           | Tasks 29-31  |
| Phase 7: Mentor View       | 1-2 days        | Tasks 32-37  |
| Phase 8: Integration       | 1 day           | Tasks 38-41  |
| Phase 9: Security          | 1 day           | Tasks 42-45  |
| Phase 10: Testing          | 1-2 days        | Tasks 46-51  |
| **Total**                  | **~10-14 days** | **51 tasks** |

---

## 🚀 Getting Started

1. Read `requirements.md` untuk memahami user stories
2. Read `design.md` untuk memahami architecture
3. Check `PRE_REQUIREMENTS_CHECKLIST.md` untuk pre-requirements
4. Follow `tasks.md` untuk implementation

---

## ✅ Success Criteria

- [ ] Student dapat membuat diskusi
- [ ] Student dapat membalas diskusi
- [ ] Sistem @mention berfungsi
- [ ] Student creator dapat buka/tutup diskusi
- [ ] Mentor dapat memoderasi diskusi
- [ ] Mentor tidak bisa membuat/membalas diskusi
- [ ] All tests passing
