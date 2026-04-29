import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/location_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/type_culture_screen.dart';
import 'screens/choix_culture_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/resultat_screen.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semence Smart',  // ← Nom changé
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/welcome': (context) => WelcomeScreen(nom: '', prenom: '', role: ''),
        '/type-culture': (context) => TypeCultureScreen(),
        '/choix-culture': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return ChoixCultureScreen(type: args['type']!);
        },
        '/formulaire': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return FormulaireScreen(
            type: args['type']!,
            culture: args['culture']!,
          );
        },
        '/resultat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ResultatScreen(result: args['result']);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}