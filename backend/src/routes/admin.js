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

    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ message: 'A user with this email already exists.' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, role, department_id, year, semester, section_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [name, email.toLowerCase(), passwordHash, role, departmentId || null, year || null, semester || null, sectionId || null]
    );

    res.status(201).json(formatUser(result.rows[0]));
  } catch (err) {
    console.error('Admin create user error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.put('/users/:id', auth(['admin']), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, password, role, departmentId, year, semester, sectionId } = req.body;

    const existing = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const current = existing.rows[0];

    const updatedName = name || current.name;
    const updatedEmail = email || current.email;
    const updatedRole = role || current.role;
    const updatedDepartmentId = departmentId !== undefined ? departmentId : current.department_id;
    const updatedYear = year !== undefined ? year : current.year;
    const updatedSemester = semester !== undefined ? semester : current.semester;
    const updatedSectionId = sectionId !== undefined ? sectionId : current.section_id;

    let passwordHash = current.password_hash;
    if (password) {
      passwordHash = await bcrypt.hash(password, 10);
    }

    const result = await pool.query(
      `UPDATE users
       SET name = $1, email = $2, password_hash = $3, role = $4,
           department_id = $5, year = $6, semester = $7, section_id = $8
       WHERE id = $9
       RETURNING *`,
      [updatedName, updatedEmail, passwordHash, updatedRole, updatedDepartmentId, updatedYear, updatedSemester, updatedSectionId, id]
    );

    res.json(formatUser(result.rows[0]));
  } catch (err) {
    console.error('Admin update user error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
