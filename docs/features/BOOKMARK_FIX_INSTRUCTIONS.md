# 🔖 Bookmark Button Fix Instructions

## Problem
The bookmark button is clickable but fails with this error:
```
❌ BookmarkService.toggleBookmark ERROR: PostgrestException(message: column "actor_id" of relation "notifications" does not exist, code: 42703)
```

## Root Cause
Your Supabase `notifications` table is missing the `actor_id` column. This column is needed by the database trigger that automatically creates notifications when someone bookmarks a post.

## Solution

### Step 1: Fix the Database (Required)
1. Open your **Supabase Dashboard**
2. Go to **SQL Editor**
3. Copy and paste the contents of `FIX_BOOKMARK_DATABASE.sql`
4. Click **Run** to execute the SQL

This will:
- Add the missing `actor_id` column to the `notifications` table
- Recreate the bookmark notification trigger

### Step 2: App Code Fix (Already Done ✅)
I've already updated `lib/models/notification_model.dart` to make `actor_id` optional, so the app won't crash if the column is missing.

## Testing
After running the SQL fix:
1. Hot restart your Flutter app
2. Try bookmarking a post
3. The bookmark should work without errors
4. The post owner should receive a notification

## Files Modified
- ✅ `lib/models/notification_model.dart` - Made `actor_id` optional
- ✅ `FIX_BOOKMARK_DATABASE.sql` - SQL script to fix database

## Alternative: Manual Database Fix
If you prefer to fix it manually in Supabase:
1. Go to **Table Editor** → `notifications` table
2. Click **Add Column**
3. Column name: `actor_id`
4. Type: `uuid`
5. Foreign key: `auth.users(id)` with `ON DELETE SET NULL`
6. Click **Save**
