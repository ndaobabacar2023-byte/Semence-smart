// routes/advisor.routes.js - VERSION SIMPLIFIÉE TEMPORAIRE
const express = require('express');
const router = express.Router();

console.log('🔄 Chargement de advisor.routes.js (version simplifiée)');

// Route d'analyse simplifiée (sans contrôleur)
router.post('/analyse', (req, res) => {
  console.log('📡 POST /api/advisor/analyse (version simplifiée)');
  console.log('📥 Données:', req.body);
  
  res.json({
    success: true,
    culture: req.body.culture || 'Tomate',
    typeCulture: req.body.typeCulture || 'serre',
    status: 'excellent',
    score: 88,
    message: 'Conditions optimales pour la culture',
    variete: {
      nom: 'Premium F1',
      resistance_secheresse: true
    },
    recommandations: [
      'Planter après les premières pluies',
      'Maintenir une humidité de 60-70%'
    ],
    fournisseurs: [
      {
        nom: 'Test Fournisseur',
        telephone: '+221 77 000 00 00'
      }
    ]
  });
});

// Historique simplifié
router.get('/historique', (req, res) => {
  res.json({
    success: true,
    data: []
  });
});

// Test
router.get('/test', (req, res) => {
  res.json({
    success: true,
    message: 'API Advisor fonctionnelle'
  });
});

console.log('✅ Routes advisor configurées');
module.exports = router;