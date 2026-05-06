# 🧪 COMPREHENSIVE TESTING PLAN - MENFESS SKANIC APP

## 📋 TESTING OVERVIEW

Testing sistematis untuk semua fitur Menfess SKANIC App dengan prioritas berdasarkan kritikalitas untuk launch.

---

## 🎯 TESTING PRIORITIES

### 🔴 **CRITICAL (Must Pass Before Launch)**
1. Authentication & Authorization
2. Core Menfess Features (Create, Read, Like, Bookmark)
3. Admin Dashboard & Permissions
4. Database Integrity
5. Security & RLS Policies

### 🟡 **HIGH PRIORITY (Important for UX)**
1. Comments System
2. Search & Pagination
3. Notifications
4. Share Functionality
5. Real-time Updates

### 🟢 **MEDIUM PRIORITY (Nice to Have)**
1. UI/UX Components
2. Error Handling
3. Performance Optimization
4. Theme Consistency

### 🔵 **LOW PRIORITY (Post-Launch)**
1. Analytics
2. Advanced Share Features
3. QR Code Generation

---

## 🧪 TESTING CATEGORIES

### 1. **UNIT TESTS** (Individual Functions)
- Model parsing & validation
- Service methods
- Utility functions
- State management logic

### 2. **INTEGRATION TESTS** (Feature Flows)
- Authentication flow
- Post creation flow
- Admin moderation flow
- Share functionality flow

### 3. **UI TESTS** (User Interface)
- Screen rendering
- Navigation
- Form validation
- Button interactions

### 4. **DATABASE TESTS** (Data Layer)
- CRUD operations
- RPC functions
- RLS policies
- Cascade deletes

### 5. **SECURITY TESTS** (Authorization)
- Role-based access
- Permission checks
- Self-action prevention
- Data isolation

---

## 📝 DETAILED TEST CASES

### 🔐 **AUTHENTICATION TESTS**

#### Test Case 1.1: User Registration
```
GIVEN: New user wants to register
WHEN: User enters valid email and password
THEN: Account is created and user is logged in
AND: User role is set to 'user' by default
AND: User is added to public users table
```

#### Test Case 1.2: User Login
```
GIVEN: Existing user wants to login
WHEN: User enters correct credentials
THEN: User is authenticated successfully
AND: User session is established
AND: User is redirected based on role (admin vs user)
```

#### Test Case 1.3: Role-Based Routing
```
GIVEN: User is authenticated
WHEN: User role is 'moderator' or 'super_admin'
THEN: User is redirected to Admin Dashboard
WHEN: User role is 'user'
THEN: User is redirected to Main Navigation
```

### 📝 **MENFESS CORE FEATURES TESTS**

#### Test Case 2.1: Create Menfess
```
GIVEN: Authenticated user wants to create menfess
WHEN: User enters message and submits
THEN: Menfess is created with 24-hour expiry
AND: User's daily post count is incremented
AND: Menfess appears in feed
```

#### Test Case 2.2: Daily Post Limit
```
GIVEN: User has reached daily post limit (3-5 posts)
WHEN: User tries to create another post
THEN: Error message is shown
AND: Post creation is blocked
```

#### Test Case 2.3: Feed Pagination
```
GIVEN: User is viewing menfess feed
WHEN: User scrolls to bottom
THEN: Next page of menfess is loaded (10 items)
AND: Loading indicator is shown during fetch
```

#### Test Case 2.4: Like/Unlike Menfess
```
GIVEN: User views a menfess
WHEN: User taps like button
THEN: Like count increases immediately (optimistic)
AND: Like status is saved to database
AND: Button state changes to liked
```

#### Test Case 2.5: Bookmark Menfess
```
GIVEN: User views a menfess
WHEN: User taps bookmark button
THEN: Menfess is added to bookmarks
AND: Button state changes to bookmarked
AND: Menfess appears in bookmark screen
```

### 💬 **COMMENTS SYSTEM TESTS**

#### Test Case 3.1: Load Comments
```
GIVEN: User opens menfess detail
WHEN: Screen loads
THEN: All comments for that menfess are fetched
AND: Comments are ordered by creation time
AND: Comment count matches database
```

#### Test Case 3.2: Add Comment
```
GIVEN: User is on menfess detail screen
WHEN: User types comment and submits
THEN: Comment is added to database
AND: Comment appears in list immediately
AND: Comment count is incremented
```

### 🔍 **SEARCH & DISCOVERY TESTS**

#### Test Case 4.1: Search Menfess
```
GIVEN: User wants to search for menfess
WHEN: User enters search query
THEN: Menfess containing query text are returned
AND: Search is case-insensitive
AND: Results are paginated
```

#### Test Case 4.2: Hot/Trending Posts
```
GIVEN: System has posts from today
WHEN: Hot section is loaded
THEN: Posts with highest like count are shown
AND: Only posts from today are included
AND: Maximum 5 posts are displayed
```

### 🛡️ **ADMIN DASHBOARD TESTS**

#### Test Case 5.1: Admin Access Control
```
GIVEN: User with 'user' role tries to access admin
WHEN: User navigates to admin URL
THEN: Access is denied
AND: User is redirected to main app
```

#### Test Case 5.2: Moderator Permissions
```
GIVEN: User with 'moderator' role accesses admin
WHEN: User views admin dashboard
THEN: User can see stats, delete posts, ban users
AND: User cannot change roles
AND: User cannot ban super admins
```

#### Test Case 5.3: Super Admin Permissions
```
GIVEN: User with 'super_admin' role accesses admin
WHEN: User views admin dashboard
THEN: User has access to all features
AND: User can change user roles
AND: User can ban any user except self
```

#### Test Case 5.4: Delete Menfess (Admin)
```
GIVEN: Admin wants to delete inappropriate menfess
WHEN: Admin clicks delete and provides reason
THEN: Menfess is deleted from database
AND: Related comments are cascade deleted
AND: Related reactions are cascade deleted
AND: Action is logged in audit trail
```

#### Test Case 5.5: Ban User
```
GIVEN: Admin wants to ban problematic user
WHEN: Admin selects user and provides ban details
THEN: User is banned with specified duration
AND: User cannot create posts or comments
AND: Ban record is created
AND: Action is logged in audit trail
```

### 🔗 **SHARE FUNCTIONALITY TESTS**

#### Test Case 6.1: Generate Share Link
```
GIVEN: User wants to share a menfess
WHEN: User taps share button
THEN: Share bottom sheet opens
AND: Web link is generated (https://menfess.skanic.com/p/{id})
AND: Deep link is available (menfess://post/{id})
```

#### Test Case 6.2: Share to WhatsApp
```
GIVEN: User selects WhatsApp share option
WHEN: Share is triggered
THEN: WhatsApp opens with formatted message
AND: Message includes menfess preview
AND: Message includes share link
AND: Share is tracked in analytics
```

#### Test Case 6.3: Copy Link
```
GIVEN: User selects copy link option
WHEN: Copy is triggered
THEN: Link is copied to clipboard
AND: Success message is shown
AND: Link format is web URL
```

#### Test Case 6.4: QR Code Generation
```
GIVEN: User selects QR code option
WHEN: QR modal opens
THEN: QR code image is generated
AND: QR code contains share link
AND: QR code is scannable
```

### 🔔 **NOTIFICATIONS TESTS**

#### Test Case 7.1: Notification Permissions
```
GIVEN: App is first launched
WHEN: Notification service initializes
THEN: Permission is requested from user
AND: Permission status is stored
```

#### Test Case 7.2: Real-time Notifications
```
GIVEN: User has notifications enabled
WHEN: New notification is created
THEN: Notification appears in system tray
AND: Notification appears in app notification list
AND: Unread count is updated
```

### 🗄️ **DATABASE INTEGRITY TESTS**

#### Test Case 8.1: Cascade Delete
```
GIVEN: Menfess has comments and reactions
WHEN: Menfess is deleted
THEN: All related comments are deleted
AND: All related reactions are deleted
AND: All related bookmarks are deleted
AND: All related reports are deleted
```

#### Test Case 8.2: RLS Policies
```
GIVEN: User tries to access another user's data
WHEN: Database query is executed
THEN: Only user's own data is returned
AND: Other users' private data is protected
```

#### Test Case 8.3: RPC Function Security
```
GIVEN: User calls admin RPC function
WHEN: User is not admin
THEN: Function call is rejected
AND: Error message indicates insufficient permissions
```

### 🎨 **UI/UX COMPONENT TESTS**

#### Test Case 9.1: Neo-Brutalism Theme
```
GIVEN: App uses neo-brutalism theme
WHEN: Any screen is rendered
THEN: Colors match theme palette
AND: Borders are 3-4px solid black
AND: Shadows are hard (no blur)
AND: Typography uses Space Grotesk font
```

#### Test Case 9.2: Bottom Navigation
```
GIVEN: User is on main navigation
WHEN: User taps different tabs
THEN: Correct screen is displayed
AND: Active tab is highlighted
AND: Navigation state is preserved
```

#### Test Case 9.3: Loading States
```
GIVEN: Data is being fetched
WHEN: Loading is in progress
THEN: Skeleton screens are shown
AND: Loading indicators are displayed
AND: User cannot interact with loading elements
```

### ⚡ **PERFORMANCE TESTS**

#### Test Case 10.1: Feed Loading Performance
```
GIVEN: User opens feed with many posts
WHEN: Feed loads
THEN: Initial load completes within 3 seconds
AND: Pagination loads within 1 second
AND: Memory usage remains stable
```

#### Test Case 10.2: Real-time Update Performance
```
GIVEN: Multiple real-time subscriptions are active
WHEN: Updates are received
THEN: UI updates smoothly without lag
AND: Battery usage is reasonable
AND: Network usage is optimized
```

---

## 🚀 TESTING EXECUTION PLAN

### Phase 1: Critical Tests (Week 1)
- [ ] Authentication & Authorization
- [ ] Core Menfess Features
- [ ] Admin Dashboard Basic Functions
- [ ] Database Integrity

### Phase 2: High Priority Tests (Week 2)
- [ ] Comments System
- [ ] Search & Pagination
- [ ] Share Functionality
- [ ] Real-time Updates

### Phase 3: Medium Priority Tests (Week 3)
- [ ] UI/UX Components
- [ ] Error Handling
- [ ] Performance Tests
- [ ] Edge Cases

### Phase 4: Low Priority Tests (Week 4)
- [ ] Analytics Integration
- [ ] Advanced Share Features
- [ ] Accessibility Tests
- [ ] Cross-platform Tests

---

## 📊 SUCCESS CRITERIA

### Minimum Viable Product (MVP)
- ✅ 100% Critical tests pass
- ✅ 90% High priority tests pass
- ✅ 70% Medium priority tests pass
- ✅ No security vulnerabilities
- ✅ Performance meets benchmarks

### Production Ready
- ✅ 100% Critical + High priority tests pass
- ✅ 90% Medium priority tests pass
- ✅ 50% Low priority tests pass
- ✅ Full security audit complete
- ✅ Load testing complete

---

## 🔧 TESTING TOOLS & SETUP

### Flutter Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_test.dart

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

### Database Testing
```sql
-- Test RLS policies
SELECT * FROM menfess; -- Should only return user's accessible data

-- Test RPC functions
SELECT admin_delete_menfess('menfess_id', 'reason'); -- Should fail for non-admin
```

### Manual Testing Checklist
- [ ] Install app on physical device
- [ ] Test all user flows end-to-end
- [ ] Test admin flows with different roles
- [ ] Test share functionality with real apps
- [ ] Test deep links from external sources
- [ ] Test notifications on device
- [ ] Test offline/online scenarios

---

## 📝 BUG TRACKING

### Bug Report Template
```
**Bug Title:** [Brief description]
**Severity:** Critical/High/Medium/Low
**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Result:** What should happen
**Actual Result:** What actually happened
**Environment:** Device, OS version, App version
**Screenshots:** [If applicable]
```

### Bug Priority Levels
- **Critical:** App crashes, data loss, security issues
- **High:** Core features broken, major UX issues
- **Medium:** Minor features broken, UI inconsistencies
- **Low:** Cosmetic issues, nice-to-have features

---

**🎯 Ready to start testing! Mari kita mulai dengan Critical tests terlebih dahulu.**