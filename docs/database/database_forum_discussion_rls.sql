-- ============================================
-- FORUM DISKUSI - RLS POLICIES
-- Role-based access control for discussions
-- ============================================

-- ============================================
-- 1. DISCUSSIONS TABLE RLS POLICIES
-- ============================================

-- Enable RLS on discussions table (if not already enabled)
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Students can view discussions for enrolled classes" ON discussions;
DROP POLICY IF EXISTS "Mentors can view discussions for their classes" ON discussions;
DROP POLICY IF EXISTS "Students can create discussions for enrolled classes" ON discussions;
DROP POLICY IF EXISTS "Discussion creators can update own discussions" ON discussions;
DROP POLICY IF EXISTS "Mentors can update discussions in their classes" ON discussions;
DROP POLICY IF EXISTS "Discussion creators can delete own discussions" ON discussions;

-- Policy 1: Students can view discussions for enrolled classes
CREATE POLICY "Students can view discussions for enrolled classes" ON discussions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = discussions.class_id 
      AND ce.user_id = auth.uid()
      AND ce.status = 'active'
    )
  );

-- Policy 2: Mentors can view discussions for their classes
CREATE POLICY "Mentors can view discussions for their classes" ON discussions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = discussions.class_id 
      AND c.tutor_id = auth.uid()
    )
  );

-- Policy 3: Students can create discussions for enrolled classes
-- Only students (not mentors) can create discussions
CREATE POLICY "Students can create discussions for enrolled classes" ON discussions
  FOR INSERT WITH CHECK (
    -- User must be enrolled in the class
    EXISTS (
      SELECT 1 FROM class_enrollments ce
      WHERE ce.class_id = discussions.class_id 
      AND ce.user_id = auth.uid()
      AND ce.status = 'active'
    )
    -- User must have student role (not mentor)
    AND EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() 
      AND r.name = 'student'
    )
    -- created_by must be current user
    AND discussions.created_by = auth.uid()
  );


-- Policy 4: Discussion creators (students) can update own discussions
-- Only is_closed field should be updatable
CREATE POLICY "Discussion creators can update own discussions" ON discussions
  FOR UPDATE USING (
    auth.uid() = discussions.created_by
  );

-- Policy 5: Mentors can update discussions in their classes (moderation)
CREATE POLICY "Mentors can update discussions in their classes" ON discussions
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM classes c
      WHERE c.id = discussions.class_id 
      AND c.tutor_id = auth.uid()
    )
  );

-- Policy 6: Discussion creators can delete own discussions
CREATE POLICY "Discussion creators can delete own discussions" ON discussions
  FOR DELETE USING (
    auth.uid() = discussions.created_by
  );

-- ============================================
-- 2. DISCUSSION_REPLIES TABLE RLS POLICIES
-- ============================================

-- Enable RLS on discussion_replies table (if not already enabled)
ALTER TABLE discussion_replies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view replies for accessible discussions" ON discussion_replies;
DROP POLICY IF EXISTS "Students can create replies for open discussions" ON discussion_replies;
DROP POLICY IF EXISTS "Reply creators can update own replies" ON discussion_replies;
DROP POLICY IF EXISTS "Reply creators can delete own replies" ON discussion_replies;

-- Policy 1: Users can view replies for discussions they can access
CREATE POLICY "Users can view replies for accessible discussions" ON discussion_replies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM discussions d
      WHERE d.id = discussion_replies.discussion_id
      AND (
        -- Student enrolled in class
        EXISTS (
          SELECT 1 FROM class_enrollments ce
          WHERE ce.class_id = d.class_id 
          AND ce.user_id = auth.uid()
          AND ce.status = 'active'
        )
        OR
        -- Mentor of the class
        EXISTS (
          SELECT 1 FROM classes c
          WHERE c.id = d.class_id 
          AND c.tutor_id = auth.uid()
        )
      )
    )
  );

-- Policy 2: Students can create replies for open discussions in enrolled classes
-- Mentors CANNOT create replies
CREATE POLICY "Students can create replies for open discussions" ON discussion_replies
  FOR INSERT WITH CHECK (
    -- Discussion must be open
    EXISTS (
      SELECT 1 FROM discussions d
      WHERE d.id = discussion_replies.discussion_id
      AND d.is_closed = false
    )
    -- User must be enrolled in the class
    AND EXISTS (
      SELECT 1 FROM discussions d
      JOIN class_enrollments ce ON ce.class_id = d.class_id
      WHERE d.id = discussion_replies.discussion_id
      AND ce.user_id = auth.uid()
      AND ce.status = 'active'
    )
    -- User must have student role (not mentor)
    AND EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() 
      AND r.name = 'student'
    )
    -- created_by must be current user
    AND discussion_replies.created_by = auth.uid()
  );

-- Policy 3: Reply creators can update own replies
CREATE POLICY "Reply creators can update own replies" ON discussion_replies
  FOR UPDATE USING (
    auth.uid() = discussion_replies.created_by
  );

-- Policy 4: Reply creators can delete own replies
CREATE POLICY "Reply creators can delete own replies" ON discussion_replies
  FOR DELETE USING (
    auth.uid() = discussion_replies.created_by
  );

-- ============================================
-- 3. INDEXES FOR PERFORMANCE
-- ============================================

-- Index for discussions (if not exists)
CREATE INDEX IF NOT EXISTS idx_discussions_class_id ON discussions(class_id);
CREATE INDEX IF NOT EXISTS idx_discussions_created_by ON discussions(created_by);
CREATE INDEX IF NOT EXISTS idx_discussions_is_closed ON discussions(is_closed);
CREATE INDEX IF NOT EXISTS idx_discussions_created_at ON discussions(created_at DESC);

-- Index for discussion_replies (if not exists)
CREATE INDEX IF NOT EXISTS idx_discussion_replies_discussion_id ON discussion_replies(discussion_id);
CREATE INDEX IF NOT EXISTS idx_discussion_replies_parent_reply_id ON discussion_replies(parent_reply_id);
CREATE INDEX IF NOT EXISTS idx_discussion_replies_created_by ON discussion_replies(created_by);
CREATE INDEX IF NOT EXISTS idx_discussion_replies_created_at ON discussion_replies(created_at DESC);

-- ============================================
-- 4. HELPER FUNCTION FOR REPLY COUNT
-- ============================================

-- Function to get reply count for a discussion
CREATE OR REPLACE FUNCTION get_discussion_reply_count(discussion_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)::INTEGER 
    FROM discussion_replies 
    WHERE discussion_id = discussion_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. TRIGGER FOR UPDATED_AT
-- ============================================

-- Trigger for discussions updated_at (if not exists)
DROP TRIGGER IF EXISTS set_updated_at ON discussions;
CREATE TRIGGER set_updated_at 
  BEFORE UPDATE ON discussions
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for discussion_replies updated_at (if not exists)
DROP TRIGGER IF EXISTS set_updated_at ON discussion_replies;
CREATE TRIGGER set_updated_at 
  BEFORE UPDATE ON discussion_replies
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- SELESAI! RLS Policies untuk Forum Diskusi
-- ============================================
-- Langkah selanjutnya:
-- 1. Jalankan script ini di Supabase SQL Editor
-- 2. Test dengan user student (create discussion, reply)
-- 3. Test dengan user mentor (view only, moderate)
-- 4. Verify RLS policies bekerja dengan baik
-- ============================================
