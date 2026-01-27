const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  nom: { 
    type: String, 
    required: [true, "Le nom est requis"],
    trim: true
  },
  prenom: { 
    type: String, 
    required: [true, "Le prénom est requis"],
    trim: true
  },
  email: { 
    type: String, 
    unique: true, 
    sparse: true,
    lowercase: true,
    trim: true
  },
  telephone: { 
    type: String, 
    sparse: true,
    trim: true
  },
  motDePasse: { 
    type: String, 
    required: [true, "Le mot de passe est requis"],
    minlength: [6, "Le mot de passe doit contenir au moins 6 caractères"]
  },
  role: { 
    type: String, 
    enum: ['agriculteur', 'technicien', 'admin'], 
    default: 'agriculteur' 
  },
  createdAt: { 
    type: Date, 
    default: Date.now 
  }
});

module.exports = mongoose.model('User', UserSchema);