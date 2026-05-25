-- Departments
CREATE TABLE IF NOT EXISTS departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Sections
CREATE TABLE IF NOT EXISTS sections (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  year INTEGER NOT NULL,
  semester INTEGER NOT NULL,
  department_id INTEGER REFERENCES departments(id)
);

-- Users
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
  department_id INTEGER REFERENCES departments(id),
  year INTEGER,
  semester INTEGER,
  section_id INTEGER REFERENCES sections(id),

  created_at TIMESTAMP DEFAULT NOW()
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  department_id INTEGER REFERENCES departments(id),
  year INTEGER NOT NULL,
  semester INTEGER NOT NULL
);

-- Course-Teacher-Section junction
CREATE TABLE IF NOT EXISTS course_teacher_section (
  id SERIAL PRIMARY KEY,
  course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
  teacher_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  section_id INTEGER REFERENCES sections(id) ON DELETE CASCADE
);

-- Announcements
CREATE TABLE IF NOT EXISTS announcements (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  teacher_id INTEGER REFERENCES users(id),
  course_id INTEGER REFERENCES courses(id),
  created_at TIMESTAMP DEFAULT NOW(),
  scheduled_at TIMESTAMP
);

-- Announcement targets
CREATE TABLE IF NOT EXISTS announcement_targets (
  id SERIAL PRIMARY KEY,
  announcement_id INTEGER REFERENCES announcements(id) ON DELETE CASCADE,
  section_id INTEGER REFERENCES sections(id) ON DELETE CASCADE
);

-- Announcement read receipts
CREATE TABLE IF NOT EXISTS announcement_reads (
  id SERIAL PRIMARY KEY,
  announcement_id INTEGER REFERENCES announcements(id) ON DELETE CASCADE,
  student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  read_at TIMESTAMP DEFAULT NOW()
);

-- Assignments
CREATE TABLE IF NOT EXISTS assignments (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  deadline TIMESTAMP,
  course_id INTEGER REFERENCES courses(id),
  teacher_id INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Assignment targets
CREATE TABLE IF NOT EXISTS assignment_targets (
  id SERIAL PRIMARY KEY,
  assignment_id INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
  section_id INTEGER REFERENCES sections(id) ON DELETE CASCADE
);

-- Assignment submissions
CREATE TABLE IF NOT EXISTS assignment_submissions (
  id SERIAL PRIMARY KEY,
  assignment_id INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
  student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  file_url TEXT,
  submitted_at TIMESTAMP DEFAULT NOW()
);

-- Files
CREATE TABLE IF NOT EXISTS files (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  topic VARCHAR(255),
  course_id INTEGER REFERENCES courses(id),
  teacher_id INTEGER REFERENCES users(id),
  version_number INTEGER DEFAULT 1,
  uploaded_at TIMESTAMP DEFAULT NOW()
);

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  sender_id INTEGER REFERENCES users(id),
  receiver_id INTEGER REFERENCES users(id),
  content TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT NOW(),
  read_at TIMESTAMP
);

-- Forum questions
CREATE TABLE IF NOT EXISTS forum_questions (
  id SERIAL PRIMARY KEY,
  student_id INTEGER REFERENCES users(id),
  course_id INTEGER REFERENCES courses(id),
  content TEXT NOT NULL,
  is_answered BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Forum answers
CREATE TABLE IF NOT EXISTS forum_answers (
  id SERIAL PRIMARY KEY,
  question_id INTEGER REFERENCES forum_questions(id) ON DELETE CASCADE,
  teacher_id INTEGER REFERENCES users(id),
  content TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  type VARCHAR(100) NOT NULL,
  reference_id INTEGER,
  title VARCHAR(255),
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- System activity logs (admin audit trail)
CREATE TABLE IF NOT EXISTS system_activity_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100),
  entity_id INTEGER,
  details JSONB,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user ON system_activity_logs(user_id);

-- Seed data: departments
INSERT INTO departments (name) VALUES
  ('Software Engineering'),
  ('Computer Science and Engineering'),
  ('Information Technology')
ON CONFLICT DO NOTHING;

-- Seed data: sections
INSERT INTO sections (name, year, semester, department_id) VALUES
  ('A', 3, 1, 1),
  ('B', 3, 1, 1),
  ('A', 3, 2, 1),
  ('B', 3, 2, 1)
ON CONFLICT DO NOTHING;
