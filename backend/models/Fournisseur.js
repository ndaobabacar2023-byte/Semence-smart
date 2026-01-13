// Fichier: models/Fournisseur.js
// Rôle: schéma Mongoose pour les fournisseurs locaux

const mongoose = require('mongoose');

const FournisseurSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  zones: [{ type: String }],
  adresse: String,
  contact: {
    telephone: String,
    email: String
  },
  produits: [{ type: String }]
});

module.exports = mongoose.model('Fournisseur', FournisseurSchema);
