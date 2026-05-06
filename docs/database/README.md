# 🗄️ DATABASE DOCUMENTATION

Dokumentasi lengkap untuk database setup dan SQL commands Menfess SKANIC.

---

## 📋 OVERVIEW

Database menggunakan **Supabase PostgreSQL** dengan:
- **Row Level Security (RLS)** untuk data protection
- **Real-time subscriptions** untuk live updates
- **RPC functions** untuk complex operations
- **Audit logging** untuk compliance
- **Cascade deletes** untuk data integrity

---

## 📚 SQL FILES

### 🔧 **Setup & Configuration**
- **[CREATE_ADMIN_ACCOUNT.sql](./CREATE_ADMIN_ACCOUNT.sql)** - Membuat akun admin pertama
- **[PRIORITAS_3_SQL_SETUP.sql](./PRIORITAS_3_SQL_SETUP.sql)** - Setup database prioritas 3
- **[REPORTS_LOGS_SQL_SETUP.sql](./REPORTS_LOGS_SQL_SETUP.sql)** - Setup reports & audit logs

### 🧪 **Testing & Demo Data**
- **[INSERT_DUMMY_DATA.sql](./INSERT_DUMMY_DATA.sql)** - Data dummy lengkap untuk demo (40+ records)
- **[INSERT_TESTING_DATA.sql](./INSERT_TESTING_DATA.sql)** - Data minimal untuk testing (20+ records)
- **[CLEANUP_DUMMY_DATA.sql](./CLEANUP_DUMMY_DATA.sql)** - Reset/hapus semua data dummy

### 🔨 **Bug Fixes & Improvements**
- **[FIX_ADMIN_GET_USERS.sql](./FIX_ADMIN_GET_USERS.sql)** - Fix query get users untuk admin
- **[FIX_BOOKMARK_DATABASE.sql](./FIX_BOOKMARK_DATABASE.sql)** - Fix database bookmark system
- **[FIX_VIEW_COUNT.sql](./FIX_VIEW_COUNT.sql)** - Fix view count tracking
- **[FIX_REPORTS_LOGS_FOREIGN_KEYS.sql](./FIX_REPORTS_LOGS_FOREIGN_KEYS.sql)** - Fix foreign key constraints
- **[FIX_REPORTS_LOGS_JOINS_ALTERNATIVE.sql](./FIX_REPORTS_LOGS_JOINS_ALTERNATIVE.sql)** - Alternative join queries

---

## 🏗️ DATABASE SCHEMA

### **Core Tables:**
- **`users`** - User accounts with roles and status
- **`menfess`** - Anonymous posts with 24-hour expiry
- **`comments`** - Comments on menfess posts
- **`reactions`** - Likes and other reactions
- **`bookmarks`** - User bookmarks

### **Admin Tables:**
- **`reports`** - User reports on content
- **`banned_users`** - Ban records with expiration
- **`admin_logs`** - Audit trail for admin actions

### **Views:**
- **`admin_stats`** - Aggregated platform statistics

---

## 🔐 SECURITY FEATURES

### **Row Level Security (RLS)**
- Users can only access their own data
- Admin tables restricted to admin roles
- Public data (menfess, comments) readable by all
- Write operations properly restricted

### **RPC Functions**
- **`increment_view`** - Atomic view count updates
- **`increment_like`** - Atomic like count updates
- **`admin_delete_menfess`** - Admin delete with logging
- **`admin_ban_user`** - Admin ban with logging
- **`admin_change_role`** - Role changes with logging

---

## 🚀 SETUP INSTRUCTIONS

### 1. **Initial Setup**
```sql
-- 1. Run PRIORITAS_3_SQL_SETUP.sql for core tables
-- 2. Run REPORTS_LOGS_SQL_SETUP.sql for admin features
-- 3. Run CREATE_ADMIN_ACCOUNT.sql to create first admin
```

### 2. **Apply Fixes**
```sql
-- Run fix files in order:
-- 1. FIX_BOOKMARK_DATABASE.sql
-- 2. FIX_VIEW_COUNT.sql
-- 3. FIX_ADMIN_GET_USERS.sql
-- 4. FIX_REPORTS_LOGS_FOREIGN_KEYS.sql
-- 5. FIX_REPORTS_LOGS_JOINS_ALTERNATIVE.sql
```

### 3. **Add Test/Demo Data**
```sql
-- Option A: Minimal testing data
\i INSERT_TESTING_DATA.sql

-- Option B: Full demo data (recommended for demo)
\i INSERT_DUMMY_DATA.sql

-- Cleanup when needed
\i CLEANUP_DUMMY_DATA.sql
```

### 4. **Verify Setup**
```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS policies
SELECT schemaname, tablename, policyname 
FROM pg_policies;

-- Test admin functions
SELECT admin_get_users();
```

---

## 📊 DATA FLOW

### **User Actions:**
1. **Create Menfess** → Insert to `menfess` table
2. **Like Post** → Insert/Delete from `reactions` table
3. **Add Comment** → Insert to `comments` table
4. **Bookmark** → Insert/Delete from `bookmarks` table

### **Admin Actions:**
1. **Delete Menfess** → Call `admin_delete_menfess()` RPC
2. **Ban User** → Call `admin_ban_user()` RPC
3. **Change Role** → Call `admin_change_role()` RPC
4. **All actions logged** → Insert to `admin_logs` table

---

## 🔍 TROUBLESHOOTING

### **Common Issues:**

#### **RLS Policy Errors**
```sql
-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables WHERE schemaname = 'public';

-- Enable RLS if needed
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;
```

#### **Foreign Key Violations**
```sql
-- Check foreign key constraints
SELECT conname, conrelid::regclass, confrelid::regclass 
FROM pg_constraint WHERE contype = 'f';

-- Use FIX_REPORTS_LOGS_FOREIGN_KEYS.sql to fix
```

#### **Performance Issues**
```sql
-- Check indexes
SELECT schemaname, tablename, indexname 
FROM pg_indexes WHERE schemaname = 'public';

-- Add missing indexes
CREATE INDEX idx_menfess_created_at ON menfess(created_at);
CREATE INDEX idx_reactions_menfess_id ON reactions(menfess_id);
```

---

## 📈 MONITORING

### **Key Metrics to Track:**
- Table sizes and growth rates
- Query performance (slow queries)
- RLS policy effectiveness
- Admin action frequency
- Data integrity (orphaned records)

### **Useful Queries:**
```sql
-- Table sizes
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables WHERE schemaname = 'public';

-- Recent admin actions
SELECT * FROM admin_logs 
ORDER BY created_at DESC LIMIT 10;

-- Active users today
SELECT COUNT(DISTINCT user_id) FROM menfess 
WHERE created_at >= CURRENT_DATE;
```

---

## 🔗 RELATED DOCUMENTATION

- **Admin Setup:** [../admin/](../admin/)
- **Testing:** [../testing/](../testing/)
- **Main Documentation:** [../README.md](../README.md)

---

**Last Updated:** May 7, 2026  
**Database Version:** PostgreSQL 15+  
**Status:** Production Ready