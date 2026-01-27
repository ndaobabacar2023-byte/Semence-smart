// seed-senegal.js - Données adaptées au Sénégal
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

dotenv.config();
// Correction des chemins (selon votre structure réelle)
const connectDB = require('../config/db');  // Remonte d'un niveau
const Culture = require('../models/Culture');
const Fournisseur = require('../models/Fournisseur');
const User = require('../models/User');

async function seedSenegal() {
  try {
    console.log('🌍 Démarrage seed semence...');
    await connectDB();

    // Suppression des données existantes
    await Culture.deleteMany({});
    await Fournisseur.deleteMany({});
    await User.deleteMany({});

    // ==================== CULTURES DU SÉNÉGAL ====================

    const cultures = [
      {
        nom: 'Arachide',
        types: ['plein_air'],
        temp_min: 25,
        temp_max: 35,
        humidite_min: 30,
        humidite_max: 60,
        sols_recommandes: ['sableux', 'limoneux'],
        difficulte: 'moyen',
        varietes: [
          { 
            nom: '73-33', 
            description: 'Variété locale, cycle court (90-100 jours)',
            temp_min: 26, 
            temp_max: 33, 
            humidite_min: 35, 
            humidite_max: 55, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 95,
            resistance_secheresse: true,
            eau_min: 15,
            eau_max: 40,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Fleur 11', 
            description: 'Haute productivité, adaptée aux sols légers',
            temp_min: 27, 
            temp_max: 34, 
            humidite_min: 40, 
            humidite_max: 60, 
            sols_recommandes: ['sableux', 'limoneux'],
            cycle_vegetatif: 105,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 45,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'ICGV 86124', 
            description: 'Résistante aux maladies, graines de bonne qualité',
            temp_min: 25, 
            temp_max: 32, 
            humidite_min: 30, 
            humidite_max: 55, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 100,
            resistance_secheresse: true,
            eau_min: 18,
            eau_max: 42,
            saison_recommandee: 'hivernage'
          }
        ],
        recommandations_generales: [
          'Semis en juin-juillet avec les premières pluies',
          'Sol bien drainé essentiel',
          'Rotation avec céréales recommandée',
          'Éviter les sols lourds et argileux'
        ]
      },
      {
        nom: 'Mil',
        types: ['plein_air'],
        temp_min: 20,
        temp_max: 35,
        humidite_min: 30,
        humidite_max: 60,
        sols_recommandes: ['sableux', 'limoneux'],
        difficulte: 'facile',
        varietes: [
          { 
            nom: 'Souna 3', 
            description: 'Variété précoce (75-80 jours), adaptée au Sahel',
            temp_min: 25, 
            temp_max: 35, 
            humidite_min: 30, 
            humidite_max: 55, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 78,
            resistance_secheresse: true,
            eau_min: 15,
            eau_max: 35,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'IBV 8001', 
            description: 'Bon rendement, résistance à la sécheresse',
            temp_min: 26, 
            temp_max: 34, 
            humidite_min: 30, 
            humidite_max: 60, 
            sols_recommandes: ['sableux', 'limoneux'],
            cycle_vegetatif: 85,
            resistance_secheresse: true,
            eau_min: 15,
            eau_max: 40,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Thialack 2', 
            description: 'Variété traditionnelle, bonne adaptation',
            temp_min: 24, 
            temp_max: 32, 
            humidite_min: 30, 
            humidite_max: 55, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 90,
            resistance_secheresse: true,
            eau_min: 12,
            eau_max: 38,
            saison_recommandee: 'hivernage'
          }
        ],
        recommandations_generales: [
          'Semis à la première pluie utile',
          'Sol léger et bien drainé',
          'Désherbage important en début de cycle',
          'Distance de semis: 40-50 cm entre lignes'
        ]
      },
      {
        nom: 'Niébé',
        types: ['plein_air'],
        temp_min: 22,
        temp_max: 32,
        humidite_min: 40,
        humidite_max: 70,
        sols_recommandes: ['sableux', 'limoneux'],
        difficulte: 'facile',
        varietes: [
          { 
            nom: 'Mouride', 
            description: 'Variété locale, cycle moyen (85-90 jours)',
            temp_min: 24, 
            temp_max: 30, 
            humidite_min: 45, 
            humidite_max: 65, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 88,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 50,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'TN 5-78', 
            description: 'Résistante aux parasites, bon rendement',
            temp_min: 23, 
            temp_max: 31, 
            humidite_min: 40, 
            humidite_max: 70, 
            sols_recommandes: ['sableux', 'limoneux'],
            cycle_vegetatif: 85,
            resistance_secheresse: true,
            eau_min: 18,
            eau_max: 45,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'IT 81 D-985', 
            description: 'Variété améliorée, tolérante à la sécheresse',
            temp_min: 25, 
            temp_max: 32, 
            humidite_min: 40, 
            humidite_max: 65, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 80,
            resistance_secheresse: true,
            eau_min: 15,
            eau_max: 40,
            saison_recommandee: 'hivernage'
          }
        ],
        recommandations_generales: [
          'Semis en juillet-août',
          'Association avec céréales possible',
          'Tuteurage recommandé pour certaines variétés',
          'Récolte avant pleine maturité pour consommation fraîche'
        ]
      },
      {
        nom: 'Maïs',
        types: ['plein_air'],
        temp_min: 18,
        temp_max: 30,
        humidite_min: 50,
        humidite_max: 80,
        sols_recommandes: ['limoneux', 'argileux'],
        difficulte: 'moyen',
        varietes: [
          { 
            nom: 'Pool 16', 
            description: 'Variété locale, adaptée aux différentes régions',
            temp_min: 20, 
            temp_max: 28, 
            humidite_min: 55, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 100,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 60,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Early Thioro', 
            description: 'Précoce (90-95 jours), bon pour zones à pluviométrie limitée',
            temp_min: 22, 
            temp_max: 30, 
            humidite_min: 50, 
            humidite_max: 70, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 92,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 55,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Obatanpa', 
            description: 'Maïs qualité protéique, bon pour nutrition',
            temp_min: 21, 
            temp_max: 29, 
            humidite_min: 50, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux', 'argileux'],
            cycle_vegetatif: 105,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 65,
            saison_recommandee: 'hivernage'
          }
        ],
        recommandations_generales: [
          'Semis début juillet',
          'Fumure organique recommandée',
          'Irrigation complémentaire en période sèche',
          'Buttage pour renforcer les racines'
        ]
      },
      {
        nom: 'Tomate',
        types: ['serre', 'plein_air'],
        temp_min: 18,
        temp_max: 32,
        humidite_min: 50,
        humidite_max: 80,
        sols_recommandes: ['limoneux', 'argileux'],
        difficulte: 'difficile',
        varietes: [
          { 
            nom: 'Roma VF', 
            description: 'Déterminée, adaptée à la transformation',
            temp_min: 20, 
            temp_max: 30, 
            humidite_min: 55, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux', 'argileux'],
            cycle_vegetatif: 90,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 60,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Mongal F1', 
            description: 'Hybride, résistante aux maladies, bon rendement',
            temp_min: 22, 
            temp_max: 32, 
            humidite_min: 50, 
            humidite_max: 70, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 85,
            resistance_secheresse: false,
            eau_min: 30,
            eau_max: 65,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Petomech', 
            description: 'Fruits charnus, bonne conservation',
            temp_min: 21, 
            temp_max: 29, 
            humidite_min: 50, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 95,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 60,
            saison_recommandee: 'saison sèche'
          }
        ],
        recommandations_generales: [
          'Culture de contre-saison recommandée',
          'Irrigation goutte-à-goutte préférée',
          'Protection contre les insectes nécessaire',
          'Tuteurage obligatoire'
        ]
      },
      {
        nom: 'Oignon',
        types: ['plein_air'],
        temp_min: 15,
        temp_max: 25,
        humidite_min: 40,
        humidite_max: 70,
        sols_recommandes: ['sableux', 'limoneux'],
        difficulte: 'moyen',
        varietes: [
          { 
            nom: 'Violet de Galmi', 
            description: 'Variété précoce, bulbes violets',
            temp_min: 18, 
            temp_max: 24, 
            humidite_min: 45, 
            humidite_max: 65, 
            sols_recommandes: ['sableux'],
            cycle_vegetatif: 120,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 50,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Blanc de Soumbedioune', 
            description: 'Variété locale, bonne conservation',
            temp_min: 17, 
            temp_max: 23, 
            humidite_min: 40, 
            humidite_max: 60, 
            sols_recommandes: ['sableux', 'limoneux'],
            cycle_vegetatif: 130,
            resistance_secheresse: true,
            eau_min: 18,
            eau_max: 45,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Jaune des Vertus', 
            description: 'Productivité élevée, bulbes dorés',
            temp_min: 16, 
            temp_max: 22, 
            humidite_min: 40, 
            humidite_max: 65, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 125,
            resistance_secheresse: false,
            eau_min: 22,
            eau_max: 55,
            saison_recommandee: 'saison sèche'
          }
        ],
        recommandations_generales: [
          'Culture de décrue ou contre-saison',
          'Sol léger et bien drainé',
          'Arrosage régulier mais modéré',
          'Arrêt irrigation 15 jours avant récolte'
        ]
      },
      {
        nom: 'Gombo',
        types: ['plein_air'],
        temp_min: 22,
        temp_max: 35,
        humidite_min: 50,
        humidite_max: 80,
        sols_recommandes: ['limoneux', 'argileux'],
        difficulte: 'facile',
        varietes: [
          { 
            nom: 'Clemson Spineless', 
            description: 'Sans épines, fruits tendres',
            temp_min: 25, 
            temp_max: 32, 
            humidite_min: 55, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 60,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 50,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Dwarf Long Pod', 
            description: 'Port nain, adapté aux petits espaces',
            temp_min: 24, 
            temp_max: 31, 
            humidite_min: 50, 
            humidite_max: 70, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 65,
            resistance_secheresse: true,
            eau_min: 18,
            eau_max: 45,
            saison_recommandee: 'hivernage'
          },
          { 
            nom: 'Pusa Sawani', 
            description: 'Résistante aux maladies, haut rendement',
            temp_min: 26, 
            temp_max: 34, 
            humidite_min: 50, 
            humidite_max: 75, 
            sols_recommandes: ['limoneux', 'argileux'],
            cycle_vegetatif: 70,
            resistance_secheresse: true,
            eau_min: 22,
            eau_max: 55,
            saison_recommandee: 'hivernage'
          }
        ],
        recommandations_generales: [
          'Semis direct en poquet',
          'Récolte fréquente pour stimuler production',
          'Association avec céréales possible',
          'Tolère bien la chaleur'
        ]
      },
      {
        nom: 'Piment',
        types: ['serre', 'plein_air'],
        temp_min: 20,
        temp_max: 30,
        humidite_min: 50,
        humidite_max: 70,
        sols_recommandes: ['limoneux'],
        difficulte: 'moyen',
        varietes: [
          { 
            nom: 'Piment Cayenne', 
            description: 'Forts, pour séchage et poudre',
            temp_min: 22, 
            temp_max: 28, 
            humidite_min: 55, 
            humidite_max: 65, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 80,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 55,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Piment Doux', 
            description: 'Pour consommation fraîche',
            temp_min: 21, 
            temp_max: 29, 
            humidite_min: 50, 
            humidite_max: 65, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 85,
            resistance_secheresse: false,
            eau_min: 25,
            eau_max: 60,
            saison_recommandee: 'saison sèche'
          },
          { 
            nom: 'Bird Eye', 
            description: 'Petits piments très forts',
            temp_min: 23, 
            temp_max: 30, 
            humidite_min: 50, 
            humidite_max: 70, 
            sols_recommandes: ['limoneux'],
            cycle_vegetatif: 75,
            resistance_secheresse: true,
            eau_min: 20,
            eau_max: 50,
            saison_recommandee: 'saison sèche'
          }
        ],
        recommandations_generales: [
          'Culture de contre-saison rentable',
          'Irrigation régulière nécessaire',
          'Protection contre les mouches blanches',
          'Récolte à maturité pour meilleur goût'
        ]
      }
    ];

    await Culture.insertMany(cultures);
    console.log(`✅ ${cultures.length} cultures insérées`);

    // ==================== FOURNISSEURS LOCAUX ====================

    const fournisseurs = [
      { 
        nom: 'SONACOS Kaolack', 
        zones: ['Kaolack', 'Fatick', 'Kaffrine'], 
        adresse: 'Route de Tambacounda, Kaolack', 
        contact: { 
          telephone: '+221 33 941 10 10', 
          email: 'sonacos.kaolack@sonacos.sn' 
        }, 
        produits: ['Semences certifiées', 'Engrais', 'Produits phytosanitaires'] 
      },
      { 
        nom: 'Coopérative Agricole de Thiès', 
        zones: ['Thiès', 'Mbour', 'Tivaouane'], 
        adresse: 'Marché central, Thiès', 
        contact: { 
          telephone: '+221 77 654 32 10', 
          email: 'coopthies@agriculture.sn' 
        }, 
        produits: ['Semences locales', 'Outils agricoles', 'Formation'] 
      },
      { 
        nom: 'Agri-Sénégal Dakar', 
        zones: ['Dakar', 'Pikine', 'Guediawaye'], 
        adresse: 'Sicap Liberté 2, Dakar', 
        contact: { 
          telephone: '+221 33 889 55 44', 
          email: 'contact@agrisenegal.sn' 
        }, 
        produits: ['Systèmes irrigation', 'Serres', 'Équipements modernes'] 
      },
      { 
        nom: 'Union des Maraîchers de Saint-Louis', 
        zones: ['Saint-Louis', 'Louga', 'Dagana'], 
        adresse: 'Quartier Nord, Saint-Louis', 
        contact: { 
          telephone: '+221 70 123 45 67', 
          email: 'maraichers.stlouis@gmail.com' 
        }, 
        produits: ['Plants potagers', 'Fumier organique', 'Conseils techniques'] 
      },
      { 
        nom: 'SEMAFORT Ziguinchor', 
        zones: ['Ziguinchor', 'Bignona', 'Oussouye'], 
        adresse: 'Avenue Charles de Gaulle, Ziguinchor', 
        contact: { 
          telephone: '+221 33 991 22 33', 
          email: 'semafort@casamanseculture.sn' 
        }, 
        produits: ['Semences riz', 'Matériel rizicole', 'Formation riziculture'] 
      }
    ];

    await Fournisseur.insertMany(fournisseurs);
    console.log(`✅ ${fournisseurs.length} fournisseurs insérés`);

    // ==================== UTILISATEURS DE TEST ====================

    const salt = await bcrypt.genSalt(10);
    
    // Admin
    const hashAdmin = await bcrypt.hash('Admin123!', salt);
    const admin = new User({ 
      nom: 'Ndiaye', 
      prenom: 'Amadou', 
      email: 'admin@agriadvisor.sn', 
      telephone: '+221772001122',
      motDePasse: hashAdmin, 
      role: 'admin' 
    });
    await admin.save();

    // Agriculteur test
    const hashAgriculteur = await bcrypt.hash('Agriculteur123!', salt);
    const agriculteur = new User({ 
      nom: 'Diallo', 
      prenom: 'Fatou', 
      email: 'fatou.diallo@test.sn', 
      telephone: '+221771112233',
      motDePasse: hashAgriculteur, 
      role: 'agriculteur' 
    });
    await agriculteur.save();

    // Technicien test
    const hashTechnicien = await bcrypt.hash('Technicien123!', salt);
    const technicien = new User({ 
      nom: 'Sow', 
      prenom: 'Moussa', 
      email: 'm.sow@technicien.sn', 
      telephone: '+221773334455',
      motDePasse: hashTechnicien, 
      role: 'technicien' 
    });
    await technicien.save();

    console.log(`✅ 3 utilisateurs de test créés`);

    // ==================== STATISTIQUES FINALES ====================

    const totalCultures = await Culture.countDocuments();
    const totalVarietes = await Culture.aggregate([
      { $unwind: "$varietes" },
      { $count: "total" }
    ]);
    const totalFournisseurs = await Fournisseur.countDocuments();

    console.log('\n' + '='.repeat(50));
    console.log('🌾 SEED SÉNÉGAL COMPLÉTÉ AVEC SUCCÈS');
    console.log('='.repeat(50));
    console.log(`📊 Cultures: ${totalCultures}`);
    console.log(`📊 Variétés: ${totalVarietes[0]?.total || 0}`);
    console.log(`📊 Fournisseurs: ${totalFournisseurs}`);
    console.log('='.repeat(50));
    console.log('\n📝 Comptes de test créés:');
    console.log('👨‍🌾 Agriculteur: fatou.diallo@test.sn / Agriculteur123!');
    console.log('👨‍🔬 Technicien: m.sow@technicien.sn / Technicien123!');
    console.log('👨‍💼 Admin: admin@agriadvisor.sn / Admin123!');
    console.log('\n🚀 Redémarrez votre serveur pour appliquer les changements');

    process.exit(0);
  } catch (err) {
    console.error('❌ Erreur seed:', err);
    process.exit(1);
  }
}

seedSenegal();