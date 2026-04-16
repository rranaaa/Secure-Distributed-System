const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

async function logAudit(serviceName, requestId, action, status, source) {
  await pool.query(
    `INSERT INTO audit_logs (service_name, request_id, action_performed, status, source)
     VALUES ($1, $2, $3, $4, $5)`,
    [serviceName, requestId, action, status, source]
  );
}

async function logState(requestId, state, serviceName) {
  await pool.query(
    `INSERT INTO request_states (request_id, state, service_name)
     VALUES ($1, $2, $3)`,
    [requestId, state, serviceName]
  );
}

module.exports = { pool, logAudit, logState };