const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

dotenv.config();
const connectDB = require('../config/db');
const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');
const User = require('../models/User');

async function seed() {
  try {
    await connectDB();

    // Supprime tout existant
    await Culture.deleteMany({});
    await Fournisseur.deleteMany({});
    await User.deleteMany({});

    // -------------------- Cultures --------------------
    const cultures = [
      {
        nom: 'Tomate',
        types: ['serre'],
        temp_min: 18,
        temp_max: 32,
        humidite_min: 50,
        humidite_max: 80,
        sols_recommandes: ['limoneux', 'argileux'],
        varietes: [
          { 
            nom: 'Roma VF', description: 'Déterminée, résistante', 
            temp_min: 20, temp_max: 30, humidite_min: 55, humidite_max: 75, 
            sols_compatibles: ['limoneux','argileux'], cycle_vegetatif: 90, 
            resistance_secheresse: false, eau_min: 25, eau_max: 60 
          },
          { 
            nom: 'Marmande', description: 'Ancienne, bonne saveur', 
            temp_min: 18, temp_max: 28, humidite_min: 50, humidite_max: 70, 
            sols_compatibles: ['limoneux'], cycle_vegetatif: 100, 
            resistance_secheresse: false, eau_min: 20, eau_max: 55 
          },
          { 
            nom: 'Cherry', description: 'Petites tomates sucrées', 
            temp_min: 20, temp_max: 32, humidite_min: 50, humidite_max: 80, 
            sols_compatibles: ['limoneux'], cycle_vegetatif: 70, 
            resistance_secheresse: false, eau_min: 25, eau_max: 65 
          },
          { 
            nom: 'San Marzano', description: 'Parfaite pour sauce', 
            temp_min: 21, temp_max: 30, humidite_min: 55, humidite_max: 75, 
            sols_compatibles: ['limoneux','argileux'], cycle_vegetatif: 85, 
            resistance_secheresse: false, eau_min: 25, eau_max: 60 
          }
        ],
        recommandations_generales: ['Semis au printemps', 'Éviter excès d\'eau']
      },
      {
        nom: 'Poivron',
        types: ['serre'],
        temp_min: 20,
        temp_max: 30,
        humidite_min: 50,
        humidite_max: 70,
        sols_recommandes: ['limoneux'],
        varietes: [
          { nom: 'California Wonder', description: 'Polyvalente', temp_min: 22, temp_max: 28, humidite_min: 55, humidite_max: 65, sols_compatibles: ['limoneux'], cycle_vegetatif: 80, resistance_secheresse: false, eau_min: 25, eau_max: 55 },
          { nom: 'Bell', description: 'Gros fruits colorés', temp_min: 21, temp_max: 29, humidite_min: 50, humidite_max: 65, sols_compatibles: ['limoneux'], cycle_vegetatif: 85, resistance_secheresse: false, eau_min: 25, eau_max: 60 },
          { nom: 'Yolo Wonder', description: 'Rendement élevé', temp_min: 22, temp_max: 30, humidite_min: 55, humidite_max: 70, sols_compatibles: ['limoneux'], cycle_vegetatif: 90, resistance_secheresse: false, eau_min: 25, eau_max: 65 },
          { nom: 'Sweet Banana', description: 'Fruits longs jaunes', temp_min: 20, temp_max: 28, humidite_min: 50, humidite_max: 65, sols_compatibles: ['limoneux'], cycle_vegetatif: 80, resistance_secheresse: false, eau_min: 20, eau_max: 55 }
        ],
        recommandations_generales: ['Protéger du gel']
      },
      {
        nom: 'Arachide',
        types: ['plein_air'],
        temp_min: 25,
        temp_max: 35,
        humidite_min: 30,
        humidite_max: 60,
        sols_recommandes: ['sableux','limoneux'],
        varietes: [
          { nom: 'Arachide locale', description: 'Adaptée climat sec', temp_min: 27, temp_max: 33, humidite_min: 30, humidite_max: 55, sols_compatibles: ['sableux'], cycle_vegetatif: 120, resistance_secheresse: true, eau_min: 15, eau_max: 40 },
          { nom: 'Valencia', description: 'Rendement élevé', temp_min: 26, temp_max: 34, humidite_min: 35, humidite_max: 60, sols_compatibles: ['limoneux'], cycle_vegetatif: 115, resistance_secheresse: true, eau_min: 15, eau_max: 45 },
          { nom: 'Florunner', description: 'Bonne résistance maladies', temp_min: 25, temp_max: 33, humidite_min: 30, humidite_max: 55, sols_compatibles: ['sableux'], cycle_vegetatif: 110, resistance_secheresse: true, eau_min: 15, eau_max: 40 },
          { nom: 'Spanish', description: 'Huile de qualité', temp_min: 27, temp_max: 35, humidite_min: 30, humidite_max: 55, sols_compatibles: ['sableux','limoneux'], cycle_vegetatif: 120, resistance_secheresse: true, eau_min: 15, eau_max: 45 }
        ],
        recommandations_generales: ['Semis en saison des pluies']
      },
      {
        nom: 'Mil',
        types: ['plein_air'],
        temp_min: 20,
        temp_max: 35,
        humidite_min: 30,
        humidite_max: 60,
        sols_recommandes: ['sableux','limoneux'],
        varietes: [
          { nom: 'Mil local', description: 'Adapté régions sèches', temp_min: 25, temp_max: 35, humidite_min: 30, humidite_max: 55, sols_compatibles: ['sableux'], cycle_vegetatif: 75, resistance_secheresse: true, eau_min: 15, eau_max: 40 },
          { nom: 'SOSAT-C88', description: 'Bonne tolérance sécheresse', temp_min: 26, temp_max: 34, humidite_min: 30, humidite_max: 60, sols_compatibles: ['sableux','limoneux'], cycle_vegetatif: 78, resistance_secheresse: true, eau_min: 15, eau_max: 45 },
          { nom: 'ICMV-IS 89305', description: 'Rendement élevé', temp_min: 25, temp_max: 33, humidite_min: 30, humidite_max: 55, sols_compatibles: ['limoneux'], cycle_vegetatif: 80, resistance_secheresse: true, eau_min: 15, eau_max: 40 },
          { nom: 'Dwarf Mil', description: 'Cycle court', temp_min: 24, temp_max: 32, humidite_min: 30, humidite_max: 55, sols_compatibles: ['sableux'], cycle_vegetatif: 70, resistance_secheresse: true, eau_min: 15, eau_max: 40 }
        ],
        recommandations_generales: ['Semis en saison des pluies']
      }
    ];

    await Culture.insertMany(cultures);

    // -------------------- Fournisseurs --------------------
    const fournisseurs = [
      { 
        nom: 'Kaolack Fournitures', 
        zones: ['Kaolack'], 
        adresse: 'Place C, Kaolack', 
        contact: { telephone: '+221770000003', email: 'contact@kaolack.sn' }, 
        produits: ['Engrais', 'Irrigation', 'Semences'] 
      }
    ];

    await Fournisseur.insertMany(fournisseurs);

    // -------------------- Admin --------------------
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash('Admin123!', salt);
    const admin = new User({ nom: 'Admin', prenom: 'Agri', email: 'admin@agri.test', motDePasse: hash, role: 'admin' });
    await admin.save();

    console.log('Seed terminé ✅');
    process.exit(0);
  } catch (err) {
    console.error('Erreur seed:', err);
    process.exit(1);
  }
}

seed();
