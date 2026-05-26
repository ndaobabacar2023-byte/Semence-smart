// controllers/technicien.controller.js
// ✅ VERSION COMPLÈTE CORRIGÉE AVEC TOUTES LES FONCTIONS MANQUANTES

const Analyse = require('../models/Analyse');
const Variete = require('../models/Variete');
const Notification = require('../models/Notification');
const User = require('../models/User');

/**
 * GET ALL ANALYSES
 */
exports.getAllAnalyses = async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;

    const filter = {};
    if (status) filter.statut = status;

    const analyses = await Analyse.find(filter)
      .populate('userId', 'nom prenom email telephone')
      .sort({ createdAt: -1 })
      .skip((page - 1) * parseInt(limit))
      .limit(parseInt(limit));

    const total = await Analyse.countDocuments(filter);

    const stats = {
      pending: await Analyse.countDocuments({ statut: 'pending' }),
      validated: await Analyse.countDocuments({ statut: 'validated' }),
      corrected: await Analyse.countDocuments({ statut: 'corrected' }),
      rejected: await Analyse.countDocuments({ statut: 'rejected' }),
      total: await Analyse.countDocuments()
    };

    res.json({
      success: true,
      data: analyses,
      stats,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error("Erreur getAllAnalyses:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * GET ANALYSE BY ID
 */
exports.getAnalyseById = async (req, res) => {
  try {
    const analyse = await Analyse.findById(req.params.id)
      .populate('userId', 'nom prenom email telephone');

    if (!analyse) {
      return res.status(404).json({
        success: false,
        message: 'Analyse non trouvée'
      });
    }

    res.json({ success: true, data: analyse });

  } catch (error) {
    console.error("Erreur getAnalyseById:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * UPDATE ANALYSE (MANQUANTE)
 */
exports.updateAnalyse = async (req, res) => {
  try {
    const analyse = await Analyse.findByIdAndUpdate(
      req.params.id,
      {
        ...req.body,
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!analyse) {
      return res.status(404).json({
        success: false,
        message: 'Analyse non trouvée'
      });
    }

    res.json({
      success: true,
      data: analyse,
      message: 'Analyse mise à jour avec succès'
    });

  } catch (error) {
    console.error("Erreur updateAnalyse:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * VALIDATE ANALYSE
 */
exports.validateAnalyse = async (req, res) => {
  try {
    const analyse = await Analyse.findByIdAndUpdate(
      req.params.id,
      {
        statut: 'validated',
        'validation.technicienId': req.user.id,
        'validation.validatedAt': new Date()
      },
      { new: true }
    );

    if (!analyse) {
      return res.status(404).json({
        success: false,
        message: 'Analyse non trouvée'
      });
    }

    await Notification.create({
      userId: analyse.userId,
      type: 'analysis_validated',
      title: 'Analyse validée',
      message: `Votre analyse de ${analyse.culture} a été validée.`,
      data: { analyseId: analyse._id },
      isRead: false
    });

    res.json({
      success: true,
      data: analyse,
      message: 'Analyse validée'
    });

  } catch (error) {
    console.error("Erreur validateAnalyse:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * CORRECT ANALYSE
 */
exports.correctAnalyse = async (req, res) => {
  try {
    const { comment, recommandations, variete } = req.body;

    const analyse = await Analyse.findByIdAndUpdate(
      req.params.id,
      {
        statut: 'corrected',
        'correction.technicienId': req.user.id,
        'correction.correctedAt': new Date(),
        'correction.comment': comment,
        'correction.recommandationsCorrigees': recommandations,
        'correction.varieteCorrigee': variete
      },
      { new: true }
    );

    if (!analyse) {
      return res.status(404).json({
        success: false,
        message: 'Analyse non trouvée'
      });
    }

    await Notification.create({
      userId: analyse.userId,
      type: 'analysis_corrected',
      title: 'Analyse corrigée',
      message: `Une analyse a été corrigée pour ${analyse.culture}.`,
      data: { analyseId: analyse._id },
      isRead: false
    });

    res.json({
      success: true,
      data: analyse,
      message: 'Analyse corrigée'
    });

  } catch (error) {
    console.error("Erreur correctAnalyse:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * DASHBOARD STATS
 */
exports.getStats = async (req, res) => {
  try {
    const [pending, validated, corrected, rejected, total, techniciens] =
      await Promise.all([
        Analyse.countDocuments({ statut: 'pending' }),
        Analyse.countDocuments({ statut: 'validated' }),
        Analyse.countDocuments({ statut: 'corrected' }),
        Analyse.countDocuments({ statut: 'rejected' }),
        Analyse.countDocuments(),
        User.countDocuments({ role: 'technicien' })
      ]);

    res.json({
      success: true,
      data: {
        pending,
        validated,
        corrected,
        rejected,
        total,
        techniciens
      }
    });

  } catch (error) {
    console.error("Erreur getStats:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * ADD VARIETE
 */
exports.addVariete = async (req, res) => {
  try {
    const {
      nom,
      culture,
      description,
      typeCulture,
      zoneRecommandee,
      periodeSemis,
      cycleJours,
      rendementTonnesHa,
      prixSemence
    } = req.body;

    const variete = new Variete({
      nom,
      culture,
      description,
      caracteristiques: {
        typeCulture,
        zoneRecommandee,
        periodeSemis,
        cycleJours,
        rendementTonnesHa
      },
      prixSemence,
      createdBy: req.user.id
    });

    await variete.save();

    res.status(201).json({
      success: true,
      data: variete,
      message: 'Variété ajoutée avec succès'
    });

  } catch (error) {
    console.error("Erreur addVariete:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * GET ALL VARIETES
 */
exports.getAllVarietes = async (req, res) => {
  try {
    const varietes = await Variete.find({ isActive: true })
      .populate('createdBy', 'nom prenom')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: varietes
    });

  } catch (error) {
    console.error("Erreur getAllVarietes:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * DELETE VARIETE
 */
exports.deleteVariete = async (req, res) => {
  try {
    const variete = await Variete.findByIdAndDelete(req.params.id);

    if (!variete) {
      return res.status(404).json({
        success: false,
        message: 'Variété non trouvée'
      });
    }

    res.json({
      success: true,
      message: 'Variété supprimée'
    });

  } catch (error) {
    console.error("Erreur deleteVariete:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * GET NOTIFICATIONS (MANQUANTE)
 */
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({
      userId: req.user.id
    }).sort({ createdAt: -1 });

    const unreadCount = await Notification.countDocuments({
      userId: req.user.id,
      isRead: false
    });

    res.json({
      success: true,
      data: notifications,
      unreadCount
    });

  } catch (error) {
    console.error("Erreur getNotifications:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * MARK NOTIFICATION READ (MANQUANTE)
 */
exports.markNotificationRead = async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification non trouvée'
      });
    }

    res.json({
      success: true,
      data: notification,
      message: 'Notification marquée comme lue'
    });

  } catch (error) {
    console.error("Erreur markNotificationRead:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};