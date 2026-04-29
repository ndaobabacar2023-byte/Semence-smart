import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../screens/type_culture_screen.dart';
import '../screens/meteo_screen.dart';
import '../screens/historique_screen.dart';  // ← AJOUTER CET IMPORT
import '../services/api_service.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ========== EN-TÊTE ==========
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[700]!,
                    Colors.green[500]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Semence Smart",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: ApiService.getRole(),
                    builder: (context, snapshot) {
                      String role = 'Agriculteur';
                      if (snapshot.hasData && snapshot.data != null) {
                        role = snapshot.data!;
                      }
                      return Text(
                        role,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.grey, thickness: 1),
            
            // ========== MENU PRINCIPAL ==========
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 1. ACCUEIL
                  _buildSidebarItem(
                    context,
                    icon: Icons.home,
                    title: "Accueil",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const TypeCultureScreen()),
                      );
                    },
                  ),
                  
                  // 2. MES CULTURES
                  _buildSidebarItem(
                    context,
                    icon: Icons.grass,
                    title: "Mes cultures",
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, "Mes cultures");
                    },
                  ),
                  
                  // 3. MÉTÉO EN TEMPS RÉEL
                  _buildSidebarItem(
                    context,
                    icon: Icons.wb_sunny,
                    title: "Météo en temps réel",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MeteoScreen()),
                      );
                    },
                  ),
                  
                  // 4. HISTORIQUE ← MAINTENANT ACTIF
                  _buildSidebarItem(
                    context,
                    icon: Icons.history,
                    title: "Historique",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
                      );
                    },
                  ),
                  
                  // 5. CONSEILS
                  _buildSidebarItem(
                    context,
                    icon: Icons.tips_and_updates,
                    title: "Conseils",
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, "Conseils");
                    },
                  ),
                  
                  // 6. MON PROFIL
                  _buildSidebarItem(
                    context,
                    icon: Icons.person,
                    title: "Mon profil",
                    onTap: () {
                      Navigator.pop(context);
                      _showProfileInfo(context);
                    },
                  ),
                  
                  const Divider(color: Colors.grey, thickness: 1),
                  
                  // 7. DÉCONNEXION
                  _buildSidebarItem(
                    context,
                    icon: Icons.logout,
                    title: "Déconnexion",
                    color: Colors.red[400]!,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
            
            // ========== PIED DE PAGE ==========
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "© 2026 Semence smart",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.green[700]),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
      hoverColor: Colors.green[50],
      splashColor: Colors.green[100],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text("Déconnexion"),
          ],
        ),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) =>  LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Déconnecter"),
          ),
        ],
      ),
    );
  }

  void _showProfileInfo(BuildContext context) async {
    final token = await ApiService.getToken();
    final role = await ApiService.getRole();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text("Mon profil"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge, size: 18, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        "Statut: ${token != null ? 'Connecté' : 'Non connecté'}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (role != null)
                    Row(
                      children: [
                        Icon(Icons.assignment_ind, size: 18, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text("Rôle: $role"),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text("Compte actif"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📱 $feature - Bientôt disponible"),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}