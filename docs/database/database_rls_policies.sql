-- RLS Policies for Meetings, Assignments & Grades
-- Requirements: 10.1-10.5, 11.1-11.8, 16.1-16.6

-- Enable RLS on all tables
ALTER TABLE meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- MEETINGS TABLE RLS POLICIES
-- =====================================================

-- Mentors can view all meetings they created
CREATE POLICY "Mentors can view own meetings"
ON meetings FOR SELECT
TO authenticated
USING (created_by = auth.uid());

-- Mentors can create meetings
CREATE POLICY "Mentors can create meetings"
ON meetings FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

-- Mentors can update their own meetings
CREATE POLICY "Mentors can update own meetings"
ON meetings FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Mentors can delete their own meetings
CREATE POLICY "Mentors can delete own meetings"
ON meetings FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Students can view meetings for classes they are enrolled in
CREATE POLICY "Students can view enrolled class meetings"
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
-- ATTENDANCE TABLE RLS POLICIES
-- =====================================================

-- Mentors can view attendance for meetings they created
CREATE POLICY "Mentors can view attendance for own meetings"
ON attendance FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM meetings
    WHERE meetings.id = attendance.meeting_id
    AND meetings.created_by = auth.uid()
  )
);

-- Mentors can mark attendance for meetings they created
CREATE POLICY "Mentors can mark attendance"
ON attendance FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM meetings
    WHERE meetings.id = attendance.meeting_id
    AND meetings.created_by = auth.uid()
  )
);

-- Mentors can update attendance for meetings they created
CREATE POLICY "Mentors can update attendance"
ON attendance FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM meetings
    WHERE meetings.id = attendance.meeting_id
    AND meetings.created_by = auth.uid()
  )
);

-- Students can view their own attendance
CREATE POLICY "Students can view own attendance"
ON attendance FOR SELECT
TO authenticated
USING (student_id = auth.uid());

-- =====================================================
-- ASSIGNMENTS TABLE RLS POLICIES
-- =====================================================

-- Mentors can view all assignments they created
CREATE POLICY "Mentors can view own assignments"
ON assignments FOR SELECT
TO authenticated
USING (created_by = auth.uid());

-- Mentors can create assignments
CREATE POLICY "Mentors can create assignments"
ON assignments FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

-- Mentors can update their own assignments
CREATE POLICY "Mentors can update own assignments"
ON assignments FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Mentors can delete their own assignments
CREATE POLICY "Mentors can delete own assignments"
ON assignments FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- Students can view assignments for classes they are enrolled in
CREATE POLICY "Students can view enrolled class assignments"
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
-- SUBMISSIONS TABLE RLS POLICIES
-- =====================================================

-- Mentors can view submissions for assignments they created
CREATE POLICY "Mentors can view submissions for own assignments"
ON submissions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM assignments
    WHERE assignments.id = submissions.assignment_id
    AND assignments.created_by = auth.uid()
  )
);

-- Mentors can grade submissions (update)
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

-- Students can view their own submissions
CREATE POLICY "Students can view own submissions"
ON submissions FOR SELECT
TO authenticated
USING (student_id = auth.uid());

-- Students can create submissions
CREATE POLICY "Students can create submissions"
ON submissions FOR INSERT
TO authenticated
WITH CHECK (student_id = auth.uid());

-- Students can update their own submissions (before grading)
CREATE POLICY "Students can update own submissions"
ON submissions FOR UPDATE
TO authenticated
USING (student_id = auth.uid() AND status != 'graded')
WITH CHECK (student_id = auth.uid());

-- =====================================================
-- GRADES TABLE RLS POLICIES
-- =====================================================

-- Students can view their own grades
CREATE POLICY "Students can view own grades"
ON grades FOR SELECT
TO authenticated
USING (student_id = auth.uid());

-- Mentors can view grades for classes they teach
CREATE POLICY "Mentors can view class grades"
ON grades FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM classes
    WHERE classes.id = grades.class_id
    AND classes.tutor_id = auth.uid()
  )
);

-- System can insert grades (via service role or triggers)
CREATE POLICY "System can insert grades"
ON grades FOR INSERT
TO authenticated
WITH CHECK (true);

-- System can update grades
CREATE POLICY "System can update grades"
ON grades FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Meetings indexes
CREATE INDEX IF NOT EXISTS idx_meetings_class_id ON meetings(class_id);
CREATE INDEX IF NOT EXISTS idx_meetings_created_by ON meetings(created_by);
CREATE INDEX IF NOT EXISTS idx_meetings_meeting_date ON meetings(meeting_date);
CREATE INDEX IF NOT EXISTS idx_meetings_status ON meetings(status);

-- Attendance indexes
CREATE INDEX IF NOT EXISTS idx_attendance_meeting_id ON attendance(meeting_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);

-- Assignments indexes
CREATE INDEX IF NOT EXISTS idx_assignments_class_id ON assignments(class_id);
CREATE INDEX IF NOT EXISTS idx_assignments_created_by ON assignments(created_by);
CREATE INDEX IF NOT EXISTS idx_assignments_deadline ON assignments(deadline);

-- Submissions indexes
CREATE INDEX IF NOT EXISTS idx_submissions_assignment_id ON submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_submissions_student_id ON submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);

-- Grades indexes
CREATE INDEX IF NOT EXISTS idx_grades_student_id ON grades(student_id);
CREATE INDEX IF NOT EXISTS idx_grades_class_id ON grades(class_id);
CREATE INDEX IF NOT EXISTS idx_grades_item_id ON grades(item_id);
CREATE INDEX IF NOT EXISTS idx_grades_item_type ON grades(item_type);
