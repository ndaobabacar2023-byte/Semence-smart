const mongoose = require('mongoose');

const AnalyseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  technicienId: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'User',
  default: null
},
  culture: {
    type: String,
    required: true
  },

  typeCulture: {
    type: String,
    enum: ['serre', 'plein_air'],
    required: true
  },

  mode_culture: {
    type: String,
    enum: ['serre', 'plein_air'],
    default: 'plein_air'
  },

  temperature: {
    type: Number,
    required: true
  },

  humidite: {
    type: Number,
    required: true
  },

  sol: {
    type: String,
    required: true
  },

  eau: {
    type: Number,
    required: true
  },

  zone: {
    type: String,
    required: true
  },

  saison: {
    type: String,
    required: true
  },

  score: {
    type: Number,
    required: true
  },

  // 🔥 UNIFICATION DU STATUT (IMPORTANT)
  statut: {
  type: String,
  enum: [
    'pending',
    'in_progress',
    'validated',
    'corrected',
    'rejected'
  ],
  default: 'pending'
},

  recommandations: [{
    type: String
  }],

  variete: {
    type: String,
    default: null
  },

  // =====================
  // CORRECTIONS TECHNICIEN
  // =====================
  correction: {
    technicienId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    correctedAt: Date,
    comment: String,
    recommandationsCorrigees: [String],
    varieteCorrigee: String
  },

  // =====================
  // VALIDATION TECHNICIEN
  // =====================
  validation: {
    technicienId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    validatedAt: Date
  },

  dateAnalyse: {
    type: Date,
    default: Date.now
  }

}, {
  timestamps: true
});

// INDEX OPTIMISÉS
AnalyseSchema.index({ userId: 1, createdAt: -1 });
AnalyseSchema.index({ culture: 1 });
AnalyseSchema.index({ zone: 1 });
AnalyseSchema.index({ statut: 1 });

module.exports = mongoose.model('Analyse', AnalyseSchema);