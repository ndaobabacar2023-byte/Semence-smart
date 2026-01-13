const mongoose = require('mongoose');

// --- Modèle pour une variété de semence ---
const VarieteSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  description: String,
  temp_min: Number,        // °C
  temp_max: Number,        // °C
  humidite_min: Number,    // %
  humidite_max: Number,    // %
  sols_recommandes: [{ type: String }], // ex: ["limoneux", "argileux"]
  cycle_vegetatif: Number, // en jours
  resistance_secheresse: { type: Boolean, required: true, default: false },
  tolérance_maladies: [String],  // ex: ["mildiou", "oïdium"]
  eau_min: Number,          // mm/semaine
  eau_max: Number,          // mm/semaine
  saison_recommandee: String // ex: "printemps", "été", etc.
});

// --- Modèle Culture global ---
const CultureSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  types: [{ type: String, enum: ["serre", "plein_air"], required: true }],
  temp_min: Number,          // °C (valeur par défaut si variété ne précise pas)
  temp_max: Number,          // °C
  humidite_min: Number,      // %
  humidite_max: Number,      // %
  sols_recommandes: [{ type: String }], // sols généraux si variété ne précise pas
  varietes: [VarieteSchema],  // liste des variétés disponibles
  recommandations_generales: [{ type: String }] // conseils généraux pour la culture
});

module.exports = mongoose.model('Culture', CultureSchema);