import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'type_culture_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _checkLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      print("🔍 Vérification token: $token");
      
      // Attendre 2 secondes pour l'animation
      await Future.delayed(const Duration(seconds: 2));
      
      if (token != null && token.isNotEmpty) {
        print("✅ Token trouvé, redirection vers l'accueil");
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => TypeCultureScreen())
        );
      } else {
        print("❌ Aucun token trouvé, redirection vers login");
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => LoginScreen())
        );
      }
    } catch (e) {
      print("❌ Erreur vérification login: $e");
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => LoginScreen())
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color.from(alpha: 1, red: 0.035, green: 0.745, blue: 0.427),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Titre
            const Text(
              "AGRIADVISOR",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(8, 201, 21, 1),
              ),
            ),
            const SizedBox(height: 10),
            
            // Sous-titre
            Text(
              "Conseiller Agricole Sénégal",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 40),
            
            // Indicateur de chargement
            CircularProgressIndicator(
              color: Colors.green[700],
            ),
            const SizedBox(height: 20),
            
            // Message
            Text(
              "Vérification de la session...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}