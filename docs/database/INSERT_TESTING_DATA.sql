-- =====================================================
-- TESTING DATA SQL - MENFESS SKANIC
-- =====================================================
-- Data minimal untuk testing fitur-fitur utama
-- Lebih ringan dari dummy data lengkap
-- =====================================================

-- =====================================================
-- 1. ESSENTIAL TEST USERS
-- =====================================================

INSERT INTO users (id, email, display_name, role, is_banned, created_at, last_login_at) VALUES
-- Test users for different scenarios
('test-user-1', 'testuser1@example.com', 'Test User One', 'user', false, NOW() - INTERVAL '7 days', NOW() - INTERVAL '1 hour'),
('test-user-2', 'testuser2@example.com', 'Test User Two', 'user', false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '2 hours'),
('test-user-3', 'testuser3@example.com', 'Test User Three', 'user', false, NOW() - INTERVAL '3 days', NOW() - INTERVAL '30 minutes'),

-- Test moderator
('test-mod', 'testmod@skanic.com', 'Test Moderator', 'moderator', false, NOW() - INTERVAL '10 days', NOW() - INTERVAL '15 minutes'),

-- Test super admin
('test-admin', 'testadmin@skanic.com', 'Test Super Admin', 'super_admin', false, NOW() - INTERVAL '15 days', NOW() - INTERVAL '5 minutes'),

-- Test banned user
('test-banned', 'testbanned@example.com', 'Test Banned User', 'user', true, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day');

-- =====================================================
-- 2. TEST MENFESS POSTS
-- =====================================================

INSERT INTO menfess (id, user_id, message, like_count, view_count, comment_count, created_at, expires_at) VALUES
-- Recent posts for testing feed
('test-menfess-1', 'test-user-1', 'This is a test menfess for testing the app functionality. Should appear in feed.', 5, 25, 2, NOW() - INTERVAL '1 hour', NOW() + INTERVAL '23 hours'),
('test-menfess-2', 'test-user-2', 'Another test post with some engagement. Testing like and comment features.', 8, 45, 3, NOW() - INTERVAL '3 hours', NOW() + INTERVAL '21 hours'),
('test-menfess-3', 'test-user-3', 'Testing share functionality with this post. Should be shareable via different methods.', 12, 67, 5, NOW() - INTERVAL '5 hours', NOW() + INTERVAL '19 hours'),

-- Hot/trending post for testing
('test-hot-1', 'test-user-1', 'This is a hot trending post for testing the hot section. High engagement expected.', 25, 150, 12, NOW() - INTERVAL '2 hours', NOW() + INTERVAL '22 hours'),

-- Older post (will expire soon)
('test-old-1', 'test-user-2', 'This post will expire soon. Testing expiry functionality.', 3, 15, 1, NOW() - INTERVAL '23 hours', NOW() + INTERVAL '1 hour');

-- =====================================================
-- 3. TEST COMMENTS
-- =====================================================

INSERT INTO comments (id, menfess_id, user_id, text, created_at) VALUES
-- Comments for test-menfess-1
('test-comment-1', 'test-menfess-1', 'test-user-2', 'This is a test comment for testing comment functionality.', NOW() - INTERVAL '45 minutes'),
('test-comment-2', 'test-menfess-1', 'test-user-3', 'Another test comment to check threading and display.', NOW() - INTERVAL '30 minutes'),

-- Comments for test-hot-1
('test-comment-3', 'test-hot-1', 'test-user-2', 'Great post! Testing engagement on hot posts.', NOW() - INTERVAL '1.5 hours'),
('test-comment-4', 'test-hot-1', 'test-user-3', 'Totally agree with this sentiment.', NOW() - INTERVAL '1 hour'),
('test-comment-5', 'test-hot-1', 'test-user-1', 'Thanks for the feedback everyone!', NOW() - INTERVAL '45 minutes');

-- =====================================================
-- 4. TEST REACTIONS
-- =====================================================

INSERT INTO reactions (menfess_id, user_id, type, created_at) VALUES
-- Likes for test posts
('test-menfess-1', 'test-user-2', 'like', NOW() - INTERVAL '50 minutes'),
('test-menfess-1', 'test-user-3', 'like', NOW() - INTERVAL '40 minutes'),
('test-menfess-2', 'test-user-1', 'like', NOW() - INTERVAL '2.5 hours'),
('test-menfess-2', 'test-user-3', 'like', NOW() - INTERVAL '2 hours'),
('test-hot-1', 'test-user-1', 'like', NOW() - INTERVAL '1.8 hours'),
('test-hot-1', 'test-user-2', 'like', NOW() - INTERVAL '1.6 hours'),
('test-hot-1', 'test-user-3', 'like', NOW() - INTERVAL '1.4 hours');

-- =====================================================
-- 5. TEST BOOKMARKS
-- =====================================================

INSERT INTO bookmarks (user_id, menfess_id, created_at) VALUES
('test-user-1', 'test-menfess-2', NOW() - INTERVAL '2 hours'),
('test-user-1', 'test-hot-1', NOW() - INTERVAL '1.5 hours'),
('test-user-2', 'test-menfess-3', NOW() - INTERVAL '4 hours'),
('test-user-3', 'test-hot-1', NOW() - INTERVAL '1 hour');

-- =====================================================
-- 6. TEST REPORTS
-- =====================================================

INSERT INTO reports (id, menfess_id, reporter_id, reason, status, created_at) VALUES
('test-report-1', 'test-old-1', 'test-user-3', 'Testing report functionality', 'pending', NOW() - INTERVAL '6 hours');

-- =====================================================
-- 7. TEST BANNED USER
-- =====================================================

INSERT INTO banned_users (id, user_id, banned_by, reason, expires_at, notes, is_active, created_at) VALUES
('test-ban-1', 'test-banned', 'test-mod', 'Testing ban functionality', NOW() + INTERVAL '3 days', 'Test ban for functionality testing', true, NOW() - INTERVAL '1 day');

-- =====================================================
-- 8. TEST ADMIN LOGS
-- =====================================================

INSERT INTO admin_logs (id, admin_id, action, target_type, target_id, details, created_at) VALUES
('test-log-1', 'test-mod', 'ban_user', 'user', 'test-banned', '{"reason": "Testing ban functionality"}', NOW() - INTERVAL '1 day'),
('test-log-2', 'test-admin', 'change_role', 'user', 'test-mod', '{"old_role": "user", "new_role": "moderator"}', NOW() - INTERVAL '5 days');

-- =====================================================
-- 9. UPDATE COUNTERS
-- =====================================================

-- Update counters to match inserted data
UPDATE menfess SET 
    like_count = (SELECT COUNT(*) FROM reactions WHERE menfess_id = menfess.id AND type = 'like'),
    comment_count = (SELECT COUNT(*) FROM comments WHERE menfess_id = menfess.id)
WHERE id LIKE 'test-%';

-- =====================================================
-- 10. VERIFICATION
-- =====================================================

-- Quick verification of test data
SELECT 
    'Test Users' as category,
    COUNT(*) as count 
FROM users 
WHERE id LIKE 'test-%'

UNION ALL

SELECT 
    'Test Menfess',
    COUNT(*) 
FROM menfess 
WHERE id LIKE 'test-%'

UNION ALL

SELECT 
    'Test Comments',
    COUNT(*) 
FROM comments 
WHERE id LIKE 'test-%'

UNION ALL

SELECT 
    'Test Reactions',
    COUNT(*) 
FROM reactions 
WHERE menfess_id LIKE 'test-%'

UNION ALL

SELECT 
    'Test Bookmarks',
    COUNT(*) 
FROM bookmarks 
WHERE menfess_id LIKE 'test-%';

-- =====================================================
-- TESTING DATA INSERTION COMPLETE!
-- =====================================================
-- Minimal test data for core functionality:
-- - 6 Test users (3 regular + 1 mod + 1 admin + 1 banned)
-- - 5 Test menfess posts (various scenarios)
-- - 5 Test comments (engagement testing)
-- - 7 Test reactions/likes
-- - 4 Test bookmarks
-- - 1 Test report
-- - 1 Test ban record
-- - 2 Test admin logs
-- =====================================================