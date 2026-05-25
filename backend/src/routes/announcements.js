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
        SELECT a.*, u.name AS teacher_name
        FROM announcements a
        JOIN users u ON u.id = a.teacher_id
        WHERE a.course_id = $1
        ORDER BY a.created_at DESC
      `;
      params = [courseId];
    } else {
      query = `
        SELECT a.*, u.name AS teacher_name,
               CASE WHEN ar.id IS NOT NULL THEN true ELSE false END AS is_read
        FROM announcements a
        JOIN users u ON u.id = a.teacher_id
        LEFT JOIN announcement_reads ar ON ar.announcement_id = a.id AND ar.student_id = $2
        WHERE a.course_id = $1
        ORDER BY a.created_at DESC
      `;
      params = [courseId, userId];
    }

    const result = await pool.query(query, params);

    const announcements = result.rows.map((a) => ({
      id: a.id.toString(),
      title: a.title,
      content: a.content,
      teacherName: a.teacher_name,
      createdAt: a.created_at,
      isRead: a.is_read || false,
      scheduledAt: a.scheduled_at || null,
    }));

    res.json(announcements);
  } catch (err) {
    console.error('Get announcements error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { title, content, courseId, sectionIds } = req.body;

    if (!title || !content || !courseId) {
      return res.status(400).json({ message: 'Title, content, and courseId are required.' });
    }

    const result = await pool.query(
      `INSERT INTO announcements (title, content, teacher_id, course_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [title, content, req.user.id, courseId]
    );

    const announcement = result.rows[0];

    if (sectionIds && Array.isArray(sectionIds) && sectionIds.length > 0) {
      const values = sectionIds.map((sectionId) =>
        pool.query(
          'INSERT INTO announcement_targets (announcement_id, section_id) VALUES ($1, $2)',
          [announcement.id, sectionId]
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
         VALUES ($1, 'announcement', $2)`,
        [student.id, announcement.id]
      );
    }

    const teacherResult = await pool.query(
      'SELECT name FROM users WHERE id = $1',
      [req.user.id]
    );

    res.status(201).json({
      id: announcement.id.toString(),
      title: announcement.title,
      content: announcement.content,
      teacherName: teacherResult.rows[0]?.name || 'Unknown',
      createdAt: announcement.created_at,
      isRead: false,
    });
  } catch (err) {
    console.error('Create announcement error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/:id/read', auth(['student']), async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    await pool.query(
      `INSERT INTO announcement_reads (announcement_id, student_id)
       VALUES ($1, $2)
       ON CONFLICT DO NOTHING`,
      [id, userId]
    );

    res.json({ message: 'Marked as read.' });
  } catch (err) {
    console.error('Mark read error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.get('/:id/reads', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { id } = req.params;

    const annResult = await pool.query(
      'SELECT course_id FROM announcements WHERE id = $1',
      [id]
    );

    if (annResult.rows.length === 0) {
      return res.status(404).json({ message: 'Announcement not found.' });
    }

    const readsResult = await pool.query(
      `SELECT ar.*, u.name AS student_name
       FROM announcement_reads ar
       JOIN users u ON u.id = ar.student_id
       WHERE ar.announcement_id = $1
       ORDER BY ar.read_at DESC`,
      [id]
    );

    const totalResult = await pool.query(
      `SELECT COUNT(*)::int AS count FROM users u
       JOIN course_teacher_section cts ON cts.section_id = u.section_id
       WHERE cts.course_id = $1 AND u.role = 'student'`,
      [annResult.rows[0].course_id]
    );

    res.json({
      reads: readsResult.rows.map((r) => ({
        id: r.id.toString(),
        studentId: r.student_id.toString(),
        studentName: r.student_name,
        readAt: r.read_at,
      })),
      total: totalResult.rows[0].count,
    });
  } catch (err) {
    console.error('Get reads error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
