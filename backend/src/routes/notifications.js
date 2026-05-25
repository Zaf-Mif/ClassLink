const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth(), async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT * FROM notifications
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 50`,
      [userId]
    );

    const notifications = result.rows.map((n) => ({
      id: n.id.toString(),
      userId: n.user_id.toString(),
      type: n.type,
      referenceId: n.reference_id ? n.reference_id.toString() : null,
      title: n.title || '',
      message: n.message || '',
      isRead: n.is_read,
      createdAt: n.created_at,
    }));

    res.json(notifications);
  } catch (err) {
    console.error('Get notifications error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.put('/:id/read', auth(), async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE notifications
       SET is_read = true
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Notification not found.' });
    }

    res.json({ message: 'Notification marked as read.' });
  } catch (err) {
    console.error('Mark notification read error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.put('/read-all', auth(), async (req, res) => {
  try {
    await pool.query(
      `UPDATE notifications SET is_read = true
       WHERE user_id = $1 AND is_read = false`,
      [req.user.id]
    );
    res.json({ message: 'All notifications marked as read.' });
  } catch (err) {
    console.error('Mark all read error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
