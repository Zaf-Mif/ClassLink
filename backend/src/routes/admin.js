const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

const EMAIL_REGEX = /^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$/;

function formatUser(user) {
  return {
    id: user.id.toString(),
    name: user.name,
    email: user.email,
    role: user.role,
    departmentId: user.department_id ? user.department_id.toString() : null,
    year: user.year ? user.year.toString() : null,
    semester: user.semester ? user.semester.toString() : null,
    sectionId: user.section_id ? user.section_id.toString() : null,
    createdAt: user.created_at,
  };
}

// GET /admin/users — list all users
router.get('/users', auth(['admin']), async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT u.*, d.name AS department_name, s.name AS section_name
       FROM users u
       LEFT JOIN departments d ON d.id = u.department_id
       LEFT JOIN sections s ON s.id = u.section_id
       ORDER BY u.created_at DESC`
    );

    const users = result.rows.map((u) => ({
      ...formatUser(u),
      departmentName: u.department_name,
      sectionName: u.section_name,
    }));

    res.json(users);
  } catch (err) {
    console.error('Admin get users error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// POST /admin/users — create a new user
router.post('/users', auth(['admin']), async (req, res) => {
  try {
    const { name, email, password, role, departmentId, year, semester, sectionId } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: 'Name, email, password, and role are required.' });
    }

    if (!EMAIL_REGEX.test(email)) {
      return res.status(400).json({ message: 'Email must be in format firstname.lastname@astu.edu.et' });
    }

    if (!['student', 'teacher', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Role must be student, teacher, or admin.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters.' });
    }

    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ message: 'A user with this email already exists.' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, role, department_id, year, semester, section_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        name,
        email.toLowerCase(),
        passwordHash,
        role,
        departmentId || null,
        year || null,
        semester || null,
        sectionId || null,
      ]
    );

    res.status(201).json(formatUser(result.rows[0]));
  } catch (err) {
    console.error('Admin create user error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// PUT /admin/users/:id — update an existing user
router.put('/users/:id', auth(['admin']), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, password, role, departmentId, year, semester, sectionId } = req.body;

    const existing = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const current = existing.rows[0];

    const updatedName = name ?? current.name;
    const updatedEmail = email ?? current.email;
    const updatedRole = role ?? current.role;
    const updatedDepartmentId = departmentId !== undefined ? (departmentId || null) : current.department_id;
    const updatedYear = year !== undefined ? (year || null) : current.year;
    const updatedSemester = semester !== undefined ? (semester || null) : current.semester;
    const updatedSectionId = sectionId !== undefined ? (sectionId || null) : current.section_id;

    if (email && !EMAIL_REGEX.test(email)) {
      return res.status(400).json({ message: 'Email must be in format firstname.lastname@astu.edu.et' });
    }

    let passwordHash = current.password_hash;
    if (password) {
      if (password.length < 6) {
        return res.status(400).json({ message: 'Password must be at least 6 characters.' });
      }
      passwordHash = await bcrypt.hash(password, 10);
    }

    const result = await pool.query(
      `UPDATE users
       SET name = $1, email = $2, password_hash = $3, role = $4,
           department_id = $5, year = $6, semester = $7, section_id = $8
       WHERE id = $9
       RETURNING *`,
      [
        updatedName,
        updatedEmail,
        passwordHash,
        updatedRole,
        updatedDepartmentId,
        updatedYear,
        updatedSemester,
        updatedSectionId,
        id,
      ]
    );

    res.json(formatUser(result.rows[0]));
  } catch (err) {
    console.error('Admin update user error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// GET /admin/departments — list all departments
router.get('/departments', auth(['admin']), async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM departments ORDER BY name');
    res.json(result.rows.map(d => ({ id: d.id.toString(), name: d.name })));
  } catch (err) {
    console.error('Admin get departments error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// GET /admin/sections — list all sections (optionally filtered)
router.get('/sections', auth(['admin']), async (req, res) => {
  try {
    const { departmentId } = req.query;
    let query = 'SELECT * FROM sections';
    let params = [];
    if (departmentId) {
      query += ' WHERE department_id = $1';
      params = [departmentId];
    }
    query += ' ORDER BY year, semester, name';
    const result = await pool.query(query, params);
    res.json(result.rows.map(s => ({
      id: s.id.toString(),
      name: s.name,
      year: s.year.toString(),
      semester: s.semester.toString(),
      departmentId: s.department_id.toString(),
    })));
  } catch (err) {
    console.error('Admin get sections error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// GET /admin/courses — list all courses (optionally filtered)
router.get('/courses', auth(['admin']), async (req, res) => {
  try {
    const { departmentId } = req.query;
    let query = 'SELECT * FROM courses';
    let params = [];
    if (departmentId) {
      query += ' WHERE department_id = $1';
      params = [departmentId];
    }
    query += ' ORDER BY year, semester, name';
    const result = await pool.query(query, params);
    res.json(result.rows.map(c => ({
      id: c.id.toString(),
      name: c.name,
      departmentId: c.department_id ? c.department_id.toString() : null,
      year: c.year.toString(),
      semester: c.semester.toString(),
    })));
  } catch (err) {
    console.error('Admin get courses error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// POST /admin/courses — create a new course
router.post('/courses', auth(['admin']), async (req, res) => {
  try {
    const { name, departmentId, year, semester } = req.body;

    if (!name || !year || !semester) {
      return res.status(400).json({ message: 'Name, year, and semester are required.' });
    }

    const result = await pool.query(
      `INSERT INTO courses (name, department_id, year, semester)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [name, departmentId || null, year, semester]
    );

    const course = result.rows[0];
    res.status(201).json({
      id: course.id.toString(),
      name: course.name,
      departmentId: course.department_id ? course.department_id.toString() : null,
      year: course.year.toString(),
      semester: course.semester.toString(),
    });
  } catch (err) {
    console.error('Admin create course error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// POST /admin/course-teacher-section — assign a teacher to a course+section
router.post('/course-teacher-section', auth(['admin']), async (req, res) => {
  try {
    const { courseId, teacherId, sectionId } = req.body;

    if (!courseId || !teacherId || !sectionId) {
      return res.status(400).json({ message: 'courseId, teacherId, and sectionId are required.' });
    }

    const existing = await pool.query(
      'SELECT id FROM course_teacher_section WHERE course_id = $1 AND teacher_id = $2 AND section_id = $3',
      [courseId, teacherId, sectionId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ message: 'This assignment already exists.' });
    }

    const result = await pool.query(
      'INSERT INTO course_teacher_section (course_id, teacher_id, section_id) VALUES ($1, $2, $3) RETURNING id',
      [courseId, teacherId, sectionId]
    );

    res.status(201).json({ id: result.rows[0].id.toString() });
  } catch (err) {
    console.error('Admin assign teacher error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
