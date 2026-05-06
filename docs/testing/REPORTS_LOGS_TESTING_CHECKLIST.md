# Reports & Audit Logs - Testing Checklist

## 🧪 Pre-Testing Setup

### Database Requirements
- [ ] Table `reports` exists dengan semua kolom
- [ ] Table `admin_logs` exists dengan semua kolom
- [ ] RLS policies aktif untuk kedua table
- [ ] RPC function `admin_resolve_report()` exists
- [ ] RPC function `admin_dismiss_report()` exists
- [ ] Realtime enabled untuk table `reports`
- [ ] Realtime enabled untuk table `admin_logs`

### Test Data
- [ ] Ada minimal 5 reports dengan status berbeda
- [ ] Ada minimal 10 audit logs dengan action berbeda
- [ ] Ada reports dengan description
- [ ] Ada reports tanpa description
- [ ] Ada reports dengan menfess yang masih exist
- [ ] Ada reports dengan menfess yang sudah dihapus
- [ ] Ada logs dengan details JSON
- [ ] Ada logs dengan IP address

---

## 📱 Reports Management Screen Testing

### Navigation
- [ ] Dari Admin Dashboard, tap "VIEW REPORTS" → Navigate ke Reports screen
- [ ] Reports screen muncul dengan app bar merah
- [ ] Back button di app bar berfungsi → Kembali ke dashboard

### Initial Load
- [ ] Loading indicator muncul saat pertama kali load
- [ ] Setelah load, reports list muncul
- [ ] Filter bar muncul dengan semua chip buttons
- [ ] Default filter adalah "ALL"

### Filter Functionality
- [ ] Tap "ALL" → Menampilkan semua reports
- [ ] Tap "PENDING" → Hanya pending reports muncul
- [ ] Tap "REVIEWING" → Hanya reviewing reports muncul
- [ ] Tap "RESOLVED" → Hanya resolved reports muncul
- [ ] Tap "DISMISSED" → Hanya dismissed reports muncul
- [ ] Active filter chip memiliki shadow dan colored background
- [ ] Inactive filter chip memiliki white background
- [ ] Loading indicator muncul saat ganti filter
- [ ] List update sesuai filter yang dipilih

### Report Card Display
- [ ] Status badge muncul dengan warna yang benar
- [ ] Reason badge muncul dengan warna yang benar
- [ ] Timestamp format benar (dd MMM, HH:mm)
- [ ] Reporter name muncul (atau "Anonymous" jika null)
- [ ] Description section muncul jika ada description
- [ ] Description section tidak muncul jika description null/empty
- [ ] Reported post section muncul jika menfess exists
- [ ] Reported post preview max 3 lines dengan ellipsis
- [ ] Reviewer info muncul jika report sudah direview
- [ ] Resolution note muncul jika report resolved
- [ ] Action buttons muncul untuk pending/reviewing reports
- [ ] Action buttons TIDAK muncul untuk resolved/dismissed reports

### Resolve Report Flow
- [ ] Tap "RESOLVE" button → Dialog muncul
- [ ] Dialog title: "RESOLVE REPORT"
- [ ] Dialog message informatif
- [ ] Text input field muncul dengan hint text
- [ ] Tap "BATAL" → Dialog close, tidak ada perubahan
- [ ] Tap "RESOLVE" dengan input kosong → Dialog close, tidak ada aksi
- [ ] Tap "RESOLVE" dengan input valid:
  - [ ] Dialog close
  - [ ] Loading indicator muncul
  - [ ] Success snackbar muncul: "Report resolved successfully"
  - [ ] Report card update ke status "Resolved"
  - [ ] Resolution note muncul di card
  - [ ] Reviewer name muncul (current admin)
  - [ ] Action buttons hilang dari card
  - [ ] List auto-refresh

### Dismiss Report Flow
- [ ] Tap "DISMISS" button → Confirmation dialog muncul
- [ ] Dialog title: "DISMISS REPORT?"
- [ ] Dialog message: "Laporan ini akan ditandai sebagai dismissed. Yakin?"
- [ ] Tap "BATAL" → Dialog close, tidak ada perubahan
- [ ] Tap "DISMISS":
  - [ ] Dialog close
  - [ ] Loading indicator muncul
  - [ ] Success snackbar muncul: "Report dismissed"
  - [ ] Report card update ke status "Dismissed"
  - [ ] Reviewer name muncul (current admin)
  - [ ] Action buttons hilang dari card
  - [ ] List auto-refresh

### Pull-to-Refresh
- [ ] Pull down list → Refresh indicator muncul
- [ ] Release → Loading indicator
- [ ] List update dengan data terbaru
- [ ] Current filter tetap aktif setelah refresh

### Empty State
- [ ] Filter ke status yang tidak ada data → Empty state muncul
- [ ] Empty state icon: Yellow box dengan checkmark
- [ ] Empty state title: "No Reports"
- [ ] Empty state message sesuai filter
- [ ] Pull-to-refresh tetap berfungsi di empty state

### Error Handling
- [ ] Disconnect internet → Error state muncul
- [ ] Error icon: Red warning icon
- [ ] Error title: "Failed to load reports"
- [ ] Error message muncul
- [ ] Resolve report gagal → Error snackbar muncul
- [ ] Dismiss report gagal → Error snackbar muncul

### Realtime Updates
- [ ] Admin lain resolve report → List auto-update
- [ ] Admin lain dismiss report → List auto-update
- [ ] User baru submit report → List auto-update (jika filter ALL/PENDING)

---

## 📜 Audit Logs Screen Testing

### Navigation
- [ ] Dari Admin Dashboard, tap "VIEW AUDIT LOGS" → Navigate ke Audit Logs screen
- [ ] Audit Logs screen muncul dengan app bar ungu
- [ ] Back button di app bar berfungsi → Kembali ke dashboard

### Initial Load
- [ ] Loading indicator muncul saat pertama kali load
- [ ] Setelah load, logs list muncul
- [ ] Filter bar muncul dengan semua chip buttons
- [ ] Default filter adalah "ALL"
- [ ] Logs diurutkan dari terbaru (descending by created_at)

### Filter Functionality
- [ ] Tap "ALL" → Menampilkan semua logs
- [ ] Tap "DELETE POST" → Hanya delete_menfess logs muncul
- [ ] Tap "BAN USER" → Hanya ban_user logs muncul
- [ ] Tap "UNBAN USER" → Hanya unban_user logs muncul
- [ ] Tap "CHANGE ROLE" → Hanya change_role logs muncul
- [ ] Tap "RESOLVE REPORT" → Hanya resolve_report logs muncul
- [ ] Active filter chip memiliki shadow dan colored background
- [ ] Inactive filter chip memiliki white background
- [ ] Loading indicator muncul saat ganti filter
- [ ] List update sesuai filter yang dipilih

### Log Card Display
- [ ] Action badge muncul dengan icon yang benar
- [ ] Action badge warna sesuai action type:
  - [ ] Delete actions: Red
  - [ ] Ban user: Orange
  - [ ] Unban user: Green
  - [ ] Change role: Blue
  - [ ] Report actions: Purple
- [ ] Timestamp format benar (dd MMM yyyy, HH:mm)
- [ ] Admin name muncul (atau "Unknown" jika null)
- [ ] Target type dan ID preview muncul (8 chars + ...)
- [ ] Details section muncul jika details exists
- [ ] Details section tidak muncul jika details null/empty
- [ ] Details key-value pairs display dengan benar
- [ ] IP address muncul jika tersedia
- [ ] IP address tidak muncul jika null

### Action Badge Icons
- [ ] Delete actions: 🗑️ delete icon
- [ ] Ban user: 🚫 block icon
- [ ] Unban user: ✓ check_circle icon
- [ ] Change role: 👨‍💼 admin_panel_settings icon
- [ ] Resolve report: ✓ check icon
- [ ] Dismiss report: ✗ close icon

### Pull-to-Refresh
- [ ] Pull down list → Refresh indicator muncul
- [ ] Release → Loading indicator
- [ ] List update dengan data terbaru
- [ ] Current filter tetap aktif setelah refresh

### Empty State
- [ ] Filter ke action yang tidak ada data → Empty state muncul
- [ ] Empty state icon: Purple box dengan history icon
- [ ] Empty state title: "No Logs"
- [ ] Empty state message sesuai filter
- [ ] Pull-to-refresh tetap berfungsi di empty state

### Error Handling
- [ ] Disconnect internet → Error state muncul
- [ ] Error icon: Red warning icon
- [ ] Error title: "Failed to load logs"
- [ ] Error message muncul

### Realtime Updates
- [ ] Admin lain perform action → New log muncul di list
- [ ] Current admin perform action → New log muncul di list
- [ ] List auto-scroll ke top saat ada log baru (optional)

---

## 🎨 UI/UX Testing

### Neo-Brutalism Design
- [ ] Semua borders tebal (4px untuk card, 2-3px untuk button)
- [ ] Semua shadows hard (no blur)
- [ ] Font: Space Grotesk
- [ ] Typography weights benar (900 untuk heading, 600-700 untuk body)
- [ ] Border radius minimal (0px atau 4px)
- [ ] Color palette konsisten dengan theme

### Button Animations
- [ ] Filter chips: Tap → Active state dengan shadow
- [ ] Action buttons: Tap down → Pressed state (no shadow, offset)
- [ ] Action buttons: Tap up → Normal state (with shadow)
- [ ] Icon buttons: Tap down → Pressed state
- [ ] Icon buttons: Tap up → Normal state
- [ ] Dialog buttons: Tap animation smooth

### Responsive Layout
- [ ] Cards full width dengan proper padding
- [ ] Text tidak overflow
- [ ] Long content dengan ellipsis atau wrap
- [ ] Scroll smooth
- [ ] Filter bar horizontal scroll jika chips overflow

### Accessibility
- [ ] Semua buttons tappable (min 44x44 dp)
- [ ] Text readable (sufficient contrast)
- [ ] Icons meaningful
- [ ] Loading states clear
- [ ] Error messages helpful

---

## 🔄 Integration Testing

### AdminProvider Integration
- [ ] `fetchReports()` dipanggil saat screen load
- [ ] `fetchReports(status: 'pending')` dipanggil saat filter pending
- [ ] `resolveReport(id, note)` dipanggil saat resolve
- [ ] `dismissReport(id)` dipanggil saat dismiss
- [ ] `fetchLogs()` dipanggil saat screen load
- [ ] `fetchLogs(actionFilter: 'delete_menfess')` dipanggil saat filter
- [ ] Provider state updates trigger UI rebuild
- [ ] Loading state dari provider reflected di UI
- [ ] Error state dari provider reflected di UI

### Navigation Integration
- [ ] Dashboard → Reports → Back → Dashboard
- [ ] Dashboard → Audit Logs → Back → Dashboard
- [ ] Reports screen tidak crash saat back
- [ ] Audit Logs screen tidak crash saat back
- [ ] State preserved saat navigate back (optional)

### Realtime Integration
- [ ] Supabase realtime channel subscribed
- [ ] Reports channel listening to changes
- [ ] Logs channel listening to inserts
- [ ] UI updates saat realtime event
- [ ] No memory leaks saat dispose

---

## 🐛 Edge Cases Testing

### Reports Screen
- [ ] Report dengan menfess yang sudah dihapus → Handle gracefully
- [ ] Report dengan reporter yang sudah dihapus → Show "Anonymous"
- [ ] Report dengan description sangat panjang → Wrap atau scroll
- [ ] Report dengan resolution note sangat panjang → Wrap atau scroll
- [ ] Resolve dengan note kosong → Tidak submit
- [ ] Resolve dengan note whitespace only → Tidak submit
- [ ] Multiple rapid taps pada button → Tidak duplicate action
- [ ] Network timeout → Show error
- [ ] Invalid report ID → Show error

### Audit Logs Screen
- [ ] Log dengan details null → Tidak crash
- [ ] Log dengan details empty object → Tidak crash
- [ ] Log dengan admin yang sudah dihapus → Show "Unknown"
- [ ] Log dengan target yang sudah dihapus → Still show ID
- [ ] Log dengan IP address null → Tidak crash
- [ ] Log dengan action tidak dikenal → Show default color/icon
- [ ] Very long details value → Wrap text
- [ ] 100+ logs → Scroll smooth, no lag

### General
- [ ] Screen rotation → Layout adjust (jika support)
- [ ] Low memory → Tidak crash
- [ ] Slow network → Loading state persistent
- [ ] No network → Error state clear
- [ ] Background → Foreground → State preserved

---

## 📊 Performance Testing

### Load Time
- [ ] Initial load < 2 seconds (normal network)
- [ ] Filter change < 1 second
- [ ] Pull-to-refresh < 2 seconds
- [ ] Dialog open/close instant
- [ ] Navigation smooth (no jank)

### Memory
- [ ] No memory leaks saat navigate back
- [ ] Realtime channels disposed properly
- [ ] Images/icons loaded efficiently
- [ ] List scrolling smooth (60fps)

### Battery
- [ ] Realtime tidak drain battery excessively
- [ ] No unnecessary rebuilds
- [ ] Efficient state management

---

## ✅ Final Checklist

### Code Quality
- [ ] No diagnostic errors
- [ ] No warnings
- [ ] Code formatted properly
- [ ] Comments clear dan helpful
- [ ] No hardcoded strings (use proper text)
- [ ] No magic numbers

### Documentation
- [ ] README updated
- [ ] Visual guide complete
- [ ] Testing checklist complete
- [ ] Implementation summary complete

### Deployment Ready
- [ ] All tests passed
- [ ] No known bugs
- [ ] Performance acceptable
- [ ] UI polished
- [ ] Ready for production

---

## 🎯 Test Results Summary

**Date:** _____________

**Tester:** _____________

**Device:** _____________

**OS Version:** _____________

**App Version:** _____________

### Results
- **Total Tests:** _____ / _____
- **Passed:** _____
- **Failed:** _____
- **Blocked:** _____

### Critical Issues Found
1. _____________________________________________
2. _____________________________________________
3. _____________________________________________

### Minor Issues Found
1. _____________________________________________
2. _____________________________________________
3. _____________________________________________

### Notes
_________________________________________________
_________________________________________________
_________________________________________________

**Status:** [ ] PASS  [ ] FAIL  [ ] NEEDS REVIEW

**Approved by:** _____________  **Date:** _____________
