// Fichier: server.js

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = require('./config/db');
const authRoutes = require('./routes/auth.routes');
const advisorRoutes = require('./routes/advisor.routes');

const app = express();

// ===== MIDDLEWARES =====

// Autorise toutes les requêtes depuis Flutter Web
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

// IMPORTANT : utilise express.json() au lieu de body-parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connexion DB
connectDB();

// ===== ROUTES =====
app.use('/api/auth', authRoutes);
app.use('/api/analyse', advisorRoutes);

// Gestion erreur
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || "Erreur serveur" });
});

// ===== LANCEMENT SERVEUR =====
const PORT = process.env.PORT || 3000;
app.listen(PORT, () =>
  console.log(`AgriAdvisor backend démarré sur le port ${PORT}`)
);
