const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const https = require('https');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const { toCamelCase } = require('../helpers');

const router = express.Router();

const otpStore = new Map();

const EMAIL_REGEX = /^[a-zA-Z]+\.[a-zA-Z]+@astu\.edu\.et$/;

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function sendBrevoEmail(toEmail, subject, htmlContent) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      sender: {
        name: process.env.BREVO_SENDER_NAME || 'ClassLink',
        email: process.env.BREVO_SENDER_EMAIL || 'classlink@astu.edu.et',
      },
      to: [{ email: toEmail }],
      subject,
      htmlContent,
    });

    const options = {
      hostname: 'api.brevo.com',
      path: '/v3/smtp/email',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-key': process.env.BREVO_API_KEY,
        'Content-Length': Buffer.byteLength(data),
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(body));
        } else {
          reject(new Error(`Brevo API error: ${res.statusCode} ${body}`));
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

function formatUserForResponse(user, token) {
  return {
    id: user.id.toString(),
    name: user.name,
    email: user.email,
    role: user.role,
    departmentId: user.department_id ? user.department_id.toString() : null,
    year: user.year ? user.year.toString() : null,
    semester: user.semester ? user.semester.toString() : null,
    sectionId: user.section_id ? user.section_id.toString() : null,
    token,
  };
}

router.post('/send-otp', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || !EMAIL_REGEX.test(email)) {
      return res.status(400).json({ message: 'Email must be in format firstname.lastname@astu.edu.et' });
    }

    const otp = generateOtp();
    const expiresAt = Date.now() + 5 * 60 * 1000;

    otpStore.set(email, { otp, expiresAt });

    try {
      await sendBrevoEmail(
        email,
        'ClassLink - OTP Verification',
        `<p>Your OTP for ClassLink is: <strong>${otp}</strong></p><p>This code expires in 5 minutes.</p>`
      );
    } catch (emailErr) {
      console.error('Failed to send email via Brevo:', emailErr.message);
    }

    res.json({ message: 'OTP sent successfully.' });
  } catch (err) {
    console.error('Send OTP error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: 'Email and OTP are required.' });
    }

    const stored = otpStore.get(email);

    if (!stored) {
      return res.status(400).json({ message: 'No OTP requested for this email.' });
    }

    if (Date.now() > stored.expiresAt) {
      otpStore.delete(email);
      return res.status(400).json({ message: 'OTP has expired. Request a new one.' });
    }

    if (stored.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP.' });
    }

    otpStore.delete(email);

    res.json({ message: 'OTP verified successfully.' });
  } catch (err) {
    console.error('Verify OTP error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }

    if (!EMAIL_REGEX.test(email)) {
      return res.status(400).json({ message: 'Email must be in format firstname.lastname@astu.edu.et' });
    }

    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const user = result.rows[0];

    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid email or password.' });
    }

    const token = generateToken(user);
    const userResponse = formatUserForResponse(user, token);

    res.json(userResponse);
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Internal server error.' });
  }
});

router.post('/logout', auth(), (req, res) => {
  res.json({ message: 'Logged out successfully.' });
});

module.exports = router;
