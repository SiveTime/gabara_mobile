# Implementation Plan - Forum Diskusi Feature

## Overview

Implementation plan untuk fitur Forum Diskusi. Setiap task dirancang untuk incremental progress dengan testing di setiap tahap.

---

## Phase 1: Data Layer & Models Setup

- [x] 1. Create Discussion entities and models

  - Create `lib/features/discussions/domain/entities/discussion_entity.dart`
  - Create `lib/features/discussions/domain/entities/reply_entity.dart`
  - Create `lib/features/discussions/data/models/discussion_model.dart`
  - Create `lib/features/discussions/data/models/reply_model.dart`
  - Implement fromJson/toJson serialization
  - _Requirements: 1.1, 2.1, 3.1_

- [x] 2. Write property test for Discussion model serialization

  - **Property 1: Discussion Creation Authorization**
  - Test model serialization/deserialization
  - **Validates: Requirements 1.1-1.8**

- [x] 3. Create DiscussionService with Supabase integration

  - Create `lib/features/discussions/data/services/discussion_service.dart`
  - Implement `createDiscussion()` - Insert discussion record
  - Implement `fetchDiscussionsByClass()` - Query discussions by class
  - Implement `fetchDiscussionsByStudent()` - Query discussions for enrolled classes
  - Implement `fetchDiscussionsByMentor()` - Query discussions for mentor's classes
  - Implement `fetchDiscussionById()` - Get single discussion with replies
  - Implement `updateDiscussionStatus()` - Toggle open/closed status
  - Implement `deleteDiscussion()` - Delete discussion (cascade delete replies)
  - _Requirements: 1.1-1.8, 2.1-2.8, 4.1-4.6, 6.1-6.6_

- [x] 4. Implement Reply methods in DiscussionService

  - Implement `createReply()` - Insert reply record with @mention
  - Implement `fetchRepliesByDiscussion()` - Get all replies for discussion
  - Implement `updateReply()` - Update reply content
  - Implement `deleteReply()` - Delete reply
  - Implement `getParentReplyAuthor()` - Get username for @mention
  - _Requirements: 3.1-3.7, 7.1-7.5_

- [x] 5. Write property test for Reply mention consistency

  - **Property 5: Reply Mention Consistency**
  - Test @mention is added when replying to reply
  - **Validates: Requirements 7.1-7.5**

- [x] 6. Checkpoint - Verify Data Layer

  - Test all CRUD operations
  - Verify model serialization
  - Test service methods with mock data

---

## Phase 2: Domain Layer - Validators & Business Logic

- [x] 7. Create Discussion validators

  - Create `lib/features/discussions/domain/validators/discussion_validator.dart`
  - Validate title (not empty, max 255 chars)
  - Validate content (not empty)
  - Validate class enrollment
  - Validate user role (student only for create)
  - _Requirements: 9.1-9.3_

- [x] 8. Create Reply validators

  - Create `lib/features/discussions/domain/validators/reply_validator.dart`
  - Validate content (not empty)
  - Validate discussion is open
  - Validate user role (student only)
  - Validate parent reply exists (if nested)
  - _Requirements: 9.3, 3.5, 6.3_

- [x] 9. Write property test for authorization

  - **Property 2: Reply Authorization**
  - **Property 3: Mentor Read-Only Access**
  - **Property 4: Discussion Status Toggle Authorization**
  - **Validates: Requirements 3.1-3.7, 5.1-5.6, 6.1-6.6**

- [x] 10. Checkpoint - Verify Domain Layer
  - Test all validators
  - Verify authorization logic

---

## Phase 3: Presentation Layer - Student Discussion Management

- [x] 11. Create DiscussionProvider

  - Create `lib/features/discussions/presentation/providers/discussion_provider.dart`
  - State: discussions list, current discussion, replies, loading, error
  - Methods: loadDiscussions, loadDiscussionDetail, createDiscussion
  - Methods: createReply, toggleDiscussionStatus
  - Role-based method access
  - _Requirements: 1.1-1.8, 2.1-2.8, 3.1-3.7, 4.1-4.6_

- [x] 12. Create DiscussionListPage

  - Create `lib/features/discussions/presentation/pages/discussion_list_page.dart`
  - Display list of discussions for enrolled classes
  - Show discussion cards with title, preview, creator, class, reply count, status
  - Add "+ Buat Diskusi" button (student only)
  - Implement filter (All, Open, Closed)
  - Implement sort (Newest, Oldest, Most Replies)
  - Navigate to detail page on tap
  - _Requirements: 2.1-2.8, 8.1-8.5_

- [x] 13. Create DiscussionCard widget

  - Create `lib/features/discussions/presentation/widgets/discussion_card.dart`
  - Display title, content preview (truncated)
  - Display creator name, class name
  - Display reply count, timestamp
  - Display status badge (Terbuka/Ditutup)
  - _Requirements: 2.2-2.4_

- [x] 14. Create StatusBadge widget

  - Create `lib/features/discussions/presentation/widgets/status_badge.dart`
  - Green badge for "Terbuka" (open)
  - Red badge for "Ditutup" (closed)
  - _Requirements: 2.3-2.4_

- [ ] 15. Write unit tests for DiscussionListPage

  - Test display of discussion list
  - Test filter functionality
  - Test sort functionality
  - Test navigation to create page (student only)
  - Test navigation to detail page

- [x] 16. Checkpoint - Verify Discussion List
  - Test page loads correctly
  - Test filter and sort work
  - Test navigation works

---

## Phase 4: Create Discussion Page (Student Only)

- [x] 17. Create CreateDiscussionPage

  - Create `lib/features/discussions/presentation/pages/create_discussion_page.dart`
  - Form fields: Kelas (dropdown), Judul (text), Konten (textarea)
  - Dropdown shows only enrolled classes
  - Form validation
  - Posting and Batal buttons
  - Navigate to detail page on success
  - _Requirements: 1.1-1.8_

- [ ] 18. Write unit tests for CreateDiscussionPage

  - Test form validation
  - Test class dropdown shows enrolled classes only
  - Test posting functionality
  - Test cancel functionality

- [ ] 19. Write property test for Discussion creation

  - **Property 1: Discussion Creation Authorization**
  - Test only students can create
  - **Validates: Requirements 1.1-1.8**

- [x] 20. Checkpoint - Verify Create Discussion
  - Test page loads correctly
  - Test form validation works
  - Test discussion is created successfully

---

## Phase 5: Discussion Detail & Reply System

- [x] 21. Create DiscussionDetailPage

  - Create `lib/features/discussions/presentation/pages/discussion_detail_page.dart`
  - Display full discussion (title, content, creator, class, date, status)
  - Display replies list with nested replies
  - Show reply input (student only, if discussion open)
  - Show "Diskusi ini telah ditutup" message if closed
  - Show Tutup/Buka Diskusi button (creator or mentor)
  - _Requirements: 2.5-2.8, 3.1-3.7, 4.1-4.6_

- [x] 22. Create ReplyCard widget

  - Create `lib/features/discussions/presentation/widgets/reply_card.dart`
  - Display author name, content, timestamp
  - Highlight @mention in content
  - Show "Balas" button (student only, if discussion open)
  - Support nested replies with indentation
  - _Requirements: 2.7-2.8, 3.3-3.4, 7.1-7.5_

- [x] 23. Create MentionText widget

  - Create `lib/features/discussions/presentation/widgets/mention_text.dart`
  - Parse and highlight @username in text
  - Different color/style for mention
  - _Requirements: 7.2-7.3_

- [x] 24. Create ReplyInput widget

  - Create `lib/features/discussions/presentation/widgets/reply_input.dart`
  - Text input field
  - @mention prefix when replying to reply
  - Send button
  - _Requirements: 3.1-3.4_

- [ ] 25. Write unit tests for DiscussionDetailPage

  - Test display of discussion details
  - Test display of replies
  - Test reply input visibility (student only)
  - Test closed discussion message

- [ ] 26. Write unit tests for ReplyCard

  - Test display of reply content
  - Test @mention highlighting
  - Test nested reply indentation
  - Test Balas button visibility

- [ ] 27. Write property test for Reply system

  - **Property 5: Reply Mention Consistency**
  - **Property 6: Closed Discussion Reply Prevention**
  - **Property 8: Reply Hierarchy Consistency**
  - **Validates: Requirements 3.1-3.7, 7.1-7.5**

- [x] 28. Checkpoint - Verify Discussion Detail & Reply
  - Test page loads correctly
  - Test replies display correctly
  - Test reply creation works
  - Test nested reply with @mention works

---

## Phase 6: Discussion Status Management

- [x] 29. Implement Student toggle status

  - Add Tutup/Buka Diskusi button for discussion creator
  - Show confirmation dialog
  - Update discussion status
  - Disable/enable reply input based on status
  - _Requirements: 4.1-4.6_

- [ ] 30. Write unit tests for Student toggle status

  - Test button visibility (creator only)
  - Test confirmation dialog
  - Test status update
  - Test reply input state change

- [x] 31. Checkpoint - Verify Student Status Management
  - Test creator can toggle status
  - Test non-creator cannot toggle status
  - Test reply input responds to status change

---

## Phase 7: Mentor View & Moderation

- [x] 32. Modify DiscussionListPage for Mentor

  - Hide "+ Buat Diskusi" button for mentor
  - Show discussions for mentor's classes
  - _Requirements: 5.1-5.6_

- [x] 33. Modify DiscussionDetailPage for Mentor

  - Hide reply input for mentor
  - Show Tutup/Buka Diskusi button for mentor
  - Read-only view of discussion and replies
  - _Requirements: 5.4-5.6, 6.1-6.6_

- [x] 34. Implement Mentor moderation

  - Add Tutup/Buka Diskusi button for mentor
  - Show confirmation dialog with optional reason
  - Update discussion status
  - Record moderator action
  - _Requirements: 6.1-6.6_

- [ ] 35. Write unit tests for Mentor view

  - Test create button hidden
  - Test reply input hidden
  - Test moderation button visible
  - Test status toggle works

- [ ] 36. Write property test for Mentor access

  - **Property 3: Mentor Read-Only Access**
  - **Property 4: Discussion Status Toggle Authorization**
  - **Validates: Requirements 5.1-5.6, 6.1-6.6**

- [x] 37. Checkpoint - Verify Mentor Features
  - Test mentor can view discussions
  - Test mentor cannot create/reply
  - Test mentor can moderate

---

## Phase 8: Integration & Navigation

- [x] 38. Add Forum Diskusi to navigation

  - Add route '/discussions' in main.dart
  - Add menu item in student drawer
  - Add menu item in mentor drawer
  - Add navigation from class detail page

- [x] 39. Register DiscussionProvider

  - Add DiscussionProvider to MultiProvider in main.dart
  - Initialize with DiscussionService

- [x] 40. Implement onGenerateRoute for discussion pages

  - Add route for '/discussions/create'
  - Add route for '/discussions/detail' with discussionId argument

- [x] 41. Checkpoint - Verify Navigation
  - Test navigation from drawer
  - Test navigation between pages
  - Test back navigation

---

## Phase 9: RLS Policies & Security

- [x] 42. Create RLS policies for discussions table

  - Students can SELECT discussions for enrolled classes
  - Students can INSERT discussions for enrolled classes
  - Students can UPDATE own discussions (is_closed only)
  - Mentors can SELECT discussions for their classes
  - Mentors can UPDATE any discussion in their classes (is_closed only)

- [x] 43. Create RLS policies for discussion_replies table

  - Students can SELECT replies for accessible discussions
  - Students can INSERT replies for open discussions in enrolled classes
  - Students can UPDATE own replies
  - Mentors can SELECT replies (read-only)
  - Mentors cannot INSERT replies

- [ ] 44. Write integration tests for RLS

  - Test student can create discussion
  - Test mentor cannot create discussion
  - Test student can reply
  - Test mentor cannot reply
  - Test status toggle authorization

- [x] 45. Checkpoint - Verify Security
  - Test all RLS policies work correctly
  - Test unauthorized actions are blocked

---

## Phase 10: Testing & Polish

- [ ] 46. Write comprehensive integration tests

  - Test complete student flow (create → view → reply → close)
  - Test complete mentor flow (view → moderate)
  - Test nested reply with @mention
  - Test authorization across roles

- [ ] 47. Integration test - Student flow

  - Create discussion → View discussion → Reply → Reply to reply → Close discussion
  - Verify all data persists correctly
  - Verify @mention is added correctly

- [ ] 48. Integration test - Mentor flow

  - View discussions → View detail → Close discussion → Open discussion
  - Verify mentor cannot create/reply
  - Verify moderation works

- [ ] 49. Integration test - Cross-role interaction

  - Student creates discussion
  - Another student replies
  - Mentor closes discussion
  - Verify students cannot reply after close

- [ ] 50. Bug fixes and optimization

  - Fix any bugs found during testing
  - Optimize database queries
  - Improve error messages
  - Add loading states where needed

- [ ] 51. Final checkpoint - All tests passing
  - Ensure all unit tests pass
  - Ensure all property tests pass
  - Ensure all integration tests pass
  - Verify no console errors

---

## Notes

- All property-based tests use `glados` package
- Each checkpoint should verify all previous work is functioning correctly
- Use `flutter test` to run tests
- Use `flutter analyze` to check for lint issues
- Ensure all code follows project conventions
- Database schema already exists in database_schema_v2.sql
