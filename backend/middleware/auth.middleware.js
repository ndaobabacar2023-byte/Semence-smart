// middleware/auth.middleware.js - CORRIGÉ
const jwt = require('jsonwebtoken');

// Fonction d'authentification
const auth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: "Token manquant" });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'votre-secret-par-defaut');
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ message: "Token invalide" });
  }
};

// Fonction de vérification de rôle
const role = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: "Accès interdit" });
    }
    next();
  };
};

// Exportez comme un objet
module.exports = {
  auth,
  role,
  // Alias pour compatibilité
  protect: auth,
  authorize: role
};