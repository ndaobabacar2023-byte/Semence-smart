// controllers/advisor.controller.js
const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');
const Analyse = require('../models/Analyse'); // ✅ modèle d'historique
const advisorService = require('../services/advisor.service');

/**
 * Analyse des conditions pour une culture
 * @route POST /api/advisor/analyse
 * @access Private
 */
exports.analyse = async (req, res) => {
  try {
    const input = req.body;

    // Validation des champs obligatoires
    const required = ['culture', 'typeCulture', 'temperature', 'humidite', 'sol', 'zone', 'saison', 'eau'];
    const missingFields = [];
    
    for (const field of required) {
      if (input[field] === undefined || input[field] === '') {
        missingFields.push(field);
      }
    }

    if (missingFields.length > 0) {
      return res.status(400).json({ 
        success: false,
        message: `Champs manquants ou vides: ${missingFields.join(', ')}` 
      });
    }

    // Conversion des valeurs numériques
    const temperature = parseFloat(input.temperature);
    const humidite = parseFloat(input.humidite);
    const eau = parseFloat(input.eau);

    // Validation des valeurs numériques
    if (isNaN(temperature) || temperature < -10 || temperature > 50) {
      return res.status(400).json({
        success: false,
        message: 'Température invalide. Doit être entre -10 et 50°C'
      });
    }

    if (isNaN(humidite) || humidite < 0 || humidite > 100) {
      return res.status(400).json({
        success: false,
        message: 'Humidité invalide. Doit être entre 0 et 100%'
      });
    }

    if (isNaN(eau) || eau < 0) {
      return res.status(400).json({
        success: false,
        message: 'Valeur d\'eau invalide. Doit être un nombre positif'
      });
    }

    // Recherche de la culture
    const cultureDoc = await Culture.findOne({ 
      nom: input.culture,
      types: { $in: [input.typeCulture] } 
    });

    if (!cultureDoc) {
      return res.status(404).json({ 
        success: false,
        message: `Fiche culture "${input.culture}" (type: ${input.typeCulture}) non trouvée` 
      });
    }

    console.log("📊 Début analyse - Culture:", cultureDoc.nom);
    console.log("📍 Zone:", input.zone, "Saison:", input.saison);
    console.log("📈 Paramètres:", { temperature, humidite, sol: input.sol, eau });

    // Préparation des données pour l'analyse
    const analysisData = {
      temperature,
      humidite,
      sol: input.sol,
      eau,
      zone: input.zone,
      saison: input.saison
    };

    // Appel du service d'analyse
    const evaluation = advisorService.evaluateConditions(analysisData, cultureDoc.toObject());

    if (!evaluation.success) {
      return res.status(500).json({
        success: false,
        message: 'Erreur lors de l\'analyse',
        error: evaluation.error
      });
    }

    // Recherche des fournisseurs
    let fournisseurs = [];
    try {
      fournisseurs = await Fournisseur.find({ 
        zones: input.zone,
        cultures: { $in: [input.culture] }
      }).limit(5);

      if (fournisseurs.length === 0) {
        fournisseurs = await Fournisseur.find({ 
          cultures: { $in: [input.culture] }
        }).limit(5);
      }

      if (fournisseurs.length === 0) {
        fournisseurs = await Fournisseur.find().limit(3);
      }
    } catch (fournisseurError) {
      console.warn("⚠️ Erreur recherche fournisseurs:", fournisseurError.message);
      fournisseurs = [];
    }

    // Formatage de la réponse
    const response = {
      success: true,
      culture: cultureDoc.nom,
      typeCulture: input.typeCulture,
      status: evaluation.status,
      score: evaluation.score,
      emoji: evaluation.emoji,
      message: evaluation.message,
      variete: evaluation.bestVariete,
      recommandations: evaluation.recommandations,
      sousScores: evaluation.subscores,
      metadata: {
        zone: input.zone,
        saison: input.saison,
        dateAnalyse: new Date().toISOString(),
        cultureId: cultureDoc._id
      },
      fournisseurs: fournisseurs.map(f => ({
        id: f._id,
        nom: f.nom,
        telephone: f.telephone,
        email: f.email,
        adresse: f.adresse,
        specialite: f.specialite,
        note: f.note,
        cultures: f.cultures
      }))
    };

    // 🔄 Sauvegarde de l'historique
    try {
      await Analyse.create({
        userId: req.user?.id || null, // Assure-toi que req.user existe si route private
        culture: response.culture,
        typeCulture: response.typeCulture,
        temperature: analysisData.temperature,
        humidite: analysisData.humidite,
        sol: analysisData.sol,
        eau: analysisData.eau,
        zone: analysisData.zone,
        saison: analysisData.saison,
        score: response.score,
        status: response.status,
        recommandations: response.recommandations,
        variete: response.variete
      });
      console.log('💾 Analyse sauvegardée dans la base');
    } catch (err) {
      console.warn('⚠️ Impossible de sauvegarder l’analyse :', err.message);
    }

    console.log(`✅ Analyse terminée - Score: ${evaluation.score}, Statut: ${evaluation.status}`);

    res.json(response);

  } catch (err) {
    console.error("❌ ERREUR ANALYSE:", err);
    res.status(500).json({ 
      success: false,
      message: 'Erreur serveur lors de l\'analyse', 
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
};

/**
 * Obtenir l'historique des analyses de l'utilisateur
 * @route GET /api/advisor/historique
 * @access Private
 */
exports.historique = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Utilisateur non authentifié' });
    }

    const analyses = await Analyse.find({ userId }).sort({ dateAnalyse: -1 });

    res.json({
      success: true,
      message: 'Historique des analyses',
      analyses
    });
  } catch (err) {
    console.error("❌ ERREUR HISTORIQUE:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de l\'historique'
    });
  }
};

/**
 * Tester le service d'analyse
 * @route GET /api/advisor/test
 * @access Public
 */
exports.test = async (req, res) => {
  try {
    const testCulture = {
      nom: 'Mil',
      temp_min: 25,
      temp_max: 35,
      humidite_min: 40,
      humidite_max: 70,
      sols_recommandes: ['sableux', 'limoneux'],
      besoin_eau: 'faible',
      saison_optimale: 'hivernage',
      varietes: [
        {
          nom: 'Souna 3',
          resistance_secheresse: true,
          saison_recommandee: 'hivernage',
          cycle_vegetatif: '85 jours'
        }
      ]
    };

    const testInput = {
      temperature: 30,
      humidite: 60,
      sol: 'sableux',
      eau: 40,
      zone: 'Nord',
      saison: 'hivernage'
    };

    const evaluation = advisorService.evaluateConditions(testInput, testCulture);

    res.json({
      success: true,
      message: 'Service d\'analyse fonctionnel',
      test_result: evaluation
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Service en erreur',
      error: err.message
    });
  }
};