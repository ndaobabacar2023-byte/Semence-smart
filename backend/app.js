const express = require('express');
const app = express();

require('dotenv').config();
require('./config/db')();

app.use(express.json());

app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/analyse', require('./routes/advisor.routes'));

module.exports = app;
