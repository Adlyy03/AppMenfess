# ⚙️ SETUP DOCUMENTATION

Panduan lengkap untuk setup dan konfigurasi Menfess SKANIC.

---

## 📋 OVERVIEW

Setup Menfess SKANIC meliputi:
- **Supabase Configuration** - Database dan authentication
- **OAuth Setup** - Social login (optional)
- **Environment Configuration** - API keys dan URLs
- **Database Schema** - Tables, RLS policies, RPC functions
- **Admin Account** - First admin user creation

---

## 📚 SETUP DOCUMENTATION

### 🗄️ **Database Setup**
- **[SUPABASE_SETUP_TUTORIAL.md](./SUPABASE_SETUP_TUTORIAL.md)** - Tutorial lengkap setup Supabase
- **[SETUP_COMPLETE_SUMMARY.md](./SETUP_COMPLETE_SUMMARY.md)** - Ringkasan setup yang sudah selesai

### 🔐 **Authentication Setup**
- **[OAUTH_SETUP_GUIDE.md](./OAUTH_SETUP_GUIDE.md)** - Setup OAuth authentication (Google, GitHub, etc.)

---

## 🚀 QUICK START GUIDE

### **Prerequisites**
- Flutter SDK 3.41.7+
- Android SDK (API level 21+)
- Supabase account
- Code editor (VS Code recommended)

### **1. Clone & Install**
```bash
# Clone repository
git clone <repository-url>
cd menfess_app

# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor
```

### **2. Supabase Setup**
1. Create new Supabase project
2. Get project URL and anon key
3. Run database setup SQL files
4. Configure RLS policies
5. Create admin account

### **3. Environment Configuration**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### **4. Database Schema Setup**
```sql
-- Run in order:
-- 1. docs/database/PRIORITAS_3_SQL_SETUP.sql
-- 2. docs/database/REPORTS_LOGS_SQL_SETUP.sql
-- 3. docs/database/CREATE_ADMIN_ACCOUNT.sql
-- 4. Apply all FIX_*.sql files
```

### **5. Test & Run**
```bash
# Run tests
flutter test

# Run on device/emulator
flutter run
```

---

## 🔧 DETAILED SETUP STEPS

### **Step 1: Supabase Project Setup**

#### **Create Project**
1. Go to [supabase.com](https://supabase.com)
2. Create new project
3. Choose region (closest to users)
4. Set strong database password
5. Wait for project initialization

#### **Get Credentials**
1. Go to Project Settings → API
2. Copy Project URL
3. Copy anon/public key
4. Save service_role key (for admin operations)

### **Step 2: Database Configuration**

#### **Run SQL Setup Files**
```sql
-- 1. Core tables and functions
\i docs/database/PRIORITAS_3_SQL_SETUP.sql

-- 2. Admin features
\i docs/database/REPORTS_LOGS_SQL_SETUP.sql

-- 3. Create first admin
\i docs/database/CREATE_ADMIN_ACCOUNT.sql

-- 4. Apply fixes
\i docs/database/FIX_BOOKMARK_DATABASE.sql
\i docs/database/FIX_VIEW_COUNT.sql
\i docs/database/FIX_ADMIN_GET_USERS.sql
\i docs/database/FIX_REPORTS_LOGS_FOREIGN_KEYS.sql
```

#### **Verify Setup**
```sql
-- Check tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS policies
SELECT schemaname, tablename, policyname 
FROM pg_policies;

-- Test admin functions
SELECT admin_get_users();
```

### **Step 3: Flutter Configuration**

#### **Update Supabase Config**
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key-here';
}
```

#### **Android Deep Links Setup**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="menfess" />
</intent-filter>

<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="menfess.skanic.com" />
</intent-filter>
```

### **Step 4: Testing Setup**

#### **Run Automated Tests**
```bash
# All tests
flutter test

# Specific categories
flutter test test/unit/
flutter test test/widget/

# With coverage
flutter test --coverage
```

#### **Manual Testing**
1. Use [Manual Testing Checklist](../testing/MANUAL_TESTING_CHECKLIST.md)
2. Test on physical Android device
3. Verify all features work end-to-end
4. Test admin functionality with different roles

---

## 🔐 SECURITY CONFIGURATION

### **Row Level Security (RLS)**
```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE menfess ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE banned_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;
```

### **API Key Security**
- **Never commit** API keys to version control
- Use **environment variables** in production
- Rotate keys regularly
- Use **service_role** key only for admin operations

### **Admin Account Security**
- Use **strong passwords** (12+ characters)
- Enable **2FA** if available
- Limit **admin accounts** to minimum necessary
- Regular **audit** of admin actions

---

## 📊 MONITORING & MAINTENANCE

### **Health Checks**
```sql
-- Database health
SELECT 
    schemaname, 
    tablename, 
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public';

-- Recent activity
SELECT COUNT(*) as posts_today FROM menfess 
WHERE created_at >= CURRENT_DATE;

-- Admin actions
SELECT COUNT(*) as admin_actions_today FROM admin_logs 
WHERE created_at >= CURRENT_DATE;
```

### **Performance Monitoring**
- Monitor **query performance**
- Track **database size** growth
- Watch **API usage** limits
- Monitor **error rates**

---

## 🐛 TROUBLESHOOTING

### **Common Issues**

#### **Supabase Connection Failed**
```dart
// Check URL and key format
const url = 'https://project-id.supabase.co'; // Must include https://
const key = 'eyJ...'; // Must be valid JWT format
```

#### **RLS Policy Errors**
```sql
-- Check if policies exist
SELECT * FROM pg_policies WHERE tablename = 'menfess';

-- Re-create if missing
CREATE POLICY "menfess_select_policy" ON menfess FOR SELECT USING (true);
```

#### **Admin Access Denied**
```sql
-- Check user role
SELECT id, email, role FROM users WHERE email = 'admin@example.com';

-- Update role if needed
UPDATE users SET role = 'super_admin' WHERE email = 'admin@example.com';
```

#### **Deep Links Not Working**
- Check AndroidManifest.xml intent filters
- Verify URL scheme matches app configuration
- Test with `adb shell am start` command

---

## 📋 DEPLOYMENT CHECKLIST

### **Pre-Deployment**
- [ ] All tests passing (41/41)
- [ ] Database schema applied
- [ ] Admin account created
- [ ] Environment variables configured
- [ ] Deep links tested
- [ ] Performance benchmarks met

### **Production Setup**
- [ ] Production Supabase project
- [ ] SSL certificates configured
- [ ] Domain setup (menfess.skanic.com)
- [ ] CDN configuration (if needed)
- [ ] Monitoring tools setup
- [ ] Backup strategy implemented

### **Post-Deployment**
- [ ] Health checks passing
- [ ] Admin dashboard accessible
- [ ] Share links working
- [ ] Deep links functional
- [ ] Analytics tracking
- [ ] Error monitoring active

---

## 🔗 RELATED DOCUMENTATION

- **Database Setup:** [../database/](../database/)
- **Admin Setup:** [../admin/](../admin/)
- **Testing:** [../testing/](../testing/)
- **Features:** [../features/](../features/)
- **Main Documentation:** [../README.md](../README.md)

---

**Last Updated:** May 7, 2026  
**Setup Version:** 1.0.0  
**Status:** Production Ready