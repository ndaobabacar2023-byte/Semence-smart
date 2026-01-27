// server.js - VERSION FINALE SANS ERREUR
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

// Charger les variables d'environnement
dotenv.config();

// Routes
const authRoutes = require('./routes/auth.routes');
const cultureRoutes = require('./routes/culture.routes');
const advisorRoutes = require('./routes/advisor.routes');

// Connexion à la base de données
connectDB();

// Initialiser l'application Express
const app = express();

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes API
app.use('/api/auth', authRoutes);
app.use('/api/cultures', cultureRoutes);
app.use('/api/advisor', advisorRoutes);

// ⚠️⚠️⚠️ NE PAS AVOIR CETTE LIGNE CI-DESSOUS ⚠️⚠️⚠️
// app.post('/api/advisor/analyse', advisorController.analyse); // ❌ SUPPRIMEZ-MOI !

// Route de base
app.get('/', (req, res) => {
  res.json({
    message: 'API AgriAdvisor Sénégal',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      cultures: '/api/cultures',
      advisor: '/api/advisor'
    }
  });
});

// Route 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée'
  });
});

// Gestionnaire d'erreurs global
app.use((err, req, res, next) => {
  console.error('🔥 Erreur globale:', err.stack);
  
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Erreur interne du serveur';
  
  res.status(statusCode).json({
    success: false,
    message: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Port d'écoute
const PORT = process.env.PORT || 5000;

// Démarrer le serveur
const server = app.listen(PORT, () => {
  console.log(`🚀 Serveur AgriAdvisor démarré sur le port ${PORT}`);
  console.log(`📡 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 URL: http://localhost:${PORT}`);
});

// Gestion propre de l'arrêt
process.on('SIGTERM', () => {
  console.log('👋 SIGTERM reçu. Arrêt gracieux du serveur...');
  server.close(() => {
    console.log('✅ Serveur arrêté');
    process.exit(0);
  });
});

module.exports = app;