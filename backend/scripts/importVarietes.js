/**
 * Script d'import des variétés de semences depuis un fichier CSV
 * Usage: node scripts/importVarietes.js
 */

const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const mongoose = require('mongoose');
require('dotenv').config();

// Configuration
const CSV_PATH = path.join(__dirname, '../data/semences.csv');
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/agriadvisor';

// Importer le modèle
const Culture = require('../models/Culture');

// Mapping des cultures vers leurs configurations par défaut
const CULTURE_CONFIG = {
  Mil: {
    types: ['plein_air'],
    temp_min: 25,
    temp_max: 35,
    humidite_min: 40,
    humidite_max: 70,
    sols_recommandes: ['sableux', 'limoneux'],
    besoin_eau: 'faible',
    saison_optimale: 'juin-septembre',
    zone_adaptation: ['Nord', 'Centre', 'Vallée'],
    difficulte: 'facile',
    marche_local: 'forte demande',
    recommandations_generales: [
      'Semer en ligne avec un écartement de 80x40 cm',
      'Apporter du NPK 15-15-15 à 100 kg/ha au semis',
      'Sarcler régulièrement les 30 premiers jours'
    ]
  },
  Arachide: {
    types: ['plein_air'],
    temp_min: 24,
    temp_max: 30,
    humidite_min: 50,
    humidite_max: 75,
    sols_recommandes: ['sableux', 'limoneux'],
    besoin_eau: 'moyen',
    saison_optimale: 'juin-septembre',
    zone_adaptation: ['Centre', 'Sud', 'Littoral'],
    difficulte: 'facile',
    marche_local: 'forte demande',
    recommandations_generales: [
      'Traiter les semences avec un fongicide avant semis',
      'Rotation culturale de 3 ans minimum',
      'Apporter du 6-20-10 à 150 kg/ha'
    ]
  },
  Tomate: {
    types: ['serre', 'plein_air'],
    temp_min: 20,
    temp_max: 28,
    humidite_min: 60,
    humidite_max: 80,
    sols_recommandes: ['limoneux', 'argileux'],
    besoin_eau: 'élevé',
    saison_optimale: 'octobre-mai',
    zone_adaptation: ['Littoral', 'Centre', 'Sud'],
    difficulte: 'moyen',
    marche_local: 'forte demande',
    recommandations_generales: [
      'Tuteurer les plants dès la plantation',
      'Traiter préventivement contre le mildiou tous les 10-15 jours',
      'Pailler pour maintenir l\'humidité'
    ]
  },
  Poivron: {
    types: ['serre', 'plein_air'],
    temp_min: 18,
    temp_max: 27,
    humidite_min: 65,
    humidite_max: 85,
    sols_recommandes: ['limoneux', 'argileux'],
    besoin_eau: 'élevé',
    saison_optimale: 'octobre-mai',
    zone_adaptation: ['Littoral', 'Centre'],
    difficulte: 'moyen',
    marche_local: 'demande moyenne',
    recommandations_generales: [
      'Espacement de 50x40 cm',
      'Apporter du compost à la plantation',
      'Surveiller les pucerons régulièrement'
    ]
  },
  Laitue: {
    types: ['serre', 'plein_air'],
    temp_min: 15,
    temp_max: 24,
    humidite_min: 60,
    humidite_max: 80,
    sols_recommandes: ['limoneux', 'sableux'],
    besoin_eau: 'élevé',
    saison_optimale: 'octobre-mai',
    zone_adaptation: ['Littoral', 'Centre'],
    difficulte: 'facile',
    marche_local: 'forte demande',
    recommandations_generales: [
      'Semis en pépinière puis repiquage à 30x30 cm',
      'Arroser régulièrement sans excès',
      'Récolter tôt le matin pour meilleure conservation'
    ]
  }
};

/**
 * Convertit une valeur "Oui/Non" en booléen
 */
function toBoolean(value) {
  return value === 'Oui' || value === 'true' || value === 'TRUE' || value === '1';
}

/**
 * Normalise le nom de la zone
 */
function normalizeZone(zone) {
  const zoneMap = {
    'Nord': 'Nord',
    'Vallee du Fleuve': 'Vallée',
    'Vallée du Fleuve': 'Vallée',
    'Centre': 'Centre',
    'Sud': 'Sud',
    'Littoral': 'Littoral'
  };
  return zoneMap[zone] || zone;
}

/**
 * Fonction principale d'import
 */
async function importVarieties() {
  console.log('🚀 Démarrage de l\'import des variétés...\n');

  try {
    // 1. Connexion à MongoDB
    console.log('📦 Connexion à MongoDB...');
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connecté avec succès\n');

    // 2. Lecture du fichier CSV
    console.log(`📂 Lecture du fichier: ${CSV_PATH}`);
    const varieties = [];

    await new Promise((resolve, reject) => {
      fs.createReadStream(CSV_PATH)
        .pipe(csv())
        .on('data', (row) => {
          // Convertir les zones en tableau
          const zones = row.zone_adaptation
            .split(',')
            .map(z => normalizeZone(z.trim()))
            .filter(z => z);

          // Créer l'objet variété selon le schéma
          const variete = {
            nom: row.nom_variete,
            description: row.description || `Variété de ${row.culture}`,
            temp_min: parseFloat(row.temperature_min),
            temp_max: parseFloat(row.temperature_max),
            cycle_vegetatif: parseInt(row.cycle_jours),
            resistance_secheresse: toBoolean(row.resistance_secheresse),
            eau_min: row.besoin_eau === 'Faible' ? 10 : (row.besoin_eau === 'Moyen' ? 30 : 50),
            eau_max: row.besoin_eau === 'Faible' ? 30 : (row.besoin_eau === 'Moyen' ? 60 : 80),
            saison_recommandee: row.culture === 'Mil' || row.culture === 'Arachide' ? 'hivernage' : 'saison sèche',
            prix_semence: parseInt(row.prix_kg_fcfa) || null,
            sols_recommandes: CULTURE_CONFIG[row.culture]?.sols_recommandes || ['sableux', 'limoneux']
          };

          varieties.push({
            culture: row.culture,
            zones: zones,
            variete: variete
          });
        })
        .on('end', resolve)
        .on('error', reject);
    });

    console.log(`📊 ${varieties.length} variétés trouvées dans le CSV\n`);

    // 3. Grouper par culture
    const cultureMap = new Map();
    for (const item of varieties) {
      if (!cultureMap.has(item.culture)) {
        cultureMap.set(item.culture, []);
      }
      cultureMap.get(item.culture).push(item);
    }

    console.log(`🎯 ${cultureMap.size} cultures à traiter\n`);

    // 4. Importer/Mettre à jour chaque culture
    for (const [cultureName, items] of cultureMap) {
      console.log(`📝 Traitement de: ${cultureName}`);

      const config = CULTURE_CONFIG[cultureName];
      if (!config) {
        console.warn(`⚠️  Configuration manquante pour ${cultureName}, création avec valeurs par défaut\n`);
      }

      const varietes = items.map(item => item.variete);

      // Vérifier si la culture existe déjà
      let culture = await Culture.findOne({ nom: cultureName });

      if (culture) {
        // Mise à jour : ajouter les nouvelles variétés sans dupliquer
        for (const nouvelleVariete of varietes) {
          const existe = culture.varietes.some(v => v.nom === nouvelleVariete.nom);
          if (!existe) {
            culture.varietes.push(nouvelleVariete);
          }
        }
        await culture.save();
        console.log(`   ✅ Mise à jour: ${culture.varietes.length} variétés`);
      } else {
        // Création d'une nouvelle culture
        culture = new Culture({
          nom: cultureName,
          nom_local: cultureName,
          types: config.types,
          temp_min: config.temp_min,
          temp_max: config.temp_max,
          humidite_min: config.humidite_min,
          humidite_max: config.humidite_max,
          sols_recommandes: config.sols_recommandes,
          besoin_eau: config.besoin_eau,
          saison_optimale: config.saison_optimale,
          zone_adaptation: config.zone_adaptation,
          difficulte: config.difficulte,
          marche_local: config.marche_local,
          recommandations_generales: config.recommandations_generales,
          varietes: varietes
        });
        await culture.save();
        console.log(`   ✅ Création: ${varietes.length} variétés`);
      }
    }

    // 5. Résumé final
    console.log('\n' + '='.repeat(50));
    console.log('📊 RÉSUMÉ FINAL');
    console.log('='.repeat(50));

    const allCultures = await Culture.find();
    for (const culture of allCultures) {
      console.log(`\n🌾 ${culture.nom} (${culture.types.join(', ')})`);
      console.log(`   📍 Zones: ${culture.zone_adaptation?.join(', ') || 'Toutes'}`);
      console.log(`   🌡️  Température: ${culture.temp_min}°C - ${culture.temp_max}°C`);
      console.log(`   💧 Besoin eau: ${culture.besoin_eau}`);
      console.log(`   🌱 Variétés: ${culture.varietes.length}`);
      for (const v of culture.varietes) {
        console.log(`      - ${v.nom} (${v.cycle_vegetatif} jours) - ${v.prix_semence ? v.prix_semence + ' FCFA/kg' : 'Prix non spécifié'}`);
      }
    }

    console.log('\n' + '='.repeat(50));
    console.log('✅ Import terminé avec succès !');
    console.log('='.repeat(50));

  } catch (error) {
    console.error('\n❌ ERREUR:', error.message);
    console.error(error.stack);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Déconnecté de MongoDB');
  }
}

// Exécution du script
importVarieties();