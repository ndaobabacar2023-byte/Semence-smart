const Notification = require("../models/Notification");
const User = require("../models/User");

// =======================================
// Enregistrer le token Firebase
// =======================================
exports.saveFcmToken = async (req,res)=>{

    try{

        await User.findByIdAndUpdate(

            req.user.id,

            {

                fcmToken:req.body.fcmToken

            }

        );

        res.json({

            success:true,
            message:"Token enregistré"

        });

    }

    catch(err){

        res.status(500).json({

            success:false,
            message:err.message

        });

    }

}

// =======================================
// Retourner toutes les notifications
// =======================================
exports.getNotifications = async (req, res) => {

    try {

        const notifications = await Notification.find({
            userId: req.user.id
        })
        .sort({
            createdAt: -1
        });

        res.json({
            success: true,
            data: notifications
        });

    } catch (e) {

        console.error("Erreur getNotifications :", e);

        res.status(500).json({
            success: false,
            message: e.message
        });

    }

};


// =======================================
// Marquer une notification comme lue
// =======================================
exports.markAsRead = async (req, res) => {

    try {

        const notification =
        await Notification.findByIdAndUpdate(

            req.params.id,

            {
                isRead: true
            },

            {
                new: true
            }

        );

        if (!notification) {

            return res.status(404).json({

                success: false,
                message: "Notification introuvable"

            });

        }

        res.json({

            success: true,
            data: notification

        });

    } catch (e) {

        console.error("Erreur markAsRead :", e);

        res.status(500).json({

            success: false,
            message: e.message

        });

    }

};


// =======================================
// Nombre de notifications non lues
// =======================================
exports.getUnreadCount = async (req, res) => {

    try {

        const count =
        await Notification.countDocuments({

            userId: req.user.id,
            isRead: false

        });

        res.json({

            success: true,
            count

        });

    } catch (e) {

        console.error("Erreur getUnreadCount :", e);

        res.status(500).json({

            success: false,
            message: e.message

        });

    }

};