const pool = require('../config/database');

function auditLog(action, entityType) {
  return async (req, res, next) => {
    const originalJson = res.json.bind(res);
    res.json = function (body) {
      if (res.statusCode < 400 && req.user) {
        const entityId = body?.id
          ? parseInt(body.id, 10)
          : res.locals.entityId || null;
        pool.query(
          `INSERT INTO system_activity_logs (user_id, action, entity_type, entity_id, details, ip_address)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [
            req.user.id,
            action,
            entityType,
            entityId,
            JSON.stringify({ method: req.method, path: req.originalUrl }),
            req.ip,
          ]
        ).catch(err => console.error('Audit log error:', err.message));
      }
      return originalJson(body);
    };
    next();
  };
}

module.exports = auditLog;
