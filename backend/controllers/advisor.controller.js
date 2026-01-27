// controllers/advisor.controller.js - VERSION COMPLÈTE
const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');

console.log('✅ advisor.controller.js chargé');

// Données par défaut pour le Sénégal
const ZONES_SENEGAL = {
  'Nord': { temp_moyenne: 28, pluviometrie: 300 },
  'Centre': { temp_moyenne: 26, pluviometrie: 500 },
  'Sud': { temp_moyenne: 24, pluviometrie: 800 },
  'Vallée': { temp_moyenne: 27, pluviometrie: 600 },
  'Littoral': { temp_moyenne: 25, pluviometrie: 400 }
};

exports.analyse = async (req, res) => {
  try {
    console.log('📡 POST /api/advisor/analyse reçu');
    console.log('📥 Données:', req.body);
    
    const { culture, typeCulture, temperature, humidite, sol, zone, saison, eau } = req.body;
    
    // Validation
    if (!culture || !typeCulture) {
      return res.status(400).json({
        success: false,
        message: 'Culture et type de culture sont requis'
      });
    }
    
    // Chercher la culture
    const cultureDoc = await Culture.findOne({ 
      nom: culture,
      types: { $in: [typeCulture] } 
    });
    
    if (!cultureDoc) {
      return res.status(404).json({
        success: false,
        message: `Culture "${culture}" (${typeCulture}) non trouvée`
      });
    }
    
    console.log(`🔍 Analyse pour: ${cultureDoc.nom} en ${zone}`);
    
    // ===== CALCUL DU SCORE =====
    let score = 70; // Score de base
    
    // Ajustements selon température
    const tempMin = cultureDoc.temp_min || 20;
    const tempMax = cultureDoc.temp_max || 30;
    if (temperature >= tempMin && temperature <= tempMax) {
      score += 15;
    } else if (temperature >= tempMin - 5 && temperature <= tempMax + 5) {
      score += 5;
    }
    
    // Ajustements selon humidité
    const humiditeMin = cultureDoc.humidite_min || 50;
    const humiditeMax = cultureDoc.humidite_max || 80;
    if (humidite >= humiditeMin && humidite <= humiditeMax) {
      score += 10;
    }
    
    // Ajustements selon zone
    if (cultureDoc.zone_adaptation && cultureDoc.zone_adaptation.includes(zone)) {
      score += 8;
    }
    
    // Ajustements selon saison
    const saisonOptimale = cultureDoc.saison_optimale || 'hivernage';
    if (saison === saisonOptimale.toLowerCase()) {
      score += 7;
    }
    
    // Limiter à 100
    score = Math.min(Math.max(score, 0), 100);
    
    // ===== DÉTERMINER LE STATUT =====
    let status, message, emoji;
    if (score >= 80) {
      status = 'excellent';
      emoji = '✅';
      message = `Conditions parfaites pour ${culture} en zone ${zone}`;
    } else if (score >= 65) {
      status = 'bon';
      emoji = '👍';
      message = `Bonnes conditions pour ${culture}`;
    } else if (score >= 50) {
      status = 'moyen';
      emoji = '⚠️';
      message = `Conditions acceptables pour ${culture}`;
    } else if (score >= 35) {
      status = 'défavorable';
      emoji = '❌';
      message = `Conditions défavorables pour ${culture}`;
    } else {
      status = 'critique';
      emoji = '🚫';
      message = `Conditions critiques pour ${culture}`;
    }
    
    // ===== CALCUL DES SOUS-SCORES =====
    const sousScores = {
      temperature: {
        score: calculateSubScore(temperature, tempMin, tempMax, 5),
        optimal: `${tempMin}-${tempMax}°C`
      },
      humidite: {
        score: calculateSubScore(humidite, humiditeMin, humiditeMax, 10),
        optimal: `${humiditeMin}-${humiditeMax}%`
      },
      sol: {
        score: cultureDoc.sols_recommandes && cultureDoc.sols_recommandes.includes(sol) ? 90 : 40,
        optimal: (cultureDoc.sols_recommandes || ['limoneux']).join(', ')
      },
      eau: {
        score: calculateWaterScore(eau, saison, cultureDoc.besoin_eau),
        besoin: cultureDoc.besoin_eau || 'moyen'
      },
      saison: {
        score: saison === (cultureDoc.saison_optimale || 'hivernage').toLowerCase() ? 90 : 50,
        optimale: cultureDoc.saison_optimale || 'hivernage'
      }
    };
    
    // ===== VARIÉTÉ RECOMMANDÉE =====
    const variete = {
      nom: getVarieteName(culture, zone),
      description: getVarieteDescription(culture, zone),
      resistance_secheresse: zone === 'Nord' || zone === 'Centre',
      score_variete: score + 8,
      cycle_vegetatif: cultureDoc.cycle_moyen || '90-120 jours'
    };
    
    // ===== RECOMMANDATIONS =====
    const recommandations = generateRecommandations(
      temperature, humidite, sol, zone, saison, eau, 
      cultureDoc, score, sousScores
    );
    
    // ===== FOURNISSEURS =====
    let fournisseurs = [];
    try {
      fournisseurs = await getFournisseurs(zone, culture);
    } catch (err) {
      console.warn('⚠️ Erreur fournisseurs:', err.message);
      fournisseurs = getDefaultFournisseurs(culture);
    }
    
    // ===== RÉPONSE COMPLÈTE =====
    const response = {
      success: true,
      culture: culture,
      typeCulture: typeCulture,
      status: status,
      score: score,
      emoji: emoji,
      message: message,
      variete: variete,
      recommandations: recommandations,
      sousScores: sousScores,
      fournisseurs: fournisseurs,
      metadata: {
        zone: zone,
        saison: saison,
        dateAnalyse: new Date().toISOString(),
        cultureId: cultureDoc._id,
        zoneInfo: ZONES_SENEGAL[zone] || ZONES_SENEGAL['Centre']
      }
    };
    
    console.log(`✅ Analyse terminée - Score: ${score}, Statut: ${status}`);
    res.json(response);
    
  } catch (error) {
    console.error('❌ Erreur analyse:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'analyse',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// ===== FONCTIONS UTILITAIRES =====

function calculateSubScore(value, min, max, tolerance) {
  if (value >= min && value <= max) return 100;
  if (value >= min - tolerance && value <= max + tolerance) return 70;
  if (value >= min - tolerance * 2 && value <= max + tolerance * 2) return 40;
  return 10;
}

function calculateWaterScore(eau, saison, besoin) {
  const besoins = {
    'faible': { hivernage: 30, 'saison sèche': 15, 'contre-saison': 20 },
    'moyen': { hivernage: 50, 'saison sèche': 25, 'contre-saison': 35 },
    'élevé': { hivernage: 70, 'saison sèche': 40, 'contre-saison': 50 }
  };
  
  const besoinType = besoin || 'moyen';
  const optimal = besoins[besoinType]?.[saison] || 30;
  
  if (eau >= optimal * 0.8 && eau <= optimal * 1.2) return 100;
  if (eau >= optimal * 0.6 && eau <= optimal * 1.4) return 70;
  if (eau >= optimal * 0.4 && eau <= optimal * 1.6) return 40;
  return 10;
}

function getVarieteName(culture, zone) {
  const varietes = {
    'Tomate': { Nord: 'Tomate F1 Résistante', Centre: 'Tomate Prima', Sud: 'Tomate Tropica' },
    'Arachide': { Nord: 'Arachide 73-33', Centre: 'Arachide Fleur 11', Sud: 'Arachide 55-437' },
    'Mil': { Nord: 'Mil Souna 3', Centre: 'Mil IBV 8001', Sud: 'Mil Sanio' },
    'Riz': { Nord: 'Riz Sahel 108', Centre: 'Riz IR 841', Sud: 'Riz NERICA' },
    'Maïs': { Nord: 'Maïs EV 8728', Centre: 'Maïs Suwan 1', Sud: 'Maïs DMR-ESR-Y' }
  };
  
  return varietes[culture]?.[zone] || `${culture} Premium`;
}

function getVarieteDescription(culture, zone) {
  const descriptions = {
    'Nord': 'Variété adaptée aux conditions arides et résistante à la sécheresse',
    'Centre': 'Variété à haut rendement pour les zones de savane',
    'Sud': 'Variété adaptée aux zones humides avec résistance aux maladies',
    'Vallée': 'Variété pour sols alluviaux avec bonne tolérance à l\'humidité',
    'Littoral': 'Variété résistante au sel et adaptée aux zones côtières'
  };
  
  return descriptions[zone] || 'Variété adaptée à votre région';
}

function generateRecommandations(temp, humidite, sol, zone, saison, eau, cultureDoc, score, sousScores) {
  const recommandations = [];
  
  // Température
  if (sousScores.temperature.score < 60) {
    if (temp < (cultureDoc.temp_min || 20)) {
      recommandations.push(`🌡️ Température trop basse (${temp}°C). Protéger les plants la nuit.`);
    } else {
      recommandations.push(`🌡️ Température trop élevée (${temp}°C). Ombrer et augmenter l'arrosage.`);
    }
  }
  
  // Humidité
  if (sousScores.humidite.score < 60) {
    if (humidite < (cultureDoc.humidite_min || 50)) {
      recommandations.push(`💧 Humidité insuffisante (${humidite}%). Augmenter l'arrosage.`);
    } else {
      recommandations.push(`💧 Humidité trop élevée (${humidite}%). Améliorer le drainage.`);
    }
  }
  
  // Sol
  if (sousScores.sol.score < 60) {
    recommandations.push(`🌍 Sol "${sol}" non optimal. Amender avec du compost.`);
  }
  
  // Eau
  if (sousScores.eau.score < 60) {
    if (eau < 20) {
      recommandations.push(`💦 Irrigation insuffisante (${eau} mm/semaine). Installer un système goutte-à-goutte.`);
    } else {
      recommandations.push(`💦 Excès d'eau (${eau} mm/semaine). Améliorer le drainage.`);
    }
  }
  
  // Recommandations spécifiques par zone
  if (zone === 'Nord') {
    recommandations.push(`📍 Zone Nord: Privilégier les cultures résistantes à la sécheresse.`);
  }
  
  if (zone === 'Sud') {
    recommandations.push(`📍 Zone Sud: Attention aux maladies fongiques en période humide.`);
  }
  
  if (saison === 'hivernage') {
    recommandations.push(`☔ Hivernage: Planifier les semis après les premières pluies.`);
  }
  
  if (saison === 'saison sèche') {
    recommandations.push(`🌵 Saison sèche: Irrigation indispensable. Utiliser du paillage.`);
  }
  
  // Recommandation générale selon le score
  if (score >= 80) {
    recommandations.push('🎉 Conditions optimales ! Maintenir les bonnes pratiques.');
  } else if (score >= 50) {
    recommandations.push('📋 Suivre les recommandations ci-dessus pour améliorer les rendements.');
  } else {
    recommandations.push('⚠️ Conditions difficiles. Considérer une culture alternative.');
  }
  
  return recommandations;
}

async function getFournisseurs(zone, culture) {
  const fournisseurs = await Fournisseur.find({
    $or: [
      { zones: zone },
      { cultures: culture },
      { zones: 'Toutes zones' }
    ]
  }).limit(3);
  
  if (fournisseurs.length === 0) {
    return getDefaultFournisseurs(culture);
  }
  
  return fournisseurs.map(f => ({
    nom: f.nom || 'Fournisseur Agricole',
    telephone: f.telephone || '+221 77 000 00 00',
    email: f.email || 'contact@agriculture.sn',
    adresse: f.adresse || 'Sénégal',
    specialite: f.specialite || 'Semences et engrais',
    note: f.note || 4.0,
    cultures: f.cultures || [culture]
  }));
}

function getDefaultFournisseurs(culture) {
  return [
    {
      nom: 'AgroSem Sénégal',
      telephone: '+221 77 123 45 67',
      email: 'contact@agrosem.sn',
      adresse: 'Dakar, Sénégal',
      specialite: 'Semences certifiées',
      note: 4.5,
      cultures: [culture, 'Mil', 'Arachide']
    },
    {
      nom: 'BioFarm Dakar',
      telephone: '+221 76 987 65 43',
      email: 'info@biofarm.sn',
      adresse: 'Thiès, Sénégal',
      specialite: 'Engrais biologiques',
      note: 4.2,
      cultures: [culture, 'Tomate', 'Riz']
    },
    {
      nom: 'Green Valley',
      telephone: '+221 70 555 44 33',
      email: 'contact@greenvalley.sn',
      adresse: 'Saint-Louis, Sénégal',
      specialite: 'Irrigation',
      note: 4.0,
      cultures: [culture, 'Maïs', 'Niébé']
    }
  ];
}

// Fonction de test
exports.test = (req, res) => {
  res.json({
    success: true,
    message: 'Service advisor fonctionnel',
    version: '1.0.0',
    structure: {
      analyse: {
        required_fields: ['culture', 'typeCulture', 'temperature', 'humidite', 'sol', 'zone', 'saison', 'eau'],
        response_structure: {
          success: 'boolean',
          culture: 'string',
          typeCulture: 'string',
          status: 'string',
          score: 'number',
          emoji: 'string',
          message: 'string',
          variete: 'object',
          recommandations: 'array',
          sousScores: 'object',
          fournisseurs: 'array',
          metadata: 'object'
        }
      }
    }
  });
};