// Local notification service — no external push dependency
// In-app notifications are created directly via DB inserts in route handlers.

async function createNotification(userId, type, referenceId, title, message) {
  const pool = require('../config/database');
  try {
    await pool.query(
      `INSERT INTO notifications (user_id, type, reference_id, title, message)
       VALUES ($1, $2, $3, $4, $5)`,
      [userId, type, referenceId, title, message]
    );
  } catch (err) {
    console.error('createNotification error:', err.message);
  }
}

module.exports = {
  createNotification,
};
