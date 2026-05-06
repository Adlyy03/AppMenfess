# 📸 ADMIN DASHBOARD - VISUAL GUIDE

Panduan visual dengan screenshot untuk setup dan penggunaan Admin Dashboard.

---

## 🎯 TABLE OF CONTENTS

1. [Supabase Dashboard Navigation](#1-supabase-dashboard-navigation)
2. [Running SQL Migration](#2-running-sql-migration)
3. [Creating Super Admin](#3-creating-super-admin)
4. [Verifying Setup](#4-verifying-setup)
5. [Flutter App Admin Access](#5-flutter-app-admin-access)
6. [Admin Features Walkthrough](#6-admin-features-walkthrough)

---

## 1. SUPABASE DASHBOARD NAVIGATION

### 1.1 Login Page
```
┌─────────────────────────────────────────────┐
│  SUPABASE                    [Sign In]      │
├─────────────────────────────────────────────┤
│                                             │
│         Build in a weekend                  │
│         Scale to millions                   │
│                                             │
│         [Start your project] →              │
│                                             │
└─────────────────────────────────────────────┘
```
**Action:** Klik "Sign In" → Login dengan akun kamu

---

### 1.2 Project Dashboard
```
┌─────────────────────────────────────────────┐
│  ☰  Supabase                    [Profile]   │
├─────────────────────────────────────────────┤
│  Your Projects                              │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  📱 Menfess App                     │   │
│  │  Active • Free Plan                 │   │
│  │  [Open Dashboard] →                 │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```
**Action:** Klik "Open Dashboard" pada project Menfess App

---

### 1.3 Sidebar Navigation
```
┌──────────────────┬──────────────────────────┐
│  🏠 Home         │  Welcome to Menfess App  │
│  📊 Table Editor │                          │
│  🔐 Auth         │  Project Overview        │
│  💾 Storage      │  - API URL               │
│  ⚡ SQL Editor   │  - Database Status       │
│  📈 Database     │  - Storage Usage         │
│  ⚙️  Settings    │                          │
└──────────────────┴──────────────────────────┘
```
**Action:** Klik "⚡ SQL Editor" di sidebar

---

## 2. RUNNING SQL MIGRATION

### 2.1 SQL Editor - New Query
```
┌─────────────────────────────────────────────┐
│  SQL Editor              [+ New query]      │
├─────────────────────────────────────────────┤
│  Recent queries:                            │
│  - Query 1 (2 hours ago)                    │
│  - Query 2 (1 day ago)                      │
│                                             │
│  [+ New query] ← KLIK INI                   │
└─────────────────────────────────────────────┘
```
**Action:** Klik "+ New query"

---

### 2.2 SQL Editor - Paste Migration
```
┌─────────────────────────────────────────────┐
│  Untitled query                   [RUN] ←   │
├─────────────────────────────────────────────┤
│  1  -- ADMIN DASHBOARD SYSTEM MIGRATION     │
│  2  -- ================================      │
│  3                                          │
│  4  ALTER TABLE public.users                │
│  5  ADD COLUMN IF NOT EXISTS role TEXT...   │
│  6                                          │
│  ... (500+ lines of SQL)                    │
│                                             │
└─────────────────────────────────────────────┘
```
**Action:** 
1. Paste SQL dari file `20260501_admin_dashboard_system.sql`
2. Klik tombol "RUN" (pojok kanan atas)

---

### 2.3 Success Message
```
┌─────────────────────────────────────────────┐
│  ✅ Success. No rows returned               │
│  Query executed in 2.3s                     │
└─────────────────────────────────────────────┘
```
**Expected:** Pesan hijau "Success. No rows returned"

---

### 2.4 Error Example (If Something Wrong)
```
┌─────────────────────────────────────────────┐
│  ❌ Error                                    │
│  relation "public.users" does not exist     │
│  LINE 4: ALTER TABLE public.users           │
└─────────────────────────────────────────────┘
```
**If Error:** Screenshot dan kasih tau aku!

---

## 3. CREATING SUPER ADMIN

### 3.1 Find Your User ID
```
┌─────────────────────────────────────────────┐
│  SQL Editor                       [RUN]     │
├─────────────────────────────────────────────┤
│  SELECT id, email, display_name, role       │
│  FROM auth.users                            │
│  ORDER BY created_at DESC;                  │
└─────────────────────────────────────────────┘
```

**Result:**
```
┌──────────────────────────────────────────────────────────────┐
│  id                                  │ email        │ role   │
├──────────────────────────────────────┼──────────────┼────────┤
│  a1b2c3d4-e5f6-7890-abcd-ef12345678  │ you@mail.com │ user   │
│  b2c3d4e5-f6g7-8901-bcde-fg23456789  │ test@mail.com│ user   │
└──────────────────────────────────────────────────────────────┘
```
**Action:** Copy ID dari baris dengan email kamu

---

### 3.2 Upgrade to Super Admin
```
┌─────────────────────────────────────────────┐
│  SQL Editor                       [RUN]     │
├─────────────────────────────────────────────┤
│  UPDATE public.users                        │
│  SET role = 'super_admin'                   │
│  WHERE id = 'a1b2c3d4-e5f6-7890-abcd...';   │
└─────────────────────────────────────────────┘
```

**Result:**
```
┌─────────────────────────────────────────────┐
│  ✅ Success. 1 rows affected                │
└─────────────────────────────────────────────┘
```
**Expected:** "1 rows affected"

---

## 4. VERIFYING SETUP

### 4.1 Table Editor - Check New Tables
```
┌──────────────────┬──────────────────────────┐
│  Tables          │  Table: reports          │
│  ✅ users        │                          │
│  ✅ menfess      │  Columns:                │
│  ✅ comments     │  - id (uuid)             │
│  ✅ reactions    │  - menfess_id (uuid)     │
│  ✅ reports      │  - reporter_id (uuid)    │
│  ✅ banned_users │  - reason (text)         │
│  ✅ admin_logs   │  - status (text)         │
└──────────────────┴──────────────────────────┘
```
**Expected:** 3 new tables (reports, banned_users, admin_logs)

---

### 4.2 Database Functions - Check RPC
```
┌─────────────────────────────────────────────┐
│  Database > Functions                       │
├─────────────────────────────────────────────┤
│  ✅ admin_delete_menfess                    │
│  ✅ admin_ban_user                          │
│  ✅ admin_unban_user                        │
│  ✅ admin_change_role                       │
│  ✅ admin_resolve_report                    │
│  ✅ admin_dismiss_report                    │
│  ✅ admin_get_users                         │
└─────────────────────────────────────────────┘
```
**Expected:** 7 admin functions

---

## 5. FLUTTER APP ADMIN ACCESS

### 5.1 Login Screen
```
┌─────────────────────────────────────────────┐
│                                             │
│         🔐 MENFESS                          │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Email                              │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Password                           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │         LOGIN                       │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```
**Action:** Login dengan akun super admin

---

### 5.2 Home Screen - Admin Button
```
┌─────────────────────────────────────────────┐
│  MENFESS                          [⚙️] ←    │
│                                    PURPLE   │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │  @user123                           │   │
│  │  This is a menfess post...          │   │
│  │  ❤️ 12  💬 5  👁️ 45                 │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  @user456                           │   │
│  │  Another post here...               │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```
**Expected:** Tombol UNGU (⚙️) di pojok kanan atas

---

## 6. ADMIN FEATURES WALKTHROUGH

### 6.1 Admin Dashboard - Main Screen
```
┌─────────────────────────────────────────────┐
│  ← ADMIN DASHBOARD                          │
├─────────────────────────────────────────────┤
│  OVERVIEW                                   │
│  ┌──────────────┬──────────────┐            │
│  │ 👥 TOTAL     │ 🟢 ACTIVE    │            │
│  │ USERS        │ TODAY        │            │
│  │ 1,234        │ 89           │            │
│  └──────────────┴──────────────┘            │
│  ┌──────────────┬──────────────┐            │
│  │ 📝 TOTAL     │ ⚠️ PENDING   │            │
│  │ POSTS        │ REPORTS      │            │
│  │ 5,678        │ 12           │            │
│  └──────────────┴──────────────┘            │
│                                             │
│  TODAY'S ACTIVITY                           │
│  ┌──────────────┬──────────────┐            │
│  │ NEW USERS    │ NEW POSTS    │            │
│  │ +15          │ +234         │            │
│  └──────────────┴──────────────┘            │
│                                             │
│  QUICK ACTIONS                              │
│  ┌─────────────────────────────────────┐   │
│  │  🗑️ MODERATE CONTENT                │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  👥 MANAGE USERS                    │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

### 6.2 Content Moderation Screen
```
┌─────────────────────────────────────────────┐
│  ← MODERATE CONTENT                         │
├─────────────────────────────────────────────┤
│  [All] [Reported] [Recent]                  │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  @user123                           │   │
│  │  This is inappropriate content...   │   │
│  │  ❤️ 5  💬 2  👁️ 23                  │   │
│  │  [DELETE]                           │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  @user456                           │   │
│  │  Another post...                    │   │
│  │  ❤️ 12  💬 8  👁️ 67                 │   │
│  │  [DELETE]                           │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

### 6.3 Delete Confirmation Dialog
```
┌─────────────────────────────────────────────┐
│                                             │
│  ⚠️ DELETE MENFESS                          │
│                                             │
│  Are you sure you want to delete this       │
│  menfess? This action cannot be undone.     │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Reason (required)                  │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [CANCEL]              [DELETE]             │
│                                             │
└─────────────────────────────────────────────┘
```

---

### 6.4 User Management Screen
```
┌─────────────────────────────────────────────┐
│  ← MANAGE USERS                             │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │  🔍 Search users...                 │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [All] [User] [Moderator] [Super Admin]    │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  👤 @user123                        │   │
│  │  Role: User                         │   │
│  │  📝 45 posts • 💬 123 comments      │   │
│  │  [BAN] [CHANGE ROLE]                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  👤 @user456  [BANNED]              │   │
│  │  Role: User                         │   │
│  │  📝 12 posts • 💬 34 comments       │   │
│  │  [UNBAN] [CHANGE ROLE]              │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

### 6.5 Ban User Dialog
```
┌─────────────────────────────────────────────┐
│                                             │
│  🚫 BAN USER                                │
│                                             │
│  User: @user123                             │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Reason (required)                  │   │
│  │  Spam / Harassment / Other          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Duration:                                  │
│  ○ 1 Day    ○ 7 Days    ○ 30 Days          │
│  ● Permanent                                │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Additional notes (optional)        │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [CANCEL]              [BAN USER]           │
│                                             │
└─────────────────────────────────────────────┘
```

---

### 6.6 Change Role Dialog (Super Admin Only)
```
┌─────────────────────────────────────────────┐
│                                             │
│  🔄 CHANGE USER ROLE                        │
│                                             │
│  User: @user123                             │
│  Current Role: User                         │
│                                             │
│  Select New Role:                           │
│  ○ User                                     │
│  ● Moderator                                │
│  ○ Super Admin                              │
│                                             │
│  ⚠️ Warning: Moderators can delete posts    │
│  and ban users. Super Admins have full      │
│  system access.                             │
│                                             │
│  [CANCEL]              [CHANGE ROLE]        │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🎨 DESIGN SYSTEM REFERENCE

### Colors
```
┌─────────────────────────────────────────────┐
│  🟡 Yellow:  #FFD600  (Primary)             │
│  🔴 Red:     #FF3B3B  (Danger/Delete)       │
│  🔵 Blue:    #0057FF  (Info/Action)         │
│  🟣 Purple:  #9333EA  (Admin)               │
│  🟢 Green:   #10B981  (Success)             │
│  ⚫ Black:   #000000  (Text/Borders)        │
│  ⚪ White:   #FFFFFF  (Background)          │
└─────────────────────────────────────────────┘
```

### Typography
```
Font: Space Grotesk
Weights: 700 (Bold), 800 (Extra Bold), 900 (Black)
```

### Borders & Shadows
```
Border: 3-4px solid black
Shadow: 4px 4px 0px black (hard shadow)
Border Radius: 0px (sharp corners)
```

### Button States
```
Normal:   [BUTTON]  ← Shadow visible
Pressed:  [BUTTON]  ← Shadow removed, position shifted
```

---

## 📝 CHECKLIST

Setup Supabase:
- [ ] Login ke Supabase Dashboard
- [ ] Buka SQL Editor
- [ ] Paste & run migration script
- [ ] Verify tables created (reports, banned_users, admin_logs)
- [ ] Verify functions created (7 RPC functions)

Create Super Admin:
- [ ] Find user ID dengan query SELECT
- [ ] Update role jadi 'super_admin'
- [ ] Verify dengan query SELECT role

Test Flutter App:
- [ ] Hot restart app
- [ ] Login dengan akun super admin
- [ ] Cek tombol admin muncul (ungu, pojok kanan atas)
- [ ] Buka admin dashboard
- [ ] Test delete menfess
- [ ] Test ban user
- [ ] Test unban user
- [ ] Test change role (super admin only)

---

## 🆘 TROUBLESHOOTING VISUAL GUIDE

### Problem: Tombol Admin Tidak Muncul

**Check 1: Verify Role in Database**
```
┌─────────────────────────────────────────────┐
│  SELECT id, display_name, role              │
│  FROM public.users                          │
│  WHERE id = 'YOUR_USER_ID';                 │
│                                             │
│  Result:                                    │
│  role = 'super_admin' ✅                    │
│  role = 'user' ❌ (Need to update!)         │
└─────────────────────────────────────────────┘
```

**Check 2: Hot Restart App**
```
Terminal:
> flutter run
...
> R  ← Press R to hot restart
```

---

### Problem: Error "Unauthorized"

**Check RLS Policies:**
```
┌─────────────────────────────────────────────┐
│  Database > Policies                        │
├─────────────────────────────────────────────┤
│  Table: reports                             │
│  ✅ Admins can view all reports             │
│  ✅ Admins can update reports               │
│                                             │
│  Table: banned_users                        │
│  ✅ Admins can view bans                    │
│  ✅ Admins can create bans                  │
└─────────────────────────────────────────────┘
```

---

## 🎉 SUCCESS INDICATORS

Kalau kamu lihat ini semua, berarti **SETUP BERHASIL!** ✅

1. ✅ Tombol admin ungu muncul di home screen
2. ✅ Admin dashboard terbuka tanpa error
3. ✅ Stats cards menampilkan angka (bukan loading terus)
4. ✅ Bisa delete menfess
5. ✅ Bisa ban/unban user
6. ✅ Bisa change role (super admin only)

---

**Created:** May 3, 2026  
**Version:** 1.0  
**Status:** Complete
