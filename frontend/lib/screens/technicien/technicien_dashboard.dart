import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/technicien_provider.dart';
import '../../services/api_service.dart';
import 'analyses_list_screen.dart';
import 'ajouter_variete_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _loadUserInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<TechnicienProvider>(context, listen: false);

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
        _userName =
            "$prenom $nom".trim().isEmpty ? "Technicien" : "$prenom $nom".trim();
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
      const _DashboardHomeScreen(),
      const AnalysesListScreen(),
      const AjouterVarieteScreen(),
      _ProfilScreen(
        userName: _userName,
        userEmail: _userEmail,
        userPhone: _userPhone,
      ),
    ];
  }

  // =========================
  // 🔄 REFRESH
  // =========================
  Future<void> _refreshData() async {
    final provider =
        Provider.of<TechnicienProvider>(context, listen: false);

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
      backgroundColor: Colors.grey[100],

      // =========================
      // APPBAR
      // =========================
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Espace Technicien',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        child: screens[_currentIndex],
      ),

      // =========================
      // NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey[600],

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Variétés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// 🏠 HOME DASHBOARD
// ======================================================
class _DashboardHomeScreen extends StatelessWidget {
  const _DashboardHomeScreen();

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
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Tableau de bord",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 20),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _StatCard(
                      title: "En attente",
                      value: pending.toString(),
                      icon: Icons.hourglass_bottom,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: "Validées",
                      value: validated.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: "Corrigées",
                      value: corrected.toString(),
                      icon: Icons.edit,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: "Total",
                      value: total.toString(),
                      icon: Icons.analytics,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Actions rapides",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.green),
                    title: const Text("Voir les analyses"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      DefaultTabController.of(context);
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.green),
                    title: const Text("Ajouter une variété"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.green[100],
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.green[700],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Technicien Agricole',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            child: ListTile(
              leading: Icon(Icons.email, color: Colors.green[700]),
              title: const Text("Email"),
              subtitle: Text(
                userEmail.isEmpty ? "Non renseigné" : userEmail,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.phone, color: Colors.green[700]),
              title: const Text("Téléphone"),
              subtitle: Text(
                userPhone.isEmpty ? "Non renseigné" : userPhone,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.green[700]),
              title: const Text("Zone"),
              subtitle: const Text("Sénégal"),
            ),
          ),
        ],
      ),
    );
  }
}