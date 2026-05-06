# 📁 FOLDER STRUCTURE - MENFESS APP

Struktur folder yang terorganisir dengan pemisahan jelas antara **User** dan **Admin** features.

---

## 🎯 OVERVIEW

Struktur baru memisahkan:
- **User screens** → `lib/screens/user/`
- **Admin screens** → `lib/screens/admin/`
- **User widgets** → `lib/widgets/user/`
- **Admin widgets** → `lib/widgets/admin/`
- **Shared screens** → `lib/screens/` (auth, splash, onboarding)

---

## 📂 COMPLETE STRUCTURE

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase configuration
│
├── core/
│   ├── app_theme.dart                # Legacy theme
│   ├── neo_brutalism_theme.dart      # Neo-Brutalism design system
│   └── utils.dart                    # Utility functions
│
├── models/
│   ├── admin_log_model.dart          # Admin action logs
│   ├── admin_stats_model.dart        # Dashboard statistics
│   ├── banned_user_model.dart        # Ban records
│   ├── comment_model.dart            # Comment data
│   ├── menfess_model.dart            # Menfess post data
│   ├── notification_model.dart       # Notification data
│   ├── report_model.dart             # User reports
│   ├── user_admin_model.dart         # User data for admin
│   └── user_role.dart                # User role enum
│
├── providers/
│   ├── admin_provider.dart           # Admin state management
│   └── app_provider.dart             # App state management
│
├── screens/
│   ├── user/                         # 👤 USER SCREENS
│   │   ├── bookmark_screen.dart      # Saved menfess
│   │   ├── create_screen.dart        # Create new menfess
│   │   ├── detail_screen.dart        # Menfess detail & comments
│   │   ├── home_screen.dart          # Main feed
│   │   ├── main_navigation.dart      # Bottom nav container
│   │   ├── notification_screen.dart  # Notifications
│   │   ├── profile_screen.dart       # User profile
│   │   ├── search_screen.dart        # Search menfess
│   │   └── settings_screen.dart      # App settings
│   │
│   ├── admin/                        # 🛡️ ADMIN SCREENS
│   │   ├── admin_dashboard_screen.dart      # Admin dashboard
│   │   ├── content_moderation_screen.dart   # Moderate posts
│   │   └── user_management_screen.dart      # Manage users
│   │
│   ├── auth_screen.dart              # 🔐 SHARED: Login/Register
│   ├── onboarding_screen.dart        # 🔐 SHARED: Onboarding
│   └── splash_screen.dart            # 🔐 SHARED: Splash screen
│
├── services/
│   ├── comment_service.dart          # Comment operations
│   ├── menfess_service.dart          # Menfess operations
│   ├── notification_service.dart     # Notification operations
│   └── reaction_service.dart         # Reaction operations
│
├── widgets/
│   ├── user/                         # 👤 USER WIDGETS
│   │   ├── bottom_nav.dart           # Bottom navigation bar
│   │   ├── comment_sheet.dart        # Comment bottom sheet
│   │   ├── error_banner.dart         # Error display
│   │   ├── input_box.dart            # Text input field
│   │   ├── menfess_card.dart         # Menfess post card
│   │   └── menfess_skeleton.dart     # Loading skeleton
│   │
│   └── admin/                        # 🛡️ ADMIN WIDGETS
│       ├── ban_user_dialog.dart      # Ban user dialog
│       ├── change_role_dialog.dart   # Change role dialog
│       ├── menfess_admin_card.dart   # Admin menfess card
│       ├── unban_user_dialog.dart    # Unban user dialog
│       └── user_admin_card.dart      # Admin user card
│
└── main.dart                         # 🚀 App entry point

```

---

## 🔀 ROUTING LOGIC

### Entry Point: `lib/main.dart`

```dart
if (userId != null) {
  if (isAdmin) {
    // Admin → Admin Dashboard
    AdminDashboardScreen()
  } else {
    // User → Main Navigation
    MainNavigation()
  }
} else {
  // Not logged in → Auth Screen
  AuthScreen()
}
```

### User Flow:
```
AuthScreen → MainNavigation → [Home, Bookmark, Create, Notification, Profile]
```

### Admin Flow:
```
AuthScreen → AdminDashboardScreen → [Moderate Content, Manage Users]
```

---

## 📋 FILE CATEGORIES

### 🔐 Shared Screens (Both User & Admin)
Located in: `lib/screens/`

- `auth_screen.dart` - Login & Register
- `splash_screen.dart` - App loading screen
- `onboarding_screen.dart` - First-time user guide

### 👤 User-Only Screens
Located in: `lib/screens/user/`

- `main_navigation.dart` - Bottom nav container
- `home_screen.dart` - Main feed
- `create_screen.dart` - Create menfess
- `detail_screen.dart` - Menfess detail
- `bookmark_screen.dart` - Saved posts
- `notification_screen.dart` - Notifications
- `profile_screen.dart` - User profile
- `search_screen.dart` - Search posts
- `settings_screen.dart` - App settings

### 🛡️ Admin-Only Screens
Located in: `lib/screens/admin/`

- `admin_dashboard_screen.dart` - Dashboard with stats
- `content_moderation_screen.dart` - Delete posts
- `user_management_screen.dart` - Ban/unban users

### 👤 User-Only Widgets
Located in: `lib/widgets/user/`

- `bottom_nav.dart` - Bottom navigation
- `menfess_card.dart` - Post card
- `menfess_skeleton.dart` - Loading skeleton
- `comment_sheet.dart` - Comment sheet
- `input_box.dart` - Text input
- `error_banner.dart` - Error display

### 🛡️ Admin-Only Widgets
Located in: `lib/widgets/admin/`

- `menfess_admin_card.dart` - Admin post card
- `user_admin_card.dart` - Admin user card
- `ban_user_dialog.dart` - Ban dialog
- `unban_user_dialog.dart` - Unban dialog
- `change_role_dialog.dart` - Role change dialog

---

## 🔗 IMPORT PATHS

### From User Screens:
```dart
// Providers
import '../../providers/app_provider.dart';
import '../../providers/admin_provider.dart';

// Models
import '../../models/menfess_model.dart';

// Core
import '../../core/neo_brutalism_theme.dart';

// Widgets
import '../../widgets/user/menfess_card.dart';

// Other user screens (same folder)
import 'detail_screen.dart';

// Admin screens (different folder)
import '../admin/admin_dashboard_screen.dart';
```

### From Admin Screens:
```dart
// Providers
import '../../providers/admin_provider.dart';
import '../../providers/app_provider.dart';

// Models
import '../../models/user_admin_model.dart';

// Core
import '../../core/neo_brutalism_theme.dart';

// Widgets
import '../../widgets/admin/user_admin_card.dart';

// Other admin screens (same folder)
import 'content_moderation_screen.dart';
```

### From User Widgets:
```dart
// Providers
import '../../providers/app_provider.dart';

// Models
import '../../models/menfess_model.dart';

// Core
import '../../core/neo_brutalism_theme.dart';
```

### From Admin Widgets:
```dart
// Providers
import '../../providers/admin_provider.dart';

// Models
import '../../models/user_admin_model.dart';

// Core
import '../../core/neo_brutalism_theme.dart';
```

---

## ✅ BENEFITS

### 1. **Clear Separation**
- User dan Admin features terpisah jelas
- Mudah menemukan file yang dicari
- Tidak ada kebingungan "ini untuk user atau admin?"

### 2. **Scalability**
- Mudah menambah fitur baru
- Tidak perlu khawatir file tercampur
- Struktur konsisten

### 3. **Maintainability**
- Mudah maintain code
- Mudah refactor per section
- Mudah onboarding developer baru

### 4. **Team Collaboration**
- Developer bisa fokus di folder masing-masing
- Mengurangi merge conflict
- Clear ownership per feature

---

## 🔍 QUICK REFERENCE

### Need to add new user screen?
→ Create in `lib/screens/user/`

### Need to add new admin screen?
→ Create in `lib/screens/admin/`

### Need to add new user widget?
→ Create in `lib/widgets/user/`

### Need to add new admin widget?
→ Create in `lib/widgets/admin/`

### Need to add shared screen (both user & admin)?
→ Create in `lib/screens/`

### Need to add model?
→ Create in `lib/models/`

### Need to add service?
→ Create in `lib/services/`

---

## 📊 FILE COUNT

```
Total Files: 40+

Screens:
  - User: 9 files
  - Admin: 3 files
  - Shared: 3 files

Widgets:
  - User: 6 files
  - Admin: 5 files

Models: 9 files
Providers: 2 files
Services: 4 files
Core: 3 files
```

---

## 🎯 MIGRATION SUMMARY

### What Changed:

**Before:**
```
lib/screens/
  ├── home_screen.dart
  ├── admin_dashboard_screen.dart
  ├── profile_screen.dart
  └── ... (all mixed together)

lib/widgets/
  ├── menfess_card.dart
  ├── user_admin_card.dart
  └── ... (all mixed together)
```

**After:**
```
lib/screens/
  ├── user/
  │   ├── home_screen.dart
  │   └── profile_screen.dart
  ├── admin/
  │   └── admin_dashboard_screen.dart
  └── auth_screen.dart (shared)

lib/widgets/
  ├── user/
  │   └── menfess_card.dart
  └── admin/
      └── user_admin_card.dart
```

### Files Moved:

**User Screens (9):**
- `home_screen.dart`
- `bookmark_screen.dart`
- `create_screen.dart`
- `detail_screen.dart`
- `main_navigation.dart`
- `notification_screen.dart`
- `profile_screen.dart`
- `search_screen.dart`
- `settings_screen.dart`

**Admin Screens (3):**
- `admin_dashboard_screen.dart`
- `content_moderation_screen.dart`
- `user_management_screen.dart`

**User Widgets (6):**
- `bottom_nav.dart`
- `comment_sheet.dart`
- `error_banner.dart`
- `input_box.dart`
- `menfess_card.dart`
- `menfess_skeleton.dart`

**Admin Widgets (5):**
- `ban_user_dialog.dart`
- `change_role_dialog.dart`
- `menfess_admin_card.dart`
- `unban_user_dialog.dart`
- `user_admin_card.dart`

### Import Paths Updated:

✅ All imports updated automatically
✅ No compilation errors
✅ All features working

---

**Created:** May 7, 2026  
**Version:** 2.0 (Organized Structure)  
**Status:** ✅ Complete & Tested

---

**Happy Coding!** 🚀📁
