const express = require('express');
const router = express.Router();

const advisorController = require('../controllers/advisor.controller');

console.log('🔄 Chargement de advisor.routes.js avec controller');

// ==========================
// ANALYSE (SANS AUTHENTIFICATION)
// ==========================
router.post(
  '/analyse',
  advisorController.analyse
);

// ==========================
// HISTORIQUE (SANS AUTHENTIFICATION)
// ==========================
router.get(
  '/historique',
  advisorController.historique
);

// ==========================
// TEST
// ==========================
router.get(
  '/test',
  advisorController.test
);

console.log('✅ Routes advisor configurées avec controller');

module.exports = router;
