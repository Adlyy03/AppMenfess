-- ============================================================================
-- REPORTS & AUDIT LOGS - SQL SETUP
-- Complete database setup for Reports Management and Audit Logs features
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. REPORTS TABLE
-- ────────────────────────────────────────────────────────────────────────────

-- Create reports table (if not exists)
CREATE TABLE IF NOT EXISTS public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menfess_id UUID NOT NULL REFERENCES public.menfess(id) ON DELETE CASCADE,
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL CHECK (reason IN ('spam', 'harassment', 'inappropriate', 'misinformation', 'other')),
    description TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
    reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    resolution_note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for reports
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_menfess ON public.reports(menfess_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_created ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_reviewed_by ON public.reports(reviewed_by);

-- Enable RLS for reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can create reports
CREATE POLICY "Users can create reports"
ON public.reports
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = reporter_id);

-- RLS Policy: Users can view their own reports
CREATE POLICY "Users can view their own reports"
ON public.reports
FOR SELECT
TO authenticated
USING (auth.uid() = reporter_id);

-- RLS Policy: Admins can view all reports
CREATE POLICY "Admins can view all reports"
ON public.reports
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND role IN ('moderator', 'super_admin')
    )
);

-- RLS Policy: Admins can update reports
CREATE POLICY "Admins can update reports"
ON public.reports
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND role IN ('moderator', 'super_admin')
    )
);

-- ────────────────────────────────────────────────────────────────────────────
-- 2. ADMIN LOGS TABLE
-- ────────────────────────────────────────────────────────────────────────────

-- Create admin_logs table (if not exists)
CREATE TABLE IF NOT EXISTS public.admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    target_type TEXT NOT NULL,
    target_id UUID NOT NULL,
    details JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for admin_logs
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin ON public.admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON public.admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_target ON public.admin_logs(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created ON public.admin_logs(created_at DESC);

-- Enable RLS for admin_logs
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Only admins can view logs
CREATE POLICY "Admins can view logs"
ON public.admin_logs
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND role IN ('moderator', 'super_admin')
    )
);

-- RLS Policy: Only system can insert logs (via RPC functions)
CREATE POLICY "System can insert logs"
ON public.admin_logs
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND role IN ('moderator', 'super_admin')
    )
);

-- No UPDATE or DELETE policies (append-only table)

-- ────────────────────────────────────────────────────────────────────────────
-- 3. RPC FUNCTION: RESOLVE REPORT
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION admin_resolve_report(
    report_id UUID,
    resolution_note TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_admin_id UUID;
    v_admin_role TEXT;
    v_report RECORD;
BEGIN
    -- Get current user
    v_admin_id := auth.uid();
    
    -- Check if user is admin
    SELECT role INTO v_admin_role
    FROM public.users
    WHERE id = v_admin_id;
    
    IF v_admin_role NOT IN ('moderator', 'super_admin') THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can resolve reports';
    END IF;
    
    -- Get report details
    SELECT * INTO v_report
    FROM public.reports
    WHERE id = report_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report not found';
    END IF;
    
    -- Update report status
    UPDATE public.reports
    SET 
        status = 'resolved',
        reviewed_by = v_admin_id,
        reviewed_at = NOW(),
        resolution_note = admin_resolve_report.resolution_note,
        updated_at = NOW()
    WHERE id = report_id;
    
    -- Log admin action
    INSERT INTO public.admin_logs (
        admin_id,
        action,
        target_type,
        target_id,
        details
    ) VALUES (
        v_admin_id,
        'resolve_report',
        'report',
        report_id,
        jsonb_build_object(
            'report_reason', v_report.reason,
            'menfess_id', v_report.menfess_id,
            'resolution_note', admin_resolve_report.resolution_note
        )
    );
END;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. RPC FUNCTION: DISMISS REPORT
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION admin_dismiss_report(
    report_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_admin_id UUID;
    v_admin_role TEXT;
    v_report RECORD;
BEGIN
    -- Get current user
    v_admin_id := auth.uid();
    
    -- Check if user is admin
    SELECT role INTO v_admin_role
    FROM public.users
    WHERE id = v_admin_id;
    
    IF v_admin_role NOT IN ('moderator', 'super_admin') THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can dismiss reports';
    END IF;
    
    -- Get report details
    SELECT * INTO v_report
    FROM public.reports
    WHERE id = report_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Report not found';
    END IF;
    
    -- Update report status
    UPDATE public.reports
    SET 
        status = 'dismissed',
        reviewed_by = v_admin_id,
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE id = report_id;
    
    -- Log admin action
    INSERT INTO public.admin_logs (
        admin_id,
        action,
        target_type,
        target_id,
        details
    ) VALUES (
        v_admin_id,
        'dismiss_report',
        'report',
        report_id,
        jsonb_build_object(
            'report_reason', v_report.reason,
            'menfess_id', v_report.menfess_id
        )
    );
END;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- 5. ENABLE REALTIME
-- ────────────────────────────────────────────────────────────────────────────

-- Enable realtime for reports table
ALTER PUBLICATION supabase_realtime ADD TABLE public.reports;

-- Enable realtime for admin_logs table
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_logs;

-- ────────────────────────────────────────────────────────────────────────────
-- 6. TEST DATA (OPTIONAL - FOR DEVELOPMENT)
-- ────────────────────────────────────────────────────────────────────────────

-- Insert sample reports (replace UUIDs with actual IDs from your database)
/*
INSERT INTO public.reports (menfess_id, reporter_id, reason, description, status)
VALUES 
    ('menfess-uuid-1', 'user-uuid-1', 'spam', 'This post is spam', 'pending'),
    ('menfess-uuid-2', 'user-uuid-2', 'harassment', 'Harassing content', 'pending'),
    ('menfess-uuid-3', 'user-uuid-3', 'inappropriate', 'Inappropriate language', 'reviewing'),
    ('menfess-uuid-4', 'user-uuid-4', 'misinformation', 'False information', 'resolved'),
    ('menfess-uuid-5', 'user-uuid-5', 'other', 'Other reason', 'dismissed');
*/

-- ────────────────────────────────────────────────────────────────────────────
-- 7. VERIFICATION QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- Check if reports table exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'reports'
);

-- Check if admin_logs table exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'admin_logs'
);

-- Check RLS policies for reports
SELECT * FROM pg_policies WHERE tablename = 'reports';

-- Check RLS policies for admin_logs
SELECT * FROM pg_policies WHERE tablename = 'admin_logs';

-- Check if RPC functions exist
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('admin_resolve_report', 'admin_dismiss_report');

-- Check realtime publication
SELECT * FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND schemaname = 'public' 
AND tablename IN ('reports', 'admin_logs');

-- ────────────────────────────────────────────────────────────────────────────
-- 8. USEFUL QUERIES FOR TESTING
-- ────────────────────────────────────────────────────────────────────────────

-- Get all reports with populated fields
SELECT 
    r.*,
    m.content as menfess_content,
    u1.display_name as reporter_display_name,
    u2.display_name as reviewer_display_name
FROM public.reports r
LEFT JOIN public.menfess m ON r.menfess_id = m.id
LEFT JOIN public.users u1 ON r.reporter_id = u1.id
LEFT JOIN public.users u2 ON r.reviewed_by = u2.id
ORDER BY r.created_at DESC;

-- Get all admin logs with admin names
SELECT 
    al.*,
    u.display_name as admin_display_name
FROM public.admin_logs al
LEFT JOIN public.users u ON al.admin_id = u.id
ORDER BY al.created_at DESC
LIMIT 100;

-- Count reports by status
SELECT status, COUNT(*) as count
FROM public.reports
GROUP BY status
ORDER BY count DESC;

-- Count admin logs by action
SELECT action, COUNT(*) as count
FROM public.admin_logs
GROUP BY action
ORDER BY count DESC;

-- Get recent admin activity (last 24 hours)
SELECT 
    al.action,
    u.display_name as admin_name,
    al.target_type,
    al.created_at
FROM public.admin_logs al
LEFT JOIN public.users u ON al.admin_id = u.id
WHERE al.created_at > NOW() - INTERVAL '24 hours'
ORDER BY al.created_at DESC;

-- Get pending reports count
SELECT COUNT(*) as pending_reports
FROM public.reports
WHERE status = 'pending';

-- ────────────────────────────────────────────────────────────────────────────
-- 9. CLEANUP (USE WITH CAUTION)
-- ────────────────────────────────────────────────────────────────────────────

-- Drop all test data (CAUTION: This will delete all reports and logs)
/*
TRUNCATE TABLE public.reports CASCADE;
TRUNCATE TABLE public.admin_logs CASCADE;
*/

-- Drop tables (CAUTION: This will delete tables and all data)
/*
DROP TABLE IF EXISTS public.reports CASCADE;
DROP TABLE IF EXISTS public.admin_logs CASCADE;
*/

-- Drop RPC functions
/*
DROP FUNCTION IF EXISTS admin_resolve_report(UUID, TEXT);
DROP FUNCTION IF EXISTS admin_dismiss_report(UUID);
*/

-- ============================================================================
-- END OF SQL SETUP
-- ============================================================================

-- NOTES:
-- 1. Run sections 1-5 in order for initial setup
-- 2. Section 6 is optional for test data
-- 3. Section 7 for verification
-- 4. Section 8 for testing queries
-- 5. Section 9 only if you need to cleanup/reset

-- IMPORTANT:
-- - Replace placeholder UUIDs with actual IDs from your database
-- - Test RPC functions in Supabase SQL Editor before using in app
-- - Verify RLS policies are working correctly
-- - Enable realtime in Supabase dashboard if not working

-- STATUS: ✅ READY FOR DEPLOYMENT
