const express = require('express');
const cors = require('cors');
const app = express();

require('dotenv').config();
require('./config/db')();

// 🔥 CORS DOIT ÊTRE ICI (avant les routes)
app.use(cors({
  origin: '*', // dev seulement
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));

app.use(express.json());

// routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/analyse', require('./routes/advisor.routes'));

module.exports = app;