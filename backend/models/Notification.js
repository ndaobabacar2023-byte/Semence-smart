const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  type: {
    type: String,
    enum: ['new_analysis', 'analysis_validated', 'analysis_corrected', 'new_variety'],
    required: true
  },

  title: String,
  message: String,

  data: {
    analyseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Analyse'
    },

    technicienId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },

    commentaire: String,
    recommandations: String
  },

  isRead: {
    type: Boolean,
    default: false
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Notification', NotificationSchema);