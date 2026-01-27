// services/advisor.service.js - Service d'analyse adapté au climat sénégalais

// Pondérations par défaut
const DEFAULT_WEIGHTS = {
  temperature: 0.30,
  humidite: 0.25,
  sol: 0.20,
  eau: 0.15,
  saison: 0.10
};

// Zones climatiques du Sénégal avec caractéristiques
const ZONES_SENEGAL = {
  'Nord': { 
    temp_moyenne: 28, 
    pluviometrie: 300, 
    sols_dominants: ['sableux', 'lateritique'],
    description: 'Zone sahélienne, climat sec et chaud'
  },
  'Centre': { 
    temp_moyenne: 26, 
    pluviometrie: 500, 
    sols_dominants: ['limoneux', 'sableux'],
    description: 'Zone soudano-sahélienne, climat intermédiaire'
  },
  'Sud': { 
    temp_moyenne: 24, 
    pluviometrie: 800, 
    sols_dominants: ['argileux', 'limoneux'],
    description: 'Zone soudanienne, climat plus humide'
  },
  'Vallée': { 
    temp_moyenne: 27, 
    pluviometrie: 600, 
    sols_dominants: ['argileux', 'tourbeux'],
    description: 'Vallée du fleuve Sénégal, sols alluviaux'
  },
  'Littoral': { 
    temp_moyenne: 25, 
    pluviometrie: 400, 
    sols_dominants: ['sableux', 'limoneux'],
    description: 'Bande côtière, influence maritime'
  }
};

// Saisons au Sénégal
const SAISONS_SENEGAL = {
  'hivernage': { 
    mois: ['juin', 'juillet', 'août', 'septembre'], 
    caracteristiques: 'saison des pluies, humidité élevée',
    periode: 'Juin à Septembre'
  },
  'saison sèche': { 
    mois: ['octobre', 'novembre', 'décembre', 'janvier', 'février', 'mars', 'avril', 'mai'], 
    caracteristiques: 'sèche, harmattan possible',
    periode: 'Octobre à Mai'
  },
  'contre-saison': { 
    mois: ['novembre', 'décembre', 'janvier', 'février'], 
    caracteristiques: 'irrigation nécessaire, températures douces',
    periode: 'Novembre à Février'
  }
};

// Types de sols reconnus au Sénégal
const TYPES_SOL = {
  'sableux': 'Drainant, pauvre en nutriments',
  'argileux': 'Rétenteur d\'eau, riche en nutriments',
  'limoneux': 'Équilibre eau/air, fertile',
  'lateritique': 'Acide, pauvre en matière organique',
  'tourbeux': 'Riche en matière organique, acide'
};

// ==================== FONCTIONS UTILITAIRES ====================

// Normalisation de texte
function normalizeText(text) {
  if (!text) return '';
  return text.toString().toLowerCase().trim();
}

// Validation des données d'entrée
function validateInput(input) {
  const defaults = {
    temperature: 25,
    humidite: 50,
    sol: 'limoneux',
    eau: 25,
    zone: 'Centre',
    saison: 'hivernage'
  };
  
  const validated = { ...defaults, ...input };
  
  // Conversion des nombres
  validated.temperature = Number(validated.temperature) || defaults.temperature;
  validated.humidite = Number(validated.humidite) || defaults.humidite;
  validated.eau = Number(validated.eau) || defaults.eau;
  
  // Limites physiques
  validated.temperature = Math.max(10, Math.min(45, validated.temperature));
  validated.humidite = Math.max(10, Math.min(100, validated.humidite));
  validated.eau = Math.max(0, Math.min(100, validated.eau));
  
  // Validation de la zone
  const zonesValides = Object.keys(ZONES_SENEGAL);
  if (!zonesValides.includes(validated.zone)) {
    validated.zone = 'Centre';
  }
  
  // Validation de la saison
  const saisonsValides = Object.keys(SAISONS_SENEGAL);
  const saisonNormalisee = normalizeText(validated.saison);
  let saisonTrouvee = false;
  
  for (const saison of saisonsValides) {
    if (saisonNormalisee.includes(saison) || saison.includes(saisonNormalisee)) {
      validated.saison = saison;
      saisonTrouvee = true;
      break;
    }
  }
  
  if (!saisonTrouvee) {
    validated.saison = 'hivernage';
  }
  
  // Validation du type de sol
  const solsValides = Object.keys(TYPES_SOL);
  const solNormalise = normalizeText(validated.sol);
  let solTrouve = false;
  
  for (const sol of solsValides) {
    if (solNormalise.includes(sol) || sol.includes(solNormalise)) {
      validated.sol = sol;
      solTrouve = true;
      break;
    }
  }
  
  if (!solTrouve) {
    validated.sol = 'limoneux';
  }
  
  return validated;
}

// ==================== FONCTIONS DE COMPARAISON ====================

// Comparaison température adaptée au Sénégal
function compareTemperature(val, min, max, zone) {
  if (!min || !max) return 50;
  
  const valNum = Number(val);
  const minNum = Number(min);
  const maxNum = Number(max);
  
  if (isNaN(valNum) || isNaN(minNum) || isNaN(maxNum)) return 50;
  
  // Ajustement selon la zone
  const zoneInfo = ZONES_SENEGAL[zone] || ZONES_SENEGAL['Centre'];
  const tempMoyenneZone = zoneInfo.temp_moyenne;
  
  // Tolérance plus large pour les zones chaudes
  const tolerance = zone.includes('Nord') ? 5 : 3;
  
  if (valNum >= minNum && valNum <= maxNum) return 100;
  
  const diff = valNum < minNum ? minNum - valNum : valNum - maxNum;
  
  if (diff <= tolerance) return 70;
  if (diff <= tolerance * 2) return 40;
  return 10;
}

// Comparaison humidité adaptée au Sénégal
function compareHumidite(val, min, max, saison) {
  if (!min || !max) return 50;
  
  const valNum = Number(val);
  const minNum = Number(min);
  const maxNum = Number(max);
  
  if (isNaN(valNum) || isNaN(minNum) || isNaN(maxNum)) return 50;
  
  // Ajustement selon la saison
  const tolerance = saison === 'hivernage' ? 15 : 10;
  
  if (valNum >= minNum && valNum <= maxNum) return 100;
  
  const diff = valNum < minNum ? minNum - valNum : valNum - maxNum;
  
  if (diff <= tolerance) return 65;
  if (diff <= tolerance * 2) return 30;
  return 5;
}

// Comparaison sol adaptée aux sols sénégalais
function compareSol(inputSol, solsRecommandes, zone) {
  if (!inputSol || !solsRecommandes || !Array.isArray(solsRecommandes) || solsRecommandes.length === 0) {
    return 50;
  }
  
  const normalizedInput = normalizeText(inputSol);
  const matches = solsRecommandes.map(s => normalizeText(s));
  
  // Sols dominants de la zone
  const zoneSols = (ZONES_SENEGAL[zone]?.sols_dominants || []).map(s => normalizeText(s));
  
  if (matches.includes(normalizedInput)) {
    // Bonus si le sol est aussi dominant dans la zone
    if (zoneSols.includes(normalizedInput)) {
      return 100;
    }
    return 90;
  }
  
  // Vérification partielle
  for (const s of matches) {
    if (s.includes(normalizedInput) || normalizedInput.includes(s)) return 60;
  }
  
  // Vérification avec les sols de la zone
  for (const s of zoneSols) {
    if (s.includes(normalizedInput) || normalizedInput.includes(s)) return 40;
  }
  
  return 20;
}

// Comparaison eau adaptée au Sénégal
function compareEau(val, saison, cultureBesoinEau) {
  const valNum = Number(val);
  if (isNaN(valNum) || valNum === 0) return 50;
  
  // Correction de la faute de frappe : cultureBesoinEai → cultureBesoinEau
  const besoinMultiplicateur = {
    'faible': 0.7,
    'moyen': 1.0,
    'élevé': 1.3
  }[cultureBesoinEau] || 1.0;
  
  // Pluviométrie moyenne selon la saison (mm/semaine)
  const pluviometrieSaison = {
    'hivernage': 50,
    'saison sèche': 10,
    'contre-saison': 30
  }[saison] || 25;
  
  const besoinOptimal = pluviometrieSaison * besoinMultiplicateur;
  
  if (valNum >= besoinOptimal * 0.8 && valNum <= besoinOptimal * 1.2) return 100;
  if (valNum >= besoinOptimal * 0.6 && valNum <= besoinOptimal * 1.4) return 70;
  if (valNum >= besoinOptimal * 0.4 && valNum <= besoinOptimal * 1.6) return 40;
  return 10;
}

// Comparaison saison adaptée au Sénégal
function compareSaison(inputSaison, cultureDoc) {
  if (!inputSaison) return 50;
  
  const s = normalizeText(inputSaison);
  
  // Vérifier dans les recommandations générales
  const recommandations = cultureDoc.recommandations_generales || [];
  const foundInRecommandations = recommandations.some(r => {
    if (!r) return false;
    return normalizeText(r).includes(s) || s.includes(normalizeText(r));
  });
  
  // Vérifier la saison optimale de la culture
  const saisonOptimale = cultureDoc.saison_optimale || '';
  const isSaisonOptimale = normalizeText(saisonOptimale).includes(s);
  
  if (foundInRecommandations || isSaisonOptimale) return 100;
  
  // Vérifier dans les variétés
  const varietes = cultureDoc.varietes || [];
  const foundInVarietes = varietes.some(v => {
    const saisonVariete = v.saison_recommandee || '';
    return normalizeText(saisonVariete).includes(s);
  });
  
  return foundInVarietes ? 80 : 40;
}

// ==================== FONCTIONS DE CALCUL ====================

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

// Détermination du statut global
function statusFromScore(score) {
  if (score >= 80) return 'excellent';
  if (score >= 65) return 'bon';
  if (score >= 50) return 'moyen';
  if (score >= 35) return 'défavorable';
  return 'critique';
}

// Sélection de la meilleure variété pour le Sénégal
function bestVariete(cultureDoc, input) {
  const varietes = cultureDoc.varietes || [];
  if (!varietes.length) return null;

  const WEIGHTS = { 
    temperature: 0.35, 
    humidite: 0.25, 
    sol: 0.20,
    saison: 0.20 
  };
  
  let best = varietes[0];
  let bestScore = 0;

  for (const v of varietes) {
    let score = 0;
    
    try {
      // Température
      const tempMin = v.temp_min || cultureDoc.temp_min || 20;
      const tempMax = v.temp_max || cultureDoc.temp_max || 35;
      score += compareTemperature(
        input.temperature || 25, 
        tempMin, 
        tempMax, 
        input.zone || 'Centre'
      ) * WEIGHTS.temperature;
      
      // Humidité
      const humiditeMin = v.humidite_min || cultureDoc.humidite_min || 40;
      const humiditeMax = v.humidite_max || cultureDoc.humidite_max || 80;
      score += compareHumidite(
        input.humidite || 50, 
        humiditeMin, 
        humiditeMax, 
        input.saison || 'saison sèche'
      ) * WEIGHTS.humidite;
      
      // Sol
      const solsVariete = v.sols_recommandes || cultureDoc.sols_recommandes || [];
      score += compareSol(
        input.sol || 'limoneux', 
        solsVariete, 
        input.zone || 'Centre'
      ) * WEIGHTS.sol;
      
      // Saison
      const saisonVariete = v.saison_recommandee || '';
      const inputSaison = input.saison || '';
      if (saisonVariete.toLowerCase().includes(inputSaison.toLowerCase())) {
        score += 100 * WEIGHTS.saison;
      } else {
        score += 40 * WEIGHTS.saison;
      }

      // Bonus pour résistance à la sécheresse (important au Sénégal)
      if (v.resistance_secheresse) {
        score += 15;
      }

      // Bonus si variété adaptée à la zone
      if (v.nom && input.zone && v.nom.toLowerCase().includes(input.zone.substring(0, 3).toLowerCase())) {
        score += 10;
      }

      if (score > bestScore) {
        bestScore = score;
        best = v;
      }
    } catch (error) {
      console.error('Erreur évaluation variété:', v.nom, error);
      continue;
    }
  }

  return { 
    variete: best, 
    score: Math.round(bestScore),
    totalVarietes: varietes.length 
  };
}

// Génération de recommandations adaptées au Sénégal
function generateRecommandations(subscores, input, cultureDoc, bestVariete) {
  const rec = [];
  const zoneInfo = ZONES_SENEGAL[input.zone] || ZONES_SENEGAL['Centre'];
  
  // Température
  if (subscores.temperature < 60) {
    if (input.temperature < (cultureDoc.temp_min || 20)) {
      rec.push(`🌡️ Température trop basse (${input.temperature}°C). Protéger les plants la nuit avec des couvertures.`);
    } else {
      rec.push(`🌡️ Température trop élevée (${input.temperature}°C). Ombrer les plants et augmenter l'arrosage matinal.`);
    }
  }
  
  // Humidité
  if (subscores.humidite < 60) {
    if (input.saison === 'hivernage') {
      rec.push(`💧 Humidité insuffisante (${input.humidite}%) pour l'hivernage. Vérifier le drainage et réduire l'irrigation.`);
    } else {
      rec.push(`💧 Humidité faible (${input.humidite}%). Augmenter la fréquence d'arrosage et utiliser du paillage.`);
    }
  }
  
  // Sol
  if (subscores.sol < 60) {
    const solsRecommandes = cultureDoc.sols_recommandes || [];
    const typeSolActuel = TYPES_SOL[input.sol] || 'Non spécifié';
    
    if (solsRecommandes.includes('argileux')) {
      rec.push(`🌍 Sol "${input.sol}" (${typeSolActuel}) non optimal. Amender avec du sable et du compost pour améliorer le drainage.`);
    } else if (solsRecommandes.includes('sableux')) {
      rec.push(`🌍 Sol "${input.sol}" (${typeSolActuel}) non optimal. Ajouter de l'argile et de la matière organique pour retenir l'eau.`);
    } else {
      rec.push(`🌍 Sol "${input.sol}" (${typeSolActuel}) non optimal. Amender avec du compost et des engrais organiques.`);
    }
  }
  
  // Eau
  if (subscores.eau < 60) {
    if (input.eau < 20) {
      rec.push(`💦 Irrigation insuffisante (${input.eau} mm/semaine). Installer un système goutte-à-goutte pour économiser l'eau.`);
    } else {
      rec.push(`💦 Excès d'eau (${input.eau} mm/semaine). Améliorer le drainage avec des sillons ou des canaux.`);
    }
  }
  
  // Saison
  if (subscores.saison < 60) {
    rec.push(`📅 Saison "${input.saison}" non optimale. Préférer "${cultureDoc.saison_optimale || 'juin-septembre'}" pour de meilleurs résultats.`);
  }
  
  // Recommandations spécifiques au Sénégal
  if (input.zone === 'Nord') {
    rec.push(`📍 Zone Nord (${zoneInfo.description}): Privilégier les cultures résistantes à la sécheresse comme le mil ou le sorgho.`);
  }
  
  if (input.zone === 'Sud') {
    rec.push(`📍 Zone Sud (${zoneInfo.description}): Attention aux maladies fongiques en période humide. Utiliser des variétés résistantes.`);
  }
  
  if (input.saison === 'hivernage') {
    rec.push(`☔ Hivernage: Planifier les semis après les premières pluies bien établies.`);
  }
  
  if (input.saison === 'saison sèche') {
    rec.push(`🌵 Saison sèche: Irrigation indispensable. Utiliser du paillage pour conserver l'humidité.`);
  }
  
  if (bestVariete && bestVariete.resistance_secheresse) {
    rec.push(`✅ Variété "${bestVariete.nom}" fortement recommandée pour sa résistance à la sécheresse.`);
  }
  
  // Recommandations générales selon le score
  const scoreTotal = computeWeightedScore(subscores);
  if (scoreTotal >= 80) {
    rec.push('🎉 Conditions optimales ! Maintenir les bonnes pratiques culturales.');
  } else if (scoreTotal >= 50) {
    rec.push('📋 Suivre les recommandations ci-dessus pour améliorer les rendements.');
  } else {
    rec.push('⚠️ Conditions difficiles. Considérer une culture alternative mieux adaptée.');
  }
  
  if (rec.length === 0) {
    rec.push('🎉 Conditions optimales pour la culture !');
    rec.push('Suivre les pratiques culturales habituelles recommandées pour la région.');
  }
  
  return rec;
}

// ==================== FONCTION PRINCIPALE ====================

// Fonction principale d'évaluation adaptée au Sénégal
function evaluateConditions(input, cultureDoc, weights = DEFAULT_WEIGHTS) {
  try {
    console.log('🔍 Début évaluation conditions Sénégal...');
    
    // Valider les données d'entrée
    const validatedInput = validateInput(input);
    console.log('Données validées:', validatedInput);
    console.log('Culture:', cultureDoc.nom || 'Culture non nommée');
    
    // S'assurer que cultureDoc a les propriétés nécessaires
    const safeCultureDoc = {
      nom: cultureDoc.nom || 'Culture',
      description: cultureDoc.description || '',
      temp_min: cultureDoc.temp_min || 20,
      temp_max: cultureDoc.temp_max || 35,
      humidite_min: cultureDoc.humidite_min || 40,
      humidite_max: cultureDoc.humidite_max || 80,
      sols_recommandes: cultureDoc.sols_recommandes || ['limoneux', 'sableux'],
      besoin_eau: cultureDoc.besoin_eau || 'moyen',
      saison_optimale: cultureDoc.saison_optimale || 'hivernage',
      recommandations_generales: cultureDoc.recommandations_generales || [],
      varietes: cultureDoc.varietes || [],
      cycle_moyen: cultureDoc.cycle_moyen || '90-120 jours',
      rendement_moyen: cultureDoc.rendement_moyen || 'Non spécifié'
    };
    
    const subscores = {};
    
    // Calculer chaque sous-score avec gestion des erreurs
    try {
      subscores.temperature = compareTemperature(
        validatedInput.temperature, 
        safeCultureDoc.temp_min, 
        safeCultureDoc.temp_max,
        validatedInput.zone
      );
    } catch (e) {
      subscores.temperature = 50;
      console.error('Erreur calcul température:', e);
    }
    
    try {
      subscores.humidite = compareHumidite(
        validatedInput.humidite, 
        safeCultureDoc.humidite_min, 
        safeCultureDoc.humidite_max,
        validatedInput.saison
      );
    } catch (e) {
      subscores.humidite = 50;
      console.error('Erreur calcul humidité:', e);
    }
    
    try {
      subscores.sol = compareSol(
        validatedInput.sol, 
        safeCultureDoc.sols_recommandes,
        validatedInput.zone
      );
    } catch (e) {
      subscores.sol = 50;
      console.error('Erreur calcul sol:', e);
    }
    
    try {
      subscores.eau = compareEau(
        validatedInput.eau, 
        validatedInput.saison,
        safeCultureDoc.besoin_eau
      );
    } catch (e) {
      subscores.eau = 50;
      console.error('Erreur calcul eau:', e);
    }
    
    try {
      subscores.saison = compareSaison(validatedInput.saison, safeCultureDoc);
    } catch (e) {
      subscores.saison = 50;
      console.error('Erreur calcul saison:', e);
    }
    
    console.log('Sous-scores calculés:', subscores);
    
    const score = computeWeightedScore(subscores, weights);
    const status = statusFromScore(score);
    const varieteResult = bestVariete(safeCultureDoc, validatedInput);
    const recommandations = generateRecommandations(
      subscores, 
      validatedInput, 
      safeCultureDoc, 
      varieteResult?.variete
    );
    
    // Message personnalisé selon le statut
    let message = '';
    let emoji = '';
    
    switch (status) {
      case 'excellent':
        emoji = '✅';
        message = `Conditions parfaites pour ${safeCultureDoc.nom} en zone ${validatedInput.zone} pendant ${validatedInput.saison}.`;
        break;
      case 'bon':
        emoji = '👍';
        message = `Bonnes conditions pour ${safeCultureDoc.nom}. Quelques ajustements recommandés pour optimiser le rendement.`;
        break;
      case 'moyen':
        emoji = '⚠️';
        message = `Conditions acceptables pour ${safeCultureDoc.nom}. Des adaptations importantes sont nécessaires pour réussir la culture.`;
        break;
      case 'défavorable':
        emoji = '❌';
        message = `Conditions difficiles pour ${safeCultureDoc.nom}. Des changements majeurs requis ou envisager une culture alternative.`;
        break;
      default:
        emoji = '🚫';
        message = `Conditions critiques pour ${safeCultureDoc.nom}. Culture non recommandée dans ces conditions actuelles.`;
    }
    
    const result = {
      success: true,
      status,
      score,
      emoji,
      message,
      recommandations,
      subscores: {
        temperature: { score: subscores.temperature, optimal: `entre ${safeCultureDoc.temp_min} et ${safeCultureDoc.temp_max}°C` },
        humidite: { score: subscores.humidite, optimal: `entre ${safeCultureDoc.humidite_min} et ${safeCultureDoc.humidite_max}%` },
        sol: { score: subscores.sol, optimal: safeCultureDoc.sols_recommandes.join(', ') },
        eau: { score: subscores.eau, besoin: safeCultureDoc.besoin_eau },
        saison: { score: subscores.saison, optimale: safeCultureDoc.saison_optimale }
      },
      bestVariete: varieteResult?.variete ? {
        nom: varieteResult.variete.nom,
        description: varieteResult.variete.description || safeCultureDoc.description,
        temperature: { 
          min: varieteResult.variete.temp_min || safeCultureDoc.temp_min, 
          max: varieteResult.variete.temp_max || safeCultureDoc.temp_max 
        },
        humidite: { 
          min: varieteResult.variete.humidite_min || safeCultureDoc.humidite_min, 
          max: varieteResult.variete.humidite_max || safeCultureDoc.humidite_max 
        },
        sols: varieteResult.variete.sols_recommandes || safeCultureDoc.sols_recommandes,
        resistance_secheresse: varieteResult.variete.resistance_secheresse || false,
        cycle_vegetatif: varieteResult.variete.cycle_vegetatif || safeCultureDoc.cycle_moyen,
        rendement_estime: varieteResult.variete.rendement_estime || safeCultureDoc.rendement_moyen,
        score_variete: varieteResult.score,
        varietes_disponibles: varieteResult.totalVarietes
      } : null,
      metadata: {
        zone: validatedInput.zone,
        zone_info: ZONES_SENEGAL[validatedInput.zone],
        saison: validatedInput.saison,
        saison_info: SAISONS_SENEGAL[validatedInput.saison],
        culture: safeCultureDoc.nom,
        date_evaluation: new Date().toISOString(),
        version_service: '1.0.0'
      }
    };
    
    console.log('✅ Évaluation terminée - Score:', score, 'Statut:', status);
    
    return result;
    
  } catch (error) {
    console.error('❌ Erreur lors de l\'évaluation:', error);
    return {
      success: false,
      error: error.message,
      message: 'Erreur lors de l\'analyse des conditions climatiques',
      recommandations: [
        'Vérifier les données d\'entrée',
        'Contacter le support technique si l\'erreur persiste'
      ]
    };
  }
}

// ==================== FONCTIONS D'AIDE ====================

// Obtenir les informations des zones
function getZonesInfo() {
  return ZONES_SENEGAL;
}

// Obtenir les informations des saisons
function getSaisonsInfo() {
  return SAISONS_SENEGAL;
}

// Obtenir les types de sol
function getSolTypes() {
  return TYPES_SOL;
}

// Calcul rapide pour une zone spécifique
function quickAssessment(cultureDoc, zone, saison) {
  const zoneInfo = ZONES_SENEGAL[zone] || ZONES_SENEGAL['Centre'];
  const saisonInfo = SAISONS_SENEGAL[saison] || SAISONS_SENEGAL['hivernage'];
  
  const input = {
    temperature: zoneInfo.temp_moyenne,
    humidite: saison === 'hivernage' ? 75 : 45,
    sol: zoneInfo.sols_dominants[0],
    eau: saisonInfo.pluviometrie || 25,
    zone: zone,
    saison: saison
  };
  
  return evaluateConditions(input, cultureDoc);
}

// ==================== EXPORT ====================

module.exports = {
  evaluateConditions,
  getZonesInfo,
  getSaisonsInfo,
  getSolTypes,
  quickAssessment,
  ZONES_SENEGAL,
  SAISONS_SENEGAL,
  TYPES_SOL,
  DEFAULT_WEIGHTS
};