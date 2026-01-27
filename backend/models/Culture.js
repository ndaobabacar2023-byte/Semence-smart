// models/Culture.js - Modèle adapté au contexte sénégalais
const mongoose = require('mongoose');

// --- Modèle pour une variété de semence ---
const VarieteSchema = new mongoose.Schema({
  nom: { 
    type: String, 
    required: [true, 'Nom de la variété requis'],
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  temp_min: { 
    type: Number, 
    min: 10,
    max: 40
  }, // °C
  temp_max: { 
    type: Number, 
    min: 15,
    max: 45
  }, // °C
  humidite_min: { 
    type: Number, 
    min: 20,
    max: 90
  }, // %
  humidite_max: { 
    type: Number, 
    min: 30,
    max: 95
  }, // %
  sols_recommandes: [{ 
    type: String,
    enum: ['sableux', 'limoneux', 'argileux', 'lateritique', 'tourbeux']
  }],
  cycle_vegetatif: { 
    type: Number, 
    min: 30,
    max: 180
  }, // en jours
  resistance_secheresse: { 
    type: Boolean, 
    default: false 
  },
  tolerance_maladies: [{ 
    type: String 
  }],
  eau_min: { 
    type: Number, 
    min: 0,
    default: 10
  }, // mm/semaine
  eau_max: { 
    type: Number, 
    min: 0,
    default: 60
  }, // mm/semaine
  saison_recommandee: { 
    type: String,
    enum: ['hivernage', 'saison sèche', 'contre-saison', 'toute l\'année']
  },
  rendement_moyen: {
    type: Number,
    min: 0,
    comment: 'Rendement moyen en tonnes/hectare'
  },
  prix_semence: {
    type: Number,
    min: 0,
    comment: 'Prix approximatif du kg de semence en FCFA'
  }
}, {
  timestamps: true
});

// --- Modèle Culture global ---
const CultureSchema = new mongoose.Schema({
  nom: { 
    type: String, 
    required: [true, 'Nom de la culture requis'],
    trim: true,
    unique: true
  },
  nom_local: {
    type: String,
    trim: true
  },
  types: [{ 
    type: String, 
    enum: ['serre', 'plein_air'], 
    required: true 
  }],
  temp_min: { 
    type: Number, 
    min: 10,
    max: 40,
    default: 20
  }, // °C
  temp_max: { 
    type: Number, 
    min: 15,
    max: 45,
    default: 30
  }, // °C
  humidite_min: { 
    type: Number, 
    min: 20,
    max: 90,
    default: 50
  }, // %
  humidite_max: { 
    type: Number, 
    min: 30,
    max: 95,
    default: 80
  }, // %
  sols_recommandes: [{ 
    type: String,
    enum: ['sableux', 'limoneux', 'argileux', 'lateritique', 'tourbeux']
  }],
  varietes: [VarieteSchema],
  recommandations_generales: [{ 
    type: String 
  }],
  difficulte: {
    type: String,
    enum: ['facile', 'moyen', 'difficile'],
    default: 'moyen'
  },
  saison_optimale: {
    type: String,
    enum: ['juin-septembre', 'octobre-mai', 'toute l\'année'],
    default: 'juin-septembre'
  },
  besoin_eau: {
    type: String,
    enum: ['faible', 'moyen', 'élevé'],
    default: 'moyen'
  },
  zone_adaptation: [{
    type: String,
    enum: ['Nord', 'Centre', 'Sud', 'Vallée', 'Littoral', 'Toutes zones']
  }],
  valeur_nutritionnelle: {
    type: String,
    trim: true
  },
  marche_local: {
    type: String,
    enum: ['forte demande', 'demande moyenne', 'niche'],
    default: 'demande moyenne'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index pour recherches rapides
CultureSchema.index({ nom: 1, types: 1 });
CultureSchema.index({ zone_adaptation: 1 });
CultureSchema.index({ saison_optimale: 1 });

// Méthode pour obtenir les variétés recommandées par zone
CultureSchema.methods.getVarietesByZone = function(zone) {
  return this.varietes.filter(variete => {
    // Logique de filtrage par zone (à adapter)
    return true; // Pour l'instant, retourne toutes les variétés
  });
};

module.exports = mongoose.model('Culture', CultureSchema);