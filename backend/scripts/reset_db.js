require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'classlink',
  user: process.env.DB_USER || 'classlink_user',
  password: process.env.DB_PASSWORD || 'classlink_pass',
});

const TABLES = [
  'notifications',
  'forum_answers',
  'forum_questions',
  'messages',
  'files',
  'assignment_submissions',
  'assignment_targets',
  'assignments',
  'announcement_reads',
  'announcement_targets',
  'announcements',
  'course_teacher_section',
  'courses',
  'users',
  'sections',
  'departments',
];

async function reset() {
  const client = await pool.connect();
  try {
    console.log('Dropping all data from all tables...\n');
    // Disable triggers temporarily to avoid FK issues
    await client.query('SET session_replication_role = replica;');
    for (const table of TABLES) {
      const res = await client.query(`DELETE FROM ${table}`);
      console.log(`  ${res.rowCount.toString().padStart(4)} rows deleted from ${table}`);
    }
    await client.query('SET session_replication_role = DEFAULT;');
    // Reset serial sequences so IDs start from 1 again
    for (const table of TABLES) {
      const seq = await client.query(
        `SELECT pg_get_serial_sequence($1, 'id') AS seq`, [table]
      );
      const seqName = seq.rows[0]?.seq;
      if (seqName) {
        await client.query(`ALTER SEQUENCE ${seqName} RESTART WITH 1`);
      }
    }
    console.log('\nAll tables cleared and sequences reset. Re-run `npm run seed:all` to repopulate.');
  } finally {
    client.release();
    await pool.end();
  }
}

reset().catch((err) => {
  console.error('Reset failed:', err);
  process.exit(1);
});
