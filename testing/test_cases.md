# Test Cases Document

| ID | Feature | Steps | Expected | Actual | Pass/Fail |
|----|---------|-------|----------|--------|------------|
| TC001 | Login with valid student credentials | 1. Open app<br>2. Enter valid student email<br>3. Enter password<br>4. Click Login | User redirected to student dashboard | | |
| TC002 | Login with valid teacher credentials | 1. Open app<br>2. Enter valid teacher email<br>3. Enter password<br>4. Click Login | User redirected to teacher dashboard | | |
| TC003 | Login with invalid password | 1. Open app<br>2. Enter valid email<br>3. Enter wrong password<br>4. Click Login | Error message: "Invalid credentials" | | |
| TC004 | Login with non-ASTU email | 1. Open app<br>2. Enter non-ASTU email (e.g., user@gmail.com)<br>3. Enter password<br>4. Click Login | Error message: "Use ASTU email" | | |
| TC005 | Student views course list | 1. Login as student<br>2. Click "Courses" tab | Display list of enrolled courses | | |
| TC006 | Student views announcements | 1. Login as student<br>2. Go to a course<br>3. Click "Announcements" | Show all course announcements | | |
| TC007 | Student taps announcement to see detail | 1. From announcements list<br>2. Tap any announcement | Open detailed view with full content | | |
| TC008 | Student submits assignment | 1. Go to assignment<br>2. Upload file<br>3. Click Submit | Confirmation: "Assignment submitted" | | |
| TC009 | Student asks question in Q&A | 1. Open course Q&A<br>2. Type question<br>3. Click Post | Question appears in Q&A feed | | |
| TC010 | Teacher posts announcement | 1. Login as teacher<br>2. Open course<br>3. Click "New Announcement"<br>4. Write and post | Announcement visible to students | | |
| TC011 | Teacher creates assignment with deadline | 1. Go to course<br>2. Click "Create Assignment"<br>3. Set title, description, deadline<br>4. Save | Assignment appears in student view | | |
| TC012 | Teacher selects specific sections for assignment | 1. Create assignment<br>2. Select "Assign to specific sections"<br>3. Choose sections A, B<br>4. Save | Only section A and B students see it | | |
| TC013 | Teacher answers Q&A question | 1. Go to course Q&A<br>2. Click on student question<br>3. Type answer<br>4. Post | Answer appears below question | | |
| TC014 | Teacher sees read receipts on announcement | 1. Post announcement<br>2. Click "View Receipts" | See list of students who read it | | |
| TC015 | Admin views dashboard | 1. Login as admin<br>2. Go to Dashboard | Show system stats (users, courses, activity) | | |
| TC016 | Logout and login again | 1. Click logout<br>2. Confirm logout<br>3. Login again | Successfully logged out and back in | | |