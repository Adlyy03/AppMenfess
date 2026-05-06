-- =====================================================
-- DUMMY DATA SQL - MENFESS SKANIC
-- =====================================================
-- Insert data dummy untuk testing dan demo aplikasi
-- Jalankan setelah setup database lengkap
-- =====================================================

-- =====================================================
-- 1. DUMMY USERS
-- =====================================================

-- Insert dummy users dengan berbagai role
INSERT INTO users (id, email, display_name, role, is_banned, created_at, last_login_at) VALUES
-- Regular Users
('user-001', 'alice@example.com', 'Alice Johnson', 'user', false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '1 hour'),
('user-002', 'bob@example.com', 'Bob Smith', 'user', false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '2 hours'),
('user-003', 'charlie@example.com', 'Charlie Brown', 'user', false, NOW() - INTERVAL '20 days', NOW() - INTERVAL '30 minutes'),
('user-004', 'diana@example.com', 'Diana Prince', 'user', false, NOW() - INTERVAL '15 days', NOW() - INTERVAL '3 hours'),
('user-005', 'eve@example.com', 'Eve Wilson', 'user', false, NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day'),
('user-006', 'frank@example.com', 'Frank Miller', 'user', false, NOW() - INTERVAL '8 days', NOW() - INTERVAL '4 hours'),
('user-007', 'grace@example.com', 'Grace Lee', 'user', false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '6 hours'),
('user-008', 'henry@example.com', 'Henry Ford', 'user', false, NOW() - INTERVAL '3 days', NOW() - INTERVAL '12 hours'),
('user-009', 'ivy@example.com', 'Ivy Chen', 'user', false, NOW() - INTERVAL '2 days', NOW() - INTERVAL '8 hours'),
('user-010', 'jack@example.com', 'Jack Ryan', 'user', false, NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours'),

-- Moderators
('mod-001', 'moderator1@skanic.com', 'Moderator One', 'moderator', false, NOW() - INTERVAL '45 days', NOW() - INTERVAL '30 minutes'),
('mod-002', 'moderator2@skanic.com', 'Moderator Two', 'moderator', false, NOW() - INTERVAL '40 days', NOW() - INTERVAL '1 hour'),

-- Super Admin
('admin-001', 'superadmin@skanic.com', 'Super Admin', 'super_admin', false, NOW() - INTERVAL '60 days', NOW() - INTERVAL '15 minutes'),

-- Banned User (for testing)
('user-banned', 'banned@example.com', 'Banned User', 'user', true, NOW() - INTERVAL '7 days', NOW() - INTERVAL '2 days');

-- =====================================================
-- 2. DUMMY MENFESS POSTS
-- =====================================================

-- Insert menfess posts dengan berbagai kondisi
INSERT INTO menfess (id, user_id, message, like_count, view_count, comment_count, created_at, expires_at) VALUES
-- Recent popular posts
('menfess-001', 'user-001', 'Hari ini aku merasa sangat bersyukur karena bisa menyelesaikan tugas akhir. Terima kasih untuk semua dukungan teman-teman! 🙏', 15, 120, 8, NOW() - INTERVAL '2 hours', NOW() + INTERVAL '22 hours'),
('menfess-002', 'user-002', 'Kenapa ya rasanya susah banget move on dari mantan? Padahal udah 6 bulan berlalu tapi masih suka keinget 😔', 23, 89, 12, NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours'),
('menfess-003', 'user-003', 'Lagi galau mau pilih jurusan kuliah. Antara ikutin passion atau ikutin yang prospek kerjanya bagus. Ada saran?', 8, 67, 15, NOW() - INTERVAL '6 hours', NOW() + INTERVAL '18 hours'),

-- Trending posts (high engagement)
('menfess-004', 'user-004', 'Plot twist: ternyata crush aku suka sama sahabat aku. Sekarang aku bingung harus gimana 😭', 45, 234, 28, NOW() - INTERVAL '8 hours', NOW() + INTERVAL '16 hours'),
('menfess-005', 'user-005', 'Unpopular opinion: Lebih enak makan indomie pake nasi daripada dimakan langsung. Fight me! 🍜', 67, 189, 34, NOW() - INTERVAL '10 hours', NOW() + INTERVAL '14 hours'),
('menfess-006', 'user-006', 'Aku baru sadar kalau selama ini aku terlalu bergantung sama orang lain untuk bahagia. Time to learn self-love ❤️', 31, 145, 19, NOW() - INTERVAL '12 hours', NOW() + INTERVAL '12 hours'),

-- Older posts
('menfess-007', 'user-007', 'Mimpi jadi youtuber terkenal tapi takut di-judge sama orang. Gimana ya cara ngatasin rasa takut ini?', 12, 78, 9, NOW() - INTERVAL '18 hours', NOW() + INTERVAL '6 hours'),
('menfess-008', 'user-008', 'Kadang aku merasa kayak impostor syndrome gitu. Padahal udah kerja keras tapi masih merasa nggak layak 😞', 19, 92, 11, NOW() - INTERVAL '20 hours', NOW() + INTERVAL '4 hours'),
('menfess-009', 'user-009', 'Pengen banget traveling ke Jepang tapi tabungan masih belum cukup. Harus nabung berapa lama lagi ya 🗾', 7, 56, 6, NOW() - INTERVAL '22 hours', NOW() + INTERVAL '2 hours'),

-- Very recent posts
('menfess-010', 'user-010', 'Baru aja putus sama pacar. Sedih sih tapi somehow merasa lega juga. Mixed feelings banget 💔', 5, 34, 3, NOW() - INTERVAL '1 hour', NOW() + INTERVAL '23 hours'),
('menfess-011', 'user-001', 'Lagi stress mikirin skripsi. Deadline tinggal sebulan tapi baru 30% selesai. Panik mode: ON 📚', 9, 45, 7, NOW() - INTERVAL '30 minutes', NOW() + INTERVAL '23.5 hours'),
('menfess-012', 'user-002', 'Akhirnya dapet kerja impian! Masih nggak percaya ini beneran terjadi. Terima kasih Tuhan 🙏✨', 18, 67, 12, NOW() - INTERVAL '15 minutes', NOW() + INTERVAL '23.75 hours'),

-- Posts from different time periods
('menfess-013', 'user-003', 'Kenapa sih orang tua selalu nanya "kapan nikah?" padahal masih fokus karir dulu 😅', 25, 134, 16, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 hour'),
('menfess-014', 'user-004', 'Baru nyadar kalau friendship itu butuh effort dari kedua belah pihak. Selama ini aku yang selalu inisiatif duluan', 14, 89, 8, NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
('menfess-015', 'user-005', 'Lagi belajar masak dan ternyata susah banget! Respect banget sama ibu-ibu yang masak setiap hari 👩‍🍳', 22, 98, 13, NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days');

-- =====================================================
-- 3. DUMMY COMMENTS
-- =====================================================

-- Insert comments untuk beberapa menfess
INSERT INTO comments (id, menfess_id, user_id, text, created_at) VALUES
-- Comments for menfess-001 (graduation post)
('comment-001', 'menfess-001', 'user-002', 'Selamat ya! Pasti perjuangan yang nggak mudah 👏', NOW() - INTERVAL '1.5 hours'),
('comment-002', 'menfess-001', 'user-003', 'Congrats! Semoga lancar terus kedepannya', NOW() - INTERVAL '1 hour'),
('comment-003', 'menfess-001', 'user-004', 'Inspiratif banget! Aku juga lagi struggle sama TA nih', NOW() - INTERVAL '45 minutes'),

-- Comments for menfess-002 (move on post)
('comment-004', 'menfess-002', 'user-005', 'Sama nih, aku juga lagi susah move on. Healing bareng yuk 😔', NOW() - INTERVAL '3.5 hours'),
('comment-005', 'menfess-002', 'user-006', 'Time heals everything kok. Pelan-pelan aja, jangan dipaksa', NOW() - INTERVAL '3 hours'),
('comment-006', 'menfess-002', 'user-007', 'Coba fokus ke hal-hal positif lain deh. Hobby baru mungkin?', NOW() - INTERVAL '2.5 hours'),

-- Comments for menfess-004 (crush post)
('comment-007', 'menfess-004', 'user-008', 'Wah plot twist banget! Tapi friendship is more important sih', NOW() - INTERVAL '7.5 hours'),
('comment-008', 'menfess-004', 'user-009', 'Sabar ya, mungkin ini bukan waktunya. Ada yang lebih baik nanti', NOW() - INTERVAL '7 hours'),
('comment-009', 'menfess-004', 'user-010', 'Been there! Trust me, it gets better with time', NOW() - INTERVAL '6.5 hours'),

-- Comments for menfess-005 (indomie post)
('comment-010', 'menfess-005', 'user-001', 'SETUJU BANGET! Indomie + nasi = combo terbaik 🍜🍚', NOW() - INTERVAL '9.5 hours'),
('comment-011', 'menfess-005', 'user-003', 'Nah ini dia! Akhirnya ada yang sependapat 😂', NOW() - INTERVAL '9 hours'),
('comment-012', 'menfess-005', 'user-006', 'Controversial tapi bener sih. Lebih kenyang juga', NOW() - INTERVAL '8.5 hours');

-- =====================================================
-- 4. DUMMY REACTIONS (LIKES)
-- =====================================================

-- Insert likes untuk berbagai menfess
INSERT INTO reactions (menfess_id, user_id, type, created_at) VALUES
-- Likes for menfess-001
('menfess-001', 'user-002', 'like', NOW() - INTERVAL '1.8 hours'),
('menfess-001', 'user-003', 'like', NOW() - INTERVAL '1.6 hours'),
('menfess-001', 'user-004', 'like', NOW() - INTERVAL '1.4 hours'),
('menfess-001', 'user-005', 'like', NOW() - INTERVAL '1.2 hours'),
('menfess-001', 'user-006', 'like', NOW() - INTERVAL '1 hour'),

-- Likes for menfess-002
('menfess-002', 'user-001', 'like', NOW() - INTERVAL '3.8 hours'),
('menfess-002', 'user-003', 'like', NOW() - INTERVAL '3.6 hours'),
('menfess-002', 'user-007', 'like', NOW() - INTERVAL '3.4 hours'),
('menfess-002', 'user-008', 'like', NOW() - INTERVAL '3.2 hours'),
('menfess-002', 'user-009', 'like', NOW() - INTERVAL '3 hours'),

-- Likes for trending post (menfess-004)
('menfess-004', 'user-001', 'like', NOW() - INTERVAL '7.8 hours'),
('menfess-004', 'user-002', 'like', NOW() - INTERVAL '7.6 hours'),
('menfess-004', 'user-003', 'like', NOW() - INTERVAL '7.4 hours'),
('menfess-004', 'user-005', 'like', NOW() - INTERVAL '7.2 hours'),
('menfess-004', 'user-006', 'like', NOW() - INTERVAL '7 hours'),
('menfess-004', 'user-007', 'like', NOW() - INTERVAL '6.8 hours'),

-- Likes for viral post (menfess-005)
('menfess-005', 'user-002', 'like', NOW() - INTERVAL '9.8 hours'),
('menfess-005', 'user-004', 'like', NOW() - INTERVAL '9.6 hours'),
('menfess-005', 'user-007', 'like', NOW() - INTERVAL '9.4 hours'),
('menfess-005', 'user-008', 'like', NOW() - INTERVAL '9.2 hours'),
('menfess-005', 'user-009', 'like', NOW() - INTERVAL '9 hours'),
('menfess-005', 'user-010', 'like', NOW() - INTERVAL '8.8 hours');

-- =====================================================
-- 5. DUMMY BOOKMARKS
-- =====================================================

-- Insert bookmarks untuk beberapa user
INSERT INTO bookmarks (user_id, menfess_id, created_at) VALUES
-- User-001 bookmarks
('user-001', 'menfess-002', NOW() - INTERVAL '3 hours'),
('user-001', 'menfess-004', NOW() - INTERVAL '7 hours'),
('user-001', 'menfess-006', NOW() - INTERVAL '11 hours'),

-- User-002 bookmarks
('user-002', 'menfess-001', NOW() - INTERVAL '1.5 hours'),
('user-002', 'menfess-005', NOW() - INTERVAL '9 hours'),
('user-002', 'menfess-008', NOW() - INTERVAL '19 hours'),

-- User-003 bookmarks
('user-003', 'menfess-004', NOW() - INTERVAL '7.5 hours'),
('user-003', 'menfess-006', NOW() - INTERVAL '11.5 hours'),

-- User-004 bookmarks
('user-004', 'menfess-001', NOW() - INTERVAL '1.2 hours'),
('user-004', 'menfess-005', NOW() - INTERVAL '9.2 hours');

-- =====================================================
-- 6. DUMMY REPORTS
-- =====================================================

-- Insert beberapa reports untuk testing admin features
INSERT INTO reports (id, menfess_id, reporter_id, reason, status, created_at) VALUES
('report-001', 'menfess-013', 'user-006', 'Inappropriate content', 'pending', NOW() - INTERVAL '12 hours'),
('report-002', 'menfess-014', 'user-007', 'Spam or misleading', 'reviewing', NOW() - INTERVAL '8 hours'),
('report-003', 'menfess-015', 'user-008', 'Harassment', 'resolved', NOW() - INTERVAL '2 days');

-- =====================================================
-- 7. DUMMY BANNED USERS
-- =====================================================

-- Insert banned user record
INSERT INTO banned_users (id, user_id, banned_by, reason, expires_at, notes, is_active, created_at) VALUES
('ban-001', 'user-banned', 'mod-001', 'Repeated inappropriate posts', NOW() + INTERVAL '7 days', 'First offense - temporary ban', true, NOW() - INTERVAL '1 day');

-- =====================================================
-- 8. DUMMY ADMIN LOGS
-- =====================================================

-- Insert admin action logs
INSERT INTO admin_logs (id, admin_id, action, target_type, target_id, details, created_at) VALUES
('log-001', 'mod-001', 'ban_user', 'user', 'user-banned', '{"reason": "Inappropriate content", "duration": "7 days"}', NOW() - INTERVAL '1 day'),
('log-002', 'mod-001', 'resolve_report', 'report', 'report-003', '{"resolution": "Content removed", "action_taken": "warning"}', NOW() - INTERVAL '2 days'),
('log-003', 'admin-001', 'change_role', 'user', 'mod-002', '{"old_role": "user", "new_role": "moderator"}', NOW() - INTERVAL '5 days'),
('log-004', 'mod-002', 'delete_menfess', 'menfess', 'menfess-deleted-001', '{"reason": "Spam content"}', NOW() - INTERVAL '3 days');

-- =====================================================
-- 9. UPDATE COUNTERS
-- =====================================================

-- Update menfess counters to match inserted data
UPDATE menfess SET 
    like_count = (SELECT COUNT(*) FROM reactions WHERE menfess_id = menfess.id AND type = 'like'),
    comment_count = (SELECT COUNT(*) FROM comments WHERE menfess_id = menfess.id)
WHERE id IN ('menfess-001', 'menfess-002', 'menfess-004', 'menfess-005');

-- =====================================================
-- 10. VERIFICATION QUERIES
-- =====================================================

-- Uncomment these to verify data insertion
/*
-- Check users count
SELECT role, COUNT(*) as count FROM users GROUP BY role;

-- Check menfess count
SELECT COUNT(*) as total_menfess FROM menfess;

-- Check recent menfess with engagement
SELECT id, LEFT(message, 50) as preview, like_count, comment_count, view_count 
FROM menfess 
ORDER BY created_at DESC 
LIMIT 10;

-- Check comments count
SELECT COUNT(*) as total_comments FROM comments;

-- Check reactions count
SELECT COUNT(*) as total_likes FROM reactions WHERE type = 'like';

-- Check bookmarks count
SELECT COUNT(*) as total_bookmarks FROM bookmarks;

-- Check reports by status
SELECT status, COUNT(*) as count FROM reports GROUP BY status;

-- Check admin logs
SELECT action, COUNT(*) as count FROM admin_logs GROUP BY action;
*/

-- =====================================================
-- DUMMY DATA INSERTION COMPLETE!
-- =====================================================
-- Total inserted:
-- - 14 Users (10 regular + 2 moderators + 1 super admin + 1 banned)
-- - 15 Menfess posts (various engagement levels)
-- - 12 Comments (distributed across popular posts)
-- - 20+ Reactions/Likes (realistic distribution)
-- - 10 Bookmarks (user preferences)
-- - 3 Reports (different statuses)
-- - 1 Banned user record
-- - 4 Admin action logs
-- =====================================================