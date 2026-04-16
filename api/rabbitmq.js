const amqp = require('amqplib');

const QUEUE_NAME = 'task_queue';

async function sendToQueue(message) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();

  await channel.assertQueue(QUEUE_NAME, { durable: true });
  channel.sendToQueue(QUEUE_NAME, Buffer.from(JSON.stringify(message)), {
    persistent: true
  });

  setTimeout(() => {
    connection.close();
  }, 500);
}

module.exports = { sendToQueue, QUEUE_NAME };