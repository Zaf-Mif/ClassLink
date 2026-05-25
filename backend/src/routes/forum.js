const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/:courseId/questions', auth(), async (req, res) => {
  try {
    const { courseId } = req.params;

    const result = await pool.query(
      `SELECT q.*, u.name AS student_name,
        (SELECT json_agg(json_build_object(
          'id', a.id::text,
          'content', a.content,
          'teacherName', tu.name,
          'isPinned', a.is_pinned,
          'createdAt', a.created_at
        ) ORDER BY a.is_pinned DESC, a.created_at ASC)
         FROM forum_answers a
         JOIN users tu ON tu.id = a.teacher_id
         WHERE a.question_id = q.id) AS answers
       FROM forum_questions q
       JOIN users u ON u.id = q.student_id
       WHERE q.course_id = $1
       ORDER BY q.created_at DESC`,
      [courseId]
    );

    const questions = result.rows.map((q) => ({
      id: q.id.toString(),
      content: q.content,
      studentName: q.student_name,
      isAnswered: q.is_answered,
      answers: q.answers || [],
      createdAt: q.created_at,
    }));

    res.json(questions);
  } catch (err) {
    console.error('Get questions error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/:courseId/questions', auth(['student']), async (req, res) => {
  try {
    const { courseId } = req.params;
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({ message: 'Content is required.' });
    }

    const result = await pool.query(
      `INSERT INTO forum_questions (student_id, course_id, content)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [req.user.id, courseId, content]
    );

    const question = result.rows[0];

    const userResult = await pool.query(
      'SELECT name FROM users WHERE id = $1',
      [req.user.id]
    );

    const teachersResult = await pool.query(
      `SELECT DISTINCT teacher_id FROM course_teacher_section WHERE course_id = $1`,
      [courseId]
    );

    for (const teacher of teachersResult.rows) {
      await pool.query(
        `INSERT INTO notifications (user_id, type, reference_id)
         VALUES ($1, 'forum', $2)`,
        [teacher.teacher_id, question.id]
      );
    }

    res.status(201).json({
      id: question.id.toString(),
      content: question.content,
      studentName: userResult.rows[0]?.name || 'Unknown',
      isAnswered: false,
      answers: [],
      createdAt: question.created_at,
    });
  } catch (err) {
    console.error('Create question error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/questions/:id/answers', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({ message: 'Content is required.' });
    }

    const questionResult = await pool.query(
      'SELECT * FROM forum_questions WHERE id = $1',
      [id]
    );

    if (questionResult.rows.length === 0) {
      return res.status(404).json({ message: 'Question not found.' });
    }

    const result = await pool.query(
      `INSERT INTO forum_answers (question_id, teacher_id, content)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [id, req.user.id, content]
    );

    await pool.query(
      'UPDATE forum_questions SET is_answered = true WHERE id = $1',
      [id]
    );

    const answer = result.rows[0];
    const teacherResult = await pool.query(
      'SELECT name FROM users WHERE id = $1',
      [req.user.id]
    );

    const question = questionResult.rows[0];

    await pool.query(
      `INSERT INTO notifications (user_id, type, reference_id)
       VALUES ($1, 'answer', $2)`,
      [question.student_id, id]
    );

    res.status(201).json({
      id: answer.id.toString(),
      content: answer.content,
      teacherName: teacherResult.rows[0]?.name || 'Unknown',
      isPinned: false,
      createdAt: answer.created_at,
    });
  } catch (err) {
    console.error('Create answer error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
