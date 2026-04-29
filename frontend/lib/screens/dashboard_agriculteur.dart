import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class DashboardAgriculteur extends StatefulWidget {
  final String nom;
  final String prenom;
  final String role;

  const DashboardAgriculteur({
    Key? key,
    required this.nom,
    required this.prenom,
    required this.role,
  }) : super(key: key);

  @override
  _DashboardAgriculteurState createState() => _DashboardAgriculteurState();
}

class _DashboardAgriculteurState extends State<DashboardAgriculteur> {
  
  void logout() async {
    await ApiService.logout();
    Fluttertoast.showToast(
      msg: "Déconnexion réussie",
      backgroundColor: Colors.green,
      toastLength: Toast.LENGTH_SHORT,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void analyseConditions() {
    // Ici tu peux naviguer vers l'écran d'analyse
    Fluttertoast.showToast(
      msg: "Fonction analyse en cours de développement",
      backgroundColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Agriculteur"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Se déconnecter",
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenue ${widget.nom} ${widget.prenom}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Rôle : ${widget.role}",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: analyseConditions,
                      icon: Icon(Icons.thermostat, color: Colors.white),
                      label: Text("Analyser conditions",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: "Conseils à venir",
                          backgroundColor: Colors.green,
                        );
                      },
                      icon: Icon(Icons.lightbulb, color: Colors.white),
                      label: Text("Voir conseils",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text("Se déconnecter",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 50),
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