// Fichier: services/advisor.service.js
// Rôle: évaluation des conditions et recommandation de la meilleure variété

const DEFAULT_WEIGHTS = {
  temperature: 0.35,
  humidite: 0.25,
  sol: 0.2,
  eau: 0.1,
  saison: 0.1
};

// Utilitaire : clamp
function clamp(v, min = 0, max = 100) {
  return Math.max(min, Math.min(max, v));
}

// Comparaison température
function compareTemperature(val, min, max) {
  if (val >= min && val <= max) return 100;
  const diff = val < min ? min - val : val - max;
  if (diff <= 3) return 60;
  if (diff <= 6) return 20;
  return 0;
}

// Comparaison humidité
function compareHumidite(val, min, max) {
  if (val >= min && val <= max) return 100;
  const diff = val < min ? min - val : val - max;
  if (diff <= 10) return 60;
  if (diff <= 20) return 20;
  return 0;
}

// Comparaison sol
function compareSol(inputSol, solsRecommandes) {
  if (!inputSol) return 50;
  const normalized = inputSol.toLowerCase();
  const matches = solsRecommandes.map(s => s.toLowerCase());
  if (matches.includes(normalized)) return 100;
  for (const s of matches) if (s.includes(normalized) || normalized.includes(s)) return 60;
  return 0;
}

// Comparaison eau (mm/semaine)
function compareEau(val) {
  if (!val) return 50;
  if (val >= 20 && val <= 80) return 100;
  if (val >= 10 && val < 20) return 60;
  return 20;
}

// Comparaison saison
function compareSaison(inputSaison, cultureDoc) {
  if (!inputSaison) return 50;
  const s = inputSaison.toLowerCase();
  const found = (cultureDoc.recommandations_generales || []).some(r => r.toLowerCase().includes(s));
  return found ? 100 : 60;
}

// Calcul du score pondéré
function computeWeightedScore(subscores, weights = DEFAULT_WEIGHTS) {
  let score = 0;
  let totalWeight = 0;
  for (const key of Object.keys(weights)) {
    const w = weights[key] || 0;
    const sub = subscores[key] !== undefined ? subscores[key] : 50;
    score += sub * w;
    totalWeight += w;
  }
  return totalWeight === 0 ? Math.round(score) : Math.round(score / totalWeight);
}

// Statut global
function statusFromScore(score) {
  if (score >= 75) return 'bon';
  if (score >= 50) return 'moyen';
  return 'mauvais';
}

// Sélection de la meilleure variété selon critères + résistance sécheresse
function bestVariete(cultureDoc, input) {
  const varietes = cultureDoc.varietes || [];
  if (!varietes.length) return null;

  const WEIGHTS = { temperature: 0.4, humidite: 0.3, sol: 0.3 };
  let best = varietes[0];
  let bestScore = 0;

  for (const v of varietes) {
    let score = 0;
    score += compareTemperature(input.temperature, v.temp_min || cultureDoc.temp_min, v.temp_max || cultureDoc.temp_max) * WEIGHTS.temperature;
    score += compareHumidite(input.humidite, v.humidite_min || cultureDoc.humidite_min, v.humidite_max || cultureDoc.humidite_max) * WEIGHTS.humidite;
    score += compareSol(input.sol, v.sols_compatibles.length ? v.sols_compatibles : cultureDoc.sols_recommandes) * WEIGHTS.sol;

    // Bonus si la variété est résistante à la sécheresse et que l'eau est faible
    if ((input.eau || 0) < 20 && v.resistance_secheresse) score += 10;

    if (score > bestScore) {
      bestScore = score;
      best = v;
    }
  }

  return best;
}

// Génération recommandations
function generateRecommandations(subscores) {
  const rec = [];
  if (subscores.temperature < 60) rec.push('Ajuster la température (protéger / aérer)');
  if (subscores.humidite < 60) rec.push('Adapter l\'irrigation');
  if (subscores.sol < 60) rec.push('Amender le sol (ajouter matière organique)');
  if (subscores.eau < 60) rec.push('Augmenter fréquence d\'arrosage');
  if (subscores.saison < 60) rec.push('Planifier semis selon saison recommandée');
  if (rec.length === 0) rec.push('Conditions favorables — suivre recommandations générales');
  return rec;
}

// Fonction principale
function evaluateConditions(input, cultureDoc, weights = DEFAULT_WEIGHTS) {
  const subscores = {};
  subscores.temperature = compareTemperature(Number(input.temperature), cultureDoc.temp_min, cultureDoc.temp_max);
  subscores.humidite = compareHumidite(Number(input.humidite), cultureDoc.humidite_min, cultureDoc.humidite_max);
  subscores.sol = compareSol(input.sol, cultureDoc.sols_recommandes || []);
  subscores.eau = compareEau(Number(input.eau));
  subscores.saison = compareSaison(input.saison, cultureDoc);

  const score = computeWeightedScore(subscores, weights);
  const status = statusFromScore(score);
  const bestVar = bestVariete(cultureDoc, input);
  const recommandations = generateRecommandations(subscores);

  let message = '';
  if (status === 'bon') message = 'Conditions favorables pour la culture choisie.';
  else if (status === 'moyen') message = 'Conditions mitigées — des ajustements sont recommandés.';
  else message = 'Conditions défavorables — adaptations importantes nécessaires.';

  return {
    status,
    score,
    message,
    recommandations,
    bestVariete: bestVar
  };
}

module.exports = { evaluateConditions };
