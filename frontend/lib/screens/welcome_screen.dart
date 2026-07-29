// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'technicien/technicien_dashboard.dart';
import 'dashboard_agriculteur.dart';
import 'admin_home_screen.dart';
import '../widgets/semence_logo.dart';

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

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final String roleNormalized = role.trim().toLowerCase();
    final bool isTechnicien = roleNormalized == 'technicien';
    final bool isAdmin = roleNormalized == 'admin';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Photo de fond ──────────────────────────────
          Image.asset(
            'assets/images/mil.jpg',
            fit: BoxFit.cover,
          ),

          // ── Voile vert/noir pour la lisibilité du texte ─
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryGreen.withOpacity(0.6),
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),

          // ── Contenu ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo circulaire
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const SemenceLogo(size: 84),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Bienvenue sur",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "SEMENCE SMART",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "Application intelligente de recommandation\nde variétés de semences",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Bouton unique "Commencer" — navigue selon le rôle
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isAdmin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => AdminHomeScreen()),
                          );
                        } else if (isTechnicien) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TechnicienDashboard(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DashboardAgriculteur(
                                nom: nom,
                                prenom: prenom,
                                role: role,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Commencer",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}