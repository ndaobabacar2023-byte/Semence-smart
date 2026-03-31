import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/type_culture_screen.dart';
import 'screens/choix_culture_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/resultat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriAdvisor Sénégal',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
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