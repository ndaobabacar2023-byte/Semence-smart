// Fichier: middleware/authMiddleware.js
// Rôle: Middleware pour protéger les routes via JWT

const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  console.warn('⚠️ JWT_SECRET non défini dans .env !');
}

module.exports = function (req, res, next) {
  try {
    // Récupération du token depuis l'en-tête Authorization
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    if (!authHeader) return res.status(401).json({ message: 'Token manquant' });

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.split(' ')[1]
      : authHeader;

    if (!token) return res.status(401).json({ message: 'Token invalide' });

    // Vérification du token
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // ex: { id: ..., role: ... }

    next(); // passe au prochain middleware ou route
  } catch (err) {
    console.error('Erreur JWT:', err.message);
    res.status(401).json({ message: 'Token non valide ou expiré' });
  }
};
