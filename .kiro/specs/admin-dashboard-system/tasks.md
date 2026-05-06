# Implementation Plan: Admin Dashboard System

## Overview

This implementation plan breaks down the Admin Dashboard System into discrete, actionable coding tasks. The system adds comprehensive administrative capabilities to the Flutter Menfess app, including role-based access control, content moderation, user management, analytics, and audit logging. All tasks build incrementally, with checkpoints to ensure quality and integration.

The implementation follows a bottom-up approach: database schema → models → services/providers → UI components → integration → testing.

## Tasks

- [ ] 1. Database Schema Setup
  - Create SQL migration file with all tables, views, RLS policies, and RPC functions
  - Add role column to existing users table
  - Create reports, banned_users, admin_logs tables with proper indexes
  - Create admin_stats materialized view for dashboard statistics
  - Implement Row Level Security policies for all admin tables
  - Create RPC functions: admin_delete_menfess, admin_ban_user, admin_unban_user, admin_change_role, admin_resolve_report, admin_dismiss_report, admin_get_users
  - Test database schema with sample data
  - _Requirements: 1.1, 1.3, 1.4, 1.6, 2.6, 16.1, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6_

- [ ] 2. Core Dart Models
  - [ ] 2.1 Create UserRole enum with role validation
    - Implement UserRole enum with user, moderator, superAdmin values
    - Add value getter for database string conversion
    - Add fromString factory for parsing database values
    - Add isAdmin and isSuperAdmin convenience getters
    - _Requirements: 1.1, 1.6_
  
  - [ ] 2.2 Create ReportModel
    - Implement ReportModel with all fields from reports table
    - Add fromMap factory for JSON deserialization
    - Include populated fields for menfess, reporter, and reviewer display names
    - _Requirements: 8.1, 8.8_
  
  - [ ] 2.3 Create BannedUserModel
    - Implement BannedUserModel with all fields from banned_users table
    - Add fromMap factory for JSON deserialization
    - Add isPermanent and isExpired computed properties
    - Include populated fields for user and admin display names
    - _Requirements: 5.1, 5.4, 18.4, 18.5_
  
  - [ ] 2.4 Create AdminLogModel
    - Implement AdminLogModel with all fields from admin_logs table
    - Add fromMap factory for JSON deserialization
    - Support JSONB details field as Map<String, dynamic>
    - Include populated field for admin display name
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ] 2.5 Create AdminStatsModel
    - Implement AdminStatsModel with all statistics fields
    - Add fromMap factory for parsing admin_stats view
    - Include user, content, engagement, report, and admin activity metrics
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  
  - [ ] 2.6 Create UserAdminModel
    - Implement UserAdminModel with user info and aggregated statistics
    - Add fromMap factory for JSON deserialization
    - Include menfess count, comments count, reactions count, reports received, reports made
    - _Requirements: 11.3, 11.4, 11.5_

- [ ] 3. AdminProvider State Management
  - [ ] 3.1 Create AdminProvider class structure
    - Extend ChangeNotifier for state management
    - Add SupabaseClient dependency injection
    - Define state variables: currentUserRole, stats, reports, users, logs, isLoading, error
    - Add getters for all state variables
    - _Requirements: 1.2, 2.4_
  
  - [ ] 3.2 Implement initialize method
    - Fetch current user's role from database
    - Set currentUserRole state
    - Fetch initial dashboard stats if user is admin
    - Setup realtime subscriptions for admin users
    - Handle authentication errors
    - _Requirements: 1.2, 1.5, 2.1, 2.2, 2.3_
  
  - [ ] 3.3 Implement fetchStats method
    - Query admin_stats view
    - Parse response into AdminStatsModel
    - Update stats state and notify listeners
    - Handle errors gracefully
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 14.1_
  
  - [ ] 3.4 Implement deleteMenfess method
    - Check admin permissions before execution
    - Call admin_delete_menfess RPC function with menfess ID and reason
    - Refresh dashboard stats after successful deletion
    - Return success/failure boolean
    - Handle errors and update error state
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.7, 15.1, 15.2_
  
  - [ ] 3.5 Implement banUser method
    - Check admin permissions before execution
    - Validate expiration date is in future if provided
    - Call admin_ban_user RPC function with parameters
    - Refresh dashboard stats after successful ban
    - Return success/failure boolean
    - Handle errors including duplicate ban attempts
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 16.6_
  
  - [ ] 3.6 Implement unbanUser method
    - Check admin permissions before execution
    - Call admin_unban_user RPC function
    - Refresh dashboard stats after successful unban
    - Return success/failure boolean
    - Handle errors gracefully
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [ ] 3.7 Implement changeUserRole method
    - Check super_admin permissions before execution
    - Prevent changing own role
    - Validate new role value
    - Call admin_change_role RPC function
    - Return success/failure boolean
    - Handle errors and update error state
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  
  - [ ] 3.8 Implement resolveReport method
    - Check admin permissions before execution
    - Require resolution note
    - Call admin_resolve_report RPC function
    - Refresh reports and stats after resolution
    - Return success/failure boolean
    - _Requirements: 8.2, 8.3, 8.4, 8.6_
  
  - [ ] 3.9 Implement dismissReport method
    - Check admin permissions before execution
    - Call admin_dismiss_report RPC function
    - Refresh reports and stats after dismissal
    - Return success/failure boolean
    - _Requirements: 8.5, 8.6_
  
  - [ ] 3.10 Implement fetchReports method
    - Check admin permissions before execution
    - Query reports table with populated menfess, reporter, reviewer
    - Support status filtering
    - Order by created_at descending
    - Update reports state and notify listeners
    - Handle loading and error states
    - _Requirements: 8.1, 8.7, 8.8, 9.7_
  
  - [ ] 3.11 Implement fetchUsers method
    - Check admin permissions before execution
    - Call admin_get_users RPC function
    - Support search query and role filter parameters
    - Update users state and notify listeners
    - Handle loading and error states
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [ ] 3.12 Implement fetchLogs method
    - Check admin permissions before execution
    - Query admin_logs table with populated admin display name
    - Support action type filtering
    - Support limit parameter (default 100)
    - Order by created_at descending
    - Update logs state and notify listeners
    - _Requirements: 9.7, 9.8_
  
  - [ ] 3.13 Implement realtime subscriptions
    - Subscribe to reports table changes
    - Subscribe to admin_logs table inserts
    - Refresh relevant data on realtime events
    - Handle connection loss and reconnection
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 4. Checkpoint - Core Models and Provider Complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Admin Dashboard Screen
  - [ ] 5.1 Create AdminDashboardScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Implement initState to fetch stats on load
    - Add RefreshIndicator for pull-to-refresh
    - Handle loading, error, and success states
    - _Requirements: 3.8, 14.1_
  
  - [ ] 5.2 Build admin app bar component
    - Create app bar with yellow background and black border
    - Add admin icon and "ADMIN DASHBOARD" title
    - Add exit button to return to regular user interface
    - Use Neo-Brutalism styling (Space Grotesk font, hard shadows)
    - _Requirements: 12.4_
  
  - [ ] 5.3 Build stats grid component
    - Create 2-column grid layout for stats cards
    - Display overview section: Total Users, Active Today, Total Posts, Pending Reports
    - Display today's activity section: New Users, New Posts, Reactions, Comments
    - Use color coding: blue (users), green (active), yellow (posts), red (reports), purple (comments)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  
  - [ ] 5.4 Create StatsCard widget
    - Display icon, value, and label
    - Use Neo-Brutalism card styling with border and hard shadow
    - Support color customization per stat type
    - Implement press animation
    - _Requirements: 17.3_
  
  - [ ] 5.5 Build quick actions section
    - Create quick action buttons: View Reports, Manage Users, View Audit Logs
    - Implement navigation to respective screens
    - Use Neo-Brutalism button styling
    - _Requirements: 12.3, 12.5_

- [ ] 6. Content Moderation Screen
  - [ ] 6.1 Create ContentModerationScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Fetch all menfess posts with admin context
    - Implement infinite scroll pagination
    - Add filter options (all, reported, recent)
    - _Requirements: 4.1, 14.5_
  
  - [ ] 6.2 Create MenfessAdminCard widget
    - Display menfess content with metadata
    - Add delete button with confirmation
    - Show report count badge if reported
    - Use Neo-Brutalism card styling
    - _Requirements: 4.1, 4.4_
  
  - [ ] 6.3 Implement delete confirmation dialog
    - Show confirmation dialog with menfess preview
    - Require deletion reason input
    - Implement two-step confirmation (confirm → reason → delete)
    - Use Neo-Brutalism dialog styling
    - Call AdminProvider.deleteMenfess on confirmation
    - Show success/error snackbar
    - _Requirements: 4.3, 4.4, 4.5, 4.6, 4.7, 19.1, 19.3, 19.4, 19.5_
  
  - [ ] 6.4 Add bulk selection mode
    - Implement checkbox selection for multiple menfess
    - Add "Select All" and "Clear Selection" actions
    - Add bulk delete action with confirmation
    - Process each deletion individually and report results
    - _Requirements: 11.6_

- [x] 7. User Management Screen
  - [x] 7.1 Create UserManagementScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Fetch users with admin statistics
    - Implement search bar with debouncing
    - Add role filter dropdown (All, User, Moderator, Super Admin)
    - _Requirements: 11.1, 11.2_
  
  - [x] 7.2 Create UserAdminCard widget
    - Display user info: display name, role badge, ban status
    - Show user statistics: menfess count, comments, reactions, reports
    - Add action buttons: Ban/Unban, Change Role (super_admin only)
    - Use Neo-Brutalism card styling with role-based color coding
    - _Requirements: 11.3, 11.4, 11.5_
  
  - [x] 7.3 Implement ban user dialog
    - Show confirmation dialog with user info
    - Require ban reason input
    - Add optional expiration date picker
    - Add optional notes field
    - Call AdminProvider.banUser on confirmation
    - Show success/error snackbar
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.10, 19.2, 19.3, 19.4, 19.5_
  
  - [x] 7.4 Implement unban user dialog
    - Show confirmation dialog with ban details
    - Call AdminProvider.unbanUser on confirmation
    - Show success/error snackbar
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [x] 7.5 Implement change role dialog (super_admin only)
    - Show dialog with current role and role selector
    - Validate super_admin permissions
    - Prevent changing own role
    - Call AdminProvider.changeUserRole on confirmation
    - Show success/error snackbar
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  
  - [x] 7.6 Add bulk user actions
    - Implement checkbox selection for multiple users
    - Add bulk ban action with shared reason
    - Process each action individually and report results
    - _Requirements: 11.6_

- [ ] 8. Checkpoint - Core Admin Screens Complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Reports Management Screen
  - [ ] 9.1 Create ReportsScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Fetch reports with populated menfess data
    - Add status filter tabs (All, Pending, Reviewing, Resolved, Dismissed)
    - Implement infinite scroll pagination
    - _Requirements: 8.1, 8.7, 14.5_
  
  - [ ] 9.2 Create ReportCard widget
    - Display report reason, description, reporter, timestamp
    - Show associated menfess content preview
    - Add action buttons: Resolve, Dismiss, Delete Content
    - Show reviewer and resolution note for processed reports
    - Use Neo-Brutalism card styling with status-based color coding
    - _Requirements: 8.1, 8.8_
  
  - [ ] 9.3 Implement resolve report dialog
    - Show dialog with report details and menfess preview
    - Require resolution note input
    - Call AdminProvider.resolveReport on confirmation
    - Show success/error snackbar
    - _Requirements: 8.2, 8.3, 8.4, 8.6_
  
  - [ ] 9.4 Implement dismiss report dialog
    - Show confirmation dialog with report details
    - Call AdminProvider.dismissReport on confirmation
    - Show success/error snackbar
    - _Requirements: 8.5, 8.6_
  
  - [ ] 9.5 Implement delete content action
    - Show confirmation dialog with menfess preview
    - Require deletion reason input
    - Call AdminProvider.deleteMenfess to delete reported content
    - Automatically resolve report after deletion
    - Show success/error snackbar
    - _Requirements: 4.1, 4.2, 4.3, 8.2, 8.6_

- [ ] 10. Analytics Screen
  - [ ] 10.1 Create AnalyticsScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Add date range selector (Today, Week, Month, Year, Custom)
    - Fetch time-series data for charts
    - _Requirements: 17.1, 17.2_
  
  - [ ] 10.2 Implement user growth chart
    - Use fl_chart package for line chart
    - Display new users over time
    - Add cumulative total users line
    - Use Neo-Brutalism styling (thick lines, hard grid)
    - Support hover/tap to show exact values
    - _Requirements: 17.1, 17.3, 17.4_
  
  - [ ] 10.3 Implement engagement metrics chart
    - Use fl_chart package for bar chart
    - Display reactions, comments, menfess counts over time
    - Use color coding per metric type
    - Support hover/tap to show exact values
    - _Requirements: 17.2, 17.3, 17.4_
  
  - [ ] 10.4 Add chart animations
    - Animate chart transitions when data updates
    - Use smooth easing curves
    - Maintain Neo-Brutalism aesthetic during animations
    - _Requirements: 17.5_

- [ ] 11. Audit Logs Screen
  - [ ] 11.1 Create AuditLogsScreen widget
    - Create StatefulWidget with AdminProvider dependency
    - Fetch audit logs with populated admin names
    - Add action type filter dropdown
    - Implement infinite scroll pagination
    - _Requirements: 9.7, 9.8, 14.5_
  
  - [ ] 11.2 Create AuditLogCard widget
    - Display admin name, action type, target type, target ID
    - Show timestamp with relative time (e.g., "2 hours ago")
    - Display action details JSON in expandable section
    - Show IP address and user agent if available
    - Use Neo-Brutalism card styling with action-based color coding
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ] 11.3 Add export functionality
    - Add export button to download logs as CSV
    - Use csv package to generate CSV file
    - Use file_picker package to save file
    - Include all log fields in export
    - Show success/error snackbar
    - _Requirements: 13.1, 13.2, 13.4_

- [ ] 12. Shared Admin Widgets
  - [ ] 12.1 Create BrutalConfirmDialog widget
    - Reusable confirmation dialog with title, message, confirm/cancel buttons
    - Support customizable button colors and labels
    - Use Neo-Brutalism styling (hard shadow, thick border)
    - Return boolean on dialog close
    - _Requirements: 19.1, 19.2, 19.4, 19.5_
  
  - [ ] 12.2 Create BrutalInputDialog widget
    - Reusable input dialog with title, message, text field, confirm/cancel buttons
    - Support validation and error messages
    - Use Neo-Brutalism text field styling
    - Return input text on confirmation
    - _Requirements: 4.3, 5.3, 8.3, 19.3_
  
  - [ ] 12.3 Create BrutalButton widget
    - Reusable button with press animation
    - Support customizable colors and icons
    - Use Neo-Brutalism styling (hard shadow, thick border)
    - Implement press state (shadow offset change)
    - _Requirements: 17.3, 19.5_
  
  - [ ] 12.4 Create BrutalBadge widget
    - Reusable badge for role, status, count indicators
    - Support customizable colors and text
    - Use Neo-Brutalism styling
    - _Requirements: 11.5, 18.5_
  
  - [ ] 12.5 Create AdminErrorHandler utility
    - Centralized error handling for admin actions
    - Map PostgrestException codes to user-friendly messages
    - Display errors as Neo-Brutalism styled snackbars
    - Log errors for debugging
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

- [ ] 13. Navigation and Routing
  - [ ] 13.1 Add admin routes to app router
    - Define routes for all admin screens
    - Implement route guards to check admin permissions
    - Redirect non-admins to home screen
    - _Requirements: 2.1, 12.3_
  
  - [ ] 13.2 Add admin toggle to main app
    - Add admin mode indicator in app bar or bottom nav
    - Show toggle only for users with admin role
    - Implement toggle to switch between user/admin views
    - Persist admin mode preference in session
    - _Requirements: 12.1, 12.2, 12.4, 12.6_
  
  - [ ] 13.3 Create admin sidebar navigation
    - Create drawer or sidebar with admin navigation links
    - Highlight current screen
    - Show user role badge
    - Add logout/exit admin mode button
    - Use Neo-Brutalism styling
    - _Requirements: 12.3, 12.4_

- [ ] 14. Checkpoint - All UI Components Complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Integration and Wiring
  - [ ] 15.1 Integrate AdminProvider with AppProvider
    - Add AdminProvider to app's provider hierarchy
    - Initialize AdminProvider on app startup
    - Share SupabaseClient instance
    - _Requirements: 1.2, 2.4_
  
  - [ ] 15.2 Wire admin screens to navigation
    - Connect all admin screens to router
    - Implement navigation from dashboard quick actions
    - Add back navigation to dashboard
    - Test navigation flows
    - _Requirements: 12.3, 12.4, 12.5_
  
  - [ ] 15.3 Implement permission-based UI rendering
    - Hide admin features for regular users
    - Show moderator features for moderators
    - Show all features for super_admins
    - Test role-based UI visibility
    - _Requirements: 2.1, 2.2, 2.3, 12.6_
  
  - [ ] 15.4 Setup realtime subscriptions on app init
    - Subscribe to reports and admin_logs channels
    - Handle realtime events and refresh UI
    - Test collaborative admin workflows
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [ ] 15.5 Add ban expiration background job
    - Create periodic task to check for expired bans
    - Automatically unban users with past expiration dates
    - Run check every hour
    - Log automatic unbans
    - _Requirements: 18.1, 18.2, 18.3_

- [ ] 16. Error Handling and Validation
  - [ ] 16.1 Add client-side input validation
    - Validate ban reason is non-empty
    - Validate expiration date is in future
    - Validate resolution notes are non-empty
    - Show inline validation errors
    - _Requirements: 4.3, 5.3, 5.5, 8.3, 15.3_
  
  - [ ] 16.2 Implement network error handling
    - Detect network failures
    - Show retry option in UI
    - Cache failed actions for retry
    - _Requirements: 15.4_
  
  - [ ] 16.3 Add unauthorized access logging
    - Log all unauthorized access attempts
    - Include user ID, attempted action, timestamp
    - Display error message to user
    - _Requirements: 2.5, 15.1_
  
  - [ ] 16.4 Implement rate limiting feedback
    - Detect rate limit errors from server
    - Show user-friendly message with retry time
    - Disable action buttons temporarily
    - _Requirements: 16.6_

- [ ] 17. Performance Optimization
  - [ ] 17.1 Implement pagination for large lists
    - Add pagination to reports list
    - Add pagination to users list
    - Add pagination to audit logs list
    - Load 20 items per page
    - Implement infinite scroll
    - _Requirements: 14.5_
  
  - [ ] 17.2 Add stats caching
    - Cache dashboard stats for 1 minute
    - Invalidate cache on admin actions
    - Show cached data while refreshing
    - _Requirements: 3.8, 14.1_
  
  - [ ] 17.3 Optimize realtime subscriptions
    - Subscribe only to relevant channels
    - Unsubscribe when leaving admin mode
    - Throttle realtime updates to prevent UI thrashing
    - _Requirements: 10.1, 10.2, 10.3, 14.3_
  
  - [ ] 17.4 Add loading skeletons
    - Create skeleton loaders for stats cards
    - Create skeleton loaders for list items
    - Show skeletons during initial load
    - _Requirements: 14.1_

- [ ] 18. Testing and Quality Assurance
  - [ ]* 18.1 Write unit tests for models
    - Test UserRole enum conversions
    - Test model fromMap factories
    - Test model computed properties
    - Test date parsing and validation
  
  - [ ]* 18.2 Write unit tests for AdminProvider
    - Test initialize method with different roles
    - Test permission checks for each action
    - Test error handling for failed actions
    - Test state updates and notifications
    - Mock SupabaseClient for isolated testing
  
  - [ ]* 18.3 Write widget tests for admin screens
    - Test dashboard screen rendering
    - Test stats card display
    - Test navigation actions
    - Test loading and error states
  
  - [ ]* 18.4 Write integration tests for admin workflows
    - Test end-to-end delete menfess workflow
    - Test end-to-end ban user workflow
    - Test end-to-end report resolution workflow
    - Test role-based access control
  
  - [ ]* 18.5 Test permission boundaries
    - Test moderator cannot change roles
    - Test moderator cannot ban super_admin
    - Test user cannot access admin features
    - Test self-action prevention
  
  - [ ]* 18.6 Test error scenarios
    - Test network failures
    - Test unauthorized access
    - Test invalid inputs
    - Test concurrent modifications
  
  - [ ]* 18.7 Perform security audit
    - Verify RLS policies are enforced
    - Test SQL injection prevention
    - Test rate limiting
    - Test session invalidation on ban

- [ ] 19. Documentation and Deployment
  - [ ] 19.1 Update pubspec.yaml with new dependencies
    - Add fl_chart for analytics charts
    - Add data_table_2 for advanced tables
    - Add file_picker for export functionality
    - Add csv for CSV generation
    - _Requirements: 13.1, 17.1, 17.2_
  
  - [ ] 19.2 Create database migration script
    - Package all SQL changes into migration file
    - Add rollback script for safety
    - Test migration on staging database
    - _Requirements: 1.3, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6_
  
  - [ ] 19.3 Write admin user guide
    - Document how to access admin dashboard
    - Document each admin feature
    - Include screenshots and examples
    - Document permission levels
  
  - [ ] 19.4 Deploy database changes
    - Run migration script on production database
    - Verify all tables, views, and functions created
    - Test RLS policies
    - Create initial super_admin user
  
  - [ ] 19.5 Deploy Flutter app update
    - Build and test app with admin features
    - Deploy to app stores or distribution platform
    - Monitor for errors and crashes
    - Gather initial feedback from admins

- [ ] 20. Final Checkpoint - Complete System Verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- The design document uses Dart (Flutter's language), so all implementation will be in Dart
- Database work uses PostgreSQL with Supabase-specific features (RLS, RPC, Realtime)
- All UI components follow the Neo-Brutalism design aesthetic established in the existing app
- Checkpoints ensure incremental validation and quality
- Property-based tests are not included as the design focuses on CRUD operations and UI rendering rather than complex algorithmic properties
- Integration tests validate end-to-end workflows and permission boundaries
- The implementation follows a bottom-up approach: database → models → services → UI → integration
