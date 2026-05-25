const express = require('express');
const multer = require('multer');
const path = require('path');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const { sendPushToCourse } = require('../services/notificationService');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = [
      '.pdf', '.docx', '.pptx',
      '.jpg', '.jpeg', '.png', '.gif',
      '.mp4', '.mov', '.avi', '.webm'
    ];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Unsupported file type'), false);
    }
  },
});

router.get('/:courseId', auth(), async (req, res) => {
  try {
    const { courseId } = req.params;
    const { topic } = req.query; // optional topic filter

    let query = `
      SELECT f.*, u.name AS teacher_name
      FROM files f
      JOIN users u ON u.id = f.teacher_id
      WHERE f.course_id = $1`;
    const values = [courseId];
    if (topic) {
      query += ` AND f.topic ILIKE $2`;
      values.push(`%${topic}%`);
    }
    query += ` ORDER BY f.uploaded_at DESC`;

    const result = await pool.query(query, values);

    const files = result.rows.map((f) => ({
      id: f.id.toString(),
      title: f.title,
      fileUrl: f.file_url,
      topic: f.topic,
      courseId: f.course_id.toString(),
      teacherName: f.teacher_name,
      versionNumber: f.version_number,
      uploadedAt: f.uploaded_at,
    }));
    res.json(files);
  } catch (err) {
    console.error('Get files error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/upload', auth(['teacher', 'admin']), upload.single('file'), async (req, res) => {
  try {
    const { title, topic, courseId } = req.body;

    if (!title || !courseId || !req.file) {
      return res.status(400).json({ message: 'Title, courseId, and file are required.' });
    }

    const fileUrl = `/uploads/${req.file.filename}`;

    const versionResult = await pool.query(
      'SELECT MAX(version_number) AS max_version FROM files WHERE course_id = $1 AND title = $2',
      [courseId, title]
    );

    const versionNumber = (versionResult.rows[0]?.max_version || 0) + 1;

    const result = await pool.query(
      `INSERT INTO files (title, file_url, topic, course_id, teacher_id, version_number)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [title, fileUrl, topic || null, courseId, req.user.id, versionNumber]
    );

    const file = result.rows[0];

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
        `INSERT INTO notifications (user_id, type, reference_id, title, message)
         VALUES ($1, 'file', $2, $3, $4)`,
        [student.id, file.id, `New File: ${title}`, topic ? `Topic: ${topic}` : title]
      );
    }
    sendPushToCourse(
      courseId,
      `New File: ${title}`,
      topic ? `Topic: ${topic} — ${title}` : title,
      { type: 'file', referenceId: file.id.toString() },
      req.user.id
    ).catch(() => {});

    res.status(201).json({
      id: file.id.toString(),
      title: file.title,
      fileUrl: file.file_url,
      topic: file.topic,
      courseId: file.course_id.toString(),
      versionNumber: file.version_number,
      uploadedAt: file.uploaded_at,
    });
  } catch (err) {
    console.error('Upload file error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.get('/search', auth(), async (req, res) => {
  try {
    const { name, topic, courseId } = req.query;
    if (!courseId) {
      return res.status(400).json({ message: 'courseId query param is required.' });
    }
    let query = `
      SELECT f.*, u.name AS teacher_name
      FROM files f
      JOIN users u ON u.id = f.teacher_id
      WHERE f.course_id = $1`;
    const values = [courseId];
    let idx = 2;
    if (name) {
      query += ` AND f.title ILIKE $${idx}`;
      values.push(`%${name}%`);
      idx++;
    }
    if (topic) {
      query += ` AND f.topic ILIKE $${idx}`;
      values.push(`%${topic}%`);
      idx++;
    }
    query += ` ORDER BY f.uploaded_at DESC`;
    const result = await pool.query(query, values);
    const files = result.rows.map(f => ({
      id: f.id.toString(),
      title: f.title,
      fileUrl: f.file_url,
      topic: f.topic,
      courseId: f.course_id.toString(),
      teacherName: f.teacher_name,
      versionNumber: f.version_number,
      uploadedAt: f.uploaded_at,
    }));
    res.json(files);
  } catch (err) {
    console.error('Search files error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
