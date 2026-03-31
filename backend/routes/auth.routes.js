const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// Inscription
router.post('/register', authController.register);

// Connexion
router.post('/login', authController.login);

module.exports = router;