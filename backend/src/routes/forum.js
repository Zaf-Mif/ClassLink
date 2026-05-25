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

    const questionTitle = content.substring(0, 100);

    for (const teacher of teachersResult.rows) {
      await pool.query(
        `INSERT INTO notifications (user_id, type, reference_id, title, message)
         VALUES ($1, 'forum', $2, $3, $4)`,
        [teacher.teacher_id, question.id, `New Question`, questionTitle]
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
    const { content, isPinned } = req.body;

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
      `INSERT INTO forum_answers (question_id, teacher_id, content, is_pinned)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [id, req.user.id, content, isPinned || false]
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

    const answerSnippet = content.substring(0, 200);

    await pool.query(
      `INSERT INTO notifications (user_id, type, reference_id, title, message)
       VALUES ($1, 'answer', $2, $3, $4)`,
      [question.student_id, id, `Your Question Answered`, answerSnippet]
    );

    res.status(201).json({
      id: answer.id.toString(),
      content: answer.content,
      teacherName: teacherResult.rows[0]?.name || 'Unknown',
      isPinned: answer.is_pinned,
      createdAt: answer.created_at,
    });
  } catch (err) {
    console.error('Create answer error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// PATCH /questions/:qId/answers/:aId/pin — Toggle pin status (teacher/admin only)
router.patch('/questions/:qId/answers/:aId/pin', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { aId } = req.params;

    const answerResult = await pool.query(
      'SELECT * FROM forum_answers WHERE id = $1',
      [aId]
    );

    if (answerResult.rows.length === 0) {
      return res.status(404).json({ message: 'Answer not found.' });
    }

    const currentPinned = answerResult.rows[0].is_pinned;
    const result = await pool.query(
      'UPDATE forum_answers SET is_pinned = $1 WHERE id = $2 RETURNING *',
      [!currentPinned, aId]
    );

    const answer = result.rows[0];

    res.json({
      id: answer.id.toString(),
      content: answer.content,
      teacherName: answer.teacher_name,
      isPinned: answer.is_pinned,
      createdAt: answer.created_at,
    });
  } catch (err) {
    console.error('Toggle pin error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// PATCH /questions/:id/toggle-answered — Toggle is_answered flag (teacher/admin only)
router.patch('/questions/:id/toggle-answered', auth(['teacher', 'admin']), async (req, res) => {
  try {
    const { id } = req.params;

    const questionResult = await pool.query(
      'SELECT * FROM forum_questions WHERE id = $1',
      [id]
    );

    if (questionResult.rows.length === 0) {
      return res.status(404).json({ message: 'Question not found.' });
    }

    const currentAnswered = questionResult.rows[0].is_answered;
    const result = await pool.query(
      'UPDATE forum_questions SET is_answered = $1 WHERE id = $2 RETURNING *',
      [!currentAnswered, id]
    );

    const question = result.rows[0];

    res.json({
      id: question.id.toString(),
      isAnswered: question.is_answered,
    });
  } catch (err) {
    console.error('Toggle answered error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
