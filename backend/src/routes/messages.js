const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const { sendPushToUser } = require('../services/notificationService');

const router = express.Router();

router.get('/conversation/:userId', auth(), async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;

    const result = await pool.query(
      `SELECT m.*, sender.name AS sender_name
       FROM messages m
       JOIN users sender ON sender.id = m.sender_id
       WHERE (m.sender_id = $1 AND m.receiver_id = $2)
          OR (m.sender_id = $2 AND m.receiver_id = $1)
       ORDER BY m.sent_at ASC`,
      [currentUserId, otherUserId]
    );

    const messages = result.rows.map((m) => ({
      id: m.id.toString(),
      senderId: m.sender_id.toString(),
      senderName: m.sender_name,
      receiverId: m.receiver_id.toString(),
      content: m.content,
      sentAt: m.sent_at,
      isRead: m.read_at !== null,
    }));

    await pool.query(
      `UPDATE messages SET read_at = NOW()
       WHERE sender_id = $1 AND receiver_id = $2 AND read_at IS NULL`,
      [otherUserId, currentUserId]
    );

    res.json(messages);
  } catch (err) {
    console.error('Get conversation error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/', auth(), async (req, res) => {
  try {
    const { receiverId, content } = req.body;

    if (!receiverId || !content) {
      return res.status(400).json({ message: 'receiverId and content are required.' });
    }

    if (req.user.id.toString() === receiverId.toString()) {
      return res.status(400).json({ message: 'Cannot send message to yourself.' });
    }

    const result = await pool.query(
      `INSERT INTO messages (sender_id, receiver_id, content)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [req.user.id, receiverId, content]
    );

    const message = result.rows[0];
    const userResult = await pool.query(
      'SELECT name FROM users WHERE id = $1',
      [req.user.id]
    );

    const senderName = userResult.rows[0]?.name || 'Unknown';

    await pool.query(
      `INSERT INTO notifications (user_id, type, reference_id, title, message)
       VALUES ($1, 'message', $2, $3, $4)`,
      [receiverId, message.id, `Message from ${senderName}`, content.substring(0, 200)]
    );
    sendPushToUser(
      receiverId,
      `Message from ${senderName}`,
      content.substring(0, 200),
      { type: 'message', referenceId: message.id.toString() }
    ).catch(() => {});

    res.status(201).json({
      id: message.id.toString(),
      senderId: message.sender_id.toString(),
      senderName: userResult.rows[0]?.name || 'Unknown',
      receiverId: message.receiver_id.toString(),
      content: message.content,
      sentAt: message.sent_at,
      isRead: false,
    });
  } catch (err) {
    console.error('Send message error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

module.exports = router;
