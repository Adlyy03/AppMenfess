-- ============================================================================
-- PRIORITAS 3: USER MANAGEMENT ENHANCEMENTS - SQL SETUP
-- Delete User Account & Test Ban with Duration
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. RPC FUNCTION: DELETE USER ACCOUNT (SUPER ADMIN ONLY)
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION admin_delete_user(
    target_user_id UUID,
    reason TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_admin_id UUID;
    v_admin_role TEXT;
    v_target_role TEXT;
    v_target_display_name TEXT;
BEGIN
    -- Get current user (admin)
    v_admin_id := auth.uid();
    
    -- Check if admin is super_admin
    SELECT role INTO v_admin_role
    FROM public.users
    WHERE id = v_admin_id;
    
    IF v_admin_role != 'super_admin' THEN
        RAISE EXCEPTION 'Unauthorized: Only super admins can delete user accounts';
    END IF;
    
    -- Check if admin is trying to delete themselves
    IF v_admin_id = target_user_id THEN
        RAISE EXCEPTION 'Cannot delete your own account';
    END IF;
    
    -- Get target user info
    SELECT role, display_name INTO v_target_role, v_target_display_name
    FROM public.users
    WHERE id = target_user_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Target user not found';
    END IF;
    
    -- Cannot delete other super_admin accounts
    IF v_target_role = 'super_admin' THEN
        RAISE EXCEPTION 'Cannot delete super admin accounts';
    END IF;
    
    -- Log admin action BEFORE deletion (so we still have user data)
    INSERT INTO public.admin_logs (
        admin_id,
        action,
        target_type,
        target_id,
        details
    ) VALUES (
        v_admin_id,
        'delete_user',
        'user',
        target_user_id,
        jsonb_build_object(
            'reason', reason,
            'target_display_name', v_target_display_name,
            'target_role', v_target_role
        )
    );
    
    -- Delete from public.users (will cascade to menfess, comments, reactions, etc.)
    DELETE FROM public.users WHERE id = target_user_id;
    
    -- Delete from auth.users (authentication account)
    DELETE FROM auth.users WHERE id = target_user_id;
    
    RAISE NOTICE 'User account deleted successfully: %', target_user_id;
END;
$$;

-- Grant execute permission to authenticated users (RLS will check role)
GRANT EXECUTE ON FUNCTION admin_delete_user(UUID, TEXT) TO authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. TEST BAN USER WITH DURATION
-- ────────────────────────────────────────────────────────────────────────────

-- Test Case 1: Ban user for 7 days
-- Replace 'user-uuid-here' with actual user ID from your database
/*
SELECT admin_ban_user(
    target_user_id := 'user-uuid-here',
    reason := 'Test ban for 7 days',
    expires_at := (NOW() + INTERVAL '7 days')::TEXT,
    notes := 'Testing temporary ban functionality'
);
*/

-- Test Case 2: Ban user for 1 hour (short duration for testing)
/*
SELECT admin_ban_user(
    target_user_id := 'user-uuid-here',
    reason := 'Test ban for 1 hour',
    expires_at := (NOW() + INTERVAL '1 hour')::TEXT,
    notes := 'Short duration test'
);
*/

-- Test Case 3: Ban user for 30 days
/*
SELECT admin_ban_user(
    target_user_id := 'user-uuid-here',
    reason := 'Test ban for 30 days',
    expires_at := (NOW() + INTERVAL '30 days')::TEXT,
    notes := 'Long duration test'
);
*/

-- Test Case 4: Permanent ban (no expiration)
/*
SELECT admin_ban_user(
    target_user_id := 'user-uuid-here',
    reason := 'Permanent ban test',
    expires_at := NULL,
    notes := 'Testing permanent ban'
);
*/

-- ────────────────────────────────────────────────────────────────────────────
-- 3. VERIFY BAN STATUS
-- ────────────────────────────────────────────────────────────────────────────

-- Check if user is banned
SELECT 
    u.id,
    u.display_name,
    u.is_banned,
    bu.reason,
    bu.expires_at,
    bu.notes,
    bu.banned_at,
    CASE 
        WHEN bu.expires_at IS NULL THEN 'Permanent'
        WHEN bu.expires_at > NOW() THEN 'Active (expires in ' || 
            EXTRACT(EPOCH FROM (bu.expires_at - NOW()))/3600 || ' hours)'
        ELSE 'Expired'
    END as ban_status
FROM public.users u
LEFT JOIN public.banned_users bu ON u.id = bu.user_id AND bu.is_active = true
WHERE u.is_banned = true
ORDER BY bu.banned_at DESC;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. AUTO-UNBAN EXPIRED BANS (OPTIONAL CRON JOB)
-- ────────────────────────────────────────────────────────────────────────────

-- Function to automatically unban users with expired bans
CREATE OR REPLACE FUNCTION auto_unban_expired_users()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_count INTEGER := 0;
    v_user RECORD;
BEGIN
    -- Find all users with expired bans
    FOR v_user IN
        SELECT DISTINCT bu.user_id
        FROM public.banned_users bu
        WHERE bu.is_active = true
        AND bu.expires_at IS NOT NULL
        AND bu.expires_at <= NOW()
    LOOP
        -- Unban the user
        UPDATE public.users
        SET is_banned = false
        WHERE id = v_user.user_id;
        
        -- Deactivate ban record
        UPDATE public.banned_users
        SET is_active = false
        WHERE user_id = v_user.user_id
        AND is_active = true;
        
        v_count := v_count + 1;
        
        RAISE NOTICE 'Auto-unbanned user: %', v_user.user_id;
    END LOOP;
    
    RETURN v_count;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION auto_unban_expired_users() TO authenticated;

-- To run manually:
-- SELECT auto_unban_expired_users();

-- To set up as cron job in Supabase:
-- Go to Database > Cron Jobs in Supabase Dashboard
-- Create new cron job:
-- Name: auto_unban_expired_users
-- Schedule: */5 * * * * (every 5 minutes)
-- Command: SELECT auto_unban_expired_users();

-- ────────────────────────────────────────────────────────────────────────────
-- 5. TESTING QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- Get all banned users with expiration info
SELECT 
    u.id,
    u.display_name,
    u.role,
    bu.reason,
    bu.expires_at,
    bu.banned_at,
    bu.banned_by,
    admin.display_name as banned_by_admin,
    CASE 
        WHEN bu.expires_at IS NULL THEN 'Permanent'
        WHEN bu.expires_at > NOW() THEN 
            'Expires in ' || 
            EXTRACT(DAY FROM (bu.expires_at - NOW())) || ' days ' ||
            EXTRACT(HOUR FROM (bu.expires_at - NOW())) || ' hours'
        ELSE 'Expired'
    END as time_remaining
FROM public.users u
INNER JOIN public.banned_users bu ON u.id = bu.user_id AND bu.is_active = true
LEFT JOIN public.users admin ON bu.banned_by = admin.id
WHERE u.is_banned = true
ORDER BY bu.banned_at DESC;

-- Get ban history for a specific user
/*
SELECT 
    bu.*,
    admin.display_name as banned_by_admin,
    unban_admin.display_name as unbanned_by_admin
FROM public.banned_users bu
LEFT JOIN public.users admin ON bu.banned_by = admin.id
LEFT JOIN public.users unban_admin ON bu.unbanned_by = unban_admin.id
WHERE bu.user_id = 'user-uuid-here'
ORDER BY bu.banned_at DESC;
*/

-- Count active bans by type
SELECT 
    CASE 
        WHEN expires_at IS NULL THEN 'Permanent'
        WHEN expires_at > NOW() THEN 'Temporary (Active)'
        ELSE 'Temporary (Expired)'
    END as ban_type,
    COUNT(*) as count
FROM public.banned_users
WHERE is_active = true
GROUP BY ban_type;

-- ────────────────────────────────────────────────────────────────────────────
-- 6. ADMIN LOGS FOR DELETE USER
-- ────────────────────────────────────────────────────────────────────────────

-- View all user deletion logs
SELECT 
    al.id,
    al.created_at,
    admin.display_name as admin_name,
    al.details->>'target_display_name' as deleted_user,
    al.details->>'target_role' as user_role,
    al.details->>'reason' as deletion_reason
FROM public.admin_logs al
LEFT JOIN public.users admin ON al.admin_id = admin.id
WHERE al.action = 'delete_user'
ORDER BY al.created_at DESC;

-- ────────────────────────────────────────────────────────────────────────────
-- 7. VERIFICATION QUERIES
-- ────────────────────────────────────────────────────────────────────────────

-- Check if admin_delete_user function exists
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'admin_delete_user';

-- Check if auto_unban_expired_users function exists
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name = 'auto_unban_expired_users';

-- Test ban expiration calculation
SELECT 
    NOW() as current_time,
    NOW() + INTERVAL '7 days' as expires_in_7_days,
    NOW() + INTERVAL '1 hour' as expires_in_1_hour,
    NOW() + INTERVAL '30 days' as expires_in_30_days;

-- ────────────────────────────────────────────────────────────────────────────
-- 8. CLEANUP (USE WITH CAUTION)
-- ────────────────────────────────────────────────────────────────────────────

-- Remove test bans
/*
UPDATE public.users
SET is_banned = false
WHERE id IN (
    SELECT user_id FROM public.banned_users
    WHERE notes LIKE '%test%' OR notes LIKE '%Test%'
);

UPDATE public.banned_users
SET is_active = false
WHERE notes LIKE '%test%' OR notes LIKE '%Test%';
*/

-- Drop functions (if needed)
/*
DROP FUNCTION IF EXISTS admin_delete_user(UUID, TEXT);
DROP FUNCTION IF EXISTS auto_unban_expired_users();
*/

-- ============================================================================
-- END OF SQL SETUP
-- ============================================================================

-- TESTING CHECKLIST:
-- [ ] 1. Create admin_delete_user function
-- [ ] 2. Test ban user with 1 hour duration
-- [ ] 3. Verify ban shows in banned_users table with expires_at
-- [ ] 4. Wait 1 hour or manually run auto_unban_expired_users()
-- [ ] 5. Verify user is automatically unbanned
-- [ ] 6. Test ban user with 7 days duration
-- [ ] 7. Test permanent ban (no expires_at)
-- [ ] 8. Test delete user account (super admin only)
-- [ ] 9. Verify user and all data are deleted
-- [ ] 10. Verify admin_logs contains delete_user entry

-- IMPORTANT NOTES:
-- 1. Delete user is PERMANENT and cannot be undone
-- 2. Only super_admin can delete user accounts
-- 3. Cannot delete own account or other super_admin accounts
-- 4. All user data (posts, comments, reactions) will be cascade deleted
-- 5. Ban with expires_at will auto-unban when time expires (if cron job is set up)
-- 6. Permanent bans have expires_at = NULL

-- STATUS: ✅ READY FOR TESTING
