const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  user: 'postgres',
  password: 'postgres',
  database: 'secure_system',
  port: 5432
});

async function checkLogs(requestId) {
  try {
    console.log('Audit Logs:');
    const auditRes = await pool.query(
      'SELECT timestamp, service_name, action_performed, status, source FROM audit_logs WHERE request_id = $1 ORDER BY timestamp',
      [requestId]
    );
    auditRes.rows.forEach(row => {
      console.log(`${row.timestamp} - ${row.service_name}: ${row.action_performed} (${row.status}) from ${row.source}`);
    });

    console.log('\nRequest States:');
    const stateRes = await pool.query(
      'SELECT timestamp, state, service_name FROM request_states WHERE request_id = $1 ORDER BY timestamp',
      [requestId]
    );
    stateRes.rows.forEach(row => {
      console.log(`${row.timestamp} - ${row.service_name}: ${row.state}`);
    });
  } catch (err) {
    console.error('Error:', err);
  } finally {
    pool.end();
  }
}

const requestId = process.argv[2];
if (!requestId) {
  console.log('Usage: node check-logs.js <request_id>');
  process.exit(1);
}

checkLogs(requestId);
