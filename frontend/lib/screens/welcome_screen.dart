import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import 'type_culture_screen.dart'; 

class WelcomeScreen extends StatelessWidget {
  final String nom;
  final String prenom;
  final String role;

  const WelcomeScreen({
    required this.nom,
    required this.prenom,
    required this.role,
    Key? key,
  }) : super(key: key);

  String getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'agriculteur':
        return 'Agriculteur';
      case 'technicien':
        return 'Technicien Agricole';
      case 'admin':
        return 'Administrateur';
      default:
        return role;
    }
  }

  Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'agriculteur':
        return Colors.green;
      case 'technicien':
        return Colors.blue;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord"),
        backgroundColor: getRoleColor(role),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Confirmation avant déconnexion
              bool confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Déconnexion"),
                  content: const Text("Voulez-vous vraiment vous déconnecter ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Déconnecter"),
                    ),
                  ],
                ),
              ) ?? false;

              if (confirm) {
                await ApiService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 100,
                color: getRoleColor(role),
              ),
              const SizedBox(height: 20),
              Text(
                "Bienvenue,",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                "$prenom $nom",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: getRoleColor(role),
                ),
              ),
              const SizedBox(height: 20),
              Chip(
                label: Text(
                  getRoleLabel(role),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: getRoleColor(role),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TypeCultureScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getRoleColor(role),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Commencer l'analyse",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  final token = await ApiService.getToken();
                  final userRole = await ApiService.getRole();
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Informations de session"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Rôle: ${getRoleLabel(userRole ?? role)}"),
                          const SizedBox(height: 10),
                          Text("Token: ${token != null ? '✓ Présent' : '✗ Absent'}"),
                          if (token != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              "${token.substring(0, 30)}...",
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text("Voir informations de session"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}