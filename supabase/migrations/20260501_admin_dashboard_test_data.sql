-- ============================================================================
-- ADMIN DASHBOARD SYSTEM - TEST DATA
-- ============================================================================
-- This file contains sample data for testing the admin dashboard system.
-- WARNING: This is for testing purposes only. Do not run in production!
-- ============================================================================

-- ============================================================================
-- 1. CREATE TEST USERS WITH DIFFERENT ROLES
-- ============================================================================

-- Note: In a real scenario, users would be created through Supabase Auth.
-- This assumes you have existing users in auth.users table.
-- You'll need to replace these UUIDs with actual user IDs from your auth.users table.

-- Example: Update an existing user to be a super_admin
-- UPDATE public.users SET role = 'super_admin' WHERE id = 'YOUR_USER_ID_HERE';

-- Example: Update another user to be a moderator
-- UPDATE public.users SET role = 'moderator' WHERE id = 'ANOTHER_USER_ID_HERE';

-- ============================================================================
-- 2. CREATE SAMPLE REPORTS
-- ============================================================================

-- Note: Replace the UUIDs below with actual IDs from your database
-- This is just to show the structure

-- Example report for spam
-- INSERT INTO public.reports (
--     menfess_id,
--     reporter_id,
--     reason,
--     description,
--     status
-- ) VALUES (
--     'EXISTING_MENFESS_ID',
--     'EXISTING_USER_ID',
--     'spam',
--     'This post contains spam content',
--     'pending'
-- );

-- Example report for harassment
-- INSERT INTO public.reports (
--     menfess_id,
--     reporter_id,
--     reason,
--     description,
--     status
-- ) VALUES (
--     'ANOTHER_MENFESS_ID',
--     'ANOTHER_USER_ID',
--     'harassment',
--     'This post contains harassing language',
--     'pending'
-- );

-- ============================================================================
-- 3. TEST QUERIES TO VERIFY SCHEMA
-- ============================================================================

-- Check if role column was added to users table
-- SELECT id, display_name, role, is_banned, created_at FROM public.users LIMIT 5;

-- Check admin_stats view
-- SELECT * FROM public.admin_stats;

-- Check reports table structure
-- SELECT * FROM public.reports LIMIT 5;

-- Check banned_users table structure
-- SELECT * FROM public.banned_users LIMIT 5;

-- Check admin_logs table structure
-- SELECT * FROM public.admin_logs LIMIT 5;

-- ============================================================================
-- 4. TEST RPC FUNCTIONS (Run these as an admin user)
-- ============================================================================

-- Test admin_get_users function
-- SELECT * FROM admin_get_users(NULL, NULL);

-- Test admin_get_users with search
-- SELECT * FROM admin_get_users('test', NULL);

-- Test admin_get_users with role filter
-- SELECT * FROM admin_get_users(NULL, 'user');

-- ============================================================================
-- 5. VERIFY INDEXES
-- ============================================================================

-- Check if indexes were created
-- SELECT indexname, tablename FROM pg_indexes 
-- WHERE tablename IN ('users', 'reports', 'banned_users', 'admin_logs')
-- ORDER BY tablename, indexname;

-- ============================================================================
-- 6. VERIFY RLS POLICIES
-- ============================================================================

-- Check RLS policies on reports table
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'reports';

-- Check RLS policies on banned_users table
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'banned_users';

-- Check RLS policies on admin_logs table
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'admin_logs';

-- ============================================================================
-- 7. MANUAL TESTING STEPS
-- ============================================================================

-- Step 1: Create a super_admin user
-- UPDATE public.users SET role = 'super_admin' WHERE id = 'YOUR_USER_ID';

-- Step 2: Test creating a report (as a regular user)
-- INSERT INTO public.reports (menfess_id, reporter_id, reason, description)
-- VALUES ('MENFESS_ID', auth.uid(), 'spam', 'Test report');

-- Step 3: Test resolving a report (as admin)
-- SELECT admin_resolve_report('REPORT_ID', 'Resolved: Content removed');

-- Step 4: Test banning a user (as admin)
-- SELECT admin_ban_user('USER_ID', 'Violation of terms', NULL, 'First offense');

-- Step 5: Test unbanning a user (as admin)
-- SELECT admin_unban_user('USER_ID');

-- Step 6: Test changing user role (as super_admin)
-- SELECT admin_change_role('USER_ID', 'moderator');

-- Step 7: Test deleting a menfess (as admin)
-- SELECT admin_delete_menfess('MENFESS_ID', 'Inappropriate content');

-- Step 8: Verify admin logs were created
-- SELECT * FROM public.admin_logs ORDER BY created_at DESC LIMIT 10;

-- ============================================================================
-- 8. CLEANUP (if needed)
-- ============================================================================

-- To remove test data (use with caution):
-- DELETE FROM public.reports WHERE description LIKE 'Test%';
-- DELETE FROM public.banned_users WHERE notes LIKE 'Test%';
-- DELETE FROM public.admin_logs WHERE details->>'reason' LIKE 'Test%';

-- To reset user roles to default:
-- UPDATE public.users SET role = 'user' WHERE role IN ('moderator', 'super_admin');

-- ============================================================================
-- TESTING CHECKLIST
-- ============================================================================

-- [ ] Users table has role, is_banned, and last_login_at columns
-- [ ] Reports table exists with proper structure
-- [ ] Banned_users table exists with proper structure
-- [ ] Admin_logs table exists with proper structure
-- [ ] Admin_stats view returns data
-- [ ] All indexes are created
-- [ ] All RLS policies are in place
-- [ ] admin_delete_menfess function works
-- [ ] admin_ban_user function works
-- [ ] admin_unban_user function works
-- [ ] admin_change_role function works
-- [ ] admin_resolve_report function works
-- [ ] admin_dismiss_report function works
-- [ ] admin_get_users function works
-- [ ] Realtime is enabled for admin tables
-- [ ] Admin actions are logged correctly
-- [ ] Permission checks work (non-admins cannot access admin functions)

-- ============================================================================
-- END OF TEST DATA FILE
-- ============================================================================
