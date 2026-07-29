import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Providers
import 'providers/location_provider.dart';
import 'providers/technicien_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/type_culture_screen.dart';
import 'screens/choix_culture_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/resultat_screen.dart';
import 'screens/technicien/technicien_dashboard.dart';

// Services
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("Notification reçue en arrière-plan : ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await NotificationService().initialize();
  }

  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => TechnicienProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return MaterialApp(
      title: 'Semence Smart',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),

        '/welcome': (context) => WelcomeScreen(
              nom: '',
              prenom: '',
              role: '',
            ),

        '/type-culture': (context) => TypeCultureScreen(),

        '/choix-culture': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;

          return ChoixCultureScreen(
            type: args['type']!,
          );
        },

        '/formulaire': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;

          return FormulaireScreen(
            type: args['type']!,
            culture: args['culture']!,
          );
        },

        '/resultat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

          return ResultatScreen(
            result: args['result'],
          );
        },

        '/technicien': (context) => const TechnicienDashboard(),
      },
    );
  }
}