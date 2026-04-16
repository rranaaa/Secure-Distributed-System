const { logAudit, logState } = require('./db');
const { consumeMessages } = require('./rabbitmq');

const SERVICE_NAME = process.env.SERVICE_NAME || 'worker';

async function processTask(task) {
  const requestId = task.request_id;

  try {
    if (task.service_token !== process.env.INTERNAL_SERVICE_TOKEN) {
      await logAudit(SERVICE_NAME, requestId, 'Invalid service identity', 'failure', 'service');
      await logState(requestId, 'FAILED', SERVICE_NAME);
      return;
    }

    await logAudit(SERVICE_NAME, requestId, 'Task consumed from RabbitMQ', 'success', 'service');
    await logState(requestId, 'CONSUMED', SERVICE_NAME);

    await new Promise(resolve => setTimeout(resolve, 2000));

    await logAudit(SERVICE_NAME, requestId, 'Task processed successfully', 'success', 'service');
    await logState(requestId, 'PROCESSED', SERVICE_NAME);

    console.log(`Processed request ${requestId}`);
  } catch (error) {
    await logAudit(SERVICE_NAME, requestId, 'Task processing failed', 'failure', 'service');
    await logState(requestId, 'FAILED', SERVICE_NAME);

    console.error(error.message);
  }
}

consumeMessages(processTask);