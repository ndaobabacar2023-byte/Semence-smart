// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import 'type_culture_screen.dart';
import 'technicien/technicien_dashboard.dart';
import '../services/api_service.dart';


class WelcomeScreen extends StatelessWidget {
  final String nom;
  final String prenom;
  final String role;

  const WelcomeScreen({
    Key? key,
    required this.nom,
    required this.prenom,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fullName = "$prenom $nom";
    final bool isTechnicien = role.toLowerCase() == 'technicien';
    final bool isAdmin = role.toLowerCase() == 'admin';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GlassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bienvenue !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTechnicien ? "Technicien Agricole" : "Agriculteur",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Bouton selon le rôle
                  if (isTechnicien)
                    _buildButton(
                      context: context,
                      text: "📊 Tableau de bord Technicien",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TechnicienDashboard(),
                          ),
                        );
                      },
                    )
                  else
                    _buildButton(
                      context: context,
                      text: "🌱 Commencer mon analyse",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TypeCultureScreen(),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 15),
                  
                  _buildButton(
                    context: context,
                    text: "🔓 Se déconnecter",
                    onPressed: () async {
                      await ApiService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

// Import nécessaire

