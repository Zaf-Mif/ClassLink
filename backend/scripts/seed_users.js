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

const users = [
  // Admin
  { name: 'Admin User', email: 'admin.admin@astu.edu.et', role: 'admin', departmentId: null, year: null, semester: null, sectionId: null },

  // Teachers (one per department)
  { name: 'Ahmed Ibrahim', email: 'ahmed.ibrahim@astu.edu.et', role: 'teacher', departmentId: 1, year: null, semester: null, sectionId: null },
  { name: 'Helen Tadesse', email: 'helen.tadesse@astu.edu.et', role: 'teacher', departmentId: 2, year: null, semester: null, sectionId: null },
  { name: 'Dawit Eshetu', email: 'dawit.eshetu@astu.edu.et', role: 'teacher', departmentId: 3, year: null, semester: null, sectionId: null },
  { name: 'Sara Mohammed', email: 'sara.mohammed@astu.edu.et', role: 'teacher', departmentId: 1, year: null, semester: null, sectionId: null },

  // Students (SWE, Year 3, Sem 1 — Section A)
  { name: 'Zaferan Miftah', email: 'zaferan.miftah@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 1 },
  { name: 'Abdi Hussein', email: 'abdi.hussein@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 1 },
  { name: 'Bontu Lemma', email: 'bontu.lemma@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 1 },
  { name: 'Chala Tesfaye', email: 'chala.tesfaye@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 1 },

  // Students (SWE, Year 3, Sem 1 — Section B)
  { name: 'Desta Alemu', email: 'desta.alemu@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 2 },
  { name: 'Eden Girma', email: 'eden.girma@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 2 },
  { name: 'Fikru Belay', email: 'fikru.belay@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 2 },
  { name: 'Genet Wondimu', email: 'genet.wondimu@astu.edu.et', role: 'student', departmentId: 1, year: 3, semester: 1, sectionId: 2 },

  // Students (CSE, Year 3, Sem 1 — generic)
  { name: 'Henok Tadesse', email: 'henok.tadesse@astu.edu.et', role: 'student', departmentId: 2, year: 3, semester: 1, sectionId: null },
  { name: 'Iman Adem', email: 'iman.adem@astu.edu.et', role: 'student', departmentId: 2, year: 3, semester: 1, sectionId: null },
  { name: 'Jemal Oumer', email: 'jemal.oumer@astu.edu.et', role: 'student', departmentId: 2, year: 3, semester: 1, sectionId: null },

  // Students (IT, Year 3, Sem 1 — generic)
  { name: 'Kebede Ayele', email: 'kebede.ayele@astu.edu.et', role: 'student', departmentId: 3, year: 3, semester: 1, sectionId: null },
  { name: 'Lemlem Hailu', email: 'lemlem.hailu@astu.edu.et', role: 'student', departmentId: 3, year: 3, semester: 1, sectionId: null },
  { name: 'Mekdes Abate', email: 'mekdes.abate@astu.edu.et', role: 'student', departmentId: 3, year: 3, semester: 1, sectionId: null },
];

async function seed() {
  const client = await pool.connect();
  try {
    const hash = await bcrypt.hash(COMMON_PASSWORD, 10);
    console.log(`Password for all users: ${COMMON_PASSWORD}\n`);

    // Ensure departments exist (from init.sql)
    const DEPARTMENTS = [
      'Software Engineering',
      'Computer Science and Engineering',
      'Information Technology',
    ];
    for (const name of DEPARTMENTS) {
      await client.query(
        'INSERT INTO departments (name) VALUES ($1) ON CONFLICT DO NOTHING',
        [name]
      );
    }

    let created = 0, skipped = 0;

    for (const u of users) {
      const existing = await client.query('SELECT id FROM users WHERE email = $1', [u.email]);
      if (existing.rows.length > 0) {
        console.log(`  SKIP  ${u.email} (already exists)`);
        skipped++;
        continue;
      }

      await client.query(
        `INSERT INTO users (name, email, password_hash, role, department_id, year, semester, section_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [u.name, u.email, hash, u.role, u.departmentId, u.year, u.semester, u.sectionId]
      );
      console.log(`  OK    ${u.role.padEnd(8)} ${u.email} (${u.name})`);
      created++;
    }

    console.log(`\nDone. ${created} created, ${skipped} skipped.`);
  } finally {
    client.release();
    await pool.end();
  }
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
