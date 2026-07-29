const express = require('express');
const router = express.Router();

const advisorController = require('../controllers/advisor.controller');
const Analyse = require('../models/Analyse');
const { auth } = require('../middleware/auth.middleware');
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

router.get('/en-attente', auth, async (req, res) => {

  try {

    const analyses = await Analyse.find({
      statut: 'pending',
      technicienId: null
    });

    res.json(analyses);

  } catch (err) {

    res.status(500).json({
      message: 'Erreur serveur'
    });

  }

});
router.put('/prendre/:id', auth, async (req, res) => {

  try {

    const analyse = await Analyse.findById(req.params.id);

    if (!analyse) {
      return res.status(404).json({
        message: 'Analyse introuvable'
      });
    }

    analyse.technicienId = req.user.id;
    analyse.statut = 'in_progress';

    await analyse.save();

    res.json({
      message: 'Analyse prise'
    });

  } catch (err) {

    res.status(500).json({
      message: 'Erreur serveur'
    });

  }

});
router.get('/mes-analyses', auth, async (req, res) => {

  try {

    const analyses = await Analyse.find({
      technicienId: req.user.id
    });

    res.json(analyses);

  } catch (err) {

    res.status(500).json({
      message: 'Erreur serveur'
    });

  }

});

console.log('✅ Routes advisor configurées avec controller');

module.exports = router;
