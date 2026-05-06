-- ============================================================================
-- FIX REPORTS & ADMIN LOGS FOREIGN KEY NAMES
-- Fix foreign key constraint names for proper Supabase joins
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. FIX REPORTS TABLE FOREIGN KEYS
-- ────────────────────────────────────────────────────────────────────────────

-- Drop existing foreign keys if they exist
ALTER TABLE public.reports 
DROP CONSTRAINT IF EXISTS reports_reporter_id_fkey;

ALTER TABLE public.reports 
DROP CONSTRAINT IF EXISTS reports_reviewed_by_fkey;

-- Add foreign keys with explicit names
ALTER TABLE public.reports
ADD CONSTRAINT reports_reporter_id_fkey 
FOREIGN KEY (reporter_id) 
REFERENCES auth.users(id) 
ON DELETE CASCADE;

ALTER TABLE public.reports
ADD CONSTRAINT reports_reviewed_by_fkey 
FOREIGN KEY (reviewed_by) 
REFERENCES auth.users(id) 
ON DELETE SET NULL;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. FIX ADMIN LOGS TABLE FOREIGN KEYS
-- ────────────────────────────────────────────────────────────────────────────

-- Drop existing foreign key if it exists
ALTER TABLE public.admin_logs 
DROP CONSTRAINT IF EXISTS admin_logs_admin_id_fkey;

-- Add foreign key with explicit name
ALTER TABLE public.admin_logs
ADD CONSTRAINT admin_logs_admin_id_fkey 
FOREIGN KEY (admin_id) 
REFERENCES auth.users(id) 
ON DELETE CASCADE;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. VERIFICATION
-- ────────────────────────────────────────────────────────────────────────────

-- Check reports foreign keys
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'reports'
ORDER BY tc.constraint_name;

-- Check admin_logs foreign keys
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'admin_logs'
ORDER BY tc.constraint_name;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. TEST QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- Test reports join (should work now)
SELECT 
    r.*,
    reporter.display_name as reporter_display_name,
    reviewer.display_name as reviewer_display_name
FROM public.reports r
LEFT JOIN public.users reporter ON r.reporter_id = reporter.id
LEFT JOIN public.users reviewer ON r.reviewed_by = reviewer.id
LIMIT 5;

-- Test admin_logs join (should work now)
SELECT 
    al.*,
    admin.display_name as admin_display_name
FROM public.admin_logs al
LEFT JOIN public.users admin ON al.admin_id = admin.id
LIMIT 5;

-- ============================================================================
-- EXPECTED RESULTS:
-- - reports_reporter_id_fkey should exist
-- - reports_reviewed_by_fkey should exist
-- - admin_logs_admin_id_fkey should exist
-- - Test queries should return data with joined display names
-- ============================================================================

-- STATUS: ✅ READY TO RUN
