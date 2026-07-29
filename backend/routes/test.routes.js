const express = require("express");

const router = express.Router();

const NotificationService =
require("../services/notification.service");


router.get("/notification-test", async(req,res)=>{

try{


await NotificationService.envoyer({

userId:"697270211d953b408b2f4d81",

type:"new_analysis",

title:"Nouvelle analyse",

message:"Une nouvelle analyse a été envoyée.",


data:{}

});



res.json({

success:true,

message:"Notification créée"

});


}catch(e){

console.error(e);


res.status(500).json({

success:false,

error:e.message

});


}


});


module.exports = router;