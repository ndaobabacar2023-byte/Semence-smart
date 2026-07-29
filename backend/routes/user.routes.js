const express = require("express");
const router = express.Router();

const User = require("../models/User");
const NotificationService = require("../services/notification.service");

const { auth } = require("../middleware/auth.middleware");
const userController = require("../controllers/user.controller");
console.log(userController);

// =======================================
// Liste des utilisateurs
// =======================================
router.get("/", auth, async (req, res) => {
    try {

        const users = await User.find()
            .select("-motDePasse")
            .sort({ createdAt: -1 });

        res.json(users);

    } catch (err) {

        console.error(err);

        res.status(500).json({
            success: false,
            message: "Erreur serveur"
        });

    }
});


// =======================================
// Enregistrer le token FCM
// =======================================
router.put(
    "/fcm-token",
    auth,
    userController.saveFcmToken
);


// =======================================
// Supprimer un utilisateur
// =======================================
router.delete("/:id", auth, async (req, res) => {

    try {

        const user = await User.findById(req.params.id);

        if (!user) {

            return res.status(404).json({
                success: false,
                message: "Utilisateur introuvable"
            });

        }

        await User.findByIdAndDelete(req.params.id);

        res.json({
            success: true,
            message: "Utilisateur supprimé"
        });

    } catch (err) {

        console.error(err);

        res.status(500).json({
            success: false,
            message: "Erreur serveur"
        });

    }

});


// =======================================
// Liste des techniciens en attente
// =======================================
router.get("/techniciens/attente", auth, async (req, res) => {

    try {

        if (req.user.role !== "admin") {

            return res.status(403).json({
                success: false,
                message: "Accès refusé"
            });

        }

        const techniciens = await User.find({

            role: "technicien",
            statut: "en_attente"

        }).select("-motDePasse");

        res.json({
            success: true,
            data: techniciens
        });

    } catch (err) {

        console.error(err);

        res.status(500).json({
            success: false,
            message: "Erreur serveur"
        });

    }

});


// =======================================
// Valider un technicien
// =======================================
router.put("/techniciens/:id/valider", auth, async (req, res) => {

    try {

        if (req.user.role !== "admin") {

            return res.status(403).json({
                success: false,
                message: "Accès refusé"
            });

        }

        const user = await User.findById(req.params.id);

        if (!user) {

            return res.status(404).json({
                success: false,
                message: "Utilisateur introuvable"
            });

        }

        user.statut = "valide";

        await user.save();

        await NotificationService.envoyer({

            userId: user._id,

            type: "account_validated",

            title: "Compte validé",

            message:
                "Félicitations ! Votre compte technicien a été validé par l'administrateur. Vous pouvez maintenant vous connecter.",

            data: {}

        });

        res.json({

            success: true,

            message: "Technicien validé avec succès"

        });

    } catch (err) {

        console.error(err);

        res.status(500).json({

            success: false,

            message: err.message

        });

    }

});


// =======================================
// Refuser un technicien
// =======================================
router.put("/techniciens/:id/refuser", auth, async (req, res) => {

    try {

        if (req.user.role !== "admin") {

            return res.status(403).json({
                success: false,
                message: "Accès refusé"
            });

        }

        const user = await User.findById(req.params.id);

        if (!user) {

            return res.status(404).json({
                success: false,
                message: "Utilisateur introuvable"
            });

        }

        user.statut = "refuse";

        await user.save();

        await NotificationService.envoyer({

            userId: user._id,

            type: "account_rejected",

            title: "Compte refusé",

            message:
                "Votre demande de compte technicien a été refusée par l'administrateur.",

            data: {}

        });

        res.json({

            success: true,

            message: "Technicien refusé"

        });

    } catch (err) {

        console.error(err);

        res.status(500).json({

            success: false,

            message: err.message

        });

    }

});

module.exports = router;