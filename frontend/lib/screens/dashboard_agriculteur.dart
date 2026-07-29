import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/api_service.dart';
import 'notifications_screen.dart';
import 'type_culture_screen.dart';
import 'login_screen.dart';
import 'historique_screen.dart';

class DashboardAgriculteur extends StatefulWidget {
  final String nom;
  final String prenom;
  final String role;

  const DashboardAgriculteur({
    super.key,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  @override
  State<DashboardAgriculteur> createState() => _DashboardAgriculteurState();
}

class _DashboardAgriculteurState extends State<DashboardAgriculteur> {
  int unreadCount = 0;
  List notifications = [];

  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;

  static const Color primaryGreen = Color(0xFF43A047);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color bgColor = Color(0xFFF4F7F5);

  @override
  void initState() {
    super.initState();
    loadNotifications();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse && _isFabExtended) {
        setState(() => _isFabExtended = false);
      } else if (direction == ScrollDirection.forward && !_isFabExtended) {
        setState(() => _isFabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    final res = await ApiService.getNotifications();

    if (res["success"] == true) {
      setState(() {
        notifications = res["data"];
        unreadCount = notifications.where((n) => n["isRead"] == false).length;
      });
    }
  }

  Future<void> logout() async {
    await ApiService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  // ── Stat card modernisée ─────────────────────────────────────────
  Widget statCard(String titre, String valeur, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action card modernisée ───────────────────────────────────────
  Widget actionButton(String titre, String sousTitre, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                        titre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sousTitre,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        child: Container(
          color: bgColor,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  "${widget.prenom} ${widget.nom}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(widget.role),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: primaryGreen, size: 40),
                ),
              ),
              _drawerTile(Icons.home_rounded, "Accueil", () {
                Navigator.pop(context);
              }),
              _drawerTile(Icons.agriculture_rounded, "Nouvelle analyse", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TypeCultureScreen()),
                );
              }),
              _drawerTile(
                Icons.notifications_rounded,
                "Notifications",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  );
                },
                badge: unreadCount > 0 ? unreadCount : null,
              ),
              const Spacer(),
              const Divider(height: 1),
              _drawerTile(
                Icons.logout_rounded,
                "Déconnexion",
                logout,
                color: Colors.red,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          "Semence Smart",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      "$unreadCount",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── FAB scroll-aware ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TypeCultureScreen()),
          );
        },
        backgroundColor: primaryGreen,
        elevation: 4,
        isExtended: _isFabExtended,
        extendedPadding: _isFabExtended
            ? const EdgeInsets.symmetric(horizontal: 20)
            : const EdgeInsets.all(16),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _isFabExtended
              ? const Text(
                  "Nouvelle analyse",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                )
              : const SizedBox.shrink(),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          controller: _scrollController, // ← relie le scroll au FAB
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            Container(
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
                    "Bonjour ${widget.prenom} 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bienvenue dans Semence Smart",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                statCard("Notifications", "$unreadCount", Icons.notifications_rounded, Colors.orange),
                const SizedBox(width: 14),
                statCard("Analyses", "0", Icons.analytics_rounded, Colors.blue),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              "Actions rapides",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 14),
            actionButton(
              "Nouvelle analyse",
              "Analyser les conditions de votre culture",
              Icons.agriculture_rounded,
              primaryGreen,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TypeCultureScreen()),
                );
              },
            ),
            actionButton(
              "Mes notifications",
              "Suivez les mises à jour et alertes",
              Icons.notifications_rounded,
              Colors.orange[700]!,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            actionButton(
              "Historique des analyses",
              "Consultez vos analyses précédentes",
              Icons.history_rounded,
              Colors.blueGrey,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap,
      {Color? color, int? badge}) {
    return ListTile(
      leading: Icon(icon, color: color ?? primaryGreen),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: badge != null
          ? CircleAvatar(
              radius: 11,
              backgroundColor: Colors.red,
              child: Text(
                "$badge",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}