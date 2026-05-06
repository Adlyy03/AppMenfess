# Requirements Document: Admin Dashboard System

## Introduction

The Admin Dashboard System provides comprehensive administrative capabilities for the Flutter Menfess app, enabling role-based content moderation, user management, analytics, and audit logging. The system implements a three-tier role hierarchy (user, moderator, super_admin) with granular permissions to ensure platform health, user safety, and compliance while maintaining the app's Neo-Brutalism design aesthetic.

## Glossary

- **System**: The Admin Dashboard System within the Flutter Menfess app
- **Admin**: A user with either moderator or super_admin role
- **Moderator**: A user with elevated permissions to moderate content and manage users
- **Super_Admin**: A user with full administrative permissions including role management
- **Regular_User**: A user with the default 'user' role and no administrative privileges
- **Menfess**: A user-generated post in the app
- **Report**: A user-submitted complaint about a menfess post
- **Ban**: A restriction preventing a user from accessing the app
- **Admin_Action**: Any moderation or management operation performed by an admin
- **Audit_Log**: A record of an admin action with timestamp and details
- **Dashboard**: The main admin interface displaying platform statistics
- **RLS_Policy**: Row Level Security policy enforcing database access control
- **RPC_Function**: Remote Procedure Call function executing server-side logic

## Requirements

### Requirement 1: Role-Based Authentication

**User Story:** As a system administrator, I want users to have distinct roles with different permission levels, so that I can control who can perform administrative actions.

#### Acceptance Criteria

1. THE System SHALL support three user roles: 'user', 'moderator', and 'super_admin'
2. WHEN a user authenticates, THE System SHALL retrieve their role from the database
3. THE System SHALL store user roles in the public.users table with a role column
4. THE System SHALL default new users to the 'user' role
5. WHEN a user's role is queried, THE System SHALL return the role within 500 milliseconds
6. THE System SHALL validate that role values are one of: 'user', 'moderator', or 'super_admin'

### Requirement 2: Admin Access Control

**User Story:** As a security administrator, I want only authorized users to access admin features, so that the platform remains secure.

#### Acceptance Criteria

1. WHEN a regular user attempts to access admin features, THE System SHALL deny access and redirect to the home screen
2. WHEN a moderator accesses the admin dashboard, THE System SHALL grant access to moderation features
3. WHEN a super_admin accesses the admin dashboard, THE System SHALL grant access to all administrative features
4. THE System SHALL verify user permissions on every admin action request
5. WHEN an unauthorized access attempt occurs, THE System SHALL log the attempt
6. THE System SHALL implement Row Level Security policies on all admin-related database tables

### Requirement 3: Dashboard Statistics

**User Story:** As an admin, I want to view platform statistics at a glance, so that I can monitor platform health and activity.

#### Acceptance Criteria

1. WHEN an admin views the dashboard, THE System SHALL display total user count
2. WHEN an admin views the dashboard, THE System SHALL display new users today and this week
3. WHEN an admin views the dashboard, THE System SHALL display active users today
4. WHEN an admin views the dashboard, THE System SHALL display total menfess count and recent activity
5. WHEN an admin views the dashboard, THE System SHALL display engagement metrics (reactions, comments)
6. WHEN an admin views the dashboard, THE System SHALL display pending and reviewing report counts
7. WHEN an admin views the dashboard, THE System SHALL display admin actions performed today
8. WHEN an admin refreshes the dashboard, THE System SHALL update all statistics within 2 seconds
9. THE System SHALL calculate statistics using the admin_stats database view

### Requirement 4: Content Moderation

**User Story:** As a moderator, I want to delete inappropriate menfess posts, so that I can maintain content quality and user safety.

#### Acceptance Criteria

1. WHEN a moderator deletes a menfess, THE System SHALL remove the menfess from the database
2. WHEN a menfess is deleted, THE System SHALL cascade delete all related reactions and comments
3. WHEN a moderator deletes a menfess, THE System SHALL require a deletion reason
4. WHEN a menfess deletion is requested, THE System SHALL show a confirmation dialog
5. WHEN a menfess is deleted, THE System SHALL create an audit log entry with the admin ID, menfess ID, and reason
6. WHEN a menfess deletion completes, THE System SHALL update the dashboard statistics
7. WHEN a menfess deletion fails, THE System SHALL display an error message and not modify the database

### Requirement 5: User Ban Management

**User Story:** As a moderator, I want to ban users who violate platform rules, so that I can protect the community.

#### Acceptance Criteria

1. WHEN a moderator bans a user, THE System SHALL create a record in the banned_users table
2. WHEN a user is banned, THE System SHALL set the is_banned flag to TRUE in the users table
3. WHEN a moderator bans a user, THE System SHALL require a ban reason
4. WHEN a moderator bans a user, THE System SHALL support optional expiration dates for temporary bans
5. WHEN a ban expiration date is provided, THE System SHALL validate that it is in the future
6. WHEN a user is banned, THE System SHALL invalidate all active user sessions
7. WHEN a moderator attempts to ban themselves, THE System SHALL reject the action
8. WHEN a moderator attempts to ban a super_admin, THE System SHALL reject the action unless the moderator is also a super_admin
9. WHEN a user is already banned, THE System SHALL reject duplicate ban attempts
10. WHEN a user is banned, THE System SHALL create an audit log entry

### Requirement 6: User Unban Management

**User Story:** As a moderator, I want to unban users, so that I can restore access for users who have served their ban period or were banned in error.

#### Acceptance Criteria

1. WHEN a moderator unbans a user, THE System SHALL set the is_banned flag to FALSE in the users table
2. WHEN a user is unbanned, THE System SHALL deactivate the active ban record by setting is_active to FALSE
3. WHEN a user is unbanned, THE System SHALL create an audit log entry
4. WHEN an unban completes, THE System SHALL allow the user to authenticate on their next login attempt

### Requirement 7: Role Management

**User Story:** As a super admin, I want to change user roles, so that I can promote moderators or demote users as needed.

#### Acceptance Criteria

1. WHEN a super_admin changes a user's role, THE System SHALL update the role column in the users table
2. WHEN a role change is requested, THE System SHALL verify the requester is a super_admin
3. WHEN a super_admin attempts to change their own role, THE System SHALL reject the action
4. WHEN a role change occurs, THE System SHALL validate the new role is one of: 'user', 'moderator', 'super_admin'
5. WHEN a role change completes, THE System SHALL create an audit log entry with the new role value
6. WHEN a moderator attempts to change any user's role, THE System SHALL reject the action

### Requirement 8: Report Management

**User Story:** As a moderator, I want to review and process user reports, so that I can address community concerns about content.

#### Acceptance Criteria

1. WHEN a moderator views reports, THE System SHALL display all reports with status, reason, and reporter information
2. WHEN a moderator resolves a report, THE System SHALL update the report status to 'resolved'
3. WHEN a moderator resolves a report, THE System SHALL require a resolution note
4. WHEN a report is resolved, THE System SHALL record the reviewing admin ID and timestamp
5. WHEN a moderator dismisses a report, THE System SHALL update the report status to 'dismissed'
6. WHEN a report is processed, THE System SHALL create an audit log entry
7. WHEN a moderator filters reports by status, THE System SHALL display only reports matching the selected status
8. WHEN a moderator views a report, THE System SHALL display the associated menfess content

### Requirement 9: Audit Logging

**User Story:** As a compliance officer, I want all admin actions to be logged, so that I can audit administrative activity and ensure accountability.

#### Acceptance Criteria

1. WHEN an admin performs any action, THE System SHALL create an entry in the admin_logs table
2. WHEN an audit log is created, THE System SHALL record the admin ID, action type, target type, and target ID
3. WHEN an audit log is created, THE System SHALL record the timestamp with millisecond precision
4. WHEN an audit log is created, THE System SHALL optionally record action details as JSON
5. WHEN an audit log is created, THE System SHALL optionally record the IP address and user agent
6. THE System SHALL prevent modification or deletion of audit log entries
7. WHEN an admin views audit logs, THE System SHALL display logs in reverse chronological order
8. WHEN an admin filters audit logs by action type, THE System SHALL display only matching log entries

### Requirement 10: Real-time Updates

**User Story:** As an admin, I want to see live updates when other admins make changes, so that I can collaborate effectively and avoid conflicts.

#### Acceptance Criteria

1. WHEN an admin is viewing the dashboard, THE System SHALL subscribe to real-time updates for reports
2. WHEN a report is created or updated, THE System SHALL notify all connected admins within 500 milliseconds
3. WHEN an admin action is logged, THE System SHALL broadcast the update to all connected admins
4. WHEN an admin receives a real-time update, THE System SHALL refresh the relevant data automatically
5. WHEN an admin loses connection, THE System SHALL attempt to reconnect automatically

### Requirement 11: User Management Interface

**User Story:** As an admin, I want to search and filter users, so that I can quickly find specific users to manage.

#### Acceptance Criteria

1. WHEN an admin searches for users, THE System SHALL filter users by display name using case-insensitive matching
2. WHEN an admin filters users by role, THE System SHALL display only users with the selected role
3. WHEN an admin views a user, THE System SHALL display aggregated statistics including menfess count, comment count, and reaction count
4. WHEN an admin views a user, THE System SHALL display the number of reports received and reports made
5. WHEN an admin views a user, THE System SHALL display the user's ban status and last login time
6. WHEN an admin performs a bulk action on multiple users, THE System SHALL process each user individually and report success or failure for each

### Requirement 12: Admin Dashboard Navigation

**User Story:** As an admin, I want to easily navigate between different admin sections, so that I can efficiently perform my duties.

#### Acceptance Criteria

1. WHEN an admin user launches the app, THE System SHALL display an admin toggle or indicator in the UI
2. WHEN an admin activates the admin mode, THE System SHALL navigate to the admin dashboard
3. WHEN an admin is in admin mode, THE System SHALL provide navigation to all admin screens
4. WHEN an admin exits admin mode, THE System SHALL return to the regular user interface
5. THE System SHALL provide quick action buttons on the dashboard for common tasks
6. WHEN a regular user launches the app, THE System SHALL hide all admin features and navigation

### Requirement 13: Data Export

**User Story:** As an admin, I want to export reports and audit logs, so that I can analyze data externally or create backups.

#### Acceptance Criteria

1. WHEN an admin requests a data export, THE System SHALL generate a CSV file with the requested data
2. WHEN exporting audit logs, THE System SHALL include all log fields in the export
3. WHEN exporting reports, THE System SHALL include report details and associated menfess information
4. WHEN an export completes, THE System SHALL provide a download link or save the file to device storage

### Requirement 14: Performance Requirements

**User Story:** As an admin, I want the dashboard to load quickly and respond promptly, so that I can work efficiently.

#### Acceptance Criteria

1. WHEN an admin opens the dashboard, THE System SHALL load and display statistics within 2 seconds
2. WHEN an admin performs an action, THE System SHALL complete the action within 1 second
3. WHEN an admin receives a real-time update, THE System SHALL display the update within 500 milliseconds
4. THE System SHALL support at least 10 concurrent admin users without performance degradation
5. WHEN an admin scrolls through large lists, THE System SHALL implement pagination to maintain performance

### Requirement 15: Error Handling

**User Story:** As an admin, I want clear error messages when actions fail, so that I can understand what went wrong and take corrective action.

#### Acceptance Criteria

1. WHEN an admin action fails due to insufficient permissions, THE System SHALL display "Insufficient permissions for this action"
2. WHEN an admin action fails due to a database error, THE System SHALL display a user-friendly error message
3. WHEN an admin attempts an invalid action, THE System SHALL display validation errors inline with the relevant field
4. WHEN a network error occurs, THE System SHALL display a retry option
5. WHEN an admin attempts to act on a deleted entity, THE System SHALL display "Target not found. It may have been deleted."
6. WHEN an error occurs, THE System SHALL log the error details for debugging purposes

### Requirement 16: Security Requirements

**User Story:** As a security administrator, I want the admin system to be secure against common attacks, so that the platform and user data remain protected.

#### Acceptance Criteria

1. THE System SHALL implement Row Level Security policies on all admin tables
2. THE System SHALL verify user permissions on the server side for every admin action
3. THE System SHALL use parameterized queries to prevent SQL injection attacks
4. THE System SHALL validate all user inputs on the server side
5. THE System SHALL sanitize user-provided text in reasons and notes
6. THE System SHALL implement rate limiting on destructive actions (maximum 10 bans per minute per admin)
7. THE System SHALL prevent users from changing their own role
8. THE System SHALL prevent moderators from banning or modifying super_admin accounts

### Requirement 17: Analytics Visualization

**User Story:** As an admin, I want to view charts and graphs of platform metrics, so that I can identify trends and patterns.

#### Acceptance Criteria

1. WHEN an admin views the analytics screen, THE System SHALL display a user growth chart
2. WHEN an admin views the analytics screen, THE System SHALL display an engagement metrics chart
3. WHEN an admin views a chart, THE System SHALL use the Neo-Brutalism design aesthetic
4. WHEN an admin interacts with a chart, THE System SHALL display detailed data on hover or tap
5. WHEN chart data is updated, THE System SHALL animate the transition smoothly

### Requirement 18: Ban Expiration Management

**User Story:** As a moderator, I want temporary bans to expire automatically, so that users regain access without manual intervention.

#### Acceptance Criteria

1. WHEN a ban expiration time is reached, THE System SHALL automatically unban the user
2. THE System SHALL check for expired bans at least once per hour
3. WHEN a ban expires, THE System SHALL set is_banned to FALSE and deactivate the ban record
4. WHEN a ban is created without an expiration date, THE System SHALL treat it as a permanent ban
5. WHEN viewing banned users, THE System SHALL indicate whether bans are temporary or permanent

### Requirement 19: Confirmation Dialogs

**User Story:** As an admin, I want confirmation dialogs for destructive actions, so that I can avoid accidental deletions or bans.

#### Acceptance Criteria

1. WHEN an admin attempts to delete a menfess, THE System SHALL display a confirmation dialog
2. WHEN an admin attempts to ban a user, THE System SHALL display a confirmation dialog
3. WHEN an admin confirms a destructive action, THE System SHALL require additional input (reason or note)
4. WHEN an admin cancels a confirmation dialog, THE System SHALL not perform the action
5. THE System SHALL style confirmation dialogs using the Neo-Brutalism design aesthetic

### Requirement 20: Database Schema Integrity

**User Story:** As a database administrator, I want the database schema to maintain referential integrity, so that data remains consistent.

#### Acceptance Criteria

1. WHEN a user is deleted, THE System SHALL cascade delete all related menfess, comments, and reactions
2. WHEN a menfess is deleted, THE System SHALL cascade delete all related reports, reactions, and comments
3. WHEN a user is deleted, THE System SHALL set the banned_by field to NULL in related ban records
4. WHEN a user is deleted, THE System SHALL set the admin_id field to NULL in related audit logs
5. THE System SHALL enforce foreign key constraints on all relationships
6. THE System SHALL enforce unique constraints on the banned_users table to prevent duplicate active bans

