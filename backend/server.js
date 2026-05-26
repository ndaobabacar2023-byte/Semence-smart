const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

dotenv.config();

const authRoutes = require('./routes/auth.routes');
const cultureRoutes = require('./routes/culture.routes');
const advisorRoutes = require('./routes/advisor.routes');
const technicienRoutes = require('./routes/technicien.routes');
const notificationRoutes = require('./routes/notification.routes');
connectDB();

const app = express();

// 🔥 FIX CORS POUR FLUTTER WEB + MOBILE
app.use(cors({
  origin: '*', // DEV ONLY (important pour ton cas)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/cultures', cultureRoutes);
app.use('/api/advisor', advisorRoutes);


// Utilisation
app.use('/api/technicien', technicienRoutes);
app.use('/api/notifications', notificationRoutes);
// test route
app.get('/', (req, res) => {
  res.json({
    message: 'API AgriAdvisor OK'
  });
});

// 404
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

// Port
const PORT = process.env.PORT || 3000;

// 🔥 IMPORTANT FIX RÉSEAU
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur lancé`);
  console.log(`📡 Local: http://localhost:${PORT}`);
  console.log(`🌐 Réseau: http://172.20.10.2:${PORT}`);
});