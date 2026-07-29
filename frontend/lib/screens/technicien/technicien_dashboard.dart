// lib/screens/technicien/technicien_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/technicien_provider.dart';
import '../../services/api_service.dart';
import 'analyses_list_screen.dart';
import 'ajouter_variete_screen.dart';
import 'selection_agriculteur_screen.dart';
class TechnicienDashboard extends StatefulWidget {
  const TechnicienDashboard({Key? key}) : super(key: key);

  @override
  State<TechnicienDashboard> createState() => _TechnicienDashboardState();
}

class _TechnicienDashboardState extends State<TechnicienDashboard> {
  int _currentIndex = 0;

  String _userName = "Technicien";
  String _userEmail = "";
  String _userPhone = "";

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();

    _loadUserInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<TechnicienProvider>(context, listen: false);
      await provider.refreshAll();
    });
  }

  // =========================
  // 👤 CHARGER INFOS UTILISATEUR
  // =========================
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final prenom = prefs.getString('prenom') ?? '';
      final nom = prefs.getString('nom') ?? '';

      if (!mounted) return;

      setState(() {
        _userName = "$prenom $nom".trim().isEmpty ? "Technicien" : "$prenom $nom".trim();
        _userEmail = prefs.getString('email') ?? "";
        _userPhone = prefs.getString('telephone') ?? "";
      });
    } catch (e) {
      debugPrint("Erreur _loadUserInfo: $e");
    }
  }

  // =========================
  // 📱 SCREENS
  // =========================
  List<Widget> _screens() {
    return [
      _DashboardHomeScreen(userName: _userName),
      const AnalysesListScreen(),
      const AjouterVarieteScreen(),
      _ProfilScreen(
        userName: _userName,
        userEmail: _userEmail,
        userPhone: _userPhone,
      ),
    ];
  }

  static const List<String> _titles = [
    'Tableau de bord',
    'Analyses',
    'Nouvelle variété',
    'Mon profil',
  ];

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> _refreshData() async {
    final provider = Provider.of<TechnicienProvider>(context, listen: false);

    await provider.refreshAll();
    await _loadUserInfo();
  }

  // =========================
  // 🚪 LOGOUT
  // =========================
  Future<void> _logout() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(child: screens[_currentIndex]),

      // =========================
      // FAB — Nouvelle analyse pour un agriculteur (rôle technicien)
      // =========================
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: primaryGreen,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectionAgriculteurScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Nouvelle analyse", style: TextStyle(color: Colors.white)),
            )
          : null,

      // =========================
      // NAVIGATION
      // =========================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: primaryGreen,
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
          unselectedLabelStyle: const TextStyle(fontSize: 11.5),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analyses'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Variétés'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// 🏠 HOME DASHBOARD
// ======================================================
// 🏠 HOME DASHBOARD
// ======================================================
class _DashboardHomeScreen extends StatelessWidget {
  final String userName;

  const _DashboardHomeScreen({required this.userName});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF66BB6A);

  @override
  Widget build(BuildContext context) {
    return Consumer<TechnicienProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats ?? {};

        final pending = stats['pending'] ?? 0;
        final validated = stats['validated'] ?? 0;
        final corrected = stats['corrected'] ?? 0;
        final total = stats['total'] ?? 0;

        return RefreshIndicator(
          onRefresh: provider.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Carte de bienvenue (façon agriculteur) ──────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), accentGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bonjour $userName ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Voici un aperçu de vos compte",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.insights_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "$total",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              "analyses au total",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Vue d'ensemble",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850],
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                  children: [
                    _StatCard(
                      title: "En attente",
                      value: pending.toString(),
                      icon: Icons.hourglass_bottom_rounded,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: "Validées",
                      value: validated.toString(),
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: "Corrigées",
                      value: corrected.toString(),
                      icon: Icons.edit_rounded,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: "Total",
                      value: total.toString(),
                      icon: Icons.analytics_rounded,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  "Actions rapides",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850],
                  ),
                ),


              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.85), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ======================================================
// 📊 STAT CARD
// ======================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// 👤 PROFIL
// ======================================================
class _ProfilScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userPhone;

  const _ProfilScreen({
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), primaryGreen],
              ),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 58, color: primaryGreen),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            userName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Technicien Agricole',
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 28),

          _profileTile(Icons.email_rounded, "Email", userEmail.isEmpty ? "Non renseigné" : userEmail, Colors.blue),
          _profileTile(Icons.phone_rounded, "Téléphone", userPhone.isEmpty ? "Non renseigné" : userPhone, Colors.green),
          _profileTile(Icons.location_on_rounded, "Zone", "Sénégal", Colors.orange),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}