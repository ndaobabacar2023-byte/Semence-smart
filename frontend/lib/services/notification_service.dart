import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class NotificationService {

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {

    // Désactivation sur le Web
    if (kIsWeb) {
      print("Firebase Messaging désactivé sur Web");
      return;
    }

    // -------------------------------
    // Initialisation notifications locales
    // -------------------------------

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification locale cliquée : ${response.payload}");
      },
    );

    // -------------------------------
    // Permissions iOS pour affichage + son même app ouverte
    // -------------------------------

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // -------------------------------
    // Création du canal Android (son système par défaut)
    // -------------------------------

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "semence_channel",
      "Semence Smart",
      description: "Notifications Semence Smart",
      importance: Importance.max,
      playSound: true,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }

    // -------------------------------
    // Demande des permissions
    // -------------------------------

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      print("Permission notification accordée");

      // -------------------------------
      // Récupération du token FCM
      // -------------------------------

      String? token = await _messaging.getToken();

      print("TOKEN FCM : $token");

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString("userId");

        if (userId != null) {
          await ApiService.saveFcmToken(userId, token);
          print("Token envoyé au backend");
        }
      }

      // -------------------------------
      // Mise à jour automatique du token
      // -------------------------------

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString("userId");

        if (userId != null) {
          await ApiService.saveFcmToken(userId, newToken);
          print("Nouveau token enregistré");
        }
      });
    }

    // -------------------------------
    // Notification reçue — Application ouverte
    // -------------------------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      print("Nouvelle notification reçue");
      print("Titre : ${message.notification?.title}");
      print("Message : ${message.notification?.body}");

      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
          id: message.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              "semence_channel",
              "Semence Smart",
              channelDescription: "Notifications Semence Smart",
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    // -------------------------------
    // Notification cliquée — Application en arrière-plan
    // -------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification ouverte");
      print(message.data);
    });

    // -------------------------------
    // Application fermée
    // -------------------------------

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("Application ouverte depuis une notification");
      print(initialMessage.data);
    }

    print("Service Notification initialisé");
  }
}