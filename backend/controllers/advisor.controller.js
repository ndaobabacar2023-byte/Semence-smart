// controllers/advisor.controller.js
const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');
const Analyse = require('../models/Analyse');
const advisorService = require('../services/advisor.service');
const Notification = require('../models/Notification');

/**
 * Analyse des conditions pour une culture
 * @route POST /api/advisor/analyse
 * @access Private
 */
exports.analyse = async (req, res) => {
  try {
    const input = req.body;

    // Validation des champs obligatoires
    const required = ['culture', 'typeCulture', 'temperature', 'humudite', 'sol', 'zone', 'saison', 'eau'];
    // Note: il y a une faute de frappe 'humudite' au lieu de 'humidite' dans votre code original
    
    // Correction: vérifier les deux orthographes possibles
    const humiditeValue = input.humidite !== undefined ? input.humidite : input.humudite;
    
    const missingFields = [];
    for (const field of required) {
      let value = input[field];
      if (field === 'humudite') {
        value = humiditeValue;
      }
      if (value === undefined || value === '') {
        missingFields.push(field === 'humudite' ? 'humidite' : field);
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
    const humidite = parseFloat(humiditeValue);
    const eau = parseFloat(input.eau);
    
    // Récupération du mode_culture (optionnel, défaut plein_air)
    const mode_culture = input.mode_culture === 'serre' ? 'serre' : 'plein_air';

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

    // Normalisation du type de culture pour la recherche
    const typeCultureNormalise = input.typeCulture === 'serre' ? 'serre' : 'plein_air';

    // Recherche de la culture
    const cultureDoc = await Culture.findOne({ 
      nom: { $regex: new RegExp(`^${input.culture}$`, 'i') },
      types: { $in: [typeCultureNormalise] } 
    });

    if (!cultureDoc) {
      return res.status(404).json({ 
        success: false,
        message: `Fiche culture "${input.culture}" (type: ${input.typeCulture}) non trouvée` 
      });
    }

    console.log("📊 Début analyse - Culture:", cultureDoc.nom);
    console.log("📍 Zone:", input.zone, "Saison:", input.saison);
    console.log("🏠 Mode culture:", mode_culture);
    console.log("📈 Paramètres:", { temperature, humidite, sol: input.sol, eau });

    // Préparation des données pour l'analyse
    const analysisData = {
      temperature,
      humidite,
      sol: input.sol,
      eau,
      zone: input.zone,
      saison: input.saison,
      mode_culture: mode_culture
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
      mode_culture: mode_culture,
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
    console.log("👤 USER:", req.user);
    console.log("🆔 USER ID:", req.user?.id);
    // Sauvegarde de l'historique
    try {
      await Analyse.create({
  userId: req.user.id,

  culture: response.culture,
  typeCulture: response.typeCulture,
  mode_culture: mode_culture,

  temperature: analysisData.temperature,
  humidite: analysisData.humidite,
  sol: analysisData.sol,
  eau: analysisData.eau,
  zone: analysisData.zone,
  saison: analysisData.saison,

  score: response.score,

  // ✅ IMPORTANT
  statut: 'pending',

  recommandations: response.recommandations,

  variete: response.variete?.nom || null
});
      console.log('💾 Analyse sauvegardée dans la base');
    } catch (err) {
      console.error("❌ ERREUR SAUVEGARDE ANALYSE:");
      console.error(err);
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
      saison_optimale: 'juin-septembre',
      varietes: [
        {
          nom: 'Souna 3',
          resistance_secheresse: true,
          saison_recommandee: 'hivernage',
          cycle_vegetatif: '85 jours',
          rendement_moyen: 1.5,
          prix_semence: 1000
        }
      ]
    };

    const testInput = {
      temperature: 30,
      humidite: 60,
      sol: 'sableux',
      eau: 40,
      zone: 'Nord',
      saison: 'hivernage',
      mode_culture: 'plein_air'
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