import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'type_culture_screen.dart';
import 'admin_home_screen.dart';
import 'technicien_home_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String nom;
  final String prenom;
  final String role;

  WelcomeScreen({
    required this.nom,
    required this.prenom,
    required this.role,
  });

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  void proceed() {
    // Navigation automatique selon le rôle
    if (widget.role == 'agriculteur') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TypeCultureScreen()),
      );
    } else if (widget.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHomeScreen()),
      );
    } else if (widget.role == 'technicien') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TechnicienHomeScreen()),
      );
    } else {
      Fluttertoast.showToast(msg: "Rôle inconnu");
    }
  }

  void logout() async {
    await ApiService.logout();
    Fluttertoast.showToast(msg: "Déconnexion réussie");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Déconnexion",
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Bonjour ${widget.prenom} ${widget.nom} !",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Bienvenue sur AgriAdvisor 🌱\n\n"
                "Ici vous pourrez choisir votre type de culture, saisir vos données locales et obtenir des recommandations personnalisées.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: proceed,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    "Commencer",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
