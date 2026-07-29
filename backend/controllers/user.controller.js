const User = require("../models/User");

// =======================================
// Enregistrer le token FCM
// =======================================
exports.saveFcmToken = async (req, res) => {

    try {

        await User.findByIdAndUpdate(
            req.user.id,
            {
                fcmToken: req.body.fcmToken
            }
        );

        res.json({
            success: true,
            message: "Token FCM enregistré"
        });

    } catch (err) {

        console.error("Erreur saveFcmToken :", err);

        res.status(500).json({
            success: false,
            message: err.message
        });

    }

};