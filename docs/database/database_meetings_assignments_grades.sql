-- =====================================================
-- DATABASE MIGRATION: Meetings, Assignments & Grades
-- Created: December 1, 2025
-- Description: Schema for meetings, attendance, assignments, submissions, and grades
-- =====================================================

-- =====================================================
-- 1. MEETINGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  meeting_date TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  meeting_type TEXT NOT NULL CHECK (meeting_type IN ('online', 'offline')),
  meeting_link TEXT, -- for online meetings
  location TEXT, -- for offline meetings
  status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled')),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for meetings
CREATE INDEX IF NOT EXISTS idx_meetings_class_id ON meetings(class_id);
CREATE INDEX IF NOT EXISTS idx_meetings_created_by ON meetings(created_by);
CREATE INDEX IF NOT EXISTS idx_meetings_meeting_date ON meetings(meeting_date);
CREATE INDEX IF NOT EXISTS idx_meetings_status ON meetings(status);

-- =====================================================
-- 2. ATTENDANCE TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'absent' CHECK (status IN ('present', 'absent', 'late', 'excused')),
  marked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(meeting_id, student_id)
);

-- Indexes for attendance
CREATE INDEX IF NOT EXISTS idx_attendance_meeting_id ON attendance(meeting_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);

-- =====================================================
-- 3. ASSIGNMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  max_score INTEGER NOT NULL DEFAULT 100,
  attachment_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for assignments
CREATE INDEX IF NOT EXISTS idx_assignments_class_id ON assignments(class_id);
CREATE INDEX IF NOT EXISTS idx_assignments_created_by ON assignments(created_by);
CREATE INDEX IF NOT EXISTS idx_assignments_deadline ON assignments(deadline);
CREATE INDEX IF NOT EXISTS idx_assignments_is_active ON assignments(is_active);

-- =====================================================
-- 4. SUBMISSIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT DEFAULT '',
  attachment_url TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'graded', 'late', 'returned')),
  submitted_at TIMESTAMP WITH TIME ZONE,
  score DECIMAL(5,2),
  feedback TEXT,
  graded_at TIMESTAMP WITH TIME ZONE,
  graded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(assignment_id, student_id)
);

-- Indexes for submissions
CREATE INDEX IF NOT EXISTS idx_submissions_assignment_id ON submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student_id ON submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);

-- =====================================================
-- 5. GRADES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS grades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES auth.users(id),
  class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  item_id UUID NOT NULL, -- quiz_id or assignment_id
  item_type TEXT NOT NULL CHECK (item_type IN ('quiz', 'assignment')),
  score DECIMAL(5,2) NOT NULL,
  max_score DECIMAL(5,2) NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, item_id)
);

-- Indexes for grades
CREATE INDEX IF NOT EXISTS idx_grades_student_id ON grades(student_id);
CREATE INDEX IF NOT EXISTS idx_grades_class_id ON grades(class_id);
CREATE INDEX IF NOT EXISTS idx_grades_item_id ON grades(item_id);
CREATE INDEX IF NOT EXISTS idx_grades_item_type ON grades(item_type);

-- =====================================================
-- 6. TRIGGERS FOR updated_at
-- =====================================================

-- Trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for meetings
DROP TRIGGER IF EXISTS update_meetings_updated_at ON meetings;
CREATE TRIGGER update_meetings_updated_at
  BEFORE UPDATE ON meetings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for assignments
DROP TRIGGER IF EXISTS update_assignments_updated_at ON assignments;
CREATE TRIGGER update_assignments_updated_at
  BEFORE UPDATE ON assignments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for submissions
DROP TRIGGER IF EXISTS update_submissions_updated_at ON submissions;
CREATE TRIGGER update_submissions_updated_at
  BEFORE UPDATE ON submissions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- MEETINGS RLS POLICIES
-- =====================================================

-- Mentor can CRUD their own meetings
CREATE POLICY "Mentors can create meetings"
  ON meetings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Mentors can view their own meetings"
  ON meetings FOR SELECT
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Mentors can update their own meetings"
  ON meetings FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Mentors can delete their own meetings"
  ON meetings FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- Students can view meetings for their enrolled classes
CREATE POLICY "Students can view meetings for enrolled classes"
  ON meetings FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM class_enrollments
      WHERE class_enrollments.class_id = meetings.class_id
      AND class_enrollments.user_id = auth.uid()
      AND class_enrollments.status = 'active'
    )
  );

-- =====================================================
-- ATTENDANCE RLS POLICIES
-- =====================================================

-- Mentor can CRUD attendance for their meetings
CREATE POLICY "Mentors can manage attendance"
  ON attendance FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM meetings
      WHERE meetings.id = attendance.meeting_id
      AND meetings.created_by = auth.uid()
    )
  );

-- Students can view their own attendance
CREATE POLICY "Students can view their own attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (auth.uid() = student_id);

-- =====================================================
-- ASSIGNMENTS RLS POLICIES
-- =====================================================

-- Mentor can CRUD their own assignments
CREATE POLICY "Mentors can create assignments"
  ON assignments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Mentors can view their own assignments"
  ON assignments FOR SELECT
  TO authenticated
  USING (auth.uid() = created_by);

CREATE POLICY "Mentors can update their own assignments"
  ON assignments FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Mentors can delete their own assignments"
  ON assignments FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- Students can view assignments for their enrolled classes
CREATE POLICY "Students can view assignments for enrolled classes"
  ON assignments FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM class_enrollments
      WHERE class_enrollments.class_id = assignments.class_id
      AND class_enrollments.user_id = auth.uid()
      AND class_enrollments.status = 'active'
    )
  );

-- =====================================================
-- SUBMISSIONS RLS POLICIES
-- =====================================================

-- Students can CRUD their own submissions
CREATE POLICY "Students can create submissions"
  ON submissions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Students can view their own submissions"
  ON submissions FOR SELECT
  TO authenticated
  USING (auth.uid() = student_id);

CREATE POLICY "Students can update their own submissions"
  ON submissions FOR UPDATE
  TO authenticated
  USING (auth.uid() = student_id AND status IN ('draft', 'submitted'))
  WITH CHECK (auth.uid() = student_id);

-- Mentors can view and grade submissions for their assignments
CREATE POLICY "Mentors can view submissions for their assignments"
  ON submissions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments
      WHERE assignments.id = submissions.assignment_id
      AND assignments.created_by = auth.uid()
    )
  );

CREATE POLICY "Mentors can grade submissions"
  ON submissions FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assignments
      WHERE assignments.id = submissions.assignment_id
      AND assignments.created_by = auth.uid()
    )
  );

-- =====================================================
-- GRADES RLS POLICIES
-- =====================================================

-- Students can view their own grades
CREATE POLICY "Students can view their own grades"
  ON grades FOR SELECT
  TO authenticated
  USING (auth.uid() = student_id);

-- Mentors can view grades for their classes
CREATE POLICY "Mentors can view grades for their classes"
  ON grades FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM classes
      WHERE classes.id = grades.class_id
      AND classes.tutor_id = auth.uid()
    )
  );

-- System can insert/update grades (via service role)
CREATE POLICY "System can manage grades"
  ON grades FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- =====================================================
-- 8. HELPER FUNCTIONS
-- =====================================================

-- Function to check if student is enrolled in class
CREATE OR REPLACE FUNCTION is_student_enrolled(p_class_id UUID, p_student_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM class_enrollments
    WHERE class_id = p_class_id
    AND user_id = p_student_id
    AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql;

-- Function to check if user is mentor of class
CREATE OR REPLACE FUNCTION is_class_mentor(p_class_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM classes
    WHERE id = p_class_id
    AND tutor_id = p_user_id
  );
END;
$$ LANGUAGE plpgsql;

-- Function to calculate student average grade
CREATE OR REPLACE FUNCTION calculate_student_average(p_student_id UUID, p_class_id UUID)
RETURNS DECIMAL AS $$
DECLARE
  avg_percentage DECIMAL;
BEGIN
  SELECT AVG(percentage) INTO avg_percentage
  FROM grades
  WHERE student_id = p_student_id
  AND class_id = p_class_id;
  
  RETURN COALESCE(avg_percentage, 0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Uncomment below to insert sample data for testing
/*
-- Sample meeting
INSERT INTO meetings (class_id, title, description, meeting_date, duration_minutes, meeting_type, meeting_link, status, created_by)
VALUES (
  'YOUR_CLASS_ID',
  'Pertemuan 1: Pengenalan',
  'Pertemuan pertama untuk pengenalan materi',
  NOW() + INTERVAL '1 day',
  60,
  'online',
  'https://meet.google.com/xxx-xxxx-xxx',
  'scheduled',
  'YOUR_MENTOR_ID'
);

-- Sample assignment
INSERT INTO assignments (class_id, title, description, deadline, max_score, is_active, created_by)
VALUES (
  'YOUR_CLASS_ID',
  'Tugas 1: Essay',
  'Buatlah essay tentang topik yang telah dipelajari',
  NOW() + INTERVAL '7 days',
  100,
  true,
  'YOUR_MENTOR_ID'
);
*/

-- =====================================================
-- END OF MIGRATION
-- =====================================================
