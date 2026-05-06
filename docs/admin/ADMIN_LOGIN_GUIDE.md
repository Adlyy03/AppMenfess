# 🔐 ADMIN LOGIN GUIDE

Panduan lengkap cara setup dan login sebagai admin di Menfess App.

---

## 📋 OVERVIEW

Sistem admin sekarang menggunakan **akun terpisah** untuk admin. Ketika login dengan akun admin (role `super_admin` atau `moderator`), kamu akan langsung masuk ke **Admin Dashboard**, bukan ke home screen user biasa.

### Alur Login:

```
┌─────────────────┐
│  Login Screen   │
└────────┬────────┘
         │
         ├─── Login dengan akun USER ──────> Main Navigation (Home, Create, Profile, dll)
         │
         └─── Login dengan akun ADMIN ─────> Admin Dashboard (Stats, Moderate, Manage Users)
```

---

## 🚀 SETUP ADMIN ACCOUNT (5 MENIT)

### STEP 1: Buka Supabase Dashboard

1. Login ke https://supabase.com
2. Pilih project "Menfess App"
3. Klik **"SQL Editor"** di sidebar kiri

### STEP 2: Jalankan SQL Script

1. Klik **"+ New query"**
2. Buka file: `CREATE_ADMIN_ACCOUNT.sql`
3. **EDIT** bagian ini (baris 18-20):

```sql
admin_email text := 'admin@menfess.com';     -- GANTI dengan email admin kamu
admin_password text := 'admin123456';         -- GANTI dengan password kuat
admin_display_name text := 'Super Admin';     -- GANTI dengan nama admin
```

4. Copy semua isi file (Ctrl+A, Ctrl+C)
5. Paste ke SQL Editor (Ctrl+V)
6. Klik tombol **"RUN"** (hijau, pojok kanan atas)
7. Tunggu sampai muncul: ✅ **"Admin account created successfully!"**

### STEP 3: Verify Admin Account

Jalankan query ini untuk cek admin account:

```sql
SELECT 
  u.id,
  au.email,
  u.display_name,
  u.role,
  u.created_at
FROM public.users u
JOIN auth.users au ON au.id = u.id
WHERE u.role IN ('super_admin', 'moderator')
ORDER BY u.created_at DESC;
```

Kalau muncul data admin kamu, berarti **BERHASIL!** ✅

---

## 🔑 LOGIN SEBAGAI ADMIN

### Cara Login:

1. **Buka app** (Flutter run atau emulator)
2. Di **login screen**, masukkan:
   - **Email**: `admin@menfess.com` (atau email yang kamu set)
   - **Password**: `admin123456` (atau password yang kamu set)
3. Tap **"MASUK"**
4. Kamu akan **langsung masuk ke Admin Dashboard** (bukan home screen)

### Tampilan Admin Dashboard:

```
┌─────────────────────────────────────────┐
│  🛡️ ADMIN DASHBOARD          [LOGOUT]  │
├─────────────────────────────────────────┤
│                                         │
│  📊 OVERVIEW                            │
│  ┌──────────┬──────────┬──────────┐    │
│  │ 150      │ 23       │ 1,234    │    │
│  │ Users    │ Active   │ Posts    │    │
│  └──────────┴──────────┴──────────┘    │
│                                         │
│  📈 TODAY'S ACTIVITY                    │
│  ┌──────────┬──────────┬──────────┐    │
│  │ 5        │ 12       │ 45       │    │
│  │ New Users│ New Posts│ Reactions│    │
│  └──────────┴──────────┴──────────┘    │
│                                         │
│  ⚡ QUICK ACTIONS                       │
│  [MODERATE CONTENT]                     │
│  [MANAGE USERS]                         │
│  [VIEW REPORTS]                         │
│  [AUDIT LOGS]                           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎯 FITUR ADMIN

### 1. **Dashboard** (Halaman Utama)
- Lihat statistik platform (total users, posts, reports)
- Lihat aktivitas hari ini (new users, new posts, reactions)
- Quick actions untuk navigasi

### 2. **Moderate Content**
- Lihat semua menfess posts
- Filter: All, Reported, Recent
- Delete menfess yang inappropriate
- Bulk delete actions

### 3. **Manage Users**
- Search users by name
- Filter by role (User, Moderator, Super Admin)
- Ban/unban users dengan reason dan duration
- Change user roles (super admin only)
- View user statistics

### 4. **View Reports** (Coming Soon)
- Lihat laporan dari users
- Resolve/dismiss reports
- Delete reported content

### 5. **Audit Logs** (Coming Soon)
- Lihat history semua admin actions
- Filter by action type
- Export logs

---

## 🔐 ROLE PERMISSIONS

### **User** (Default)
- ❌ Tidak bisa akses admin dashboard
- ✅ Akses normal app features (home, create, profile)

### **Moderator**
- ✅ View dashboard statistics
- ✅ Delete menfess posts
- ✅ Ban/unban users (kecuali super admins)
- ✅ View and manage reports
- ✅ View audit logs
- ❌ Tidak bisa change user roles

### **Super Admin**
- ✅ Semua fitur moderator
- ✅ Change user roles (user ↔ moderator ↔ super_admin)
- ✅ Ban/unban any user (termasuk moderators)
- ✅ Full system access

---

## 🚪 LOGOUT DARI ADMIN

### Cara Logout:

1. Di **Admin Dashboard**, tap tombol **LOGOUT** (merah, pojok kanan atas)
2. Confirm di dialog: **"LOGOUT ADMIN?"**
3. Tap **"LOGOUT"**
4. Kamu akan kembali ke **login screen**

---

## 🔄 SWITCH ANTARA ADMIN & USER

### Scenario 1: Punya 2 Akun Terpisah

**Akun Admin:**
- Email: `admin@menfess.com`
- Role: `super_admin`
- Login → Masuk ke Admin Dashboard

**Akun User:**
- Email: `user@example.com`
- Role: `user`
- Login → Masuk ke Main Navigation (Home)

**Cara Switch:**
1. Logout dari akun saat ini
2. Login dengan akun yang lain

### Scenario 2: Upgrade User Jadi Admin

Kalau kamu mau upgrade akun user biasa jadi admin:

```sql
-- Cari user ID
SELECT id, email, display_name FROM auth.users WHERE email = 'user@example.com';

-- Upgrade jadi super_admin
UPDATE public.users SET role = 'super_admin' WHERE id = 'USER_ID_HERE';
```

Setelah upgrade:
- Logout dari app
- Login lagi
- Sekarang masuk ke Admin Dashboard

---

## 🛠️ TROUBLESHOOTING

### ❌ Problem: Login berhasil tapi masuk ke Home, bukan Admin Dashboard

**Solution:**
```sql
-- Cek role user
SELECT id, display_name, role FROM public.users WHERE id = 'YOUR_USER_ID';

-- Kalau role = 'user', update jadi super_admin
UPDATE public.users SET role = 'super_admin' WHERE id = 'YOUR_USER_ID';
```
- Hot restart app (tekan 'R' di terminal)
- Login lagi

---

### ❌ Problem: Error "Invalid login credentials"

**Solution:**
- Cek email dan password benar
- Pastikan admin account sudah dibuat (run SQL script lagi)
- Verify dengan query:
```sql
SELECT email FROM auth.users WHERE email = 'admin@menfess.com';
```

---

### ❌ Problem: Admin Dashboard blank/error

**Solution:**
```sql
-- Cek admin_stats view ada
SELECT * FROM admin_stats;

-- Kalau error, run migration lagi
-- (Copy dari file: supabase/migrations/20260501_admin_dashboard_system.sql)
```

---

## 📝 QUICK REFERENCE

### Default Admin Credentials (Setelah Run Script)

```
Email: admin@menfess.com
Password: admin123456
Role: super_admin
```

⚠️ **PENTING:**
- **GANTI password** setelah first login!
- **Jangan share** credentials ini!
- Gunakan **email yang valid** untuk production

### SQL Commands Cheat Sheet

```sql
-- Create admin account
-- (Lihat file: CREATE_ADMIN_ACCOUNT.sql)

-- Verify admin accounts
SELECT u.id, au.email, u.display_name, u.role
FROM public.users u
JOIN auth.users au ON au.id = u.id
WHERE u.role IN ('super_admin', 'moderator');

-- Upgrade user to admin
UPDATE public.users SET role = 'super_admin' WHERE id = 'USER_ID';

-- Downgrade admin to user
UPDATE public.users SET role = 'user' WHERE id = 'USER_ID';

-- Delete admin account (HATI-HATI!)
DELETE FROM auth.users WHERE email = 'admin@menfess.com';
```

---

## 🎉 SUMMARY

### Alur Lengkap:

1. **Setup** (Sekali aja):
   - Run `CREATE_ADMIN_ACCOUNT.sql` di Supabase
   - Verify admin account created

2. **Login**:
   - Buka app → Login screen
   - Masukkan email & password admin
   - Tap "MASUK"
   - **Langsung masuk ke Admin Dashboard** ✅

3. **Logout**:
   - Tap tombol "LOGOUT" di Admin Dashboard
   - Confirm → Kembali ke login screen

4. **Switch Account**:
   - Logout → Login dengan akun lain
   - Admin account → Admin Dashboard
   - User account → Main Navigation

---

## 📚 RELATED DOCS

- **Setup Database**: `ADMIN_SETUP_CHECKLIST.md`
- **SQL Commands**: `ADMIN_SQL_COMMANDS.md`
- **Implementation**: `ADMIN_DASHBOARD_IMPLEMENTATION_SUMMARY.md`
- **Visual Guide**: `ADMIN_DASHBOARD_VISUAL_GUIDE.md`

---

**Created:** May 7, 2026  
**Version:** 2.0 (Separate Admin Login)  
**Status:** ✅ Ready to Use

---

**Happy Administrating!** 🚀🛡️
