# 🔗 INTEGRATION GUIDE

**Date:** December 3, 2025  
**Status:** ✅ COMPLETE  
**Target Audience:** Backend Developers, Integration Engineers  
**Document Type:** Integration & Setup Guide

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Setup Instructions](#setup-instructions)
3. [Database Setup](#database-setup)
4. [Service Integration](#service-integration)
5. [Provider Setup](#provider-setup)
6. [UI Integration](#ui-integration)
7. [Testing](#testing)
8. [Deployment](#deployment)

---

## OVERVIEW

### What's Being Integrated

Two complete features:
- **Meetings Feature** - Meeting management with attendance tracking
- **Assignments Feature** - Assignment management with grading

### Integration Points

1. **Database** - 4 new tables
2. **Services** - 2 new services
3. **Providers** - 2 new providers
4. **Pages** - 7 new pages
5. **Widgets** - 10 new widgets
6. **Grades Integration** - Automatic grade syncing

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  supabase_flutter: ^1.0.0
  intl: ^0.18.0
```

---

## SETUP INSTRUCTIONS

### Step 1: Clone/Pull Latest Code

```bash
git pull origin main
flutter pub get
```

### Step 2: Verify File Structure

```
lib/features/
├── meetings/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── usecases/
│   │   └── validators/
│   └── presentation/
│       ├── pages/
│       ├── providers/
│       └── widgets/
└── assignments/
    ├── data/
    │   ├── models/
    │   ├── repositories/
    │   └── services/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   ├── usecases/
    │   └── validators/
    └── presentation/
        ├── pages/
        ├── providers/
        └── widgets/
```

### Step 3: Verify Dependencies

```bash
flutter pub get
flutter pub upgrade
```

### Step 4: Run Tests

```bash
flutter test test/features/meetings/
flutter test test/features/assignments/
```

---

## DATABASE SETUP

### Step 1: Create Tables

Run the following SQL in Supabase:

```sql
-- Meetings Table
CREATE TABLE meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  meeting_type VARCHAR(50) NOT NULL CHECK (meeting_type IN ('online', 'offline')),
  meeting_link VARCHAR(500),
  location VARCHAR(255),
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attendance Table
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  status VARCHAR(50) NOT NULL CHECK (status IN ('present', 'absent', 'late')),
  marked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(meeting_id, student_id)
);

-- Assignments Table
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  meeting_id UUID REFERENCES meetings(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  max_score INTEGER DEFAULT 100 CHECK (max_score > 0),
  attachment_url VARCHAR(500),
  is_active BOOLEAN DEFAULT true,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Assignment Submissions Table
CREATE TABLE assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT,
  attachment_url VARCHAR(500),
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'late', 'graded')),
  submitted_at TIMESTAMP WITH TIME ZONE,
  score DECIMAL(5,2) CHECK (score >= 0 AND score <= 100),
  feedback TEXT,
  graded_at TIMESTAMP WITH TIME ZONE,
  graded_by UUID REFERENCES auth.users(id),
  UNIQUE(assignment_id, user_id)
);

-- Create Indexes
CREATE INDEX idx_meetings_class_id ON meetings(class_id);
CREATE INDEX idx_meetings_created_by ON meetings(created_by);
CREATE INDEX idx_meetings_meeting_date ON meetings(meeting_date);
CREATE INDEX idx_meetings_status ON meetings(status);

CREATE INDEX idx_attendance_meeting_id ON attendance(meeting_id);
CREATE INDEX idx_attendance_student_id ON attendance(student_id);
CREATE INDEX idx_attendance_status ON attendance(status);

CREATE INDEX idx_assignments_class_id ON assignments(class_id);
CREATE INDEX idx_assignments_meeting_id ON assignments(meeting_id);
CREATE INDEX idx_assignments_created_by ON assignments(created_by);
CREATE INDEX idx_assignments_deadline ON assignments(deadline);
CREATE INDEX idx_assignments_is_active ON assignments(is_active);

CREATE INDEX idx_submissions_assignment_id ON assignment_submissions(assignment_id);
CREATE INDEX idx_submissions_user_id ON assignment_submissions(user_id);
CREATE INDEX idx_submissions_status ON assignment_submissions(status);
CREATE INDEX idx_submissions_submitted_at ON assignment_submissions(submitted_at);
```

### Step 2: Set Up RLS Policies

```sql
-- Meetings RLS
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view meetings in their classes"
  ON meetings FOR SELECT
  USING (
    class_id IN (
      SELECT id FROM classes WHERE tutor_id = auth.uid()
      UNION
      SELECT class_id FROM class_enrollments WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Mentors can create meetings"
  ON meetings FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Mentors can update their meetings"
  ON meetings FOR UPDATE
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Mentors can delete their meetings"
  ON meetings FOR DELETE
  USING (created_by = auth.uid());

-- Attendance RLS
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view attendance for their meetings"
  ON attendance FOR SELECT
  USING (
    meeting_id IN (
      SELECT id FROM meetings WHERE created_by = auth.uid()
      UNION
      SELECT id FROM meetings WHERE class_id IN (
        SELECT class_id FROM class_enrollments WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Mentors can mark attendance"
  ON attendance FOR INSERT
  WITH CHECK (
    meeting_id IN (
      SELECT id FROM meetings WHERE created_by = auth.uid()
    )
  );

-- Assignments RLS
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view assignments in their classes"
  ON assignments FOR SELECT
  USING (
    class_id IN (
      SELECT id FROM classes WHERE tutor_id = auth.uid()
      UNION
      SELECT class_id FROM class_enrollments WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Mentors can create assignments"
  ON assignments FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Mentors can update their assignments"
  ON assignments FOR UPDATE
  USING (created_by = auth.uid())
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Mentors can delete their assignments"
  ON assignments FOR DELETE
  USING (created_by = auth.uid());

-- Assignment Submissions RLS
ALTER TABLE assignment_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their submissions"
  ON assignment_submissions FOR SELECT
  USING (
    user_id = auth.uid()
    OR
    assignment_id IN (
      SELECT id FROM assignments WHERE created_by = auth.uid()
    )
  );

CREATE POLICY "Students can submit assignments"
  ON assignment_submissions FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Students can update their submissions"
  ON assignment_submissions FOR UPDATE
  USING (user_id = auth.uid() AND status != 'graded')
  WITH CHECK (user_id = auth.uid() AND status != 'graded');

CREATE POLICY "Mentors can grade submissions"
  ON assignment_submissions FOR UPDATE
  USING (
    assignment_id IN (
      SELECT id FROM assignments WHERE created_by = auth.uid()
    )
  )
  WITH CHECK (
    assignment_id IN (
      SELECT id FROM assignments WHERE created_by = auth.uid()
    )
  );
```

### Step 3: Verify Tables

```bash
# In Supabase console, verify:
# - meetings table exists with correct columns
# - attendance table exists with correct columns
# - assignments table exists with correct columns
# - assignment_submissions table exists with correct columns
# - All indexes are created
# - RLS policies are enabled
```

---

## SERVICE INTEGRATION

### Step 1: Initialize Services

In your main app initialization:

```dart
// In main.dart or app initialization
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:your_app/features/meetings/data/services/meeting_service.dart';
import 'package:your_app/features/assignments/data/services/assignment_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

### Step 2: Register Services in Provider

```dart
// In your provider setup file
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:your_app/features/meetings/data/services/meeting_service.dart';
import 'package:your_app/features/meetings/presentation/providers/meeting_provider.dart';
import 'package:your_app/features/assignments/data/services/assignment_service.dart';
import 'package:your_app/features/assignments/presentation/providers/assignment_provider.dart';

List<ChangeNotifierProvider> getProviders() {
  final supabaseClient = Supabase.instance.client;
  
  return [
    // Meetings
    Provider<MeetingService>(
      create: (_) => MeetingService(supabaseClient),
    ),
    ChangeNotifierProvider<MeetingProvider>(
      create: (context) => MeetingProvider(
        context.read<MeetingService>(),
      ),
    ),
    
    // Assignments
    Provider<AssignmentService>(
      create: (_) => AssignmentService(supabaseClient),
    ),
    ChangeNotifierProvider<AssignmentProvider>(
      create: (context) => AssignmentProvider(
        context.read<AssignmentService>(),
      ),
    ),
  ];
}
```

### Step 3: Use in App

```dart
// In your main app widget
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MaterialApp(
        // ... your app configuration
      ),
    );
  }
}
```

---

## PROVIDER SETUP

### Step 1: Access Providers

```dart
// In your widgets
import 'package:provider/provider.dart';
import 'package:your_app/features/meetings/presentation/providers/meeting_provider.dart';
import 'package:your_app/features/assignments/presentation/providers/assignment_provider.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access providers
    final meetingProvider = context.read<MeetingProvider>();
    final assignmentProvider = context.read<AssignmentProvider>();
    
    return Container();
  }
}
```

### Step 2: Listen to Changes

```dart
// In your widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (provider.errorMessage != null) {
          return Text('Error: ${provider.errorMessage}');
        }
        
        return ListView(
          children: provider.meetings.map((meeting) {
            return ListTile(title: Text(meeting.title));
          }).toList(),
        );
      },
    );
  }
}
```

### Step 3: Load Data

```dart
// In your page
class MeetingsPage extends StatefulWidget {
  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    // Load meetings when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingProvider>().loadMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meetings')),
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          // ... build UI
        },
      ),
    );
  }
}
```

---

## UI INTEGRATION

### Step 1: Add Navigation Routes

```dart
// In your router/navigation file
import 'package:your_app/features/meetings/presentation/pages/meeting_list_page.dart';
import 'package:your_app/features/meetings/presentation/pages/meeting_detail_page.dart';
import 'package:your_app/features/meetings/presentation/pages/create_meeting_page.dart';
import 'package:your_app/features/assignments/presentation/pages/assignment_list_page.dart';
import 'package:your_app/features/assignments/presentation/pages/assignment_detail_page.dart';
import 'package:your_app/features/assignments/presentation/pages/create_assignment_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/meetings':
        return MaterialPageRoute(builder: (_) => MeetingListPage());
      case '/meetings/create':
        return MaterialPageRoute(builder: (_) => CreateMeetingPage());
      case '/meetings/detail':
        final meetingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MeetingDetailPage(meetingId: meetingId),
        );
      case '/assignments':
        return MaterialPageRoute(builder: (_) => AssignmentListPage());
      case '/assignments/create':
        return MaterialPageRoute(builder: (_) => CreateAssignmentPage());
      case '/assignments/detail':
        final assignmentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AssignmentDetailPage(assignmentId: assignmentId),
        );
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  }
}
```

### Step 2: Add Menu Items

```dart
// In your main navigation menu
class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Menu')),
          ListTile(
            title: Text('Meetings'),
            onTap: () => Navigator.pushNamed(context, '/meetings'),
          ),
          ListTile(
            title: Text('Assignments'),
            onTap: () => Navigator.pushNamed(context, '/assignments'),
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Add Widgets to Existing Pages

```dart
// In your class detail page, add meetings and assignments sections
class ClassDetailPage extends StatelessWidget {
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Class Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Existing class info
            SizedBox(height: 20),
            
            // Meetings section
            MeetingsSection(classId: classId),
            
            SizedBox(height: 20),
            
            // Assignments section
            AssignmentsSection(classId: classId),
          ],
        ),
      ),
    );
  }
}

// Create these sections
class MeetingsSection extends StatelessWidget {
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meetings', style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/meetings/create'),
                child: Text('Create'),
              ),
            ],
          ),
        ),
        Consumer<MeetingProvider>(
          builder: (context, provider, child) {
            final meetings = provider.meetings
                .where((m) => m.classId == classId)
                .toList();
            
            if (meetings.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text('No meetings yet'),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                return MeetingCard(meeting: meetings[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class AssignmentsSection extends StatelessWidget {
  final String classId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assignments', style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/assignments/create'),
                child: Text('Create'),
              ),
            ],
          ),
        ),
        Consumer<AssignmentProvider>(
          builder: (context, provider, child) {
            final assignments = provider.assignments
                .where((a) => a.classId == classId)
                .toList();
            
            if (assignments.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text('No assignments yet'),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                return AssignmentCard(assignment: assignments[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
```

---

## TESTING

### Step 1: Run Unit Tests

```bash
flutter test test/features/meetings/data/models/
flutter test test/features/meetings/data/services/
flutter test test/features/assignments/data/models/
flutter test test/features/assignments/data/services/
```

### Step 2: Run Integration Tests

```bash
flutter test test/features/meetings/presentation/
flutter test test/features/assignments/presentation/
```

### Step 3: Run All Tests

```bash
flutter test
```

### Step 4: Check Coverage

```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## DEPLOYMENT

### Step 1: Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Database migrations applied
- [ ] RLS policies enabled
- [ ] Services initialized
- [ ] Providers registered
- [ ] Routes configured
- [ ] UI integrated
- [ ] Error handling tested
- [ ] Performance tested

### Step 2: Deploy to Staging

```bash
# Build APK for Android
flutter build apk --release

# Build IPA for iOS
flutter build ios --release

# Build web
flutter build web --release
```

### Step 3: Test in Staging

- [ ] Create meeting
- [ ] Edit meeting
- [ ] Delete meeting
- [ ] Mark attendance
- [ ] Create assignment
- [ ] Edit assignment
- [ ] Delete assignment
- [ ] Submit assignment
- [ ] Grade submission
- [ ] Verify grade syncing

### Step 4: Deploy to Production

```bash
# Deploy to app stores
# Deploy to web server
# Update documentation
# Notify users
```

### Step 5: Monitor Production

- [ ] Monitor error logs
- [ ] Monitor performance
- [ ] Collect user feedback
- [ ] Address issues
- [ ] Plan improvements

---

## TROUBLESHOOTING

### Issue: Tables Not Found

**Solution:** Verify tables are created in Supabase

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

### Issue: RLS Policies Not Working

**Solution:** Verify RLS is enabled and policies are correct

```sql
SELECT * FROM pg_policies WHERE tablename = 'meetings';
```

### Issue: Services Not Initializing

**Solution:** Verify Supabase is initialized before services

```dart
await Supabase.initialize(
  url: 'YOUR_URL',
  anonKey: 'YOUR_KEY',
);
```

### Issue: Providers Not Updating

**Solution:** Verify notifyListeners() is called

```dart
Future<void> loadMeetings() async {
  _isLoading = true;
  notifyListeners(); // Add this
  
  try {
    _meetings = await meetingService.fetchMeetingsByMentor();
  } finally {
    _isLoading = false;
    notifyListeners(); // Add this
  }
}
```

### Issue: DateTime Mismatch

**Solution:** Ensure UTC conversion

```dart
String? _formatDateTimeForSupabase(DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.toUtc().toIso8601String();
}
```

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2025  
**Status:** ✅ COMPLETE
