# Admin Dashboard System - Database Migration Guide

## Overview

This migration adds comprehensive administrative capabilities to the Menfess app, including:

- **Role-Based Access Control**: Three-tier role hierarchy (user, moderator, super_admin)
- **Content Moderation**: Reports system for flagging inappropriate content
- **User Management**: Ban/unban users with optional expiration dates
- **Audit Logging**: Complete audit trail of all admin actions
- **Dashboard Statistics**: Real-time platform metrics and analytics
- **RPC Functions**: Secure server-side functions for admin operations

## Migration Files

1. **20260501_admin_dashboard_system.sql** - Main migration file
   - Adds role, is_banned, and last_login_at columns to users table
   - Creates reports, banned_users, and admin_logs tables
   - Creates admin_stats view for dashboard statistics
   - Implements Row Level Security (RLS) policies
   - Creates 7 RPC functions for admin operations
   - Enables realtime subscriptions for admin tables

2. **20260501_admin_dashboard_test_data.sql** - Test data and verification queries
   - Sample data structure examples
   - Test queries to verify schema
   - Manual testing steps
   - Testing checklist

## Database Schema

### Enhanced Users Table

```sql
public.users
├── id (UUID, PK)
├── display_name (TEXT)
├── role (TEXT) - NEW: 'user', 'moderator', 'super_admin'
├── is_banned (BOOLEAN) - NEW
├── last_login_at (TIMESTAMPTZ) - NEW
└── created_at (TIMESTAMPTZ)
```

### Reports Table

```sql
public.reports
├── id (UUID, PK)
├── menfess_id (UUID, FK -> menfess)
├── reporter_id (UUID, FK -> auth.users)
├── reason (TEXT) - 'spam', 'harassment', 'inappropriate', 'misinformation', 'other'
├── description (TEXT)
├── status (TEXT) - 'pending', 'reviewing', 'resolved', 'dismissed'
├── reviewed_by (UUID, FK -> auth.users)
├── reviewed_at (TIMESTAMPTZ)
├── resolution_note (TEXT)
├── created_at (TIMESTAMPTZ)
└── updated_at (TIMESTAMPTZ)
```

### Banned Users Table

```sql
public.banned_users
├── id (UUID, PK)
├── user_id (UUID, FK -> auth.users)
├── banned_by (UUID, FK -> auth.users)
├── reason (TEXT)
├── banned_at (TIMESTAMPTZ)
├── expires_at (TIMESTAMPTZ) - NULL = permanent ban
├── is_active (BOOLEAN)
└── notes (TEXT)
```

### Admin Logs Table

```sql
public.admin_logs
├── id (UUID, PK)
├── admin_id (UUID, FK -> auth.users)
├── action (TEXT) - 'delete_menfess', 'ban_user', 'unban_user', etc.
├── target_type (TEXT) - 'menfess', 'user', 'comment', 'report'
├── target_id (UUID)
├── details (JSONB)
├── ip_address (INET)
├── user_agent (TEXT)
└── created_at (TIMESTAMPTZ)
```

### Admin Stats View

```sql
public.admin_stats (VIEW)
├── total_users
├── users_today
├── users_this_week
├── active_users_today
├── banned_users_count
├── total_menfess
├── menfess_today
├── menfess_this_week
├── total_reactions
├── reactions_today
├── total_comments
├── comments_today
├── pending_reports
├── reviewing_reports
├── reports_today
└── admin_actions_today
```

## RPC Functions

### 1. admin_delete_menfess(menfess_id, reason)
Deletes a menfess post and logs the action.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `menfess_id` (UUID): ID of the menfess to delete
- `reason` (TEXT): Reason for deletion

**Example**:
```sql
SELECT admin_delete_menfess('123e4567-e89b-12d3-a456-426614174000', 'Spam content');
```

### 2. admin_ban_user(target_user_id, reason, expires_at, notes)
Bans a user from the platform.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `target_user_id` (UUID): ID of user to ban
- `reason` (TEXT): Reason for ban
- `expires_at` (TIMESTAMPTZ, optional): Ban expiration date (NULL = permanent)
- `notes` (TEXT, optional): Additional notes

**Example**:
```sql
-- Permanent ban
SELECT admin_ban_user('123e4567-e89b-12d3-a456-426614174000', 'Harassment', NULL, 'Multiple violations');

-- Temporary ban (7 days)
SELECT admin_ban_user('123e4567-e89b-12d3-a456-426614174000', 'Spam', NOW() + INTERVAL '7 days', 'First offense');
```

### 3. admin_unban_user(target_user_id)
Unbans a user.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `target_user_id` (UUID): ID of user to unban

**Example**:
```sql
SELECT admin_unban_user('123e4567-e89b-12d3-a456-426614174000');
```

### 4. admin_change_role(target_user_id, new_role)
Changes a user's role.

**Permissions**: Super Admin only
**Parameters**:
- `target_user_id` (UUID): ID of user to modify
- `new_role` (TEXT): New role ('user', 'moderator', 'super_admin')

**Example**:
```sql
SELECT admin_change_role('123e4567-e89b-12d3-a456-426614174000', 'moderator');
```

### 5. admin_resolve_report(report_id, resolution_note)
Marks a report as resolved.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `report_id` (UUID): ID of report to resolve
- `resolution_note` (TEXT): Resolution details

**Example**:
```sql
SELECT admin_resolve_report('123e4567-e89b-12d3-a456-426614174000', 'Content removed and user warned');
```

### 6. admin_dismiss_report(report_id)
Dismisses a report without action.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `report_id` (UUID): ID of report to dismiss

**Example**:
```sql
SELECT admin_dismiss_report('123e4567-e89b-12d3-a456-426614174000');
```

### 7. admin_get_users(search_query, role_filter)
Retrieves users with aggregated statistics.

**Permissions**: Moderator or Super Admin
**Parameters**:
- `search_query` (TEXT, optional): Search by display name
- `role_filter` (TEXT, optional): Filter by role

**Example**:
```sql
-- Get all users
SELECT * FROM admin_get_users(NULL, NULL);

-- Search for users
SELECT * FROM admin_get_users('john', NULL);

-- Filter by role
SELECT * FROM admin_get_users(NULL, 'moderator');
```

## Installation Steps

### 1. Apply the Migration

**Option A: Using Supabase CLI**
```bash
# Navigate to project root
cd /path/to/menfess_app

# Apply migration
supabase db push
```

**Option B: Using Supabase Dashboard**
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy the contents of `20260501_admin_dashboard_system.sql`
4. Paste and run the SQL

### 2. Create Your First Super Admin

After applying the migration, you need to manually create at least one super admin user:

```sql
-- Replace 'YOUR_USER_ID' with an actual user ID from auth.users
UPDATE public.users 
SET role = 'super_admin' 
WHERE id = 'YOUR_USER_ID';
```

To find your user ID:
```sql
SELECT id, display_name FROM public.users WHERE display_name = 'YourDisplayName';
```

### 3. Verify Installation

Run these queries to verify everything is set up correctly:

```sql
-- Check if role column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name IN ('role', 'is_banned', 'last_login_at');

-- Check if new tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('reports', 'banned_users', 'admin_logs');

-- Check if admin_stats view exists
SELECT * FROM public.admin_stats;

-- Check if RPC functions exist
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE 'admin_%';
```

## Testing

### Manual Testing Steps

1. **Test Role Assignment**
   ```sql
   -- Assign moderator role
   UPDATE public.users SET role = 'moderator' WHERE id = 'USER_ID';
   
   -- Verify role
   SELECT id, display_name, role FROM public.users WHERE id = 'USER_ID';
   ```

2. **Test Report Creation**
   ```sql
   -- Create a test report (as a regular user)
   INSERT INTO public.reports (menfess_id, reporter_id, reason, description)
   VALUES ('MENFESS_ID', 'USER_ID', 'spam', 'Test report for spam content');
   ```

3. **Test Admin Functions**
   ```sql
   -- Test resolve report
   SELECT admin_resolve_report('REPORT_ID', 'Resolved: Content removed');
   
   -- Test ban user
   SELECT admin_ban_user('USER_ID', 'Test ban', NOW() + INTERVAL '1 day', 'Testing');
   
   -- Test unban user
   SELECT admin_unban_user('USER_ID');
   
   -- Test get users
   SELECT * FROM admin_get_users(NULL, NULL);
   ```

4. **Verify Audit Logs**
   ```sql
   -- Check that actions were logged
   SELECT * FROM public.admin_logs ORDER BY created_at DESC LIMIT 10;
   ```

5. **Test RLS Policies**
   ```sql
   -- As a regular user, try to access admin data (should fail)
   -- As an admin, access should work
   SELECT * FROM public.reports;
   SELECT * FROM public.banned_users;
   SELECT * FROM public.admin_logs;
   ```

### Automated Testing Checklist

- [ ] Users table has new columns (role, is_banned, last_login_at)
- [ ] Reports table created with proper structure
- [ ] Banned_users table created with proper structure
- [ ] Admin_logs table created with proper structure
- [ ] Admin_stats view returns data
- [ ] All indexes created successfully
- [ ] All RLS policies in place
- [ ] All 7 RPC functions created
- [ ] Realtime enabled for admin tables
- [ ] Super admin can perform all actions
- [ ] Moderator can perform moderation actions
- [ ] Regular users cannot access admin functions
- [ ] Admin actions are logged correctly
- [ ] Ban expiration logic works
- [ ] Cannot ban self
- [ ] Cannot change own role

## Security Considerations

### Row Level Security (RLS)

All admin tables have RLS enabled with the following policies:

1. **Reports Table**
   - Users can create their own reports
   - Users can view their own reports
   - Admins can view and update all reports

2. **Banned Users Table**
   - Only admins can view, create, and update ban records

3. **Admin Logs Table**
   - Only admins can view logs
   - System can insert logs (via RPC functions)

### Permission Checks

All RPC functions include permission checks:
- Moderator and Super Admin can perform moderation actions
- Only Super Admin can change user roles
- Users cannot perform actions on themselves (ban, role change)
- Moderators cannot ban Super Admins

### Audit Trail

Every admin action is automatically logged with:
- Admin ID
- Action type
- Target entity
- Timestamp
- Action details (JSON)

## Realtime Subscriptions

The following tables have realtime enabled:
- `public.reports` - For live report updates
- `public.admin_logs` - For live admin activity feed
- `public.banned_users` - For live ban status updates

### Flutter Integration Example

```dart
// Subscribe to reports changes
supabase
  .channel('admin_reports')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'reports',
    callback: (payload) {
      // Refresh reports list
    },
  )
  .subscribe();
```

## Rollback

If you need to rollback this migration:

```sql
-- Drop RPC functions
DROP FUNCTION IF EXISTS admin_delete_menfess(UUID, TEXT);
DROP FUNCTION IF EXISTS admin_ban_user(UUID, TEXT, TIMESTAMPTZ, TEXT);
DROP FUNCTION IF EXISTS admin_unban_user(UUID);
DROP FUNCTION IF EXISTS admin_change_role(UUID, TEXT);
DROP FUNCTION IF EXISTS admin_resolve_report(UUID, TEXT);
DROP FUNCTION IF EXISTS admin_dismiss_report(UUID);
DROP FUNCTION IF EXISTS admin_get_users(TEXT, TEXT);

-- Drop view
DROP VIEW IF EXISTS public.admin_stats;

-- Drop tables
DROP TABLE IF EXISTS public.admin_logs;
DROP TABLE IF EXISTS public.banned_users;
DROP TABLE IF EXISTS public.reports;

-- Remove columns from users table
ALTER TABLE public.users DROP COLUMN IF EXISTS role;
ALTER TABLE public.users DROP COLUMN IF EXISTS is_banned;
ALTER TABLE public.users DROP COLUMN IF EXISTS last_login_at;

-- Drop indexes
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_users_banned;
```

## Troubleshooting

### Issue: "Unauthorized: Admin access required"
**Solution**: Verify the user has the correct role:
```sql
SELECT id, display_name, role FROM public.users WHERE id = auth.uid();
```

### Issue: "User is already banned"
**Solution**: Check for existing active bans:
```sql
SELECT * FROM public.banned_users WHERE user_id = 'USER_ID' AND is_active = TRUE;
```

### Issue: RPC function not found
**Solution**: Verify functions were created:
```sql
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_name LIKE 'admin_%';
```

### Issue: RLS policy blocking access
**Solution**: Check current user's role and RLS policies:
```sql
-- Check user role
SELECT role FROM public.users WHERE id = auth.uid();

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'reports';
```

## Next Steps

After successfully applying this migration:

1. **Create Admin Users**: Assign moderator and super_admin roles to trusted users
2. **Implement Flutter UI**: Build the admin dashboard screens using the provided design
3. **Test Thoroughly**: Test all admin functions with different user roles
4. **Monitor Logs**: Regularly review admin_logs for suspicious activity
5. **Set Up Alerts**: Configure alerts for critical admin actions
6. **Document Procedures**: Create internal documentation for admin workflows

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the design document: `.kiro/specs/admin-dashboard-system/design.md`
3. Review the requirements: `.kiro/specs/admin-dashboard-system/requirements.md`
4. Check Supabase logs in the dashboard

## Version History

- **v1.0.0** (2026-05-01): Initial migration
  - Added role-based access control
  - Created reports, banned_users, admin_logs tables
  - Implemented 7 RPC functions
  - Added admin_stats view
  - Enabled realtime subscriptions
