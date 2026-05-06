# Google OAuth Setup Guide untuk Menfess App

## Implementasi yang Sudah Dilakukan

### 1. main.dart - Auth State Listener
- **File:** `lib/main.dart`
- **Flow:**
  - Inisialisasi Supabase setelah app start
  - Setup listener `supabase.auth.onAuthStateChange`
  - Listener menangkap session perubahan
  - Ketika session != null: update userId di provider dan rebuild UI
  - Ketika session null: logout, rebuild ke AuthScreen

### 2. auth_service.dart - Google OAuth Method
- **File:** `lib/services/auth_service.dart`
- **Method:** `signInWithGoogle()`
- **Fitur:**
  - Gunakan `signInWithOAuth(OAuthProvider.google)`
  - Redirect URL: `http://localhost:62308`
  - Automatic callback handling (built-in Supabase)
  - Tidak ada manual URL parsing

### 3. app_provider.dart - User State Management
- **File:** `lib/providers/app_provider.dart`
- **Method:** `setUserId(String? id)`
- **Method:** `signInWithGoogle()`
- **Flow:**
  - setUserId() dipanggil dari auth listener saat session berubah
  - signInWithGoogle() trigger OAuth flow dari UI

### 4. auth_screen.dart - Login Button
- **File:** `lib/screens/auth_screen.dart`
- **Behavior:**
  - Tombol "Masuk dengan Google" trigger provider.signInWithGoogle()
  - Screen menunggu auth listener memicu navigation
  - Tidak perlu manual navigation (main.dart handle otomatis)

## Setup Supabase

### Step 1: Enable Google OAuth Provider

1. Buka [Supabase Dashboard](https://app.supabase.com)
2. Pilih project kamu
3. Ke **Authentication** > **Providers**
4. Cari **Google** dan klik
5. Toggle **Enable Google**

### Step 2: Setup Google OAuth Credentials

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Buat project baru atau pilih yang sudah ada
3. Ke **APIs & Services** > **Credentials**
4. Klik **Create Credentials** > **OAuth 2.0 Client ID**
5. Pilih **Web application**
6. Nama: `Menfess App`
7. **Authorized JavaScript origins:**
   ```
   http://localhost:62308
   http://localhost:8080
   ```
8. **Authorized redirect URIs:**
   ```
   http://localhost:62308
   https://ooetawyfgkiwyzvyiqow.supabase.co/auth/v1/callback
   ```
9. Copy **Client ID** dan **Client Secret**

### Step 3: Masukkan Credentials ke Supabase

1. Kembali ke Supabase Dashboard > Authentication > Providers > Google
2. Paste **Client ID**
3. Paste **Client Secret**
4. Klik **Save**

### Step 4: Tambah Redirect URL di Supabase

1. Supabase Dashboard > Authentication > URL Configuration
2. **Site URL:** `http://localhost:62308`
3. **Redirect URLs (additional):**
   ```
   http://localhost:62308
   http://localhost:62308/*
   ```

### Step 5: Setup SQL Migrations

Jalankan SQL migration untuk RLS policies:

```bash
# File: supabase/migrations/20260429_one_table_auth_users.sql
# Copy-paste di Supabase SQL Editor dan jalankan
```

## Testing Flow

### 1. Run App di Web
```bash
flutter run -d chrome
```

### 2. Lihat Console Logs
```
🔐 Auth Event: INITIAL_SESSION / SIGNED_IN / SIGNED_OUT
✅ LOGIN SUCCESS: user@example.com
   User ID: xxx-xxx-xxx
   Provider: google
```

### 3. Test Steps
1. App muncul dengan Splash Screen (loading provider.init())
2. Jika belum login: tampil AuthScreen dengan tombol "Masuk dengan Google"
3. Klik tombol Google
4. Browser buka Google login dialog
5. Login dengan akun Google
6. Redirect ke `http://localhost:62308/?code=xxx&state=xxx`
7. Supabase handle callback otomatis
8. Session terbentuk
9. Auth listener tertrigger
10. App rebuild dan tampil MainNavigation (Home/Create/Profile)

## Troubleshooting

### Error: `bad_oauth_state`
- **Penyebab:** Redirect URL tidak cocok antara Supabase dan Google OAuth
- **Solusi:** Pastikan URL di step 2 dan step 4 sama persis

### Error: `invalid_client`
- **Penyebab:** Client ID atau Secret salah
- **Solusi:** Double-check credentials di Google Cloud Console

### Session null setelah login
- **Penyebab:** Callback tidak dihandle dengan baik
- **Solusi:** 
  - Pastikan debug mode di Supabase init: `debug: true`
  - Cek console log untuk error detail
  - Pastikan auth listener di main.dart aktif

### Redirect loop atau white page
- **Penyebab:** main.dart tidak render UI dengan benar
- **Solusi:** Pastikan `home:` di MaterialApp menampilkan userId != null ? MainNavigation : AuthScreen

### User bisa login tapi userId null di provider
- **Penyebab:** Auth listener tidak set userId
- **Solusi:** Pastikan setUserId() dipanggil di listener

## Production Setup

Untuk production, ubah:

1. **redirectTo** di `auth_service.dart`:
   ```dart
   redirectTo: 'https://your-app.com',
   ```

2. **Site URL** di Supabase: `https://your-app.com`

3. **Google OAuth redirect URIs:**
   ```
   https://your-app.com
   https://your-app.com/*
   https://ooetawyfgkiwyzvyiqow.supabase.co/auth/v1/callback
   ```

4. **Authorized JavaScript origins** di Google Cloud:
   ```
   https://your-app.com
   ```

## File Structure

```
lib/
├── main.dart                    # App entry + auth listener
├── services/
│   └── auth_service.dart       # OAuth methods
├── providers/
│   └── app_provider.dart       # User state + setUserId()
├── screens/
│   ├── auth_screen.dart        # Login UI
│   ├── main_navigation.dart    # Main app (after login)
│   └── profile_screen.dart     # Logout button
└── config/
    └── supabase_config.dart    # Supabase URL + keys

supabase/
└── migrations/
    └── 20260429_one_table_auth_users.sql  # RLS policies
```

## Auth Flow Diagram

```
App Start
    ↓
Supabase.initialize()
    ↓
Setup auth state listener
    ↓
provider.init() → check if user exists
    ↓
Rebuild: userId != null ? MainNav : AuthScreen
    ↓
[If AuthScreen]
User clicks "Masuk dengan Google"
    ↓
signInWithGoogle() → redirect ke Google
    ↓
User login di Google
    ↓
Redirect ke http://localhost:62308/?code=xxx
    ↓
Supabase handle callback → create session
    ↓
Auth listener triggered → session != null
    ↓
setUserId(user.id) → notifyListeners()
    ↓
main.dart setState() → rebuild
    ↓
userId != null → show MainNavigation
```

## Debugging Tips

### Enable Debug Mode
```dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
  debug: true,  // ← Ini untuk melihat debug logs
);
```

### Check Session di Provider
```dart
final user = Supabase.instance.client.auth.currentUser;
print('Current user: ${user?.email}');
print('Session: ${Supabase.instance.client.auth.currentSession}');
```

### Monitor Auth Events
Buka browser DevTools > Console untuk melihat semua auth events yang diekirim Supabase.
