# 👨‍💻 DEVELOPER DOCUMENTATION

**Target Audience:** Backend Developers, Frontend Developers, Full-Stack Developers  
**Date:** December 3, 2025  
**Status:** ✅ COMPLETE

---

## 📚 DOCUMENTS IN THIS FOLDER

### 1. MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md

**Purpose:** Complete technical implementation guide  
**Read Time:** 45 minutes  
**Best For:** Understanding the overall architecture and implementation

**Contains:**
- Architecture overview
- Directory structure
- Meetings feature details (create, fetch, update, delete, attendance)
- Assignments feature details (create, fetch, update, delete, submit, grade)
- Integration points between features
- Database schema overview
- API reference
- Code patterns and best practices
- Testing guide
- Troubleshooting guide

**When to Read:**
- First thing when starting development
- When you need to understand the overall system
- When you need to implement a new feature

---

### 2. API_DATABASE_REFERENCE.md

**Purpose:** Detailed API and database reference  
**Read Time:** 60 minutes  
**Best For:** Implementing API calls and database queries

**Contains:**
- Complete database schema with SQL
- All API endpoints with request/response examples
- Data models and their fields
- Error handling and error codes
- Authentication and authorization
- Rate limiting information
- Practical code examples

**When to Read:**
- When implementing API calls
- When writing database queries
- When debugging API issues
- When implementing error handling

---

### 3. INTEGRATION_GUIDE.md

**Purpose:** Step-by-step integration and setup guide  
**Read Time:** 90 minutes  
**Best For:** Setting up and integrating the features

**Contains:**
- Setup instructions
- Database setup with complete SQL scripts
- Service initialization
- Provider setup and configuration
- UI integration steps
- Testing procedures
- Deployment checklist
- Troubleshooting common issues

**When to Read:**
- When setting up the project
- When integrating features into your app
- When deploying to production
- When troubleshooting setup issues

---

## 🎯 QUICK START

### I'm a New Developer

1. **Read:** `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` (45 min)
   - Understand the architecture
   - Learn the directory structure
   - See how features are organized

2. **Read:** `INTEGRATION_GUIDE.md` (90 min)
   - Set up the database
   - Initialize services
   - Configure providers
   - Integrate UI

3. **Reference:** `API_DATABASE_REFERENCE.md`
   - Use as reference when implementing

**Total Time:** ~2.5 hours

---

### I Need to Implement a Feature

1. **Reference:** `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md`
   - Find the feature section
   - Understand the architecture
   - See the code patterns

2. **Reference:** `API_DATABASE_REFERENCE.md`
   - Find the API endpoint
   - See the request/response format
   - Check error codes

3. **Implement:** Follow the patterns shown

---

### I Need to Debug an Issue

1. **Check:** `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` - Troubleshooting section
2. **Check:** `API_DATABASE_REFERENCE.md` - Error codes section
3. **Check:** `INTEGRATION_GUIDE.md` - Troubleshooting section

---

### I Need to Deploy

1. **Read:** `INTEGRATION_GUIDE.md` - Deployment section
2. **Follow:** Pre-deployment checklist
3. **Execute:** Deployment steps

---

## 📖 READING GUIDE

### By Task

#### "I need to create a meeting"

→ `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` - Meetings Feature section  
→ `API_DATABASE_REFERENCE.md` - Create Meeting endpoint

#### "I need to mark attendance"

→ `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` - Attendance Tracking section  
→ `API_DATABASE_REFERENCE.md` - Mark Attendance endpoint

#### "I need to create an assignment"

→ `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` - Assignments Feature section  
→ `API_DATABASE_REFERENCE.md` - Create Assignment endpoint

#### "I need to grade a submission"

→ `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md` - Grade Submission section  
→ `API_DATABASE_REFERENCE.md` - Grade Submission endpoint

#### "I need to set up the database"

→ `INTEGRATION_GUIDE.md` - Database Setup section

#### "I need to integrate the features"

→ `INTEGRATION_GUIDE.md` - Service Integration section

#### "I need to understand the API"

→ `API_DATABASE_REFERENCE.md` - API Endpoints section

#### "I need to understand the database"

→ `API_DATABASE_REFERENCE.md` - Database Schema section

---

## 🔍 KEY CONCEPTS

### Architecture

The features follow Clean Architecture with three layers:

1. **Data Layer** - Models, Services, Repositories
2. **Domain Layer** - Entities, Use Cases, Validators
3. **Presentation Layer** - Pages, Widgets, Providers

### State Management

Uses Provider pattern for state management:

- `MeetingProvider` - Manages meeting state
- `AssignmentProvider` - Manages assignment state

### Database

Uses Supabase (PostgreSQL) with:

- 4 main tables (meetings, attendance, assignments, assignment_submissions)
- Row-level security (RLS) for data protection
- Proper indexes for performance

### API

RESTful API with:

- Standard HTTP methods (GET, POST, PUT, DELETE)
- JSON request/response format
- Bearer token authentication
- Comprehensive error handling

---

## 💡 CODE PATTERNS

### DateTime Handling

Always convert to UTC before storing:

```dart
String? _formatDateTimeForSupabase(DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.toUtc().toIso8601String();
}
```

### Error Handling

Use try-catch with proper error messages:

```dart
try {
  // operation
} catch (e) {
  debugPrint('Error: $e');
  rethrow;
}
```

### Ownership Verification

Always check user ownership before update/delete:

```dart
if (existingMeeting['created_by'] != user.id) {
  throw Exception('Anda bukan pembuat meeting ini');
}
```

### State Management

Use Provider with loading, error, and data states:

```dart
Future<void> loadMeetings() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  try {
    _meetings = await meetingService.fetchMeetingsByMentor();
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 🧪 TESTING

### Run All Tests

```bash
flutter test
```

### Run Specific Feature Tests

```bash
flutter test test/features/meetings/
flutter test test/features/assignments/
```

### Run with Coverage

```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## 🚀 DEPLOYMENT

### Pre-Deployment

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Database migrations applied
- [ ] RLS policies enabled
- [ ] Services initialized
- [ ] Providers registered

### Deployment

```bash
# Build for release
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### Post-Deployment

- [ ] Monitor error logs
- [ ] Monitor performance
- [ ] Collect user feedback
- [ ] Address issues

---

## 📞 SUPPORT

### Getting Help

1. **Check Documentation** - Start with the relevant document
2. **Check Troubleshooting** - Look for your issue
3. **Ask Team Lead** - If still stuck
4. **Check Code Comments** - Implementation details

### Common Issues

**DateTime Mismatch** → Check timezone conversion  
**Ownership Error** → Check user authentication  
**API Error** → Check error codes in reference  
**Database Error** → Check RLS policies  

---

## 📚 ADDITIONAL RESOURCES

### Internal Documentation

- Main docs README: `../README.md`
- Project Manager Report: `../project-manager/MEETINGS_ASSIGNMENTS_PROJECT_REPORT.md`
- Stakeholder Summary: `../stakeholder/MEETINGS_ASSIGNMENTS_SUMMARY.md`

### External Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart Language](https://dart.dev/guides)

---

## ✅ CHECKLIST

### Before Starting Development

- [ ] Read `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md`
- [ ] Read `INTEGRATION_GUIDE.md`
- [ ] Set up database
- [ ] Initialize services
- [ ] Configure providers
- [ ] Run tests

### Before Implementing a Feature

- [ ] Read relevant section in `MEETINGS_ASSIGNMENTS_IMPLEMENTATION.md`
- [ ] Check API endpoint in `API_DATABASE_REFERENCE.md`
- [ ] Follow code patterns
- [ ] Write tests
- [ ] Test locally

### Before Deploying

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Database ready
- [ ] Services initialized
- [ ] Providers configured
- [ ] UI integrated

---

## 🎓 LEARNING OUTCOMES

After reading this documentation, you should be able to:

✅ Understand the architecture and design patterns  
✅ Implement new features following the patterns  
✅ Use the API endpoints correctly  
✅ Query the database properly  
✅ Manage state with providers  
✅ Handle errors appropriately  
✅ Write tests for your code  
✅ Deploy to production  
✅ Troubleshoot common issues  
✅ Maintain and extend the features  

---

**Documentation Version:** 1.0  
**Last Updated:** December 3, 2025  
**Status:** ✅ COMPLETE & READY FOR USE
