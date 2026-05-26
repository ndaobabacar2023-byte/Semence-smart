const express = require('express');
const router = express.Router();

const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth.middleware');

router.get('/', auth, async (req, res) => {
  try {
    const notifications = await Notification.find({
     userId: req.user?.id || req.user?._id
    }).sort({ createdAt: -1 });

    res.json({
      success: true,
      data: notifications
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;