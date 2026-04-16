const amqp = require('amqplib');

const QUEUE_NAME = 'task_queue';

async function consumeMessages(onMessage) {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();

  await channel.assertQueue(QUEUE_NAME, { durable: true });

  channel.consume(QUEUE_NAME, async (msg) => {
    if (msg !== null) {
      const content = JSON.parse(msg.content.toString());
      await onMessage(content);
      channel.ack(msg);
    }
  });

  console.log('Worker is waiting for messages...');
}

module.exports = { consumeMessages };