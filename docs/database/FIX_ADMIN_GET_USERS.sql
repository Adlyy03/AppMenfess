-- ============================================================================
-- FIX: admin_get_users - Ambiguous "id" column reference
-- ============================================================================
-- Error: column reference "id" is ambiguous
-- Fix: Use explicit table alias in subquery
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
    u.created_at::TIMESTAMPTZ,
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
    SELECT m2.id FROM public.menfess m2 WHERE m2.user_id = u.id
  )
  LEFT JOIN public.reports rep_made ON rep_made.reporter_id = u.id
  WHERE 
    (search_query IS NULL OR u.display_name ILIKE '%' || search_query || '%')
    AND (role_filter IS NULL OR u.role = role_filter)
  GROUP BY u.id, u.display_name, u.role, u.is_banned, u.last_login_at, u.created_at
  ORDER BY u.created_at DESC;
END;
$$;




















PRIORITAS 2: Fitur Baru (Quick Actions)
✅ Bikin screen Reports Management
✅ Bikin screen Audit Logs


PRIORITAS 3: Enhance User Management
✅ Tambah Delete User Account function
✅ Test Ban User dengan durasi