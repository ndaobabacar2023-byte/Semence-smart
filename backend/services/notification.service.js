const admin = require("../config/firebase");
const Notification = require("../models/Notification");
const User = require("../models/User");


class NotificationService {


static async envoyer({
    userId,
    type,
    title,
    message,
    data = {}
}) {


    // 1 - Sauvegarde MongoDB

    const notification = await Notification.create({

        userId,

        type,

        title,

        message,

        data

    });



    // 2 - Recherche utilisateur

    const user = await User.findById(userId);



    if(!user || !user.tokenFCM){

        console.log(
          "Utilisateur sans token FCM"
        );

        return notification;
    }



    // 3 - Notification Firebase

    await admin.messaging().send({

        token:user.tokenFCM,


        notification:{
            title,
            body:message
        },


        data:{
            notificationId:
            notification._id.toString(),

            type:type
        }

    });



    console.log(
      "✅ Notification envoyée"
    );


    return notification;

}


}


module.exports = NotificationService;