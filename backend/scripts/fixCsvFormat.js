/**
 * Script pour corriger le format du CSV
 * Les lignes sont actuellement toutes entre guillemets
 * Usage: node scripts/fixCsvFormat.js
 */

const fs = require('fs');
const path = require('path');

const INPUT_PATH = path.join(__dirname, '../data/semences_senegal_500plus.csv');
const OUTPUT_PATH = path.join(__dirname, '../data/semences_senegal_fixed.csv');

function fixCSV() {
  console.log('🚀 Correction du fichier CSV...\n');
  
  if (!fs.existsSync(INPUT_PATH)) {
    console.error(`❌ Fichier non trouvé: ${INPUT_PATH}`);
    return;
  }
  
  const content = fs.readFileSync(INPUT_PATH, 'utf8');
  const lines = content.split('\n');
  
  console.log(`📊 ${lines.length} lignes lues\n`);
  
  const fixedLines = [];
  
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i].trim();
    
    if (!line) {
      fixedLines.push('');
      continue;
    }
    
    // Enlever les guillemets au début et à la fin
    if (line.startsWith('"') && line.endsWith('"')) {
      line = line.slice(1, -1);
    }
    
    // Remplacer les guillemets doubles internes par des guillemets simples
    line = line.replace(/""/g, '"');
    
    fixedLines.push(line);
  }
  
  // Écrire le fichier corrigé
  fs.writeFileSync(OUTPUT_PATH, fixedLines.join('\n'), 'utf8');
  
  console.log(`✅ Fichier corrigé sauvegardé: ${OUTPUT_PATH}`);
  console.log(`\n📋 Aperçu des 3 premières lignes:`);
  
  for (let i = 0; i < Math.min(3, fixedLines.length); i++) {
    console.log(`   ${i + 1}: ${fixedLines[i].substring(0, 100)}...`);
  }
}

fixCSV();