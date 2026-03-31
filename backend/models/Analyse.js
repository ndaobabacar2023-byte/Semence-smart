const mongoose = require('mongoose');

const analyseSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  culture: { type: String, required: true },
  typeCulture: { type: String, required: true },
  temperature: Number,
  humidite: Number,
  sol: String,
  eau: Number,
  zone: String,
  saison: String,
  score: Number,
  status: String,
  recommandations: [String],
  variete: Object,
  dateAnalyse: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Analyse', analyseSchema);