// Fichier: config/db.js
// Rôle: gestion de la connexion à MongoDB via mongoose

const mongoose = require('mongoose');
require('dotenv').config();

const connectDB = async () => {
  try {
    // Afficher l'URI MongoDB (masquer le mot de passe si présent)
    const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/agriadvisor';
    
    let displayUri = mongoUri;
    // Masquer le mot de passe dans les logs
    if (mongoUri.includes('@')) {
      displayUri = mongoUri.replace(/:\/\/[^:]+:[^@]+@/, '://****:****@');
    }
    
    console.log('='.repeat(50));
    console.log('🔍 TENTATIVE DE CONNEXION MONGODB');
    console.log('='.repeat(50));
    console.log(`📌 URI: ${displayUri}`);
    console.log(`📊 Environnement: ${process.env.NODE_ENV || 'development'}`);
    
    // Options de connexion améliorées
    const options = {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 10000, // 10 secondes
      socketTimeoutMS: 45000,
      maxPoolSize: 10,
      family: 4 // Utiliser IPv4, IPv6 peut causer des problèmes
    };
    
    console.log('⏳ Connexion en cours...');
    
    const conn = await mongoose.connect(mongoUri, options);
    
    // Afficher les informations de connexion réussie
    console.log('='.repeat(50));
    console.log('✅ MONGODB CONNECTÉ AVEC SUCCÈS!');
    console.log('='.repeat(50));
    console.log(`📊 Base de données: ${conn.connection.db.databaseName}`);
    console.log(`📍 Host: ${conn.connection.host}`);
    console.log(`📍 Port: ${conn.connection.port}`);
    console.log(`📈 État: ${getConnectionState(mongoose.connection.readyState)}`);
    
    // Écouteurs d'événements pour débogage
    mongoose.connection.on('connected', () => {
      console.log('🔗 Événement: Mongoose connecté');
    });
    
    mongoose.connection.on('error', (err) => {
      console.error('❌ Événement: Erreur Mongoose:', err.message);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.log('🔌 Événement: Mongoose déconnecté');
    });
    
    mongoose.connection.on('reconnected', () => {
      console.log('🔄 Événement: Mongoose reconnecté');
    });
    
    // Test de la connexion avec une requête simple
    try {
      console.log('\n🧪 Test de la connexion...');
      const adminDb = conn.connection.db.admin();
      const serverStatus = await adminDb.command({ serverStatus: 1 });
      console.log(`✅ MongoDB version: ${serverStatus.version}`);
      console.log(`✅ Uptime: ${Math.floor(serverStatus.uptime / 60)} minutes`);
    } catch (testError) {
      console.warn('⚠️ Impossible de récupérer le statut serveur:', testError.message);
    }
    
    console.log('\n🎉 Prêt à recevoir des requêtes!');
    console.log('='.repeat(50));
    
  } catch (err) {
    console.error('\n' + '='.repeat(50));
    console.error('❌ ERREUR DE CONNEXION MONGODB');
    console.error('='.repeat(50));
    console.error(`Message: ${err.message}`);
    console.error(`Code: ${err.code || 'N/A'}`);
    console.error(`Nom: ${err.name}`);
    
    // Diagnostics détaillés
    console.error('\n🔧 DIAGNOSTIC:');
    
    if (err.message.includes('ECONNREFUSED')) {
      console.error('→ MongoDB n\'est pas démarré ou inaccessible');
      console.error('→ Vérifiez: sudo systemctl start mongod (Linux)');
      console.error('→ Vérifiez: Services > MongoDB (Windows)');
    }
    
    if (err.message.includes('ENOTFOUND')) {
      console.error('→ L\'hôte MongoDB est introuvable');
      console.error('→ Vérifiez l\'URL dans .env');
    }
    
    if (err.message.includes('auth failed')) {
      console.error('→ Authentification MongoDB échouée');
      console.error('→ Vérifiez le nom d\'utilisateur/mot de passe');
    }
    
    if (err.message.includes('MongoNetworkError')) {
      console.error('→ Problème réseau avec MongoDB');
      console.error('→ Vérifiez votre connexion internet');
      console.error('→ Vérifiez le firewall sur le port 27017');
    }
    
    console.error('\n💡 CONSEILS:');
    console.error('1. Vérifiez que MongoDB est installé: mongod --version');
    console.error('2. Démarrer MongoDB: sudo systemctl start mongod');
    console.error('3. Tester la connexion: mongo --eval "db.version()"');
    console.error('4. Vérifiez le fichier .env: MONGO_URI est-elle correcte?');
    console.error('5. Pour MongoDB local, essayez: mongodb://127.0.0.1:27017/agriadvisor');
    
    console.error('\n' + '='.repeat(50));
    process.exit(1);
  }
};

// Fonction helper pour l'état de connexion
function getConnectionState(state) {
  const states = [
    '0 = déconnecté',
    '1 = connecté',
    '2 = connexion en cours',
    '3 = déconnexion en cours'
  ];
  return states[state] || 'état inconnu';
}

module.exports = connectDB;