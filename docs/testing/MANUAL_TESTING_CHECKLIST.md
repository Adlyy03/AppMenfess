# 📱 MANUAL TESTING CHECKLIST - MENFESS SKANIC APP

**Testing Device:** Android Phone  
**Testing Date:** ___________  
**Tester:** ___________  
**App Version:** 1.0.0+1

---

## 🎯 PRE-TESTING SETUP

### **Device Requirements**
- [ ] Android device (API level 21+)
- [ ] Internet connection (WiFi/Mobile data)
- [ ] Sufficient storage space (>100MB)
- [ ] Notification permissions available

### **Testing Environment**
- [ ] Fresh app installation
- [ ] Clear app data before testing
- [ ] Test with both WiFi and mobile data
- [ ] Test with different network speeds (if possible)

---

## 🔐 AUTHENTICATION FLOW TESTING

### **App Launch & Splash Screen**
- [ ] App launches without crashes
- [ ] Splash screen displays for ~2 seconds
- [ ] Logo and branding appear correctly
- [ ] Smooth transition to next screen

### **Onboarding Flow**
- [ ] Onboarding screens display properly
- [ ] Text is readable and properly formatted
- [ ] Navigation between onboarding screens works
- [ ] Skip/Next buttons function correctly
- [ ] Final screen leads to authentication

### **User Registration**
- [ ] Registration form displays correctly
- [ ] Email validation works (invalid emails rejected)
- [ ] Password validation works (minimum requirements)
- [ ] Registration succeeds with valid credentials
- [ ] User is automatically logged in after registration
- [ ] User role is set to 'user' by default

### **User Login**
- [ ] Login form displays correctly
- [ ] Login succeeds with correct credentials
- [ ] Login fails with incorrect credentials
- [ ] Error messages are user-friendly
- [ ] "Remember me" functionality (if implemented)
- [ ] Password reset functionality (if implemented)

### **Role-Based Navigation**
- [ ] Regular users navigate to main app
- [ ] Admin users navigate to admin dashboard
- [ ] Navigation is consistent and predictable

---

## 📝 CORE MENFESS FEATURES

### **Home Screen & Feed**
- [ ] Feed loads within 3 seconds
- [ ] Menfess cards display properly
- [ ] Skeleton loading appears during fetch
- [ ] Pull-to-refresh works correctly
- [ ] Infinite scroll/pagination works
- [ ] "Hot Today" section displays (if posts exist)
- [ ] Empty state shows when no posts

### **Create Menfess**
- [ ] Create screen accessible from bottom nav
- [ ] Text input works properly
- [ ] Character count displays correctly
- [ ] Daily post limit enforced (3-5 posts)
- [ ] Post creation succeeds
- [ ] New post appears in feed immediately
- [ ] Post expires after 24 hours (check timestamp)

### **Menfess Interactions**

#### **Like Functionality**
- [ ] Like button responds to taps
- [ ] Like count updates immediately (optimistic)
- [ ] Like state persists after app restart
- [ ] Unlike functionality works
- [ ] Like count decreases when unliked

#### **Bookmark Functionality**
- [ ] Bookmark button responds to taps
- [ ] Bookmark state updates immediately
- [ ] Bookmarked posts appear in bookmark screen
- [ ] Unbookmark functionality works
- [ ] Bookmark state persists after app restart

#### **View Count**
- [ ] View count increases when post is viewed
- [ ] View count doesn't increase on repeated views (same session)
- [ ] View count displays correctly

### **Comments System**
- [ ] Tap on menfess opens detail screen
- [ ] Comments load correctly
- [ ] Add comment functionality works
- [ ] Comment appears immediately after submission
- [ ] Comment count updates correctly
- [ ] Empty state shows when no comments

---

## 🔍 SEARCH & DISCOVERY

### **Search Functionality**
- [ ] Search screen accessible from home
- [ ] Search input works properly
- [ ] Search results display correctly
- [ ] Search is case-insensitive
- [ ] Search results are relevant
- [ ] Empty search results handled gracefully
- [ ] Search history (if implemented)

### **Hot/Trending Posts**
- [ ] Hot section displays on home screen
- [ ] Hot posts are from today only
- [ ] Hot posts have high engagement
- [ ] Horizontal scroll works smoothly
- [ ] Tap on hot post opens detail screen

---

## 🔗 SHARE FUNCTIONALITY

### **Share Bottom Sheet**
- [ ] Share button visible on detail screen
- [ ] Share bottom sheet opens correctly
- [ ] All share options display (General, WhatsApp, Copy, QR)
- [ ] Menfess preview shows correctly
- [ ] Stats display correctly (likes, comments, views)
- [ ] Long messages are truncated with "..."

### **Share Options Testing**

#### **General Share**
- [ ] General share opens system share dialog
- [ ] Share message includes menfess preview
- [ ] Share link is correctly formatted
- [ ] Share to different apps works (Messages, Email, etc.)

#### **WhatsApp Share**
- [ ] WhatsApp opens with formatted message
- [ ] Message includes menfess preview
- [ ] Message includes share link
- [ ] Formatting is WhatsApp-friendly

#### **Copy Link**
- [ ] Link is copied to clipboard
- [ ] Success message appears
- [ ] Copied link is web URL format
- [ ] Link can be pasted in other apps

#### **QR Code**
- [ ] QR code modal opens
- [ ] QR code image displays correctly
- [ ] QR code is scannable (test with another device)
- [ ] QR code contains correct share link
- [ ] Modal closes properly

### **Deep Link Testing**
- [ ] Share link opens in browser (if app not installed)
- [ ] Share link opens app (if app installed)
- [ ] Deep link navigates to correct menfess
- [ ] Invalid deep links handled gracefully

---

## 📱 NAVIGATION & UI

### **Bottom Navigation**
- [ ] All 5 tabs display correctly
- [ ] Tab switching works smoothly
- [ ] Active tab is highlighted
- [ ] Tab state persists during navigation
- [ ] Badge count displays on notification tab (if applicable)

### **Screen Navigation**
- [ ] Back button works on all screens
- [ ] Navigation animations are smooth
- [ ] Screen transitions are consistent
- [ ] No navigation loops or dead ends

### **UI Components**

#### **Neo-Brutalism Theme**
- [ ] Colors match design system (Yellow, Red, Blue, Black, White)
- [ ] Borders are thick (3-4px) and black
- [ ] Shadows are hard (no blur)
- [ ] Typography uses Space Grotesk font
- [ ] Button press animations work
- [ ] Consistent styling across all screens

#### **Loading States**
- [ ] Skeleton screens display during loading
- [ ] Loading indicators are visible
- [ ] Loading doesn't block user interaction unnecessarily
- [ ] Loading states are consistent

#### **Error States**
- [ ] Error messages are user-friendly
- [ ] Retry buttons work when provided
- [ ] Network errors handled gracefully
- [ ] App doesn't crash on errors

---

## 🔔 NOTIFICATIONS

### **Notification Permissions**
- [ ] App requests notification permission
- [ ] Permission dialog is clear and informative
- [ ] App works correctly if permission denied
- [ ] Permission can be changed in settings

### **Notification Functionality**
- [ ] Notifications appear in system tray
- [ ] Notification content is appropriate
- [ ] Tap on notification opens correct screen
- [ ] Notification badges update correctly
- [ ] Notifications can be dismissed

---

## 👤 USER PROFILE & SETTINGS

### **Profile Screen**
- [ ] Profile screen displays user stats
- [ ] Post count is accurate
- [ ] Like count is accurate
- [ ] Comment count is accurate
- [ ] Profile information displays correctly

### **Bookmark Screen**
- [ ] Bookmarked posts display correctly
- [ ] Unbookmark functionality works from this screen
- [ ] Empty state shows when no bookmarks
- [ ] Bookmarks are sorted appropriately

### **Settings Screen**
- [ ] Settings options display correctly
- [ ] Theme switching works (if implemented)
- [ ] Notification settings work
- [ ] Account settings accessible
- [ ] Logout functionality works

---

## 🛡️ ADMIN DASHBOARD (Admin Users Only)

### **Admin Access**
- [ ] Admin users automatically navigate to dashboard
- [ ] Non-admin users cannot access admin screens
- [ ] Role-based permissions enforced

### **Dashboard Statistics**
- [ ] Stats display correctly (users, posts, reports)
- [ ] Numbers are accurate and up-to-date
- [ ] Real-time updates work

### **Content Moderation**
- [ ] Menfess list displays for moderation
- [ ] Delete functionality works
- [ ] Delete requires confirmation
- [ ] Deleted posts disappear from feed
- [ ] Delete action is logged

### **User Management**
- [ ] User list displays correctly
- [ ] Search users functionality works
- [ ] Ban user functionality works
- [ ] Unban user functionality works
- [ ] Role change functionality works (super admin only)
- [ ] Actions are logged in audit trail

### **Reports Management**
- [ ] Reports list displays correctly
- [ ] Resolve report functionality works
- [ ] Dismiss report functionality works
- [ ] Report status updates correctly

---

## 🔧 PERFORMANCE & STABILITY

### **App Performance**
- [ ] App launches in <3 seconds
- [ ] Screen transitions are smooth (<300ms)
- [ ] Scrolling is smooth (60fps)
- [ ] No memory leaks during extended use
- [ ] Battery usage is reasonable

### **Network Handling**
- [ ] App works on WiFi
- [ ] App works on mobile data
- [ ] Graceful handling of network loss
- [ ] Offline mode behavior (if implemented)
- [ ] Sync when network restored

### **Device Compatibility**
- [ ] App works on different screen sizes
- [ ] App works in portrait orientation
- [ ] App works in landscape orientation (if supported)
- [ ] App respects system font size settings
- [ ] App works with system dark mode (if supported)

---

## 🐛 EDGE CASES & ERROR SCENARIOS

### **Data Edge Cases**
- [ ] Very long menfess messages (>500 chars)
- [ ] Empty menfess messages
- [ ] Special characters in messages
- [ ] Emoji handling
- [ ] Multiple rapid taps (double-tap prevention)

### **Network Edge Cases**
- [ ] Slow network connection
- [ ] Intermittent network connection
- [ ] Network timeout scenarios
- [ ] Server error responses (500, 404, etc.)

### **User Behavior Edge Cases**
- [ ] Rapid navigation between screens
- [ ] App backgrounding and foregrounding
- [ ] Device rotation during operations
- [ ] Low memory conditions
- [ ] Low battery conditions

---

## 📊 TESTING RESULTS

### **Critical Issues Found**
| Issue | Severity | Description | Status |
|-------|----------|-------------|--------|
| | | | |
| | | | |
| | | | |

### **Minor Issues Found**
| Issue | Description | Status |
|-------|-------------|--------|
| | | |
| | | |

### **Performance Metrics**
- **App Launch Time:** _____ seconds
- **Feed Load Time:** _____ seconds
- **Search Response Time:** _____ seconds
- **Memory Usage:** _____ MB
- **Battery Drain:** _____% per hour

### **Overall Assessment**
- **Functionality:** ⭐⭐⭐⭐⭐ (1-5 stars)
- **Performance:** ⭐⭐⭐⭐⭐ (1-5 stars)
- **User Experience:** ⭐⭐⭐⭐⭐ (1-5 stars)
- **Stability:** ⭐⭐⭐⭐⭐ (1-5 stars)

### **Launch Recommendation**
- [ ] ✅ READY FOR LAUNCH
- [ ] ⚠️ READY WITH MINOR FIXES
- [ ] ❌ NOT READY - CRITICAL ISSUES FOUND

### **Additional Notes**
```
[Space for additional observations, suggestions, or concerns]
```

---

**Testing Completed By:** ___________  
**Date:** ___________  
**Time Spent:** _____ hours  
**Next Testing Phase:** ___________