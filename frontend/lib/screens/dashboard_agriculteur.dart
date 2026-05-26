import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import 'notifications_screen.dart';

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
  
  // ===== NOTIFICATIONS =====
  int unreadCount = 0;
  List notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _startAutoRefresh();
  }

  // ===== CHARGER NOTIFICATIONS =====
  void loadNotifications() async {
    final res = await ApiService.getNotifications();

    if (res['success'] == true) {
      setState(() {
        notifications = res['data'];
        unreadCount = notifications.where((n) => n['isRead'] == false).length;
      });
    }
  }

  // ===== AUTO REFRESH =====
  void _startAutoRefresh() async {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 10));
      loadNotifications();
      return mounted;
    });
  }

  // ===== LOGOUT =====
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

  // ===== ANALYSE =====
  void analyseConditions() {
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

          // ===== NOTIFICATION ICON =====
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(),
                    ),
                  );
                  loadNotifications(); // refresh après retour
                },
              ),

              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
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

                    // ===== ANALYSE =====
                    ElevatedButton.icon(
                      onPressed: analyseConditions,
                      icon: Icon(Icons.thermostat, color: Colors.white),
                      label: Text(
                        "Analyser conditions",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 20),

                    // ===== NOTIFICATIONS =====
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(),
                          ),
                        );
                        loadNotifications();
                      },
                      icon: Icon(Icons.notifications, color: Colors.white),
                      label: Text(
                        "Voir notifications",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 20),

                    // ===== LOGOUT =====
                    ElevatedButton.icon(
                      onPressed: logout,
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "Se déconnecter",
                        style: TextStyle(color: Colors.white),
                      ),
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