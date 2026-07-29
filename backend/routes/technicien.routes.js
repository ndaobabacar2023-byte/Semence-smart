// routes/technicien.routes.js
// ✅ VERSION CORRIGÉE — ERREUR Route.put callback undefined résolue

const express = require('express');
const router = express.Router();

const technicienController = require('../controllers/technicien.controller');
const { auth, role } = require('../middleware/auth.middleware');

// ===============================
// MIDDLEWARE GLOBAL
// ===============================
router.use(auth);
router.use(role('technicien', 'admin'));

// ===============================
// DEBUG IMPORTS (IMPORTANT)
// ===============================
console.log("technicienController keys:", Object.keys(technicienController));

// ===============================
// DASHBOARD & STATS
// ===============================
router.get(
  '/stats',
  technicienController.getStats
);

// ===============================
// ANALYSES
// ===============================
router.get(
  '/analyses',
  technicienController.getAllAnalyses
);
//router.get(
 // '/mes-analyses',
 // technicienController.getMesAnalyses
//);

router.get(
  '/analyses/:id',
  technicienController.getAnalyseById
);

// ✅ Vérifie que updateAnalyse existe bien dans le controller
router.put(
  '/analyses/:id',
  technicienController.updateAnalyse
);

router.put(
  '/analyses/:id/validate',
  technicienController.validateAnalyse
);

router.put(
  '/analyses/:id/correct',
  technicienController.correctAnalyse
);

// ===============================
// VARIÉTÉS
// ===============================
router.get(
  '/varietes',
  technicienController.getAllVarietes
);

router.post(
  '/varietes',
  technicienController.addVariete
);

router.delete(
  '/varietes/:id',
  technicienController.deleteVariete
);

// ===============================
// NOTIFICATIONS
// ===============================
router.get(
  '/notifications',
  technicienController.getNotifications
);

router.put(
  '/notifications/:id/read',
  technicienController.markNotificationRead
);

// ===============================
module.exports = router;