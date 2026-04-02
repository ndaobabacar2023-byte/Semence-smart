import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // 🔥 Icône
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.white,
                    ),

                    SizedBox(height: 20),

                    // 🔥 Titre
                    Text(
                      "Tableau de bord Admin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    // 🔥 Sous-titre
                    Text(
                      "Bienvenue Admin 👋",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 30),

                    // 🔥 Bouton 1
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: gérer utilisateurs
                      },
                      icon: Icon(Icons.people),
                      label: Text("Gérer les utilisateurs"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 15),

                    // 🔥 Bouton 2
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: voir statistiques
                      },
                      icon: Icon(Icons.bar_chart),
                      label: Text("Voir les statistiques"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 15),

                    // 🔥 Bouton 3
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: paramètres
                      },
                      icon: Icon(Icons.settings),
                      label: Text("Paramètres"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 25),

                    // 🔥 Déconnexion
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Déconnexion",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
