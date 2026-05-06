# ✅ ADMIN DASHBOARD SETUP CHECKLIST

Quick checklist untuk setup Admin Dashboard System dalam 10 menit!

---

## 🚀 QUICK START (10 MENIT)

### STEP 1: SUPABASE SETUP (5 menit)

#### 1.1 Buka Supabase Dashboard
- [ ] Login ke https://supabase.com
- [ ] Pilih project "Menfess App"
- [ ] Klik "SQL Editor" di sidebar kiri

#### 1.2 Jalankan Migration
- [ ] Klik "+ New query"
- [ ] Buka file: `supabase/migrations/20260501_admin_dashboard_system.sql`
- [ ] Copy semua isi file (Ctrl+A, Ctrl+C)
- [ ] Paste ke SQL Editor (Ctrl+V)
- [ ] Klik tombol "RUN" (hijau, pojok kanan atas)
- [ ] Tunggu sampai muncul: ✅ "Success. No rows returned"

#### 1.3 Verify Tables
- [ ] Klik "Table Editor" di sidebar
- [ ] Cek ada 3 table baru:
  - [ ] `reports`
  - [ ] `banned_users`
  - [ ] `admin_logs`

#### 1.4 Verify Functions
- [ ] Klik "Database" → "Functions" di sidebar
- [ ] Cek ada 7 functions:
  - [ ] `admin_delete_menfess`
  - [ ] `admin_ban_user`
  - [ ] `admin_unban_user`
  - [ ] `admin_change_role`
  - [ ] `admin_resolve_report`
  - [ ] `admin_dismiss_report`
  - [ ] `admin_get_users`

---

### STEP 2: CREATE SUPER ADMIN (3 menit)

#### 2.1 Find Your User ID
- [ ] Buka SQL Editor → "+ New query"
- [ ] Paste query ini:
```sql
SELECT id, email, display_name, role 
FROM auth.users 
ORDER BY created_at DESC;
```
- [ ] Klik "RUN"
- [ ] Copy ID dari baris dengan email kamu
- [ ] Paste ID ke notepad (kita butuh sebentar lagi)

#### 2.2 Upgrade to Super Admin
- [ ] Buka SQL Editor → "+ New query"
- [ ] Paste query ini (GANTI `YOUR_USER_ID` dengan ID yang tadi):
```sql
UPDATE public.users 
SET role = 'super_admin' 
WHERE id = 'YOUR_USER_ID';
```
- [ ] Klik "RUN"
- [ ] Cek muncul: ✅ "Success. 1 rows affected"

#### 2.3 Verify Super Admin
- [ ] Buka SQL Editor → "+ New query"
- [ ] Paste query ini:
```sql
SELECT id, display_name, role 
FROM public.users 
WHERE role = 'super_admin';
```
- [ ] Klik "RUN"
- [ ] Cek akun kamu muncul dengan role = 'super_admin'

---

### STEP 3: TEST FLUTTER APP (2 menit)

#### 3.1 Restart App
- [ ] Buka terminal di VS Code (Ctrl+`)
- [ ] Tekan `R` (hot restart)
- [ ] Atau stop app (Ctrl+C) → `flutter run`

#### 3.2 Login
- [ ] Logout dari app (kalau sudah login)
- [ ] Login lagi dengan akun super admin

#### 3.3 Check Admin Button
- [ ] Lihat pojok kanan atas home screen
- [ ] Cek ada tombol UNGU dengan icon ⚙️
- [ ] Kalau ada, berarti **BERHASIL!** 🎉

#### 3.4 Open Admin Dashboard
- [ ] Tap tombol ungu
- [ ] Cek admin dashboard terbuka
- [ ] Cek stats cards menampilkan angka

---

## 🧪 TESTING FEATURES (5 menit)

### Test 1: View Dashboard Stats
- [ ] Buka Admin Dashboard
- [ ] Cek stats cards:
  - [ ] Total Users (ada angka)
  - [ ] Active Today (ada angka)
  - [ ] Total Posts (ada angka)
  - [ ] Pending Reports (ada angka)

### Test 2: Delete Menfess
- [ ] Tap "MODERATE CONTENT"
- [ ] Pilih menfess
- [ ] Tap "DELETE" (merah)
- [ ] Confirm → Masukkan reason: "Test delete"
- [ ] Tap "DELETE" lagi
- [ ] Cek menfess hilang dari list

### Test 3: Ban User
- [ ] Tap "MANAGE USERS"
- [ ] Pilih user (jangan diri sendiri!)
- [ ] Tap "BAN" (merah)
- [ ] Isi form:
  - Reason: "Test ban"
  - Duration: Permanent
- [ ] Tap "BAN USER"
- [ ] Cek user ada badge "BANNED"

### Test 4: Unban User
- [ ] Di "MANAGE USERS", cari user yang tadi di-ban
- [ ] Tap "UNBAN" (hijau)
- [ ] Confirm
- [ ] Cek badge "BANNED" hilang

### Test 5: Change Role (Super Admin Only)
- [ ] Di "MANAGE USERS", pilih user
- [ ] Tap "CHANGE ROLE" (biru)
- [ ] Pilih role baru: "Moderator"
- [ ] Tap "CHANGE ROLE"
- [ ] Cek role user berubah

---

## ✅ SUCCESS CRITERIA

Kalau semua ini ✅, berarti setup **100% BERHASIL!**

### Database Setup
- [x] Migration script berhasil dijalankan
- [x] 3 table baru dibuat (reports, banned_users, admin_logs)
- [x] 7 RPC functions dibuat
- [x] Table users punya kolom baru (role, is_banned, last_login_at)

### Super Admin Created
- [x] User ID ditemukan
- [x] Role updated jadi 'super_admin'
- [x] Verified dengan query SELECT

### Flutter App Working
- [x] App berhasil di-restart
- [x] Login dengan akun super admin berhasil
- [x] Tombol admin ungu muncul
- [x] Admin dashboard terbuka tanpa error
- [x] Stats cards menampilkan data

### Features Working
- [x] Delete menfess berhasil
- [x] Ban user berhasil
- [x] Unban user berhasil
- [x] Change role berhasil (super admin only)

---

## 🐛 TROUBLESHOOTING QUICK FIX

### ❌ Tombol Admin Tidak Muncul

**Quick Fix:**
```sql
-- 1. Cek role
SELECT id, display_name, role FROM public.users WHERE id = 'YOUR_USER_ID';

-- 2. Kalau role = 'user', update jadi super_admin
UPDATE public.users SET role = 'super_admin' WHERE id = 'YOUR_USER_ID';

-- 3. Hot restart app (tekan R di terminal)
```

---

### ❌ Error "Unauthorized: Admin access required"

**Quick Fix:**
```sql
-- 1. Verify RLS policies ada
SELECT * FROM pg_policies WHERE tablename IN ('reports', 'banned_users', 'admin_logs');

-- 2. Kalau kosong, jalankan migration lagi
-- (Copy-paste dari file 20260501_admin_dashboard_system.sql)
```

---

### ❌ Function tidak ditemukan

**Quick Fix:**
```sql
-- 1. Cek functions ada
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE 'admin_%';

-- 2. Kalau kosong, jalankan migration lagi
```

---

### ❌ Stats Cards Loading Terus

**Quick Fix:**
```sql
-- 1. Cek view admin_stats ada
SELECT * FROM admin_stats;

-- 2. Kalau error, jalankan migration lagi
```

---

## 📋 PRE-FLIGHT CHECKLIST

Sebelum mulai setup, pastikan:

- [ ] Supabase project sudah ada dan running
- [ ] Flutter app sudah terkoneksi ke Supabase
- [ ] Minimal 1 user sudah terdaftar di app
- [ ] Punya akses ke Supabase Dashboard
- [ ] Punya akses ke VS Code / code editor
- [ ] Flutter app bisa di-run di emulator/device

---

## 🎯 POST-SETUP TASKS

Setelah setup selesai:

### Immediate (Hari ini)
- [ ] Test semua fitur admin
- [ ] Buat 1-2 moderator untuk testing
- [ ] Test permission moderator vs super admin
- [ ] Backup database (Supabase Dashboard → Database → Backups)

### Short-term (Minggu ini)
- [ ] Implement Reports Management Screen (optional)
- [ ] Implement Audit Logs Screen (optional)
- [ ] Add analytics charts (optional)
- [ ] Write admin user guide

### Long-term (Bulan ini)
- [ ] Test di staging environment
- [ ] Deploy ke production
- [ ] Monitor admin activity
- [ ] Collect feedback dari moderators

---

## 📚 DOCUMENTATION REFERENCE

Kalau butuh info lebih detail:

- **Setup Tutorial:** `SUPABASE_SETUP_TUTORIAL.md`
- **SQL Commands:** `ADMIN_SQL_COMMANDS.md`
- **Visual Guide:** `ADMIN_DASHBOARD_VISUAL_GUIDE.md`
- **Implementation Summary:** `ADMIN_DASHBOARD_IMPLEMENTATION_SUMMARY.md`
- **Database Schema:** `supabase/ADMIN_DASHBOARD_MIGRATION_README.md`

---

## 🆘 NEED HELP?

Kalau stuck atau ada error:

1. **Screenshot error message**
2. **Note step mana yang bermasalah**
3. **Copy error log dari Flutter console**
4. **Kasih tau aku!**

---

## 🎉 CONGRATULATIONS!

Kalau kamu sampai sini dan semua ✅, berarti:

**ADMIN DASHBOARD SYSTEM SUDAH JALAN 100%!** 🚀

Sekarang kamu punya:
- ✅ Role-based access control
- ✅ Content moderation tools
- ✅ User management system
- ✅ Audit logging
- ✅ Real-time dashboard stats

**Next:** Explore fitur-fitur admin dan mulai moderate content! 💪

---

**Created:** May 3, 2026  
**Version:** 1.0  
**Estimated Time:** 10-15 minutes  
**Difficulty:** Easy 🟢
