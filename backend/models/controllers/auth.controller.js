const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    const { nom, prenom, email, telephone, motDePasse, role } = req.body;

    if (!nom || !prenom || !motDePasse) 
      return res.status(400).json({ message: "Nom, prénom et mot de passe requis" });

    if (role === 'agriculteur' && !telephone)
      return res.status(400).json({ message: "Le téléphone est requis pour les agriculteurs" });
    if ((role === 'admin' || role === 'technicien') && !email)
      return res.status(400).json({ message: "L'email est requis pour admin/technicien" });

    const existingUser = await User.findOne({ $or: [{ email }, { telephone }] });
    if (existingUser) 
      return res.status(400).json({ message: "Utilisateur déjà enregistré" });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(motDePasse, salt);

    const user = new User({ nom, prenom, email, telephone, motDePasse: hashedPassword, role: role || 'agriculteur' });
    await user.save();

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      token,
      user: { id: user._id, nom: user.nom, prenom: user.prenom, email: user.email, telephone: user.telephone, role: user.role }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, telephone, motDePasse } = req.body;
    if (!motDePasse || (!email && !telephone))
      return res.status(400).json({ message: "Email ou téléphone + mot de passe requis" });

    const user = await User.findOne({ $or: [{ email }, { telephone }] });
    if (!user) return res.status(401).json({ message: "Utilisateur non trouvé" });

    const isMatch = await bcrypt.compare(motDePasse, user.motDePasse);
    if (!isMatch) return res.status(401).json({ message: "Mot de passe incorrect" });

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: { id: user._id, nom: user.nom, prenom: user.prenom, email: user.email, telephone: user.telephone, role: user.role }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
  }
};
