/**
 * Script d'import final - Version qui fonctionne
 * Usage: node scripts/importVarietesFinal.js
 */

const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
require('dotenv').config();

const CSV_PATH = path.join(__dirname, '../data/semences_senegal_fixed.csv');
const MONGO_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/agriadvisor';

const Culture = require('../models/Culture');

// Mapping des zones
function getZone(zoneFavorable) {
  const zones = [];
  const z = (zoneFavorable || '').toLowerCase();
  if (z.includes('niayes') || z.includes('dakar') || z.includes('thiès') || z.includes('littoral')) zones.push('Littoral');
  if (z.includes('vallée') || z.includes('fleuve')) zones.push('Vallée');
  if (z.includes('sud') || z.includes('ziguinchor') || z.includes('kolda') || z.includes('casamance')) zones.push('Sud');
  if (z.includes('bassin') || z.includes('kaolack') || z.includes('diourbel')) zones.push('Centre');
  if (z.includes('nord') || z.includes('sahel')) zones.push('Nord');
  return zones.length ? zones : ['Toutes zones'];
}

function getSaison(saisonStr) {
  const s = (saisonStr || '').toLowerCase();
  if (s.includes('sèche')) return 'saison sèche';
  if (s.includes('hivernage') || s.includes('pluie')) return 'hivernage';
  return 'saison sèche';
}

function getSols(solStr) {
  const sols = [];
  const s = (solStr || '').toLowerCase();
  if (s.includes('sable')) sols.push('sableux');
  if (s.includes('limon')) sols.push('limoneux');
  if (s.includes('argile')) sols.push('argileux');
  return sols.length ? sols : ['limoneux'];
}

const cultureConfig = {
  tomate: { temp_min: 20, temp_max: 30, humidite_min: 55, humidite_max: 80, besoin_eau: 'élevé' },
  poivron: { temp_min: 18, temp_max: 30, humidite_min: 60, humidite_max: 80, besoin_eau: 'élevé' },
  piment: { temp_min: 20, temp_max: 35, humidite_min: 50, humidite_max: 80, besoin_eau: 'moyen' },
  laitue: { temp_min: 15, temp_max: 24, humidite_min: 60, humidite_max: 80, besoin_eau: 'élevé' },
  chou: { temp_min: 15, temp_max: 22, humidite_min: 60, humidite_max: 85, besoin_eau: 'élevé' },
  carotte: { temp_min: 15, temp_max: 25, humidite_min: 50, humidite_max: 80, besoin_eau: 'moyen' },
  aubergine: { temp_min: 20, temp_max: 35, humidite_min: 50, humidite_max: 80, besoin_eau: 'moyen' },
  oignon: { temp_min: 15, temp_max: 30, humidite_min: 40, humidite_max: 70, besoin_eau: 'moyen' },
  pomme_de_terre: { temp_min: 15, temp_max: 22, humidite_min: 60, humidite_max: 80, besoin_eau: 'élevé' },
  gombo: { temp_min: 25, temp_max: 35, humidite_min: 60, humidite_max: 80, besoin_eau: 'moyen' },
  haricot_vert: { temp_min: 18, temp_max: 32, humidite_min: 50, humidite_max: 80, besoin_eau: 'moyen' },
  niebe: { temp_min: 25, temp_max: 40, humidite_min: 30, humidite_max: 70, besoin_eau: 'faible' },
  mais: { temp_min: 20, temp_max: 35, humidite_min: 40, humidite_max: 80, besoin_eau: 'moyen' },
  riz: { temp_min: 25, temp_max: 38, humidite_min: 60, humidite_max: 90, besoin_eau: 'élevé' },
  sorgho: { temp_min: 25, temp_max: 40, humidite_min: 30, humidite_max: 70, besoin_eau: 'faible' },
  mil: { temp_min: 25, temp_max: 35, humidite_min: 40, humidite_max: 70, besoin_eau: 'faible' },
  arachide: { temp_min: 24, temp_max: 35, humidite_min: 40, humidite_max: 70, besoin_eau: 'moyen' }
};

async function importData() {
  console.log('🚀 Démarrage de l\'import...\n');

  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connecté à MongoDB\n');

    if (!fs.existsSync(CSV_PATH)) {
      console.error(`❌ Fichier non trouvé: ${CSV_PATH}`);
      console.log('\n💡 Exécutez d\'abord: node scripts/fixCsvFormat.js');
      return;
    }

    const content = fs.readFileSync(CSV_PATH, 'utf8');
    const lines = content.split('\n').filter(l => l.trim());
    
    console.log(`📊 ${lines.length} lignes trouvées\n`);
    
    const headers = lines[0].split(',');
    console.log('📋 En-têtes:', headers);
    console.log('');
    
    let totalVarietes = 0;
    let culturesModifiees = 0;
    let erreurs = 0;

    for (let idx = 1; idx < lines.length; idx++) {
      const line = lines[idx];
      if (!line.trim()) continue;
      
      try {
        // Parser la ligne
        const values = [];
        let current = '';
        let inQuotes = false;
        
        for (let i = 0; i < line.length; i++) {
          const char = line[i];
          if (char === '"') {
            inQuotes = !inQuotes;
          } else if (char === ',' && !inQuotes) {
            values.push(current.trim());
            current = '';
          } else {
            current += char;
          }
        }
        values.push(current.trim());
        
        if (values.length < 10) {
          console.log(`⚠️ Ligne ${idx + 1}: ${values.length} colonnes ignorée`);
          continue;
        }
        
        const cultureNom = values[0].toLowerCase();
        const varieteNom = values[1];
        const typeCulture = values[2] || '';
        const modeCulture = values[3] && values[3].toLowerCase().includes('serre') ? 'serre' : 'plein_air';
        const tempMin = parseInt(values[4]) || 20;
        const tempMax = parseInt(values[5]) || 30;
        const humMin = parseInt(values[6]) || 50;
        const humMax = parseInt(values[7]) || 80;
        const typeSol = values[8] || '';
        const saisonStr = values[9] || '';
        const zoneFavorable = values[10] || '';
        const rendement = values[11] ? parseInt(values[11]) : null;
        const cycleJours = values[12] ? parseInt(values[12]) : null;
        const resistanceChaleur = values[13] ? parseInt(values[13]) : 5;
        const resistanceSecheresse = values[14] ? parseInt(values[14]) : 5;
        const prix = values[15] ? parseInt(values[15]) : null;
        
        if (!varieteNom || varieteNom === '') {
          console.log(`⚠️ Ligne ${idx + 1}: Variété sans nom`);
          continue;
        }
        
        console.log(`📝 ${idx + 1}/${lines.length - 1}: ${cultureNom} - ${varieteNom} (${modeCulture})`);
        
        let culture = await Culture.findOne({
          nom: { $regex: new RegExp(`^${cultureNom}$`, 'i') },
          types: modeCulture
        });
        
        const config = cultureConfig[cultureNom] || { temp_min: 20, temp_max: 30, humidite_min: 50, humidite_max: 80, besoin_eau: 'moyen' };
        
        if (!culture) {
          culture = new Culture({
            nom: cultureNom,
            nom_local: cultureNom,
            types: [modeCulture],
            temp_min: config.temp_min,
            temp_max: config.temp_max,
            humidite_min: config.humidite_min,
            humidite_max: config.humidite_max,
            sols_recommandes: getSols(typeSol),
            besoin_eau: config.besoin_eau,
            saison_optimale: 'octobre-mai',
            zone_adaptation: getZone(zoneFavorable),
            difficulte: 'moyen',
            marche_local: 'demande moyenne',
            varietes: []
          });
          culturesModifiees++;
        }
        
        const varieteExiste = culture.varietes.some(v => 
          v.nom && v.nom.toLowerCase() === varieteNom.toLowerCase()
        );
        
        if (varieteExiste) {
          console.log(`   ⏭️  Déjà existante`);
          continue;
        }
        
        const variete = {
          nom: varieteNom,
          description: typeCulture || `Variété de ${cultureNom}`,
          temp_min: tempMin,
          temp_max: tempMax,
          humidite_min: humMin,
          humidite_max: humMax,
          sols_recommandes: getSols(typeSol),
          resistance_secheresse: resistanceSecheresse >= 7,
          resistance_chaleur: resistanceChaleur,
          saison_recommandee: getSaison(saisonStr),
          zone_adaptation: getZone(zoneFavorable)
        };
        
        if (rendement) variete.rendement_moyen = rendement / 1000;
        if (prix) variete.prix_semence = prix;
        if (cycleJours) variete.cycle_vegetatif = cycleJours;
        
        culture.varietes.push(variete);
        await culture.save();
        
        totalVarietes++;
        console.log(`   ✅ Ajouté (total culture: ${culture.varietes.length})`);
        
      } catch (err) {
        console.error(`❌ Erreur ligne ${idx + 1}:`, err.message);
        erreurs++;
      }
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 RÉSUMÉ FINAL');
    console.log('='.repeat(50));
    console.log(`\n✅ Cultures créées/modifiées: ${culturesModifiees}`);
    console.log(`✅ Variétés ajoutées: ${totalVarietes}`);
    console.log(`❌ Erreurs: ${erreurs}`);
    
    const allCultures = await Culture.find().sort({ nom: 1 });
    console.log(`\n🌾 État final de la base (${allCultures.length} cultures):`);
    for (const c of allCultures) {
      console.log(`   - ${c.nom} (${c.types.join(', ')}) : ${c.varietes.length} variétés`);
    }
    
    await mongoose.disconnect();
    console.log('\n🔌 Déconnecté');
    
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    await mongoose.disconnect();
  }
}

importData();