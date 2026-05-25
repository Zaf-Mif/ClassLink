const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK using service account credentials
// Expect FIREBASE_SERVICE_ACCOUNT env variable to point to JSON key file
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!serviceAccountPath) {
  console.error('FIREBASE_SERVICE_ACCOUNT env var not set');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(serviceAccountPath))),
});

/**
 * Send a push notification to a device token.
 * @param {string} deviceToken - The FCM device registration token.
 * @param {Object} payload - The notification payload (title, body, data).
 * @returns {Promise<string>} Message ID on success.
 */
async function sendPushNotification(deviceToken, payload) {
  if (!deviceToken) {
    throw new Error('Device token is required');
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
  return response; // Message ID
}

module.exports = {
  sendPushNotification,
};
