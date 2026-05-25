const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/:courseId', auth(), async (req, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user.id;
    const role = req.user.role;

    let query;
    let params;

    if (role === 'teacher' || role === 'admin') {
      query = `
        SELECT a.*, u.name AS teacher_name,
          (SELECT COUNT(*)::int FROM assignment_submissions WHERE assignment_id = a.id) AS submission_count,
          (SELECT COUNT(*)::int FROM users u2
           JOIN course_teacher_section cts ON cts.section_id = u2.section_id
           WHERE cts.course_id = a.course_id AND u2.role = 'student') AS total_students
        FROM assignments a
        JOIN users u ON u.id = a.teacher_id
        WHERE a.course_id = $1
        ORDER BY a.created_at DESC
      `;
      params = [courseId];
    } else {
      query = `
        SELECT a.*, u.name AS teacher_name,
               CASE WHEN asub.id IS NOT NULL THEN true ELSE false END AS submitted,
               asub.file_url AS submitted_file,
               asub.submitted_at
        FROM assignments a
        JOIN users u ON u.id = a.teacher_id
        LEFT JOIN assignment_submissions asub ON asub.assignment_id = a.id AND asub.student_id = $2
        WHERE a.course_id = $1
        ORDER BY a.created_at DESC
      `;
      params = [courseId, userId];
    }

    const result = await pool.query(query, params);

    const assignments = result.rows.map((a) => {
      const base = {
        id: a.id.toString(),
        title: a.title,
        description: a.description,
        deadline: a.deadline,
        courseId: a.course_id.toString(),
        teacherName: a.teacher_name,
        createdAt: a.created_at,
      };

      if (role === 'teacher' || role === 'admin') {
        base.submissionCount = a.submission_count;
        base.totalStudents = a.total_students;
      } else {
        base.submitted = a.submitted;
        base.submittedFile = a.submitted_file || null;
        base.submittedAt = a.submitted_at || null;
      }

      return base;
    });

    res.json(assignments);
  } catch (err) {
    console.error('Get assignments error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { title, description, deadline, courseId, sectionIds } = req.body;

    if (!title || !courseId) {
      return res.status(400).json({ message: 'Title and courseId are required.' });
    }

    const result = await pool.query(
      `INSERT INTO assignments (title, description, deadline, course_id, teacher_id)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [title, description || null, deadline || null, courseId, req.user.id]
    );

    const assignment = result.rows[0];

    if (sectionIds && Array.isArray(sectionIds) && sectionIds.length > 0) {
      const values = sectionIds.map((sectionId) =>
        pool.query(
          'INSERT INTO assignment_targets (assignment_id, section_id) VALUES ($1, $2)',
          [assignment.id, sectionId]
        )
      );
      await Promise.all(values);
    }

    const studentsResult = await pool.query(
      `SELECT id FROM users
       WHERE section_id IN (
         SELECT section_id FROM course_teacher_section WHERE course_id = $1
       )
       AND role = 'student'`,
      [courseId]
    );

    for (const student of studentsResult.rows) {
      await pool.query(
        `INSERT INTO notifications (user_id, type, reference_id)
         VALUES ($1, 'assignment', $2)`,
        [student.id, assignment.id]
      );
    }

    const teacherResult = await pool.query(
      'SELECT name FROM users WHERE id = $1',
      [req.user.id]
    );

    res.status(201).json({
      id: assignment.id.toString(),
      title: assignment.title,
      description: assignment.description,
      deadline: assignment.deadline,
      courseId: assignment.course_id.toString(),
      teacherName: teacherResult.rows[0]?.name || 'Unknown',
      createdAt: assignment.created_at,
    });
  } catch (err) {
    console.error('Create assignment error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/:id/submit', auth(['student']), async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { fileUrl } = req.body;

    if (!fileUrl) {
      return res.status(400).json({ message: 'fileUrl is required.' });
    }

    const existing = await pool.query(
      'SELECT id FROM assignment_submissions WHERE assignment_id = $1 AND student_id = $2',
      [id, userId]
    );

    if (existing.rows.length > 0) {
      await pool.query(
        'UPDATE assignment_submissions SET file_url = $1, submitted_at = NOW() WHERE id = $2',
        [fileUrl, existing.rows[0].id]
      );
    } else {
      await pool.query(
        'INSERT INTO assignment_submissions (assignment_id, student_id, file_url) VALUES ($1, $2, $3)',
        [id, userId, fileUrl]
      );
    }

    res.json({ message: 'Assignment submitted successfully.' });
  } catch (err) {
    console.error('Submit assignment error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
