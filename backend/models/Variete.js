const mongoose = require('mongoose');

const VarieteSchema = new mongoose.Schema({

  nom: {
    type: String,
    required: true,
    trim: true
  },

  culture: {
    type: String,
    required: true,
    trim: true
  },

  description: {
    type: String,
    default: ''
  },

  typeCulture: {
    type: String,
    enum: ['plein_air', 'serre', 'both'],
    default: 'both'
  },

  // ✅ STRUCTURE PROPRE (alignée backend + Flutter)
  caracteristiques: {

    zoneRecommandee: {
      type: [String],
      default: []
    },

    periodeSemis: {
      type: String,
      default: ''
    },

    cycleJours: {
      type: Number,
      default: 0
    },

    rendementTonnesHa: {
      type: Number,
      default: 0
    }
  },

  prixSemence: {
    type: Number,
    default: 0
  },

  resistances: {
    maladies: {
      type: [String],
      default: []
    },
    climat: {
      type: [String],
      default: []
    }
  },

  isActive: {
    type: Boolean,
    default: true
  },

  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }

}, {
  timestamps: true
});

// ======================
// INDEX (PERFORMANCE)
// ======================
VarieteSchema.index({ culture: 1 });
VarieteSchema.index({ typeCulture: 1 });
VarieteSchema.index({ 'caracteristiques.zoneRecommandee': 1 });
VarieteSchema.index({ isActive: 1 });

// ======================
// CLEAN JSON OUTPUT
// ======================
VarieteSchema.methods.toJSON = function () {
  const obj = this.toObject();

  return {
    id: obj._id,
    nom: obj.nom,
    culture: obj.culture,
    description: obj.description,
    typeCulture: obj.typeCulture,

    zoneRecommandee: obj.caracteristiques?.zoneRecommandee || [],
    periodeSemis: obj.caracteristiques?.periodeSemis || '',
    cycleJours: obj.caracteristiques?.cycleJours || 0,
    rendementTonnesHa: obj.caracteristiques?.rendementTonnesHa || 0,

    prixSemence: obj.prixSemence,

    createdAt: obj.createdAt,
    updatedAt: obj.updatedAt
  };
};

module.exports = mongoose.model('Variete', VarieteSchema);