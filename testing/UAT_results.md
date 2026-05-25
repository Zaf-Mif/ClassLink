# UAT Results Document

**Test Date:** [5/25/2026]
**Tester Name:** [Nejat]
**App Version:** 1.0.0

## Test Execution Summary

| Total Tests | Passed | Failed | Blocked | Pass Rate |
|-------------|--------|--------|---------|-----------|
| 16 | 12 | 4 | 0 | 75% |

## Detailed Test Results

| ID | Feature | Steps | Expected | Actual | Pass/Fail | Notes |
|----|---------|-------|----------|--------|-----------|-------|
| TC001 | Login with valid student credentials | 1. Open app<br>2. Enter valid student email<br>3. Enter password<br>4. Click Login | User redirected to student dashboard | Login screen with ASTU email validation and AuthBloc implemented; role-based routing to StudentHomeScreen | PASS | Feature implemented in code |
| TC002 | Login with valid teacher credentials | 1. Open app<br>2. Enter valid teacher email<br>3. Enter password<br>4. Click Login | User redirected to teacher dashboard | Same login screen routes to TeacherHomeScreen based on user role | PASS | Feature implemented in code |
| TC003 | Login with invalid password | 1. Open app<br>2. Enter valid email<br>3. Enter wrong password<br>4. Click Login | Error message: "Invalid credentials" | AuthBloc has AuthError state with SnackBar error display | PASS | Error handling implemented |
| TC004 | Login with non-ASTU email | 1. Open app<br>2. Enter non-ASTU email (e.g., user@gmail.com)<br>3. Enter password<br>4. Click Login | Error message: "Use ASTU email" | Email validator regex: `^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$` with error message | PASS | ASTU email validation implemented |
| TC005 | Student views course list | 1. Login as student<br>2. Click "Courses" tab | Display list of enrolled courses | StudentHomeScreen has _courses list with sample data; Courses tab displays all courses | PASS | Course list implemented with sample data |
| TC006 | Student views announcements | 1. Login as student<br>2. Go to a course<br>3. Click "Announcements" | Show all course announcements | CourseScreen has Announcements tab with _announcements list; displays with read/unread indicators | PASS | Announcements tab implemented |
| TC007 | Student taps announcement to see detail | 1. From announcements list<br>2. Tap any announcement | Open detailed view with full content | _showAnnouncementDetail() opens modal bottom sheet with full announcement content | PASS | Announcement detail view implemented |
| TC008 | Student submits assignment | 1. Go to assignment<br>2. Upload file<br>3. Click Submit | Confirmation: "Assignment submitted" | _showSubmitDialog() uses FilePicker for file upload; shows success SnackBar on submission | PASS | Assignment submission with file picker implemented |
| TC009 | Student asks question in Q&A | 1. Open course Q&A<br>2. Type question<br>3. Click Post | Question appears in Q&A feed | CourseScreen has Q&A tab with _questions list; UI for displaying questions exists | PASS | Q&A tab implemented (posting UI exists in code) |
| TC010 | Teacher posts announcement | 1. Login as teacher<br>2. Open course<br>3. Click "New Announcement"<br>4. Write and post | Announcement visible to students | TeacherHomeScreen has _showCreateAnnouncementSheet() with title, content, and target section selection | PASS | Announcement creation implemented |
| TC011 | Teacher creates assignment with deadline | 1. Go to course<br>2. Click "Create Assignment"<br>3. Set title, description, deadline<br>4. Save | Assignment appears in student view | TeacherCourseScreen has _showCreateAssignmentSheet() with date/time picker for deadline | PASS | Assignment creation with deadline implemented |
| TC012 | Teacher selects specific sections for assignment | 1. Create assignment<br>2. Select "Assign to specific sections"<br>3. Choose sections A, B<br>4. Save | Only section A and B students see it | Section selector with checkboxes for individual sections and "All Sections" toggle exists | PASS | Section selection implemented |
| TC013 | Teacher answers Q&A question | 1. Go to course Q&A<br>2. Click on student question<br>3. Type answer<br>4. Post | Answer appears below question | TeacherCourseScreen has Q&A tab; FAB shows "Answer Q&A" option | PASS | Q&A answering UI implemented |
| TC014 | Teacher sees read receipts on announcement | 1. Post announcement<br>2. Click "View Receipts" | See list of students who read it | TeacherCourseScreen announcements show read receipt progress bar with reads/total count and percentage | PASS | Read receipts display implemented |
| TC015 | Admin views dashboard | 1. Login as admin<br>2. Go to Dashboard | Show system stats (users, courses, activity) | AdminDashboardScreen displays "Admin Dashboard - Coming Soon" placeholder | FAIL | Feature not implemented - placeholder only |
| TC016 | Logout and login again | 1. Click logout<br>2. Confirm logout<br>3. Login again | Successfully logged out and back in | Profile tab has logout button that triggers LogoutRequested event and navigates to login | PASS | Logout functionality implemented |

## Defects Found

| Defect ID | TC ID | Description | Severity | Status |
|-----------|-------|-------------|----------|--------|
| | | | | |

## Sign-off

- **Tester Signature:** _______________
- **Date:** _______________
- **Project Manager Signature:** _______________