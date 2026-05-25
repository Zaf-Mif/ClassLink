require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const coursesRoutes = require('./routes/courses');
const announcementsRoutes = require('./routes/announcements');
const assignmentsRoutes = require('./routes/assignments');
const filesRoutes = require('./routes/files');
const forumRoutes = require('./routes/forum');
const messagesRoutes = require('./routes/messages');
const notificationsRoutes = require('./routes/notifications');
const adminRoutes = require('./routes/admin');

const app = express();
const PORT = process.env.PORT || 3000;

const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(uploadsDir));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/courses', coursesRoutes);
app.use('/api/v1/announcements', announcementsRoutes);
app.use('/api/v1/assignments', assignmentsRoutes);
app.use('/api/v1/files', filesRoutes);
app.use('/api/v1/forum', forumRoutes);
app.use('/api/v1/messages', messagesRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/admin', adminRoutes);

app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Internal server error.' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`ClassLink API running on port ${PORT}`);
});
