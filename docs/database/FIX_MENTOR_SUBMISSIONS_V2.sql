-- =====================================================
-- FIX V2: Mentor Cannot View Student Submissions
-- =====================================================
-- Solusi: Buat RPC Function yang bypass RLS

-- =====================================================
-- STEP 1: Create RPC Function to get submissions
-- =====================================================
CREATE OR REPLACE FUNCTION get_assignment_submissions(p_assignment_id UUID)
RETURNS TABLE (
  id UUID,
  assignment_id UUID,
  user_id UUID,
  content TEXT,
  attachment_url TEXT,
  status TEXT,
  submitted_at TIMESTAMPTZ,
  score DECIMAL(5,2),
  feedback TEXT,
  graded_at TIMESTAMPTZ,
  graded_by UUID,
  student_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.assignment_id,
    s.user_id,
    s.content,
    s.attachment_url,
    s.status,
    s.submitted_at,
    s.score,
    s.feedback,
    s.graded_at,
    s.graded_by,
    p.full_name as student_name
  FROM assignment_submissions s
  LEFT JOIN profiles p ON s.user_id = p.id
  WHERE s.assignment_id = p_assignment_id
  ORDER BY s.submitted_at DESC;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_assignment_submissions(UUID) TO authenticated;

-- =====================================================
-- STEP 2: Create RPC Function to grade submission
-- =====================================================
CREATE OR REPLACE FUNCTION grade_submission(
  p_submission_id UUID,
  p_score DECIMAL(5,2),
  p_feedback TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE assignment_submissions
  SET 
    score = p_score,
    feedback = p_feedback,
    status = 'graded',
    graded_at = NOW(),
    graded_by = auth.uid()
  WHERE id = p_submission_id;
  
  RETURN FOUND;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION grade_submission(UUID, DECIMAL, TEXT) TO authenticated;

-- =====================================================
-- DONE! 
-- =====================================================
-- Setelah menjalankan script ini, aplikasi akan menggunakan
-- RPC function untuk mengambil dan menilai submissions

-- =====================================================
-- STEP 3: Add DELETE policy for students
-- =====================================================
DROP POLICY IF EXISTS "Students can delete own submissions" ON assignment_submissions;

CREATE POLICY "Students can delete own submissions" ON assignment_submissions
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id AND status IN ('draft', 'submitted', 'late'));

-- =====================================================
-- STEP 4: Fix UPDATE policy for students (allow update even after graded for resubmission)
-- =====================================================
DROP POLICY IF EXISTS "Students can update own submissions" ON assignment_submissions;

CREATE POLICY "Students can update own submissions" ON assignment_submissions
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id AND status IN ('draft', 'submitted', 'late'))
  WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- UPDATED! 
-- =====================================================
-- Siswa sekarang bisa:
-- 1. Menghapus pengajuan yang belum dinilai
-- 2. Mengupdate pengajuan yang belum dinilai
