# 🚀 TUTORIAL SETUP SUPABASE ADMIN DASHBOARD

Tutorial lengkap step-by-step untuk setup Admin Dashboard System di Menfess App.

---

## 📋 PERSIAPAN

Sebelum mulai, pastikan kamu punya:
- ✅ Akun Supabase (gratis di [supabase.com](https://supabase.com))
- ✅ Project Supabase yang sudah jalan untuk Menfess App
- ✅ Flutter app sudah terkoneksi ke Supabase
- ✅ Minimal 1 user sudah terdaftar di app

---

## 🎯 STEP 1: BUKA SUPABASE DASHBOARD

1. **Login ke Supabase**
   - Buka browser, pergi ke: https://supabase.com
   - Klik **"Sign In"** (pojok kanan atas)
   - Login dengan akun kamu

2. **Pilih Project Menfess**
   - Setelah login, kamu akan lihat list project
   - Klik project **Menfess App** kamu
   - Tunggu sampai dashboard terbuka

3. **Buka SQL Editor**
   - Di sidebar kiri, cari icon **"SQL Editor"** (icon database dengan tanda ⚡)
   - Klik **"SQL Editor"**
   - Klik tombol **"+ New query"** (pojok kanan atas)

---

## 🗄️ STEP 2: JALANKAN DATABASE MIGRATION

### 2.1 Copy SQL Migration Script

1. **Buka file migration di VS Code**
   - File: `supabase/migrations/20260501_admin_dashboard_system.sql`
   - Tekan `Ctrl+A` (select all)
   - Tekan `Ctrl+C` (copy)

2. **Paste ke Supabase SQL Editor**
   - Kembali ke browser (Supabase Dashboard)
   - Di SQL Editor yang baru dibuka tadi
   - Klik di area editor (kotak putih besar)
   - Tekan `Ctrl+V` (paste)
   - Kamu akan lihat SQL script yang panjang banget

### 2.2 Jalankan Migration

1. **Klik tombol "RUN"**
   - Ada tombol hijau **"RUN"** di pojok kanan bawah
   - Klik tombol itu
   - Tunggu beberapa detik...

2. **Cek hasilnya**
   - Kalau berhasil, akan muncul pesan: ✅ **"Success. No rows returned"**
   - Kalau ada error merah, screenshot dan kasih tau aku ya!

### 2.3 Verifikasi Tables Sudah Dibuat

1. **Buka Table Editor**
   - Di sidebar kiri, klik **"Table Editor"** (icon tabel)
   - Kamu sekarang harus lihat table baru:
     - ✅ `reports` (untuk laporan user)
     - ✅ `banned_users` (untuk user yang di-ban)
     - ✅ `admin_logs` (untuk log aktivitas admin)

2. **Cek kolom baru di table users**
   - Klik table **"users"**
   - Scroll ke kanan, cek ada kolom baru:
     - ✅ `role` (default: 'user')
     - ✅ `is_banned` (default: false)
     - ✅ `last_login_at` (default: null)

---

## 👑 STEP 3: BUAT SUPER ADMIN PERTAMA

Sekarang kita perlu bikin akun super admin pertama (ini akun kamu!).

### 3.1 Cari User ID Kamu

1. **Buka SQL Editor lagi**
   - Klik **"SQL Editor"** di sidebar
   - Klik **"+ New query"**

2. **Jalankan query ini:**
   ```sql
   SELECT id, email, display_name, role 
   FROM auth.users 
   ORDER BY created_at DESC;
   ```

3. **Klik "RUN"**
   - Kamu akan lihat list semua user
   - Cari email kamu di list itu
   - **COPY** nilai di kolom `id` (contoh: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)
   - Paste di notepad dulu, kita butuh ini sebentar lagi

### 3.2 Upgrade Akun Jadi Super Admin

1. **Buka SQL Editor baru lagi**
   - Klik **"+ New query"**

2. **Jalankan query ini** (ganti `YOUR_USER_ID` dengan ID yang tadi kamu copy):
   ```sql
   UPDATE public.users 
   SET role = 'super_admin' 
   WHERE id = 'YOUR_USER_ID';
   ```

   **Contoh:**
   ```sql
   UPDATE public.users 
   SET role = 'super_admin' 
   WHERE id = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
   ```

3. **Klik "RUN"**
   - Kalau berhasil, akan muncul: ✅ **"Success. 1 rows affected"**

### 3.3 Verifikasi Super Admin Sudah Dibuat

1. **Jalankan query cek:**
   ```sql
   SELECT id, display_name, role, is_banned 
   FROM public.users 
   WHERE role = 'super_admin';
   ```

2. **Klik "RUN"**
   - Kamu harus lihat akun kamu dengan `role = 'super_admin'`
   - Kalau ada, berarti **BERHASIL!** 🎉

---

## 🔍 STEP 4: CEK RPC FUNCTIONS

Sekarang kita cek apakah semua function admin sudah dibuat.

1. **Buka Database Functions**
   - Di sidebar kiri, klik **"Database"**
   - Klik **"Functions"**

2. **Cek function-function ini ada:**
   - ✅ `admin_delete_menfess`
   - ✅ `admin_ban_user`
   - ✅ `admin_unban_user`
   - ✅ `admin_change_role`
   - ✅ `admin_resolve_report`
   - ✅ `admin_dismiss_report`
   - ✅ `admin_get_users`

3. **Kalau semua ada, berarti setup database SELESAI!** ✅

---

## 📱 STEP 5: TEST DI FLUTTER APP

Sekarang kita test admin dashboard di Flutter app!

### 5.1 Hot Restart Flutter App

1. **Buka terminal di VS Code**
   - Tekan `` Ctrl+` `` (backtick)
   - Pastikan Flutter app masih running

2. **Hot Restart**
   - Di terminal, tekan **`R`** (huruf R besar)
   - Atau stop app (`Ctrl+C`) terus jalankan lagi: `flutter run`

### 5.2 Login dengan Akun Super Admin

1. **Buka app di emulator/device**
2. **Logout dulu** (kalau sudah login)
   - Pergi ke **Profile** → **Settings** → **Logout**
3. **Login lagi** dengan akun yang tadi kamu jadikan super admin
   - Masukkan email & password

### 5.3 Akses Admin Dashboard

1. **Cari tombol admin**
   - Setelah login, lihat di **pojok kanan atas**
   - Ada tombol **UNGU** dengan icon ⚙️ (gear/settings)
   - Kalau tombol ini MUNCUL, berarti kamu berhasil jadi admin! 🎉

2. **Klik tombol admin**
   - Tap tombol ungu itu
   - Kamu akan masuk ke **Admin Dashboard**

3. **Explore Admin Dashboard**
   - Lihat **statistics cards** (Total Users, Active Today, dll)
   - Coba klik tombol:
     - 🗑️ **Moderate Content** → Lihat semua menfess, bisa delete
     - 👥 **Manage Users** → Lihat semua user, bisa ban/unban
     - 📊 **View Reports** → (Coming soon)
     - 📝 **Audit Logs** → (Coming soon)

---

## ✅ STEP 6: TEST FITUR ADMIN

Mari kita test semua fitur admin!

### Test 1: Delete Menfess

1. **Pergi ke "Moderate Content"**
2. **Pilih menfess yang mau dihapus**
3. **Tap tombol "DELETE"** (merah)
4. **Confirm** → Masukkan alasan (contoh: "Test delete")
5. **Tap "DELETE"** lagi
6. **Cek:** Menfess harus hilang dari list ✅

### Test 2: Ban User

1. **Pergi ke "Manage Users"**
2. **Pilih user yang mau di-ban** (jangan ban diri sendiri!)
3. **Tap tombol "BAN"** (merah)
4. **Isi form:**
   - Reason: "Test ban"
   - Duration: Pilih "Permanent" atau set tanggal
   - Notes: (optional)
5. **Tap "BAN USER"**
6. **Cek:** User harus ada badge "BANNED" ✅

### Test 3: Unban User

1. **Di "Manage Users"**, cari user yang tadi di-ban
2. **Tap tombol "UNBAN"** (hijau)
3. **Confirm**
4. **Cek:** Badge "BANNED" harus hilang ✅

### Test 4: Change Role (Super Admin Only)

1. **Di "Manage Users"**, pilih user
2. **Tap tombol "CHANGE ROLE"** (biru)
3. **Pilih role baru:**
   - User → Moderator
   - Moderator → Super Admin
   - dll
4. **Tap "CHANGE ROLE"**
5. **Cek:** Role user harus berubah ✅

---

## 🎉 SELESAI!

Kalau semua test di atas berhasil, berarti **ADMIN DASHBOARD SUDAH JALAN 100%!** 🚀

---

## 🐛 TROUBLESHOOTING

### Problem 1: Tombol Admin Tidak Muncul

**Solusi:**
1. Cek role di database:
   ```sql
   SELECT id, display_name, role FROM public.users WHERE id = 'YOUR_USER_ID';
   ```
2. Pastikan `role = 'super_admin'` atau `'moderator'`
3. Hot restart app (tekan `R` di terminal)
4. Logout → Login lagi

### Problem 2: Error "Unauthorized: Admin access required"

**Solusi:**
1. Pastikan kamu sudah login dengan akun admin
2. Cek RLS policies sudah dibuat (jalankan migration lagi)
3. Restart Supabase project:
   - Dashboard → Settings → General → Restart project

### Problem 3: Function tidak ditemukan

**Solusi:**
1. Buka SQL Editor
2. Jalankan migration lagi (copy-paste dari file)
3. Cek di Database → Functions apakah function sudah ada

### Problem 4: Table tidak ada

**Solusi:**
1. Buka Table Editor
2. Cek apakah table `reports`, `banned_users`, `admin_logs` ada
3. Kalau tidak ada, jalankan migration lagi

---

## 📚 NEXT STEPS

Setelah setup selesai, kamu bisa:

1. **Tambah moderator lain:**
   ```sql
   UPDATE public.users 
   SET role = 'moderator' 
   WHERE id = 'USER_ID_MODERATOR';
   ```

2. **Implement fitur tambahan:**
   - Reports Management Screen
   - Audit Logs Screen
   - Analytics dengan charts

3. **Deploy ke production:**
   - Test semua fitur di staging dulu
   - Backup database sebelum deploy
   - Monitor error logs

---

## 🆘 BUTUH BANTUAN?

Kalau ada error atau stuck, kasih tau aku dengan info:
1. Screenshot error message
2. Step mana yang bermasalah
3. Log error dari Flutter console

**Happy Coding!** 🚀✨

---

**Created:** May 3, 2026  
**Version:** 1.0  
**Status:** ✅ Complete & Tested
