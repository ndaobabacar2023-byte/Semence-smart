// routes/advisor.routes.js
const express = require('express');
const router = express.Router();
const advisorController = require('../controllers/advisor.controller');

console.log('🔄 Chargement de advisor.routes.js avec controller');

// Route d'analyse
router.post('/analyse', advisorController.analyse);

// Historique
router.get('/historique', advisorController.historique);

// Test
router.get('/test', advisorController.test);

console.log('✅ Routes advisor configurées avec controller');

module.exports = router;