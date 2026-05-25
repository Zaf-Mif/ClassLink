const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

const EMAIL_REGEX = /^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$/;

function formatUser(user, token) {
  return {
    id: user.id.toString(),
    name: user.name,
    email: user.email,
    role: user.role,
    departmentId: user.department_id ? user.department_id.toString() : null,
    year: user.year ? user.year.toString() : null,
    semester: user.semester ? user.semester.toString() : null,
    sectionId: user.section_id ? user.section_id.toString() : null,
    token: token || undefined,
  };
}

router.get('/me', auth(), async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json(formatUser(result.rows[0]));
  } catch (err) {
    console.error('Get me error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

// POST /fcm-token — Save or update FCM device token
router.post('/fcm-token', auth(), async (req, res) => {
  try {
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ message: 'fcmToken is required.' });
    }

    await pool.query(
      'UPDATE users SET fcm_token = $1 WHERE id = $2',
      [fcmToken, req.user.id]
    );

    res.json({ message: 'FCM token updated.' });
  } catch (err) {
    console.error('Update FCM token error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
