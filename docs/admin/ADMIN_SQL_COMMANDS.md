# 🔧 ADMIN SQL COMMANDS - QUICK REFERENCE

Command SQL yang sering dipake untuk manage admin dashboard.

---

## 👑 ROLE MANAGEMENT

### Lihat Semua User dengan Role
```sql
SELECT 
  id, 
  display_name, 
  email, 
  role, 
  is_banned,
  created_at
FROM auth.users au
JOIN public.users pu ON au.id = pu.id
ORDER BY created_at DESC;
```

### Jadikan User Jadi Super Admin
```sql
UPDATE public.users 
SET role = 'super_admin' 
WHERE id = 'USER_ID_HERE';
```

### Jadikan User Jadi Moderator
```sql
UPDATE public.users 
SET role = 'moderator' 
WHERE id = 'USER_ID_HERE';
```

### Downgrade Admin Jadi User Biasa
```sql
UPDATE public.users 
SET role = 'user' 
WHERE id = 'USER_ID_HERE';
```

### Lihat Semua Admin (Moderator + Super Admin)
```sql
SELECT 
  id, 
  display_name, 
  role,
  created_at
FROM public.users 
WHERE role IN ('moderator', 'super_admin')
ORDER BY role DESC, created_at DESC;
```

---

## 🚫 BAN MANAGEMENT

### Lihat Semua User yang Di-ban
```sql
SELECT 
  u.id,
  u.display_name,
  u.is_banned,
  bu.reason,
  bu.banned_at,
  bu.expires_at,
  bu.is_active,
  admin.display_name as banned_by
FROM public.users u
JOIN public.banned_users bu ON u.id = bu.user_id
JOIN public.users admin ON bu.banned_by = admin.id
WHERE bu.is_active = TRUE
ORDER BY bu.banned_at DESC;
```

### Ban User Secara Manual (Permanent)
```sql
-- Step 1: Insert ban record
INSERT INTO public.banned_users (
  user_id, 
  banned_by, 
  reason, 
  banned_at, 
  expires_at, 
  is_active
) VALUES (
  'USER_ID_TO_BAN',
  'YOUR_ADMIN_ID',
  'Reason for ban',
  NOW(),
  NULL, -- NULL = permanent ban
  TRUE
);

-- Step 2: Update user status
UPDATE public.users 
SET is_banned = TRUE 
WHERE id = 'USER_ID_TO_BAN';
```

### Ban User dengan Expiration (Temporary)
```sql
-- Ban for 7 days
INSERT INTO public.banned_users (
  user_id, 
  banned_by, 
  reason, 
  banned_at, 
  expires_at, 
  is_active
) VALUES (
  'USER_ID_TO_BAN',
  'YOUR_ADMIN_ID',
  'Temporary ban - 7 days',
  NOW(),
  NOW() + INTERVAL '7 days',
  TRUE
);

UPDATE public.users 
SET is_banned = TRUE 
WHERE id = 'USER_ID_TO_BAN';
```

### Unban User Secara Manual
```sql
-- Step 1: Deactivate ban record
UPDATE public.banned_users 
SET is_active = FALSE 
WHERE user_id = 'USER_ID_TO_UNBAN' AND is_active = TRUE;

-- Step 2: Update user status
UPDATE public.users 
SET is_banned = FALSE 
WHERE id = 'USER_ID_TO_UNBAN';
```

### Cek Ban yang Sudah Expired (Tapi Masih Active)
```sql
SELECT 
  u.display_name,
  bu.reason,
  bu.banned_at,
  bu.expires_at,
  bu.is_active
FROM public.banned_users bu
JOIN public.users u ON bu.user_id = u.id
WHERE 
  bu.is_active = TRUE 
  AND bu.expires_at IS NOT NULL 
  AND bu.expires_at < NOW()
ORDER BY bu.expires_at DESC;
```

---

## 📊 STATISTICS QUERIES

### Dashboard Stats (Manual)
```sql
SELECT
  -- Users
  (SELECT COUNT(*) FROM auth.users) AS total_users,
  (SELECT COUNT(*) FROM auth.users WHERE created_at >= NOW() - INTERVAL '24 hours') AS users_today,
  (SELECT COUNT(*) FROM public.users WHERE is_banned = TRUE) AS banned_users,
  
  -- Menfess
  (SELECT COUNT(*) FROM public.menfess) AS total_menfess,
  (SELECT COUNT(*) FROM public.menfess WHERE created_at >= NOW() - INTERVAL '24 hours') AS menfess_today,
  
  -- Engagement
  (SELECT COUNT(*) FROM public.reactions) AS total_reactions,
  (SELECT COUNT(*) FROM public.comments) AS total_comments,
  
  -- Reports
  (SELECT COUNT(*) FROM public.reports WHERE status = 'pending') AS pending_reports;
```

### Top 10 Most Active Users
```sql
SELECT 
  u.display_name,
  COUNT(DISTINCT m.id) AS menfess_count,
  COUNT(DISTINCT c.id) AS comments_count,
  COUNT(DISTINCT r.id) AS reactions_count,
  (COUNT(DISTINCT m.id) + COUNT(DISTINCT c.id) + COUNT(DISTINCT r.id)) AS total_activity
FROM public.users u
LEFT JOIN public.menfess m ON m.user_id = u.id
LEFT JOIN public.comments c ON c.user_id = u.id
LEFT JOIN public.reactions r ON r.user_id = u.id
GROUP BY u.id, u.display_name
ORDER BY total_activity DESC
LIMIT 10;
```

### User Growth (Last 7 Days)
```sql
SELECT 
  DATE(created_at) AS date,
  COUNT(*) AS new_users
FROM auth.users
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Menfess Growth (Last 7 Days)
```sql
SELECT 
  DATE(created_at) AS date,
  COUNT(*) AS new_menfess
FROM public.menfess
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

---

## 📝 REPORTS MANAGEMENT

### Lihat Semua Pending Reports
```sql
SELECT 
  r.id,
  r.reason,
  r.description,
  r.status,
  r.created_at,
  reporter.display_name AS reporter_name,
  m.content AS menfess_content,
  author.display_name AS menfess_author
FROM public.reports r
JOIN public.users reporter ON r.reporter_id = reporter.id
JOIN public.menfess m ON r.menfess_id = m.id
JOIN public.users author ON m.user_id = author.id
WHERE r.status = 'pending'
ORDER BY r.created_at DESC;
```

### Resolve Report Secara Manual
```sql
UPDATE public.reports 
SET 
  status = 'resolved',
  reviewed_by = 'YOUR_ADMIN_ID',
  reviewed_at = NOW(),
  resolution_note = 'Resolved: Content deleted',
  updated_at = NOW()
WHERE id = 'REPORT_ID_HERE';
```

### Dismiss Report Secara Manual
```sql
UPDATE public.reports 
SET 
  status = 'dismissed',
  reviewed_by = 'YOUR_ADMIN_ID',
  reviewed_at = NOW(),
  updated_at = NOW()
WHERE id = 'REPORT_ID_HERE';
```

### Lihat Report Statistics by Reason
```sql
SELECT 
  reason,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE status = 'pending') AS pending,
  COUNT(*) FILTER (WHERE status = 'resolved') AS resolved,
  COUNT(*) FILTER (WHERE status = 'dismissed') AS dismissed
FROM public.reports
GROUP BY reason
ORDER BY total DESC;
```

---

## 🗑️ CONTENT MODERATION

### Lihat Menfess yang Paling Banyak Dilaporkan
```sql
SELECT 
  m.id,
  m.content,
  author.display_name AS author_name,
  COUNT(r.id) AS report_count,
  m.created_at
FROM public.menfess m
JOIN public.users author ON m.user_id = author.id
LEFT JOIN public.reports r ON r.menfess_id = m.id
GROUP BY m.id, m.content, author.display_name, m.created_at
HAVING COUNT(r.id) > 0
ORDER BY report_count DESC, m.created_at DESC
LIMIT 20;
```

### Delete Menfess Secara Manual (dengan Log)
```sql
-- Step 1: Log the action
INSERT INTO public.admin_logs (
  admin_id,
  action,
  target_type,
  target_id,
  details
) VALUES (
  'YOUR_ADMIN_ID',
  'delete_menfess',
  'menfess',
  'MENFESS_ID_HERE',
  jsonb_build_object('reason', 'Manual deletion - inappropriate content')
);

-- Step 2: Delete the menfess (cascade will handle related data)
DELETE FROM public.menfess WHERE id = 'MENFESS_ID_HERE';
```

### Lihat Menfess Terbaru (Last 24 Hours)
```sql
SELECT 
  m.id,
  m.content,
  u.display_name AS author,
  m.created_at,
  COUNT(DISTINCT r.id) AS reactions_count,
  COUNT(DISTINCT c.id) AS comments_count
FROM public.menfess m
JOIN public.users u ON m.user_id = u.id
LEFT JOIN public.reactions r ON r.menfess_id = m.id
LEFT JOIN public.comments c ON c.menfess_id = m.id
WHERE m.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY m.id, m.content, u.display_name, m.created_at
ORDER BY m.created_at DESC;
```

---

## 📋 AUDIT LOGS

### Lihat Admin Activity (Last 24 Hours)
```sql
SELECT 
  al.action,
  al.target_type,
  al.target_id,
  al.details,
  al.created_at,
  admin.display_name AS admin_name
FROM public.admin_logs al
JOIN public.users admin ON al.admin_id = admin.id
WHERE al.created_at >= NOW() - INTERVAL '24 hours'
ORDER BY al.created_at DESC;
```

### Lihat Activity by Admin
```sql
SELECT 
  al.action,
  COUNT(*) AS count
FROM public.admin_logs al
WHERE al.admin_id = 'ADMIN_ID_HERE'
GROUP BY al.action
ORDER BY count DESC;
```

### Lihat Semua Delete Actions
```sql
SELECT 
  al.created_at,
  admin.display_name AS admin_name,
  al.target_type,
  al.target_id,
  al.details
FROM public.admin_logs al
JOIN public.users admin ON al.admin_id = admin.id
WHERE al.action = 'delete_menfess'
ORDER BY al.created_at DESC;
```

---

## 🔧 MAINTENANCE QUERIES

### Reset User Role (Emergency)
```sql
-- Reset all users to 'user' role (CAREFUL!)
UPDATE public.users 
SET role = 'user' 
WHERE role != 'super_admin';
```

### Clean Up Expired Bans
```sql
-- Deactivate expired bans
UPDATE public.banned_users 
SET is_active = FALSE 
WHERE 
  is_active = TRUE 
  AND expires_at IS NOT NULL 
  AND expires_at < NOW();

-- Update user status
UPDATE public.users u
SET is_banned = FALSE
WHERE is_banned = TRUE
AND NOT EXISTS (
  SELECT 1 FROM public.banned_users bu
  WHERE bu.user_id = u.id AND bu.is_active = TRUE
);
```

### Delete Old Admin Logs (Older than 90 days)
```sql
DELETE FROM public.admin_logs 
WHERE created_at < NOW() - INTERVAL '90 days';
```

### Vacuum and Analyze Tables (Performance)
```sql
VACUUM ANALYZE public.reports;
VACUUM ANALYZE public.banned_users;
VACUUM ANALYZE public.admin_logs;
```

---

## 🆘 EMERGENCY COMMANDS

### Unban All Users (Emergency)
```sql
-- Deactivate all bans
UPDATE public.banned_users SET is_active = FALSE;

-- Unban all users
UPDATE public.users SET is_banned = FALSE;
```

### Delete All Reports (Clean Slate)
```sql
DELETE FROM public.reports;
```

### Reset Admin System (NUCLEAR OPTION - USE WITH CAUTION!)
```sql
-- This will delete ALL admin data
DELETE FROM public.admin_logs;
DELETE FROM public.banned_users;
DELETE FROM public.reports;
UPDATE public.users SET role = 'user', is_banned = FALSE;
```

---

## 💡 TIPS

1. **Always backup before running DELETE or UPDATE queries!**
2. **Test queries on staging environment first**
3. **Use transactions for multi-step operations:**
   ```sql
   BEGIN;
   -- Your queries here
   COMMIT; -- or ROLLBACK if something went wrong
   ```
4. **Check affected rows after UPDATE/DELETE:**
   - Supabase will show "X rows affected"
5. **Use LIMIT when testing SELECT queries:**
   ```sql
   SELECT * FROM public.users LIMIT 10;
   ```

---

**Last Updated:** May 3, 2026  
**Version:** 1.0
