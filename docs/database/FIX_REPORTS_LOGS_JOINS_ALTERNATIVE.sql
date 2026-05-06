-- ============================================================================
-- ALTERNATIVE FIX: REPORTS & ADMIN LOGS JOINS
-- Check existing foreign keys and create proper ones
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 1: CHECK EXISTING FOREIGN KEYS
-- ────────────────────────────────────────────────────────────────────────────

-- Check all foreign keys on reports table
SELECT 
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'reports';

-- Check all foreign keys on admin_logs table
SELECT 
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'admin_logs';

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 2: DROP ALL EXISTING FOREIGN KEYS (SAFE)
-- ────────────────────────────────────────────────────────────────────────────

-- Drop any existing foreign keys on reports table
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT constraint_name
        FROM information_schema.table_constraints
        WHERE table_name = 'reports'
        AND constraint_type = 'FOREIGN KEY'
    ) LOOP
        EXECUTE 'ALTER TABLE public.reports DROP CONSTRAINT IF EXISTS ' || r.constraint_name;
    END LOOP;
END $$;

-- Drop any existing foreign keys on admin_logs table
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT constraint_name
        FROM information_schema.table_constraints
        WHERE table_name = 'admin_logs'
        AND constraint_type = 'FOREIGN KEY'
    ) LOOP
        EXECUTE 'ALTER TABLE public.admin_logs DROP CONSTRAINT IF EXISTS ' || r.constraint_name;
    END LOOP;
END $$;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 3: CREATE NEW FOREIGN KEYS WITH EXPLICIT NAMES
-- ────────────────────────────────────────────────────────────────────────────

-- Reports table foreign keys
ALTER TABLE public.reports
ADD CONSTRAINT reports_reporter_id_fkey 
FOREIGN KEY (reporter_id) 
REFERENCES public.users(id) 
ON DELETE CASCADE;

ALTER TABLE public.reports
ADD CONSTRAINT reports_reviewed_by_fkey 
FOREIGN KEY (reviewed_by) 
REFERENCES public.users(id) 
ON DELETE SET NULL;

-- Admin logs table foreign key
ALTER TABLE public.admin_logs
ADD CONSTRAINT admin_logs_admin_id_fkey 
FOREIGN KEY (admin_id) 
REFERENCES public.users(id) 
ON DELETE CASCADE;

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 4: VERIFY NEW FOREIGN KEYS
-- ────────────────────────────────────────────────────────────────────────────

-- Should show: reports_reporter_id_fkey, reports_reviewed_by_fkey
SELECT constraint_name, column_name
FROM information_schema.key_column_usage
WHERE table_name = 'reports'
AND constraint_name LIKE '%_fkey';

-- Should show: admin_logs_admin_id_fkey
SELECT constraint_name, column_name
FROM information_schema.key_column_usage
WHERE table_name = 'admin_logs'
AND constraint_name LIKE '%_fkey';

-- ────────────────────────────────────────────────────────────────────────────
-- STEP 5: TEST JOINS (SHOULD WORK NOW)
-- ────────────────────────────────────────────────────────────────────────────

-- Test reports join
SELECT 
    r.id,
    r.reason,
    r.status,
    reporter.display_name as reporter_name,
    reviewer.display_name as reviewer_name
FROM public.reports r
LEFT JOIN public.users reporter ON r.reporter_id = reporter.id
LEFT JOIN public.users reviewer ON r.reviewed_by = reviewer.id
LIMIT 5;

-- Test admin_logs join
SELECT 
    al.id,
    al.action,
    admin.display_name as admin_name
FROM public.admin_logs al
LEFT JOIN public.users admin ON al.admin_id = admin.id
LIMIT 5;

-- ============================================================================
-- IMPORTANT NOTES:
-- 1. Run STEP 1 first to see existing foreign keys
-- 2. Run STEP 2 to drop all existing foreign keys safely
-- 3. Run STEP 3 to create new foreign keys with correct names
-- 4. Run STEP 4 to verify
-- 5. Run STEP 5 to test joins
-- 
-- After this, the Flutter app joins should work!
-- ============================================================================
