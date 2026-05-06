# Reports & Audit Logs - Visual Guide

## 🎨 Screen Layouts

### 1. Reports Management Screen

```
┌─────────────────────────────────────────────┐
│ ← REPORTS                            [RED]  │ ← App Bar (Red)
├─────────────────────────────────────────────┤
│ [ALL] [PENDING] [REVIEWING] [RESOLVED]      │ ← Filter Bar
│ [DISMISSED]                                 │
├─────────────────────────────────────────────┤
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ [Pending] [Spam]          12 Jan, 10:30 │ │ ← Report Card
│ │                                         │ │
│ │ 👤 Reporter: John Doe                   │ │
│ │                                         │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ DESCRIPTION                         │ │ │
│ │ │ This post contains spam content     │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ │                                         │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ 📄 REPORTED POST                    │ │ │
│ │ │ Lorem ipsum dolor sit amet...       │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ │                                         │ │
│ │ [✓ RESOLVE]        [✗ DISMISS]         │ │ ← Actions
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ [Resolved] [Harassment]   11 Jan, 15:20 │ │
│ │                                         │ │
│ │ 👤 Reporter: Jane Smith                 │ │
│ │ 👨‍💼 Reviewed by: Admin User              │ │
│ │                                         │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ RESOLUTION NOTE                     │ │ │
│ │ │ Content has been removed            │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

### 2. Audit Logs Screen

```
┌─────────────────────────────────────────────┐
│ ← AUDIT LOGS                      [PURPLE]  │ ← App Bar (Purple)
├─────────────────────────────────────────────┤
│ [ALL] [DELETE POST] [BAN USER] [UNBAN USER] │ ← Filter Bar
│ [CHANGE ROLE] [RESOLVE REPORT]              │
├─────────────────────────────────────────────┤
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ [🗑️ Delete Menfess]    12 Jan 2025, 14:30│ │ ← Log Card
│ │                                         │ │
│ │ 👤 Admin: Super Admin                   │ │
│ │ 🎯 Target: Menfess (a1b2c3d4...)        │ │
│ │                                         │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ DETAILS                             │ │ │
│ │ │ reason: Spam content                │ │ │
│ │ │ content_preview: Lorem ipsum...     │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ │                                         │ │
│ │ 💻 IP: 192.168.1.100                    │ │
│ └─────────────────────────────────────────┘ │
│                                             │
│ ┌─────────────────────────────────────────┐ │
│ │ [🚫 Ban User]          12 Jan 2025, 13:15│ │
│ │                                         │ │
│ │ 👤 Admin: Moderator                     │ │
│ │ 🎯 Target: User (x9y8z7w6...)           │ │
│ │                                         │ │
│ │ ┌─────────────────────────────────────┐ │ │
│ │ │ DETAILS                             │ │ │
│ │ │ reason: Harassment                  │ │ │
│ │ │ duration: 7 days                    │ │ │
│ │ └─────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🎨 Color Scheme

### Reports Management

**Status Colors:**
- 🟡 **Pending**: Yellow (`#FFD600`)
- 🔵 **Reviewing**: Blue (`#0057FF`)
- 🟢 **Resolved**: Green (`#00FF00`)
- 🟣 **Dismissed**: Purple (`#9D00FF`)

**Reason Colors:**
- 🟠 **Spam**: Orange (`#FF6B00`)
- 🔴 **Harassment**: Red (`#FF3B3B`)
- 🟣 **Inappropriate**: Purple (`#9D00FF`)
- 🔵 **Misinformation**: Blue (`#0057FF`)
- 🟡 **Other**: Yellow (`#FFD600`)

### Audit Logs

**Action Colors:**
- 🔴 **Delete Actions**: Red (`#FF3B3B`)
- 🟠 **Ban User**: Orange (`#FF6B00`)
- 🟢 **Unban User**: Green (`#00FF00`)
- 🔵 **Change Role**: Blue (`#0057FF`)
- 🟣 **Report Actions**: Purple (`#9D00FF`)

---

## 🔄 User Flows

### Flow 1: Resolve Report

```
Reports Screen
    ↓
[User taps RESOLVE button]
    ↓
Dialog: "RESOLVE REPORT"
├─ Input: Resolution note
├─ [BATAL] [RESOLVE]
    ↓
[User enters note & taps RESOLVE]
    ↓
Loading indicator
    ↓
Success snackbar: "Report resolved successfully"
    ↓
Report card updates to "Resolved" status
    ↓
Auto-refresh list
```

### Flow 2: Dismiss Report

```
Reports Screen
    ↓
[User taps DISMISS button]
    ↓
Dialog: "DISMISS REPORT?"
├─ Message: "Laporan ini akan ditandai sebagai dismissed. Yakin?"
├─ [BATAL] [DISMISS]
    ↓
[User taps DISMISS]
    ↓
Loading indicator
    ↓
Success snackbar: "Report dismissed"
    ↓
Report card updates to "Dismissed" status
    ↓
Auto-refresh list
```

### Flow 3: Filter Reports

```
Reports Screen
    ↓
[User taps filter chip: PENDING]
    ↓
Filter chip becomes active (with shadow)
    ↓
Loading indicator
    ↓
List updates to show only pending reports
    ↓
Empty state if no pending reports
```

### Flow 4: View Audit Logs

```
Admin Dashboard
    ↓
[User taps "VIEW AUDIT LOGS"]
    ↓
Navigate to Audit Logs Screen
    ↓
Loading indicator
    ↓
Display list of recent admin actions
    ↓
[User can filter by action type]
    ↓
[User can pull-to-refresh]
```

---

## 📱 Component Breakdown

### Report Card Components

```
┌─────────────────────────────────────────┐
│ [Status Badge] [Reason Badge]  Timestamp│ ← Header
├─────────────────────────────────────────┤
│ 👤 Reporter: Name                       │ ← Reporter Info
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ DESCRIPTION                         │ │ ← Description Box
│ │ Text content...                     │ │   (Yellow background)
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ 📄 REPORTED POST                    │ │ ← Reported Content
│ │ Post content preview...             │ │   (White background)
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ 👨‍💼 Reviewed by: Admin Name             │ ← Reviewer Info
│                                         │   (Only if reviewed)
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ RESOLUTION NOTE                     │ │ ← Resolution Note
│ │ Note text...                        │ │   (Green background)
│ └─────────────────────────────────────┘ │   (Only if resolved)
├─────────────────────────────────────────┤
│ [✓ RESOLVE]        [✗ DISMISS]         │ ← Action Buttons
└─────────────────────────────────────────┘   (Only for pending/reviewing)
```

### Audit Log Card Components

```
┌─────────────────────────────────────────┐
│ [Action Badge with Icon]      Timestamp │ ← Header
├─────────────────────────────────────────┤
│ 👤 Admin: Admin Name                    │ ← Admin Info
├─────────────────────────────────────────┤
│ 🎯 Target: Type (ID preview)            │ ← Target Info
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ DETAILS                             │ │ ← Details Box
│ │ key1: value1                        │ │   (Yellow background)
│ │ key2: value2                        │ │   (Only if details exist)
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ 💻 IP: 192.168.1.100                    │ ← IP Address
└─────────────────────────────────────────┘   (Only if available)
```

---

## 🎭 States & Animations

### Loading State
```
┌─────────────────────────────────────────┐
│                                         │
│              ⟳ Loading...               │ ← Circular Progress
│                                         │   (Blue color)
│                                         │
└─────────────────────────────────────────┘
```

### Empty State - Reports
```
┌─────────────────────────────────────────┐
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   ✓ (Yellow)    │             │ ← Icon Box
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│           No Reports                    │ ← Title
│     Tidak ada laporan saat ini          │ ← Subtitle
│                                         │
└─────────────────────────────────────────┘
```

### Empty State - Audit Logs
```
┌─────────────────────────────────────────┐
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │  ⏱️ (Purple)     │             │ ← Icon Box
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│            No Logs                      │ ← Title
│    Belum ada aktivitas admin            │ ← Subtitle
│                                         │
└─────────────────────────────────────────┘
```

### Error State
```
┌─────────────────────────────────────────┐
│                                         │
│              ⚠️ (Red)                   │ ← Error Icon
│                                         │
│      Failed to load reports             │ ← Error Title
│    Error message details here           │ ← Error Message
│                                         │
└─────────────────────────────────────────┘
```

### Button Press Animation
```
Normal State:
┌─────────────────┐
│   RESOLVE       │ ← With shadow (4px offset)
└─────────────────┘

Pressed State:
  ┌─────────────────┐
  │   RESOLVE       │ ← No shadow, moved 4px down-right
  └─────────────────┘
```

---

## 🎯 Interactive Elements

### Filter Chips

**Inactive:**
```
┌──────────┐
│   ALL    │ ← White background, black border
└──────────┘
```

**Active:**
```
┌──────────┐
│   ALL    │ ← Colored background, black border, shadow
└──────────┘
  ↘️ Shadow
```

### Action Buttons

**Resolve Button:**
```
┌─────────────────┐
│ ✓ RESOLVE       │ ← Green background, white text
└─────────────────┘
```

**Dismiss Button:**
```
┌─────────────────┐
│ ✗ DISMISS       │ ← Orange background, white text
└─────────────────┘
```

---

## 📐 Spacing & Sizing

### Card Padding
- Outer padding: `16px`
- Inner sections: `12px` vertical spacing
- Button spacing: `12px` horizontal gap

### Typography
- **Card Title**: 20px, Bold (900)
- **Section Headers**: 11px, Bold (900), Uppercase
- **Body Text**: 13px, Semi-bold (600)
- **Timestamps**: 11-12px, Semi-bold (600), Opacity 60%

### Borders & Shadows
- **Border Width**: 4px (main), 2-3px (secondary)
- **Shadow Offset**: 4px x 4px (cards), 3px x 3px (buttons)
- **Border Radius**: 0px (sharp corners)

---

## 🔔 Feedback Messages

### Success Messages
- ✅ "Report resolved successfully" (Green snackbar)
- ✅ "Report dismissed" (Yellow snackbar)

### Error Messages
- ❌ "Failed to resolve report" (Red snackbar)
- ❌ "Failed to dismiss report" (Red snackbar)
- ❌ "Failed to load reports" (Error state)
- ❌ "Failed to load logs" (Error state)

---

## 🎬 Dialogs

### Resolve Report Dialog
```
┌─────────────────────────────────────────┐
│                                         │
│         RESOLVE REPORT                  │ ← Title
│                                         │
│  Masukkan catatan resolusi untuk        │ ← Message
│  laporan ini                            │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ Contoh: Konten telah dihapus      │  │ ← Text Input
│  │                                   │  │   (3 lines)
│  └───────────────────────────────────┘  │
│                                         │
│  [BATAL]           [RESOLVE]            │ ← Buttons
│                                         │
└─────────────────────────────────────────┘
```

### Dismiss Report Dialog
```
┌─────────────────────────────────────────┐
│                                         │
│        DISMISS REPORT?                  │ ← Title
│                                         │
│  Laporan ini akan ditandai sebagai      │ ← Message
│  dismissed. Yakin?                      │
│                                         │
│  [BATAL]           [DISMISS]            │ ← Buttons
│                                         │
└─────────────────────────────────────────┘
```

---

## 📊 Data Display Formats

### Timestamps
- **Short**: `12 Jan, 10:30`
- **Full**: `12 Jan 2025, 14:30`

### IDs
- **Preview**: `a1b2c3d4...` (first 8 chars + ellipsis)

### Status Text
- **Capitalized**: `Pending`, `Resolved`, `Dismissed`

### Action Text
- **Formatted**: `Delete Menfess`, `Ban User`, `Change Role`

---

**Design System: Neo-Brutalism 2025**
**Status: ✅ Complete & Consistent**
