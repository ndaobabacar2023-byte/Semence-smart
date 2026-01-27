// controllers/culture.controller.js - CORRIGÉ
const Culture = require('../models/Culture');

/**
 * Récupérer toutes les cultures
 * @route GET /api/cultures
 * @access Public
 */
exports.getCultures = async (req, res) => {
  try {
    const cultures = await Culture.find().sort({ nom: 1 });
    
    res.json({
      success: true,
      count: cultures.length,
      data: cultures
    });
  } catch (err) {
    console.error("❌ Erreur récupération cultures:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des cultures'
    });
  }
};

/**
 * Récupérer une culture par son ID
 * @route GET /api/cultures/:id
 * @access Public
 */
exports.getCultureById = async (req, res) => {
  try {
    const culture = await Culture.findById(req.params.id);
    
    if (!culture) {
      return res.status(404).json({
        success: false,
        message: 'Culture non trouvée'
      });
    }
    
    res.json({
      success: true,
      data: culture
    });
  } catch (err) {
    console.error("❌ Erreur récupération culture:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de la culture'
    });
  }
};

/**
 * Récupérer les types de culture disponibles
 * @route GET /api/cultures/types
 * @access Public
 */
exports.getCultureTypes = async (req, res) => {
  try {
    const cultures = await Culture.find({}, 'types');
    const types = [...new Set(cultures.flatMap(c => c.types))];
    
    res.json({
      success: true,
      data: types
    });
  } catch (err) {
    console.error("❌ Erreur récupération types:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des types'
    });
  }
};

/**
 * Créer une nouvelle culture (admin seulement)
 * @route POST /api/cultures
 * @access Private/Admin
 */
exports.createCulture = async (req, res) => {
  try {
    const culture = new Culture(req.body);
    await culture.save();
    
    res.status(201).json({
      success: true,
      message: 'Culture créée avec succès',
      data: culture
    });
  } catch (err) {
    console.error("❌ Erreur création culture:", err);
    
    if (err.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Cette culture existe déjà'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la culture'
    });
  }
};

/**
 * Mettre à jour une culture (admin seulement)
 * @route PUT /api/cultures/:id
 * @access Private/Admin
 */
exports.updateCulture = async (req, res) => {
  try {
    const culture = await Culture.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    
    if (!culture) {
      return res.status(404).json({
        success: false,
        message: 'Culture non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Culture mise à jour avec succès',
      data: culture
    });
  } catch (err) {
    console.error("❌ Erreur mise à jour culture:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour de la culture'
    });
  }
};

/**
 * Supprimer une culture (admin seulement)
 * @route DELETE /api/cultures/:id
 * @access Private/Admin
 */
exports.deleteCulture = async (req, res) => {
  try {
    const culture = await Culture.findByIdAndDelete(req.params.id);
    
    if (!culture) {
      return res.status(404).json({
        success: false,
        message: 'Culture non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Culture supprimée avec succès'
    });
  } catch (err) {
    console.error("❌ Erreur suppression culture:", err);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la culture'
    });
  }
};

// PAS de deuxième module.exports ici !