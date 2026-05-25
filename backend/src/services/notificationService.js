const admin = require('firebase-admin');
const path = require('path');
const pool = require('../config/database');

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!serviceAccountPath) {
  console.warn('FIREBASE_SERVICE_ACCOUNT env var not set — push notifications disabled');
} else {
  if (admin.apps.length === 0) {
    admin.initializeApp({
      credential: admin.credential.cert(require(path.resolve(serviceAccountPath))),
    });
  }
}

async function sendPushNotification(deviceToken, payload) {
  if (!deviceToken || admin.apps.length === 0) {
    return null;
  }
  const message = {
    token: deviceToken,
    notification: {
      title: payload.title || 'ClassLink Notification',
      body: payload.body || '',
    },
    data: payload.data || {},
  };
  const response = await admin.messaging().send(message);
  return response;
}

async function sendPushToUser(userId, title, body, data) {
  try {
    const result = await pool.query(
      'SELECT fcm_token FROM users WHERE id = $1 AND fcm_token IS NOT NULL',
      [userId]
    );
    if (result.rows.length === 0) return null;
    return await sendPushNotification(result.rows[0].fcm_token, {
      title,
      body,
      data: data || {},
    });
  } catch (err) {
    console.error('sendPushToUser error:', err.message);
    return null;
  }
}

async function sendPushToCourse(courseId, title, body, data, excludeUserId) {
  try {
    const tokenQuery = `
      SELECT DISTINCT u.fcm_token FROM users u
      JOIN course_teacher_section cts ON cts.section_id = u.section_id
      WHERE cts.course_id = $1
        AND u.fcm_token IS NOT NULL
        ${excludeUserId ? 'AND u.id != $2' : ''}
    `;
    const values = excludeUserId ? [courseId, excludeUserId] : [courseId];
    const result = await pool.query(tokenQuery, values);

    const results = await Promise.allSettled(
      result.rows.map(row =>
        admin.apps.length > 0
          ? sendPushNotification(row.fcm_token, { title, body, data: data || {} })
          : Promise.resolve(null)
      )
    );
    return results.filter(r => r.status === 'fulfilled').length;
  } catch (err) {
    console.error('sendPushToCourse error:', err.message);
    return 0;
  }
}

module.exports = {
  sendPushNotification,
  sendPushToUser,
  sendPushToCourse,
};
