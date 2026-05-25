const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const { toCamelCaseArray } = require('../helpers');

const router = express.Router();

router.get('/', auth(), async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    let query;
    let params;

    if (role === 'teacher') {
      query = `
        SELECT DISTINCT c.id, c.name, c.department_id, c.year, c.semester
        FROM courses c
        JOIN course_teacher_section cts ON cts.course_id = c.id
        WHERE cts.teacher_id = $1
        ORDER BY c.name
      `;
      params = [userId];
    } else if (role === 'student') {
      query = `
        SELECT DISTINCT c.id, c.name, c.department_id, c.year, c.semester
        FROM courses c
        JOIN course_teacher_section cts ON cts.course_id = c.id
        JOIN sections s ON s.id = cts.section_id
        WHERE s.id = (SELECT section_id FROM users WHERE id = $1)
        ORDER BY c.name
      `;
      params = [userId];
    } else {
      query = 'SELECT * FROM courses ORDER BY name';
      params = [];
    }

    const result = await pool.query(query, params);

    const courses = toCamelCaseArray(result.rows);

    const enriched = await Promise.all(
      courses.map(async (course) => {
        const annCount = await pool.query(
          'SELECT COUNT(*)::int AS count FROM announcements WHERE course_id = $1',
          [course.id]
        );
        const fileCount = await pool.query(
          'SELECT COUNT(*)::int AS count FROM files WHERE course_id = $1',
          [course.id]
        );

        if (role === 'student') {
          const unreadAnn = await pool.query(
            `SELECT COUNT(*)::int AS count FROM announcements a
             WHERE a.course_id = $1
             AND a.id NOT IN (
               SELECT announcement_id FROM announcement_reads WHERE student_id = $2
             )`,
            [course.id, userId]
          );
          course.newAnnouncements = unreadAnn.rows[0].count;
        } else {
          course.newAnnouncements = annCount.rows[0].count;
        }

        course.newFiles = fileCount.rows[0].count;
        return course;
      })
    );

    res.json(enriched);
  } catch (err) {
    console.error('Get courses error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.get('/:id', auth(), async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM courses WHERE id = $1',
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Course not found.' });
    }

    const course = result.rows[0];
    const sectionsResult = await pool.query(
      `SELECT s.* FROM sections s
       JOIN course_teacher_section cts ON cts.section_id = s.id
       WHERE cts.course_id = $1`,
      [req.params.id]
    );

    const teachersResult = await pool.query(
      `SELECT u.id, u.name, u.email FROM users u
       JOIN course_teacher_section cts ON cts.teacher_id = u.id
       WHERE cts.course_id = $1`,
      [req.params.id]
    );

    res.json({
      id: course.id.toString(),
      name: course.name,
      departmentId: course.department_id ? course.department_id.toString() : null,
      year: course.year.toString(),
      semester: course.semester.toString(),
      sections: sectionsResult.rows.map(s => ({
        id: s.id.toString(),
        name: s.name,
        year: s.year.toString(),
        semester: s.semester.toString(),
      })),
      teachers: teachersResult.rows.map(t => ({
        id: t.id.toString(),
        name: t.name,
        email: t.email,
      })),
    });
  } catch (err) {
    console.error('Get course error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
