const jwt = require('jsonwebtoken');

const token = jwt.sign({ user: 'maryam' }, 'mysecretkey', { expiresIn: '1h' });
console.log(token);