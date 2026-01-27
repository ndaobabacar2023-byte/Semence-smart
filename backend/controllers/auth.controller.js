const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// ===== INSCRIPTION =====
exports.register = async (req, res) => {
  try {
    const { nom, prenom, email, telephone, motDePasse, role } = req.body;

    // Validation de base
    if (!nom || !prenom || !motDePasse) 
      return res.status(400).json({ message: "Nom, prénom et mot de passe requis" });

    // Validation conditionnelle
    if (role === 'agriculteur' && !telephone)
      return res.status(400).json({ message: "Le téléphone est requis pour les agriculteurs" });
    if ((role === 'admin' || role === 'technicien') && !email)
      return res.status(400).json({ message: "L'email est requis pour admin/technicien" });

    // Vérification utilisateur existant (améliorée)
    let query = {};
    if (email && email.trim() !== '') query.email = email;
    if (telephone && telephone.trim() !== '') query.telephone = telephone;
    
    if (Object.keys(query).length > 0) {
      const existingUser = await User.findOne(query);
      if (existingUser) {
        return res.status(400).json({ 
          message: "Email ou téléphone déjà utilisé" 
        });
      }
    }

    // Hachage du mot de passe
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(motDePasse, salt);

    // Création de l'utilisateur
    const user = new User({
      nom,
      prenom,
      email: email || undefined, // Garde undefined si vide
      telephone: telephone || undefined,
      motDePasse: hashedPassword,
      role: role || 'agriculteur'
    });

    await user.save();

    // Génération du token JWT
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Réponse
    res.status(201).json({
      token,
      user: {
        id: user._id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        telephone: user.telephone,
        role: user.role
      }
    });

  } catch (err) {
    console.error("Erreur inscription:", err);
    res.status(500).json({ message: "Erreur serveur lors de l'inscription" });
  }
};

// ===== CONNEXION =====
exports.login = async (req, res) => {
  try {
    const { email, motDePasse } = req.body;

    if (!email || !motDePasse) 
      return res.status(400).json({ message: "Email et mot de passe requis" });

    // Recherche de l'utilisateur
    const user = await User.findOne({ email });
    if (!user) 
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });

    // Vérification du mot de passe
    const isMatch = await bcrypt.compare(motDePasse, user.motDePasse);
    if (!isMatch) 
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });

    // Génération du token JWT
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    // Réponse
    res.status(200).json({
      token,
      user: {
        id: user._id,
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        telephone: user.telephone,
        role: user.role
      }
    });

  } catch (err) {
    console.error("Erreur connexion:", err);
    res.status(500).json({ message: "Erreur serveur lors de la connexion" });
  }
};