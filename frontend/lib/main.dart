import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/location_provider.dart';
import 'providers/technicien_provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/type_culture_screen.dart';
import 'screens/choix_culture_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/resultat_screen.dart';
import 'screens/technicien/technicien_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Semence Smart',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Démarrage direct sur l'accueil
      initialRoute: '/type-culture',

      routes: {
        '/type-culture': (context) => TypeCultureScreen(),

        '/welcome': (context) =>
            WelcomeScreen(nom: '', prenom: '', role: ''),

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
