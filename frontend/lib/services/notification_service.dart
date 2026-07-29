import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class NotificationService {


final FirebaseMessaging _messaging =
FirebaseMessaging.instance;



Future<void> initialize() async {


if(kIsWeb){

print(
"Firebase Messaging désactivé Web"
);

return;

}



NotificationSettings settings =
await _messaging.requestPermission(

alert:true,
badge:true,
sound:true,

);



if(settings.authorizationStatus ==
AuthorizationStatus.authorized){



print(
"Permission notification accordée"
);



String? token =
await _messaging.getToken();



print(
"TOKEN FCM : $token"
);



if(token != null){


final prefs =
await SharedPreferences.getInstance();


String? userId =
prefs.getString("userId");



if(userId != null){


await ApiService.saveFcmToken(
userId,
token
);


print(
"Token envoyé au backend"
);


}


}




}



FirebaseMessaging.onMessage.listen(
(RemoteMessage message){


print(
"Notification reçue : ${message.notification?.title}"
);


});



FirebaseMessaging.onMessageOpenedApp.listen(
(RemoteMessage message){


print(
"Notification ouverte"
);


});


}


}