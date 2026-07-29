import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List notifications = [];
  bool loading = true;

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();

    chargerNotifications();

    // Rafraîchir automatiquement lorsqu'une notification arrive
    FirebaseMessaging.onMessage.listen((event) {
      print("Nouvelle notification reçue");
      chargerNotifications();
    });
  }

  Future<void> chargerNotifications() async {
    final result = await ApiService.getNotifications();

    if (result["success"] == true) {
      setState(() {
        notifications = result["data"] ?? [];
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: chargerNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _buildNotificationCard(notif);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_rounded,
                size: 56, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune notification",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Vous serez informé ici des mises à jour",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notif) {
    final bool isUnread = notif["isRead"] == false;
    final data = notif["data"];

    // ── Lecture des clés à plat (structure réelle du backend) ──
    final String? technicienNom = data?["technicienNom"];
    final String? technicienTelephone = data?["technicienTelephone"];
    final commentaire = data?["commentaire"];
    final recommandations = data?["recommandations"];
    final variete = data?["variete"];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isUnread
            ? Border.all(color: primaryGreen.withOpacity(0.25), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await ApiService.marquerNotificationLue(notif["_id"]);
            await chargerNotifications();

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationDetailScreen(notification: notif),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? Colors.red.withOpacity(0.12)
                        : primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isUnread
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_rounded,
                    color: isUnread ? Colors.red : primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif["title"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif["message"] ?? "",
                        style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                      ),

                      if (technicienNom != null && technicienNom.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildInfoLine(
                          Icons.engineering_rounded,
                          "Technicien : $technicienNom",
                        ),
                      ],

                      if (technicienTelephone != null &&
                          technicienTelephone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildInfoLine(
                          Icons.phone_rounded,
                          technicienTelephone,
                          color: Colors.green[700],
                        ),
                      ],

                      if (variete != null && variete.toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildBadgeLine(
                          "🌱 Variété : $variete",
                          Colors.green,
                        ),
                      ],

                      if (commentaire != null &&
                          commentaire.toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildBadgeLine(
                          "💬 $commentaire",
                          Colors.blueGrey,
                        ),
                      ],

                      if (recommandations != null) ...[
                        const SizedBox(height: 6),
                        _buildBadgeLine(
                          "✅ ${recommandations is List ? recommandations.join(', ') : recommandations}",
                          Colors.orange,
                        ),
                      ],

                      if (notif["createdAt"] != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          notif["createdAt"],
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeLine(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, color: color.withOpacity(0.9)),
      ),
    );
  }
}