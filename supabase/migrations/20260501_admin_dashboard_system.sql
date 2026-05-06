-- ============================================================================
-- ADMIN DASHBOARD SYSTEM MIGRATION
-- ============================================================================
-- This migration adds comprehensive administrative capabilities including:
-- - Role-based access control (user, moderator, super_admin)
-- - Content moderation (reports, banned users)
-- - Admin audit logging
-- - Dashboard statistics view
-- - RPC functions for admin actions
-- ============================================================================

-- ============================================================================
-- 1. ENHANCE USERS TABLE WITH ADMIN ROLES
-- ============================================================================

-- Add role column to existing users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'moderator', 'super_admin'));

-- Add banned status
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT FALSE;

-- Add metadata
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

-- Create indexes for role queries
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_banned ON public.users(is_banned);

-- ============================================================================
-- 2. REPORTS TABLE
-- ============================================================================

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

-- Ensure columns exist if table was already created manually without them
ALTER TABLE public.reports 
ADD COLUMN IF NOT EXISTS menfess_id UUID REFERENCES public.menfess(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS reporter_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS reason TEXT,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS resolution_note TEXT,
ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

-- Indexes for reports
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_menfess ON public.reports(menfess_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON public.reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_created ON public.reports(created_at DESC);

-- Enable RLS on reports
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reports
DROP POLICY IF EXISTS "Users can create reports" ON public.reports;
CREATE POLICY "Users can create reports"
ON public.reports FOR INSERT
WITH CHECK (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Users can view own reports" ON public.reports;
CREATE POLICY "Users can view own reports"
ON public.reports FOR SELECT
USING (auth.uid() = reporter_id);

DROP POLICY IF EXISTS "Admins can view all reports" ON public.reports;
CREATE POLICY "Admins can view all reports"
ON public.reports FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

DROP POLICY IF EXISTS "Admins can update reports" ON public.reports;
CREATE POLICY "Admins can update reports"
ON public.reports FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

-- ============================================================================
-- 3. BANNED USERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.banned_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    banned_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    banned_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ, -- NULL means permanent ban
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    UNIQUE(user_id, is_active)
);

-- Indexes for banned_users
CREATE INDEX IF NOT EXISTS idx_banned_users_user ON public.banned_users(user_id);
CREATE INDEX IF NOT EXISTS idx_banned_users_active ON public.banned_users(is_active);
CREATE INDEX IF NOT EXISTS idx_banned_users_expires ON public.banned_users(expires_at);

-- Enable RLS on banned_users
ALTER TABLE public.banned_users ENABLE ROW LEVEL SECURITY;

-- RLS Policies for banned_users
DROP POLICY IF EXISTS "Admins can view bans" ON public.banned_users;
CREATE POLICY "Admins can view bans"
ON public.banned_users FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

DROP POLICY IF EXISTS "Admins can create bans" ON public.banned_users;
CREATE POLICY "Admins can create bans"
ON public.banned_users FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

DROP POLICY IF EXISTS "Admins can update bans" ON public.banned_users;
CREATE POLICY "Admins can update bans"
ON public.banned_users FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

-- ============================================================================
-- 4. ADMIN LOGS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN (
        'delete_menfess', 'ban_user', 'unban_user', 'change_role', 
        'resolve_report', 'dismiss_report', 'delete_comment'
    )),
    target_type TEXT NOT NULL CHECK (target_type IN ('menfess', 'user', 'comment', 'report')),
    target_id UUID NOT NULL,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for admin_logs
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin ON public.admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON public.admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created ON public.admin_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_logs_target ON public.admin_logs(target_type, target_id);

-- Enable RLS on admin_logs
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for admin_logs
DROP POLICY IF EXISTS "Admins can view logs" ON public.admin_logs;
CREATE POLICY "Admins can view logs"
ON public.admin_logs FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() 
        AND role IN ('moderator', 'super_admin')
    )
);

DROP POLICY IF EXISTS "System can insert logs" ON public.admin_logs;
CREATE POLICY "System can insert logs"
ON public.admin_logs FOR INSERT
WITH CHECK (true);

-- ============================================================================
-- 5. ADMIN STATS MATERIALIZED VIEW
-- ============================================================================

-- Drop existing view if it exists
DROP VIEW IF EXISTS public.admin_stats;

-- Create view for dashboard statistics
CREATE OR REPLACE VIEW public.admin_stats AS
SELECT
    -- User stats
    (SELECT COUNT(*) FROM auth.users) AS total_users,
    (SELECT COUNT(*) FROM auth.users WHERE created_at >= NOW() - INTERVAL '24 hours') AS users_today,
    (SELECT COUNT(*) FROM auth.users WHERE created_at >= NOW() - INTERVAL '7 days') AS users_this_week,
    (SELECT COUNT(*) FROM public.users WHERE last_login_at >= NOW() - INTERVAL '24 hours') AS active_users_today,
    (SELECT COUNT(*) FROM public.users WHERE is_banned = TRUE) AS banned_users_count,
    
    -- Menfess stats
    (SELECT COUNT(*) FROM public.menfess) AS total_menfess,
    (SELECT COUNT(*) FROM public.menfess WHERE created_at >= NOW() - INTERVAL '24 hours') AS menfess_today,
    (SELECT COUNT(*) FROM public.menfess WHERE created_at >= NOW() - INTERVAL '7 days') AS menfess_this_week,
    
    -- Engagement stats
    (SELECT COUNT(*) FROM public.reactions) AS total_reactions,
    (SELECT COUNT(*) FROM public.reactions WHERE created_at >= NOW() - INTERVAL '24 hours') AS reactions_today,
    (SELECT COUNT(*) FROM public.comments) AS total_comments,
    (SELECT COUNT(*) FROM public.comments WHERE created_at >= NOW() - INTERVAL '24 hours') AS comments_today,
    
    -- Report stats
    (SELECT COUNT(*) FROM public.reports WHERE status = 'pending') AS pending_reports,
    (SELECT COUNT(*) FROM public.reports WHERE status = 'reviewing') AS reviewing_reports,
    (SELECT COUNT(*) FROM public.reports WHERE created_at >= NOW() - INTERVAL '24 hours') AS reports_today,
    
    -- Admin activity
    (SELECT COUNT(*) FROM public.admin_logs WHERE created_at >= NOW() - INTERVAL '24 hours') AS admin_actions_today;

-- Grant access to authenticated users (RLS will control who can actually see it)
GRANT SELECT ON public.admin_stats TO authenticated;

-- ============================================================================
-- 6. RPC FUNCTION: admin_delete_menfess
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_delete_menfess(
  menfess_id UUID,
  reason TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Delete the menfess (cascade will handle related data)
  DELETE FROM public.menfess WHERE id = menfess_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 
    'delete_menfess', 
    'menfess', 
    menfess_id,
    jsonb_build_object('reason', reason)
  );
END;
$$;

-- ============================================================================
-- 7. RPC FUNCTION: admin_ban_user
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_ban_user(
  target_user_id UUID,
  reason TEXT,
  expires_at TIMESTAMPTZ DEFAULT NULL,
  notes TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
  target_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Get target user role
  SELECT role INTO target_role FROM public.users WHERE id = target_user_id;
  
  -- Super admin protection
  IF target_role = 'super_admin' AND admin_role != 'super_admin' THEN
    RAISE EXCEPTION 'Unauthorized: Cannot ban super admin';
  END IF;
  
  -- Cannot ban self
  IF target_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Cannot ban yourself';
  END IF;
  
  -- Check if already banned
  IF EXISTS (
    SELECT 1 FROM public.banned_users 
    WHERE user_id = target_user_id AND is_active = TRUE
  ) THEN
    RAISE EXCEPTION 'User is already banned';
  END IF;
  
  -- Create ban record
  INSERT INTO public.banned_users (
    user_id, banned_by, reason, banned_at, expires_at, is_active, notes
  ) VALUES (
    target_user_id, auth.uid(), reason, NOW(), expires_at, TRUE, notes
  );
  
  -- Update user status
  UPDATE public.users SET is_banned = TRUE WHERE id = target_user_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 
    'ban_user', 
    'user', 
    target_user_id,
    jsonb_build_object(
      'reason', reason,
      'expires_at', expires_at,
      'permanent', expires_at IS NULL
    )
  );
END;
$$;

-- ============================================================================
-- 8. RPC FUNCTION: admin_unban_user
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_unban_user(
  target_user_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Deactivate ban record
  UPDATE public.banned_users 
  SET is_active = FALSE 
  WHERE user_id = target_user_id AND is_active = TRUE;
  
  -- Update user status
  UPDATE public.users SET is_banned = FALSE WHERE id = target_user_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 'unban_user', 'user', target_user_id, NULL
  );
END;
$$;

-- ============================================================================
-- 9. RPC FUNCTION: admin_change_role
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_change_role(
  target_user_id UUID,
  new_role TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is super admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role != 'super_admin' THEN
    RAISE EXCEPTION 'Unauthorized: Super admin access required';
  END IF;
  
  -- Cannot change own role
  IF target_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Cannot change your own role';
  END IF;
  
  -- Validate new role
  IF new_role NOT IN ('user', 'moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Invalid role: %', new_role;
  END IF;
  
  -- Update user role
  UPDATE public.users SET role = new_role WHERE id = target_user_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 
    'change_role', 
    'user', 
    target_user_id,
    jsonb_build_object('new_role', new_role)
  );
END;
$$;

-- ============================================================================
-- 10. RPC FUNCTION: admin_resolve_report
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_resolve_report(
  report_id UUID,
  resolution_note TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Update report
  UPDATE public.reports 
  SET 
    status = 'resolved',
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    resolution_note = resolution_note,
    updated_at = NOW()
  WHERE id = report_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 
    'resolve_report', 
    'report', 
    report_id,
    jsonb_build_object('resolution_note', resolution_note)
  );
END;
$$;

-- ============================================================================
-- 11. RPC FUNCTION: admin_dismiss_report
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_dismiss_report(
  report_id UUID
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT role INTO admin_role FROM public.users WHERE id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  -- Update report
  UPDATE public.reports 
  SET 
    status = 'dismissed',
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    updated_at = NOW()
  WHERE id = report_id;
  
  -- Log the action
  INSERT INTO public.admin_logs (
    admin_id, action, target_type, target_id, details
  ) VALUES (
    auth.uid(), 'dismiss_report', 'report', report_id, NULL
  );
END;
$$;

-- ============================================================================
-- 12. RPC FUNCTION: admin_get_users
-- ============================================================================

CREATE OR REPLACE FUNCTION admin_get_users(
  search_query TEXT DEFAULT NULL,
  role_filter TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  display_name TEXT,
  role TEXT,
  is_banned BOOLEAN,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  menfess_count BIGINT,
  comments_count BIGINT,
  reactions_count BIGINT,
  reports_received BIGINT,
  reports_made BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  admin_role TEXT;
BEGIN
  -- Check if caller is admin
  SELECT u.role INTO admin_role FROM public.users u WHERE u.id = auth.uid();
  
  IF admin_role NOT IN ('moderator', 'super_admin') THEN
    RAISE EXCEPTION 'Unauthorized: Admin access required';
  END IF;
  
  RETURN QUERY
  SELECT 
    u.id,
    u.display_name,
    u.role,
    u.is_banned,
    u.last_login_at,
    u.created_at,
    COUNT(DISTINCT m.id) AS menfess_count,
    COUNT(DISTINCT c.id) AS comments_count,
    COUNT(DISTINCT r.id) AS reactions_count,
    COUNT(DISTINCT rep_received.id) AS reports_received,
    COUNT(DISTINCT rep_made.id) AS reports_made
  FROM public.users u
  LEFT JOIN public.menfess m ON m.user_id = u.id
  LEFT JOIN public.comments c ON c.user_id = u.id
  LEFT JOIN public.reactions r ON r.user_id = u.id
  LEFT JOIN public.reports rep_received ON rep_received.menfess_id IN (
    SELECT id FROM public.menfess WHERE user_id = u.id
  )
  LEFT JOIN public.reports rep_made ON rep_made.reporter_id = u.id
  WHERE 
    (search_query IS NULL OR u.display_name ILIKE '%' || search_query || '%')
    AND (role_filter IS NULL OR u.role = role_filter)
  GROUP BY u.id, u.display_name, u.role, u.is_banned, u.last_login_at, u.created_at
  ORDER BY u.created_at DESC;
END;
$$;

-- ============================================================================
-- 13. ENABLE REALTIME FOR ADMIN TABLES
-- ============================================================================

-- Enable realtime for reports table
ALTER PUBLICATION supabase_realtime ADD TABLE public.reports;

-- Enable realtime for admin_logs table
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_logs;

-- Enable realtime for banned_users table
ALTER PUBLICATION supabase_realtime ADD TABLE public.banned_users;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- The admin dashboard system is now ready to use.
-- Next steps:
-- 1. Create a super_admin user by manually updating a user's role in the database
-- 2. Test the RPC functions with sample data
-- 3. Implement the Flutter UI components
-- ============================================================================
