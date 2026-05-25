require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'classlink',
  user: process.env.DB_USER || 'classlink_user',
  password: process.env.DB_PASSWORD || 'classlink_pass',
});

const COMMON_PASSWORD = 'password123';

// ---------------------------------------------------------------------------
// Section definitions (name, year, semester, department_id)
// ---------------------------------------------------------------------------
const SECTION_DEFS = [
  // SWE (dept 1)
  ['A', 1, 1, 1], ['B', 1, 1, 1],
  ['A', 1, 2, 1], ['B', 1, 2, 1],
  ['A', 2, 1, 1], ['B', 2, 1, 1],
  ['A', 2, 2, 1], ['B', 2, 2, 1],
  ['A', 3, 1, 1], ['B', 3, 1, 1],   // already in init.sql
  ['A', 3, 2, 1], ['B', 3, 2, 1],   // already in init.sql
  ['A', 4, 1, 1], ['B', 4, 1, 1],
  ['A', 4, 2, 1], ['B', 4, 2, 1],
  // CSE (dept 2)
  ['A', 1, 1, 2], ['B', 1, 1, 2],
  ['A', 1, 2, 2], ['B', 1, 2, 2],
  ['A', 2, 1, 2], ['B', 2, 1, 2],
  ['A', 2, 2, 2], ['B', 2, 2, 2],
  ['A', 3, 1, 2], ['B', 3, 1, 2],
  ['A', 3, 2, 2], ['B', 3, 2, 2],
  ['A', 4, 1, 2], ['B', 4, 1, 2],
  ['A', 4, 2, 2], ['B', 4, 2, 2],
  // IT (dept 3)
  ['A', 1, 1, 3], ['B', 1, 1, 3],
  ['A', 1, 2, 3], ['B', 1, 2, 3],
  ['A', 2, 1, 3], ['B', 2, 1, 3],
  ['A', 2, 2, 3], ['B', 2, 2, 3],
  ['A', 3, 1, 3], ['B', 3, 1, 3],
  ['A', 3, 2, 3], ['B', 3, 2, 3],
  ['A', 4, 1, 3], ['B', 4, 1, 3],
  ['A', 4, 2, 3], ['B', 4, 2, 3],
];

// ---------------------------------------------------------------------------
// Course definitions (name, department_id, year, semester)
// ---------------------------------------------------------------------------
const COURSE_DEFS = [
  // SWE — Year 1
  ['Introduction to Programming', 1, 1, 1],
  ['Calculus I', 1, 1, 1],
  ['English for Engineers', 1, 1, 1],
  ['Physics for Engineers', 1, 1, 2],
  ['Discrete Mathematics', 1, 1, 2],
  // SWE — Year 2
  ['Object-Oriented Programming', 1, 2, 1],
  ['Data Structures', 1, 2, 1],
  ['Database Systems', 1, 2, 2],
  ['Web Development', 1, 2, 2],
  // SWE — Year 3
  ['Software Engineering', 1, 3, 1],
  ['Software Architecture', 1, 3, 1],
  ['Mobile Application Development', 1, 3, 2],
  ['Software Testing & Quality', 1, 3, 2],
  // SWE — Year 4
  ['Capstone Project I', 1, 4, 1],
  ['Professional Ethics', 1, 4, 2],

  // CSE — Year 1
  ['Introduction to Computing', 2, 1, 1],
  ['Calculus I', 2, 1, 1],
  ['Digital Logic', 2, 1, 2],
  ['Linear Algebra', 2, 1, 2],
  // CSE — Year 2
  ['Data Structures & Algorithms', 2, 2, 1],
  ['Computer Organization', 2, 2, 1],
  ['Operating Systems', 2, 2, 2],
  ['Computer Networks', 2, 2, 2],
  // CSE — Year 3
  ['Database Management Systems', 2, 3, 1],
  ['Artificial Intelligence', 2, 3, 1],
  ['Machine Learning', 2, 3, 2],
  ['Compiler Design', 2, 3, 2],
  // CSE — Year 4
  ['Distributed Systems', 2, 4, 1],
  ['Network Security', 2, 4, 2],

  // IT — Year 1
  ['IT Essentials', 3, 1, 1],
  ['Programming Fundamentals', 3, 1, 1],
  ['Multimedia Systems', 3, 1, 2],
  ['Web Technologies', 3, 1, 2],
  // IT — Year 2
  ['Network Administration', 3, 2, 1],
  ['IT Security', 3, 2, 1],
  ['Database Management', 3, 2, 2],
  ['Systems Analysis & Design', 3, 2, 2],
  // IT — Year 3
  ['Enterprise Architecture', 3, 3, 1],
  ['Cloud Computing', 3, 3, 1],
  ['Information Security', 3, 3, 2],
  ['IT Project Management', 3, 3, 2],
  // IT — Year 4
  ['Capstone Project', 3, 4, 1],
  ['Emerging Technologies', 3, 4, 2],
];

// ---------------------------------------------------------------------------
// Users (same as seed_users.js + extra students)
// ---------------------------------------------------------------------------
const USERS = [
  // Admin
  { name: 'Admin User', email: 'admin.admin@astu.edu.et', role: 'admin' },
  // Teachers
  { name: 'Ahmed Ibrahim', email: 'ahmed.ibrahim@astu.edu.et', role: 'teacher', dept: 1 },
  { name: 'Helen Tadesse', email: 'helen.tadesse@astu.edu.et', role: 'teacher', dept: 2 },
  { name: 'Dawit Eshetu', email: 'dawit.eshetu@astu.edu.et', role: 'teacher', dept: 3 },
  { name: 'Sara Mohammed', email: 'sara.mohammed@astu.edu.et', role: 'teacher', dept: 1 },
  // SWE students Y3 S1 Section A
  { name: 'Zaferan Miftah', email: 'zaferan.miftah@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'A' },
  { name: 'Abdi Hussein', email: 'abdi.hussein@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'A' },
  { name: 'Bontu Lemma', email: 'bontu.lemma@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'A' },
  { name: 'Chala Tesfaye', email: 'chala.tesfaye@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'A' },
  // SWE students Y3 S1 Section B
  { name: 'Desta Alemu', email: 'desta.alemu@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'B' },
  { name: 'Eden Girma', email: 'eden.girma@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'B' },
  { name: 'Fikru Belay', email: 'fikru.belay@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'B' },
  { name: 'Genet Wondimu', email: 'genet.wondimu@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 1, sec: 'B' },
  // CSE students Y3 S1 Section A
  { name: 'Henok Tadesse', email: 'henok.tadesse@astu.edu.et', role: 'student', dept: 2, year: 3, sem: 1, sec: 'A' },
  { name: 'Iman Adem', email: 'iman.adem@astu.edu.et', role: 'student', dept: 2, year: 3, sem: 1, sec: 'A' },
  { name: 'Jemal Oumer', email: 'jemal.oumer@astu.edu.et', role: 'student', dept: 2, year: 3, sem: 1, sec: 'A' },
  { name: 'Selam Tesfaye', email: 'selam.tesfaye@astu.edu.et', role: 'student', dept: 2, year: 3, sem: 1, sec: 'A' },
  // IT students Y3 S1 Section A
  { name: 'Kebede Ayele', email: 'kebede.ayele@astu.edu.et', role: 'student', dept: 3, year: 3, sem: 1, sec: 'A' },
  { name: 'Lemlem Hailu', email: 'lemlem.hailu@astu.edu.et', role: 'student', dept: 3, year: 3, sem: 1, sec: 'A' },
  { name: 'Mekdes Abate', email: 'mekdes.abate@astu.edu.et', role: 'student', dept: 3, year: 3, sem: 1, sec: 'A' },
  { name: 'Yonas Ayele', email: 'yonas.ayele@astu.edu.et', role: 'student', dept: 3, year: 3, sem: 1, sec: 'A' },
  // Extra students for more data coverage
  { name: 'Hana Wondimu', email: 'hana.wondimu@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 2, sec: 'A' },
  { name: 'Biruk Tadesse', email: 'biruk.tadesse@astu.edu.et', role: 'student', dept: 1, year: 3, sem: 2, sec: 'B' },
  { name: 'Meron Alemu', email: 'meron.alemu@astu.edu.et', role: 'student', dept: 2, year: 3, sem: 2, sec: 'A' },
  { name: 'Ruth Desta', email: 'ruth.desta@astu.edu.et', role: 'student', dept: 3, year: 3, sem: 2, sec: 'A' },
];

// ---------------------------------------------------------------------------
// Helpers for generating random dates
// ---------------------------------------------------------------------------
function daysAgo(n) {
  const d = new Date();
  d.setDate(d.getDate() - n);
  return d;
}

function daysFromNow(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return d;
}

// ---------------------------------------------------------------------------
// Main seed function
// ---------------------------------------------------------------------------
async function seed() {
  const client = await pool.connect();
  try {
    const hash = await bcrypt.hash(COMMON_PASSWORD, 10);
    console.log(`Password for all users: ${COMMON_PASSWORD}\n`);

    // ---------------------------------------------------------------
    // 1. SEED SECTIONS
    // ---------------------------------------------------------------
    console.log('--- Sections ---');
    const sectionCache = {}; // "name_year_sem_dept" -> id
    for (const [name, year, sem, deptId] of SECTION_DEFS) {
      const key = `${name}_${year}_${sem}_${deptId}`;
      const existing = await client.query(
        'SELECT id FROM sections WHERE name = $1 AND year = $2 AND semester = $3 AND department_id = $4',
        [name, year, sem, deptId]
      );
      if (existing.rows.length > 0) {
        sectionCache[key] = existing.rows[0].id;
        continue;
      }
      const res = await client.query(
        'INSERT INTO sections (name, year, semester, department_id) VALUES ($1,$2,$3,$4) RETURNING id',
        [name, year, sem, deptId]
      );
      sectionCache[key] = res.rows[0].id;
      console.log(`  OK    ${name} Y${year} S${sem} Dept${deptId}`);
    }

    // ---------------------------------------------------------------
    // 2. SEED USERS
    // ---------------------------------------------------------------
    console.log('\n--- Users ---');
    const userCache = {}; // email -> { id, role }
    let created = 0, skipped = 0;
    for (const u of USERS) {
      const existing = await client.query('SELECT id, role FROM users WHERE email = $1', [u.email]);
      if (existing.rows.length > 0) {
        userCache[u.email] = { id: existing.rows[0].id, role: existing.rows[0].role };
        skipped++;
        continue;
      }
      let sectionId = null;
      if (u.sec && u.dept && u.year && u.sem) {
        const key = `${u.sec}_${u.year}_${u.sem}_${u.dept}`;
        sectionId = sectionCache[key] || null;
      }
      const res = await client.query(
        `INSERT INTO users (name, email, password_hash, role, department_id, year, semester, section_id)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING id`,
        [u.name, u.email, hash, u.role, u.dept || null, u.year || null, u.sem || null, sectionId]
      );
      userCache[u.email] = { id: res.rows[0].id, role: u.role };
      console.log(`  OK    ${u.role.padEnd(8)} ${u.email} (${u.name})`);
      created++;
    }
    console.log(`  (${created} created, ${skipped} skipped)`);

    // ---------------------------------------------------------------
    // 3. SEED COURSES
    // ---------------------------------------------------------------
    console.log('\n--- Courses ---');
    const courseCache = {}; // "name_dept_year_sem" -> id
    for (const [name, deptId, year, sem] of COURSE_DEFS) {
      const key = `${name}_${deptId}_${year}_${sem}`;
      const existing = await client.query(
        'SELECT id FROM courses WHERE name = $1 AND department_id = $2 AND year = $3 AND semester = $4',
        [name, deptId, year, sem]
      );
      if (existing.rows.length > 0) {
        courseCache[key] = existing.rows[0].id;
        continue;
      }
      const res = await client.query(
        'INSERT INTO courses (name, department_id, year, semester) VALUES ($1,$2,$3,$4) RETURNING id',
        [name, deptId, year, sem]
      );
      courseCache[key] = res.rows[0].id;
      console.log(`  OK    ${name} (Dept${deptId} Y${year} S${sem})`);
    }

    // ---------------------------------------------------------------
    // 4. SEED COURSE-TEACHER-SECTION
    // ---------------------------------------------------------------
    console.log('\n--- Course-Teacher-Section ---');
    const ctsAssignments = [
      // SWE teachers
      { teacher: 'ahmed.ibrahim@astu.edu.et', course: 'Software Engineering_1_3_1', sections: ['A_3_1_1', 'B_3_1_1'] },
      { teacher: 'ahmed.ibrahim@astu.edu.et', course: 'Software Architecture_1_3_1', sections: ['A_3_1_1', 'B_3_1_1'] },
      { teacher: 'sara.mohammed@astu.edu.et', course: 'Mobile Application Development_1_3_2', sections: ['A_3_2_1', 'B_3_2_1'] },
      { teacher: 'sara.mohammed@astu.edu.et', course: 'Software Testing & Quality_1_3_2', sections: ['A_3_2_1', 'B_3_2_1'] },
      { teacher: 'ahmed.ibrahim@astu.edu.et', course: 'Object-Oriented Programming_1_2_1', sections: ['A_2_1_1', 'B_2_1_1'] },
      { teacher: 'sara.mohammed@astu.edu.et', course: 'Web Development_1_2_2', sections: ['A_2_2_1', 'B_2_2_1'] },
      { teacher: 'ahmed.ibrahim@astu.edu.et', course: 'Database Systems_1_2_2', sections: ['A_2_2_1', 'B_2_2_1'] },
      // CSE teachers
      { teacher: 'helen.tadesse@astu.edu.et', course: 'Data Structures & Algorithms_2_2_1', sections: ['A_2_1_2', 'B_2_1_2'] },
      { teacher: 'helen.tadesse@astu.edu.et', course: 'Artificial Intelligence_2_3_1', sections: ['A_3_1_2', 'B_3_1_2'] },
      { teacher: 'helen.tadesse@astu.edu.et', course: 'Machine Learning_2_3_2', sections: ['A_3_2_2', 'B_3_2_2'] },
      { teacher: 'helen.tadesse@astu.edu.et', course: 'Computer Networks_2_2_2', sections: ['A_2_2_2', 'B_2_2_2'] },
      // IT teachers
      { teacher: 'dawit.eshetu@astu.edu.et', course: 'Network Administration_3_2_1', sections: ['A_2_1_3', 'B_2_1_3'] },
      { teacher: 'dawit.eshetu@astu.edu.et', course: 'Enterprise Architecture_3_3_1', sections: ['A_3_1_3', 'B_3_1_3'] },
      { teacher: 'dawit.eshetu@astu.edu.et', course: 'Cloud Computing_3_3_1', sections: ['A_3_1_3', 'B_3_1_3'] },
      { teacher: 'dawit.eshetu@astu.edu.et', course: 'Information Security_3_3_2', sections: ['A_3_2_3', 'B_3_2_3'] },
    ];
    let ctsCount = 0;
    for (const a of ctsAssignments) {
      const teacherId = userCache[a.teacher]?.id;
      if (!teacherId) { console.log(`  SKIP  teacher ${a.teacher} not found`); continue; }
      const courseId = courseCache[a.course];
      if (!courseId) { console.log(`  SKIP  course ${a.course} not found`); continue; }
      for (const secKey of a.sections) {
        const sectionId = sectionCache[secKey];
        if (!sectionId) { console.log(`  SKIP  section ${secKey} not found`); continue; }
        const existing = await client.query(
          'SELECT id FROM course_teacher_section WHERE course_id=$1 AND teacher_id=$2 AND section_id=$3',
          [courseId, teacherId, sectionId]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          'INSERT INTO course_teacher_section (course_id, teacher_id, section_id) VALUES ($1,$2,$3)',
          [courseId, teacherId, sectionId]
        );
        ctsCount++;
      }
    }
    console.log(`  OK    ${ctsCount} assignments created`);

    // ---------------------------------------------------------------
    // 5. SEED ANNOUNCEMENTS
    // ---------------------------------------------------------------
    console.log('\n--- Announcements ---');
    const announcementData = [
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Welcome to Software Engineering',
        content: 'Welcome to the Software Engineering course! Please review the syllabus and form your project groups by next week.', days: 14 },
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Project Milestone 1 Due',
        content: 'Reminder: Project Milestone 1 (Requirements Specification) is due this Friday. Submit via the portal.', days: 7 },
      { course: 'Software Architecture_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Midterm Exam Schedule',
        content: 'The midterm exam will be held on Saturday, 9:00 AM - 11:00 AM in Hall 301. Bring your ID.', days: 5 },
      { course: 'Mobile Application Development_1_3_2', teacher: 'sara.mohammed@astu.edu.et', title: 'Flutter Workshop',
        content: 'There will be a Flutter workshop this Thursday at 2:00 PM in Lab 204. Attendance is optional but encouraged.', days: 3 },
      { course: 'Object-Oriented Programming_1_2_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Assignment 1 Graded',
        content: 'Assignment 1 grades have been posted. Please check your scores and reach out during office hours if you have questions.', days: 2 },
      { course: 'Artificial Intelligence_2_3_1', teacher: 'helen.tadesse@astu.edu.et', title: 'AI Guest Lecture',
        content: 'Dr. Tadesse from IBM will give a guest lecture on "AI in Industry" this Friday at 10:00 AM.', days: 1 },
      { course: 'Enterprise Architecture_3_3_1', teacher: 'dawit.eshetu@astu.edu.et', title: 'Reading Materials',
        content: 'Chapter 4-6 of the textbook are now available in the library. Please read before next class.', days: 0 },
    ];
    const announcementIds = [];
    for (const a of announcementData) {
      const courseId = courseCache[a.course];
      const teacherId = userCache[a.teacher]?.id;
      if (!courseId || !teacherId) continue;
      const res = await client.query(
        `INSERT INTO announcements (title, content, teacher_id, course_id, created_at)
         VALUES ($1,$2,$3,$4,$5) RETURNING id`,
        [a.title, a.content, teacherId, courseId, daysAgo(a.days)]
      );
      announcementIds.push(res.rows[0].id);
      console.log(`  OK    "${a.title}"`);
    }

    // ---------------------------------------------------------------
    // 6. SEED ANNOUNCEMENT TARGETS
    // ---------------------------------------------------------------
    console.log('\n--- Announcement Targets ---');
    // Target all sections that are enrolled: for SWE courses, target SWE sections
    for (const annId of announcementIds) {
      // Get the announcement's course to figure out department/year/sem
      const annRow = await client.query('SELECT course_id FROM announcements WHERE id = $1', [annId]);
      if (!annRow.rows.length) continue;
      const c = await client.query('SELECT department_id, year, semester FROM courses WHERE id = $1', [annRow.rows[0].course_id]);
      if (!c.rows.length) continue;
      const { department_id, year, semester } = c.rows[0];
      // Find matching sections
      const secs = await client.query(
        'SELECT id FROM sections WHERE department_id = $1 AND year = $2 AND semester = $3',
        [department_id, year, semester]
      );
      for (const s of secs.rows) {
        const existing = await client.query(
          'SELECT id FROM announcement_targets WHERE announcement_id=$1 AND section_id=$2',
          [annId, s.id]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          'INSERT INTO announcement_targets (announcement_id, section_id) VALUES ($1,$2)',
          [annId, s.id]
        );
      }
    }
    console.log(`  OK    targets set for ${announcementIds.length} announcements`);

    // ---------------------------------------------------------------
    // 7. SEED ANNOUNCEMENT READS
    // ---------------------------------------------------------------
    console.log('\n--- Announcement Reads ---');
    let readsCount = 0;
    for (const annId of announcementIds.slice(0, 3)) {
      const annRow = await client.query('SELECT course_id FROM announcements WHERE id = $1', [annId]);
      if (!annRow.rows.length) continue;
      const cRow = await client.query('SELECT department_id, year, semester FROM courses WHERE id = $1', [annRow.rows[0].course_id]);
      if (!cRow.rows.length) continue;
      const { department_id, year, semester } = cRow.rows[0];
      const students = await client.query(
        'SELECT id FROM users WHERE role=$1 AND department_id=$2 AND year=$3 AND semester=$4',
        ['student', department_id, year, semester]
      );
      for (const stu of students.rows) {
        const existing = await client.query(
          'SELECT id FROM announcement_reads WHERE announcement_id=$1 AND student_id=$2',
          [annId, stu.id]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          'INSERT INTO announcement_reads (announcement_id, student_id, read_at) VALUES ($1,$2,$3)',
          [annId, stu.id, daysAgo(Math.floor(Math.random() * 3))]
        );
        readsCount++;
      }
    }
    console.log(`  OK    ${readsCount} read receipts created`);

    // ---------------------------------------------------------------
    // 8. SEED ASSIGNMENTS
    // ---------------------------------------------------------------
    console.log('\n--- Assignments ---');
    const assignmentData = [
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Requirements Specification',
        desc: 'Write a full SRS document for your chosen project following IEEE 830 standard.', deadline: 5 },
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'UML Diagrams',
        desc: 'Draw use case, class, sequence, and activity diagrams for your project.', deadline: 12 },
      { course: 'Software Architecture_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Architecture Design Document',
        desc: 'Design the architecture for your project using C4 model. Include context, container, component, and code diagrams.', deadline: 8 },
      { course: 'Mobile Application Development_1_3_2', teacher: 'sara.mohammed@astu.edu.et', title: 'Flutter UI Assignment',
        desc: 'Recreate the provided Figma design in Flutter. Submit the GitHub repo link.', deadline: 10 },
      { course: 'Artificial Intelligence_2_3_1', teacher: 'helen.tadesse@astu.edu.et', title: 'Search Algorithms',
        desc: 'Implement BFS, DFS, and A* search algorithms. Test on the provided puzzle inputs.', deadline: 7 },
      { course: 'Network Administration_3_2_1', teacher: 'dawit.eshetu@astu.edu.et', title: 'Network Topology Design',
        desc: 'Design a network topology for a 3-building campus using Cisco Packet Tracer.', deadline: 14 },
    ];
    const assignmentIds = [];
    for (const a of assignmentData) {
      const courseId = courseCache[a.course];
      const teacherId = userCache[a.teacher]?.id;
      if (!courseId || !teacherId) continue;
      const res = await client.query(
        `INSERT INTO assignments (title, description, deadline, course_id, teacher_id, created_at)
         VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
        [a.title, a.desc, daysFromNow(a.deadline), courseId, teacherId, daysAgo(14)]
      );
      assignmentIds.push(res.rows[0].id);
      console.log(`  OK    "${a.title}"`);
    }

    // ---------------------------------------------------------------
    // 9. SEED ASSIGNMENT TARGETS
    // ---------------------------------------------------------------
    console.log('\n--- Assignment Targets ---');
    for (const assignId of assignmentIds) {
      const aRow = await client.query('SELECT course_id FROM assignments WHERE id = $1', [assignId]);
      if (!aRow.rows.length) continue;
      const c = await client.query('SELECT department_id, year, semester FROM courses WHERE id = $1', [aRow.rows[0].course_id]);
      if (!c.rows.length) continue;
      const { department_id, year, semester } = c.rows[0];
      const secs = await client.query(
        'SELECT id FROM sections WHERE department_id = $1 AND year = $2 AND semester = $3',
        [department_id, year, semester]
      );
      for (const s of secs.rows) {
        const existing = await client.query(
          'SELECT id FROM assignment_targets WHERE assignment_id=$1 AND section_id=$2',
          [assignId, s.id]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          'INSERT INTO assignment_targets (assignment_id, section_id) VALUES ($1,$2)',
          [assignId, s.id]
        );
      }
    }
    console.log(`  OK    targets set for ${assignmentIds.length} assignments`);

    // ---------------------------------------------------------------
    // 10. SEED ASSIGNMENT SUBMISSIONS
    // ---------------------------------------------------------------
    console.log('\n--- Assignment Submissions ---');
    let subsCount = 0;
    for (const assignId of assignmentIds.slice(0, 3)) {
      const aRow = await client.query('SELECT course_id FROM assignments WHERE id = $1', [assignId]);
      if (!aRow.rows.length) continue;
      const c = await client.query('SELECT department_id, year, semester FROM courses WHERE id = $1', [aRow.rows[0].course_id]);
      if (!c.rows.length) continue;
      const { department_id, year, semester } = c.rows[0];
      const students = await client.query(
        'SELECT id FROM users WHERE role=$1 AND department_id=$2 AND year=$3 AND semester=$4',
        ['student', department_id, year, semester]
      );
      // Only some students submit
      const submitters = students.rows.filter(() => Math.random() > 0.3);
      for (const stu of submitters) {
        const existing = await client.query(
          'SELECT id FROM assignment_submissions WHERE assignment_id=$1 AND student_id=$2',
          [assignId, stu.id]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          `INSERT INTO assignment_submissions (assignment_id, student_id, file_url, submitted_at)
           VALUES ($1,$2,$3,$4)`,
          [assignId, stu.id, `uploads/assignment_${assignId}_${stu.id}.pdf`, daysAgo(Math.floor(Math.random() * 5))]
        );
        subsCount++;
      }
    }
    console.log(`  OK    ${subsCount} submissions created`);

    // ---------------------------------------------------------------
    // 11. SEED FILES
    // ---------------------------------------------------------------
    console.log('\n--- Files ---');
    const fileData = [
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Lecture 1 - Introduction',
        topic: 'Introduction', url: 'uploads/swe_lec1.pdf' },
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'Lecture 2 - SDLC',
        topic: 'SDLC', url: 'uploads/swe_lec2.pdf', version: 2 },
      { course: 'Software Engineering_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'SRS Template',
        topic: 'Templates', url: 'uploads/srs_template.docx' },
      { course: 'Software Architecture_1_3_1', teacher: 'ahmed.ibrahim@astu.edu.et', title: 'C4 Model Reference',
        topic: 'Architecture', url: 'uploads/c4_model.pdf' },
      { course: 'Mobile Application Development_1_3_2', teacher: 'sara.mohammed@astu.edu.et', title: 'Flutter Basics',
        topic: 'Flutter', url: 'uploads/flutter_basics.pdf' },
      { course: 'Artificial Intelligence_2_3_1', teacher: 'helen.tadesse@astu.edu.et', title: 'AI Lecture Notes',
        topic: 'Introduction to AI', url: 'uploads/ai_lec1.pdf' },
      { course: 'Network Administration_3_2_1', teacher: 'dawit.eshetu@astu.edu.et', title: 'Networking Basics',
        topic: 'Networking', url: 'uploads/net_basics.pdf' },
    ];
    for (const f of fileData) {
      const courseId = courseCache[f.course];
      const teacherId = userCache[f.teacher]?.id;
      if (!courseId || !teacherId) continue;
      await client.query(
        `INSERT INTO files (title, file_url, topic, course_id, teacher_id, version_number, uploaded_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [f.title, f.url, f.topic, courseId, teacherId, f.version || 1, daysAgo(Math.floor(Math.random() * 20))]
      );
      console.log(`  OK    "${f.title}"`);
    }

    // ---------------------------------------------------------------
    // 12. SEED MESSAGES
    // ---------------------------------------------------------------
    console.log('\n--- Messages ---');
    const messageData = [
      { from: 'zaferan.miftah@astu.edu.et', to: 'ahmed.ibrahim@astu.edu.et',
        content: 'Hello Dr. Ahmed, I have a question about the project milestone 1 requirements.' },
      { from: 'ahmed.ibrahim@astu.edu.et', to: 'zaferan.miftah@astu.edu.et',
        content: 'Hi Zaferan, sure. What would you like to know?' },
      { from: 'zaferan.miftah@astu.edu.et', to: 'ahmed.ibrahim@astu.edu.et',
        content: 'Should we include the UI mockups in the SRS document?' },
      { from: 'ahmed.ibrahim@astu.edu.et', to: 'zaferan.miftah@astu.edu.et',
        content: 'Yes, please include wireframes or mockups in the appendix section.' },
      { from: 'henok.tadesse@astu.edu.et', to: 'helen.tadesse@astu.edu.et',
        content: 'Dr. Helen, I am unable to access the AI lecture notes on the portal.' },
      { from: 'helen.tadesse@astu.edu.et', to: 'henok.tadesse@astu.edu.et',
        content: 'Let me check. Try refreshing the page or clearing your cache.' },
      { from: 'kebede.ayele@astu.edu.et', to: 'dawit.eshetu@astu.edu.et',
        content: 'Mr. Dawit, when is the Network Administration lab session this week?' },
    ];
    for (const m of messageData) {
      const senderId = userCache[m.from]?.id;
      const receiverId = userCache[m.to]?.id;
      if (!senderId || !receiverId) continue;
      await client.query(
        `INSERT INTO messages (sender_id, receiver_id, content, sent_at)
         VALUES ($1,$2,$3,$4)`,
        [senderId, receiverId, m.content, daysAgo(Math.floor(Math.random() * 7))]
      );
    }
    console.log(`  OK    ${messageData.length} messages created`);

    // ---------------------------------------------------------------
    // 13. SEED FORUM QUESTIONS
    // ---------------------------------------------------------------
    console.log('\n--- Forum Questions ---');
    const questionData = [
      { course: 'Software Engineering_1_3_1', student: 'abdi.hussein@astu.edu.et',
        content: 'What is the difference between waterfall and agile methodologies?' },
      { course: 'Software Engineering_1_3_1', student: 'bontu.lemma@astu.edu.et',
        content: 'How do we determine the appropriate software architecture for our project?' },
      { course: 'Software Engineering_1_3_1', student: 'desta.alemu@astu.edu.et',
        content: 'Can someone explain the concept of technical debt?' },
      { course: 'Software Architecture_1_3_1', student: 'chala.tesfaye@astu.edu.et',
        content: 'What are the main differences between monolith and microservices?' },
      { course: 'Mobile Application Development_1_3_2', student: 'eden.girma@astu.edu.et',
        content: 'Is Flutter better than React Native for cross-platform development?' },
      { course: 'Artificial Intelligence_2_3_1', student: 'henok.tadesse@astu.edu.et',
        content: 'What is the difference between supervised and unsupervised learning?' },
      { course: 'Artificial Intelligence_2_3_1', student: 'iman.adem@astu.edu.et',
        content: 'How does backpropagation work in neural networks?' },
    ];
    const questionIds = [];
    for (const q of questionData) {
      const courseId = courseCache[q.course];
      const studentId = userCache[q.student]?.id;
      if (!courseId || !studentId) continue;
      const res = await client.query(
        `INSERT INTO forum_questions (student_id, course_id, content, created_at)
         VALUES ($1,$2,$3,$4) RETURNING id`,
        [studentId, courseId, q.content, daysAgo(Math.floor(Math.random() * 10))]
      );
      questionIds.push(res.rows[0].id);
      console.log(`  OK    "${q.content.substring(0, 50)}..."`);
    }

    // ---------------------------------------------------------------
    // 14. SEED FORUM ANSWERS
    // ---------------------------------------------------------------
    console.log('\n--- Forum Answers ---');
    const answerData = [
      { qIdx: 0, teacher: 'ahmed.ibrahim@astu.edu.et',
        content: 'Waterfall is linear and sequential, while agile is iterative and incremental. Agile allows for changing requirements throughout the development process.' },
      { qIdx: 1, teacher: 'ahmed.ibrahim@astu.edu.et',
        content: 'Consider your requirements: if you need scalability and flexibility, microservices is a good choice. For simpler applications, monolithic architecture works fine.' },
      { qIdx: 3, teacher: 'ahmed.ibrahim@astu.edu.et',
        content: 'Monolith is a single codebase deployed as one unit. Microservices decompose the application into small, independent services that communicate via APIs.' },
      { qIdx: 5, teacher: 'helen.tadesse@astu.edu.et',
        content: 'Supervised learning uses labeled data to train models, while unsupervised learning finds patterns in unlabeled data.' },
    ];
    for (const a of answerData) {
      const questionId = questionIds[a.qIdx];
      const teacherId = userCache[a.teacher]?.id;
      if (!questionId || !teacherId) continue;
      await client.query(
        `INSERT INTO forum_answers (question_id, teacher_id, content, created_at)
         VALUES ($1,$2,$3,$4)`,
        [questionId, teacherId, a.content, daysAgo(Math.floor(Math.random() * 5))]
      );
      console.log(`  OK    answer for question #${a.qIdx + 1}`);
    }

    // Mark answered questions
    for (const a of answerData) {
      const questionId = questionIds[a.qIdx];
      if (questionId) {
        await client.query('UPDATE forum_questions SET is_answered = TRUE WHERE id = $1', [questionId]);
      }
    }

    // ---------------------------------------------------------------
    // 15. SEED NOTIFICATIONS
    // ---------------------------------------------------------------
    console.log('\n--- Notifications ---');
    // Announcement notifications for students
    const students = await client.query(
      "SELECT id FROM users WHERE role = 'student'"
    );
    let notifCount = 0;
    for (const stu of students.rows) {
      // Give each student 2-4 notifications
      const count = 2 + Math.floor(Math.random() * 3);
      for (let i = 0; i < count; i++) {
        const type = ['announcement', 'assignment', 'forum', 'message'][Math.floor(Math.random() * 4)];
        const existing = await client.query(
          'SELECT id FROM notifications WHERE user_id=$1 AND type=$2 AND reference_id=$3',
          [stu.id, type, i + 1]
        );
        if (existing.rows.length > 0) continue;
        await client.query(
          `INSERT INTO notifications (user_id, type, reference_id, is_read, created_at)
           VALUES ($1,$2,$3,$4,$5)`,
          [stu.id, type, i + 1, Math.random() > 0.5, daysAgo(Math.floor(Math.random() * 7))]
        );
        notifCount++;
      }
    }
    console.log(`  OK    ${notifCount} notifications created`);

    console.log('\n===== SEED COMPLETE =====');
  } finally {
    client.release();
    await pool.end();
  }
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
