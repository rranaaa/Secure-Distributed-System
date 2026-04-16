const express = require('express');
const { v4: uuidv4 } = require('uuid');
const verifyToken = require('./middleware/auth');
const { logAudit, logState } = require('./db');
const { sendToQueue } = require('./rabbitmq');

const app = express();
app.use(express.json());

const SERVICE_NAME = process.env.SERVICE_NAME || 'api';

app.get('/', (req, res) => {
  res.json({ message: `Hello from ${SERVICE_NAME}` });
});

app.post('/task', verifyToken, async (req, res) => {
  const requestId = uuidv4();

  try {
    await logAudit(SERVICE_NAME, requestId, 'Request received', 'success', 'client');
    await logState(requestId, 'RECEIVED', SERVICE_NAME);

    await logAudit(SERVICE_NAME, requestId, 'JWT authenticated', 'success', 'client');
    await logState(requestId, 'AUTHENTICATED', SERVICE_NAME);

    const taskMessage = {
      request_id: requestId,
      payload: req.body,
      sent_by: SERVICE_NAME,
      service_token: process.env.INTERNAL_SERVICE_TOKEN
    };

    await sendToQueue(taskMessage);

    await logAudit(SERVICE_NAME, requestId, 'Task sent to RabbitMQ', 'success', 'service');
    await logState(requestId, 'QUEUED', SERVICE_NAME);

    res.status(200).json({
      message: 'Task queued successfully',
      request_id: requestId,
      handled_by: SERVICE_NAME
    });
  } catch (error) {
    await logAudit(SERVICE_NAME, requestId, 'Failed to process request', 'failure', 'service');
    await logState(requestId, 'FAILED', SERVICE_NAME);

    res.status(500).json({
      message: 'Internal server error',
      error: error.message
    });
  }
});

app.listen(process.env.PORT || 3000, () => {
  console.log(`${SERVICE_NAME} running on port ${process.env.PORT || 3000}`);
});
