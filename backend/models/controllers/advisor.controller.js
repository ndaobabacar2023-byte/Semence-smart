const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');
const advisorService = require('../services/advisor.service');

exports.analyse = async (req, res) => {
  try {
    const input = req.body;

    const required = ['culture', 'typeCulture', 'temperature', 'humidite', 'sol', 'zone', 'saison', 'eau'];
    for (const field of required) {
      if (input[field] === undefined || input[field] === '') 
        return res.status(400).json({ message: `${field} manquant ou vide` });
    }

    const temperature = Number(input.temperature || 0);
    const humidite = Number(input.humidite || 0);
    const eau = Number(input.eau || 0);

    const cultureDoc = await Culture.findOne({ 
      nom: input.culture, 
      types: { $in: [input.typeCulture] } 
    });

    if (!cultureDoc) return res.status(404).json({ message: 'Fiche culture non trouvée' });

    console.log("INPUT SECURISÉ:", { temperature, humidite, eau });
    console.log("CULTURE DOC:", cultureDoc);

    const evaluation = advisorService.evaluateConditions(
      { ...input, temperature, humidite, eau },
      cultureDoc
    );

    let fournisseurs = await Fournisseur.find({ zones: input.zone });
    if (!fournisseurs || fournisseurs.length === 0) fournisseurs = await Fournisseur.find().limit(3);

    res.json({
      culture: cultureDoc.nom,
      typeCulture: input.typeCulture,
      status: evaluation.status,
      score: evaluation.score,
      message: evaluation.message,
      variete: evaluation.bestVariete,
      recommandations: evaluation.recommandations,
      fournisseurs
    });

  } catch (err) {
    console.error("ERREUR ANALYSE:", err);
    res.status(500).json({ message: 'Erreur serveur', error: err.message, stack: err.stack });
  }
};
