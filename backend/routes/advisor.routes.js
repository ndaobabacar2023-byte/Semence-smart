// Fichier: routes/advisor.routes.js
// Rôle: routes pour l'analyse des conditions agricoles

const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const advisorController = require('../controllers/advisor.controller');

/**
 * @route   POST /api/analyse
 * @desc    Analyse les conditions d'une culture et retourne recommandations
 * @access  Private (JWT)
 */
router.post('/', authMiddleware, advisorController.analyse);

/**
 * Exemple d'extension future:
 * - GET /api/analyse/historique -> récupérer les analyses précédentes de l'utilisateur
 * - POST /api/analyse/batch -> analyser plusieurs cultures en même temps
 */

// Export du router
module.exports = router;
