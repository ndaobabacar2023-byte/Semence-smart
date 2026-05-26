// routes/advisor.routes.js

const express = require('express');
const router = express.Router();

const advisorController = require('../controllers/advisor.controller');

// ✅ IMPORT DU MIDDLEWARE AUTH
const { auth } = require('../middleware/auth.middleware');

console.log('🔄 Chargement de advisor.routes.js avec controller');

// ==========================
// ANALYSE (PROTÉGÉE)
// ==========================
router.post(
  '/analyse',
  auth,
  advisorController.analyse
);

// ==========================
// HISTORIQUE (PROTÉGÉE)
// ==========================
router.get(
  '/historique',
  auth,
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