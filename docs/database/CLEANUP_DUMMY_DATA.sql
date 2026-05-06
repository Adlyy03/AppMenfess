-- =====================================================
-- CLEANUP DUMMY DATA SQL - MENFESS SKANIC
-- =====================================================
-- Hapus semua data dummy untuk reset database
-- HATI-HATI: Ini akan menghapus SEMUA data!
-- =====================================================

-- =====================================================
-- WARNING: BACKUP DATABASE SEBELUM MENJALANKAN!
-- =====================================================

-- Disable foreign key checks temporarily (if needed)
-- SET session_replication_role = replica;

-- =====================================================
-- 1. DELETE ALL DATA (in correct order to avoid FK violations)
-- =====================================================

-- Delete admin logs first
DELETE FROM admin_logs;

-- Delete banned users
DELETE FROM banned_users;

-- Delete reports
DELETE FROM reports;

-- Delete bookmarks
DELETE FROM bookmarks;

-- Delete reactions
DELETE FROM reactions;

-- Delete comments
DELETE FROM comments;

-- Delete menfess posts
DELETE FROM menfess;

-- Delete users (keep admin if needed)
-- Option 1: Delete ALL users
DELETE FROM users;

-- Option 2: Keep only super admin (uncomment if needed)
-- DELETE FROM users WHERE role != 'super_admin';

-- =====================================================
-- 2. RESET SEQUENCES (if using auto-increment)
-- =====================================================

-- Reset any sequences if your tables use them
-- ALTER SEQUENCE users_id_seq RESTART WITH 1;
-- ALTER SEQUENCE menfess_id_seq RESTART WITH 1;
-- ALTER SEQUENCE comments_id_seq RESTART WITH 1;

-- =====================================================
-- 3. VERIFICATION QUERIES
-- =====================================================

-- Check that all tables are empty
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'menfess', COUNT(*) FROM menfess
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'reactions', COUNT(*) FROM reactions
UNION ALL
SELECT 'bookmarks', COUNT(*) FROM bookmarks
UNION ALL
SELECT 'reports', COUNT(*) FROM reports
UNION ALL
SELECT 'banned_users', COUNT(*) FROM banned_users
UNION ALL
SELECT 'admin_logs', COUNT(*) FROM admin_logs;

-- =====================================================
-- 4. RE-ENABLE CONSTRAINTS
-- =====================================================

-- Re-enable foreign key checks
-- SET session_replication_role = DEFAULT;

-- =====================================================
-- CLEANUP COMPLETE!
-- =====================================================
-- All dummy data has been removed.
-- Database is now clean and ready for fresh data.
-- =====================================================